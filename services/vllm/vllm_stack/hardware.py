from __future__ import annotations

import json
import math
import re
import subprocess
from dataclasses import asdict, dataclass
from typing import Iterable


@dataclass(slots=True)
class GPUInfo:
    index: int
    uuid: str
    name: str
    memory_total_mib: int

    @property
    def memory_total_gib(self) -> float:
        return self.memory_total_mib / 1024.0

    def to_dict(self) -> dict:
        return asdict(self)


def run_command(cmd: list[str]) -> str:
    proc = subprocess.run(cmd, check=True, capture_output=True, text=True)
    return proc.stdout.strip()


def detect_gpus() -> list[GPUInfo]:
    cmd = [
        "nvidia-smi",
        "--query-gpu=index,uuid,name,memory.total",
        "--format=csv,noheader,nounits",
    ]
    try:
        output = run_command(cmd)
    except (FileNotFoundError, subprocess.CalledProcessError):
        return []

    gpus: list[GPUInfo] = []
    for line in output.splitlines():
        parts = [p.strip() for p in line.split(",")]
        if len(parts) != 4:
            continue
        index, uuid, name, memory = parts
        try:
            gpus.append(
                GPUInfo(
                    index=int(index),
                    uuid=uuid,
                    name=name,
                    memory_total_mib=int(float(memory)),
                )
            )
        except ValueError:
            continue
    return gpus


def median_gpu_memory_gib(gpus: Iterable[GPUInfo]) -> float:
    values = sorted(g.memory_total_gib for g in gpus)
    if not values:
        return 0.0
    mid = len(values) // 2
    if len(values) % 2:
        return values[mid]
    return (values[mid - 1] + values[mid]) / 2.0


def infer_parameter_count_b(model_name: str) -> float | None:
    """Best-effort extraction of a parameter count from names like 7B, 32B, 70B, 405B.

    For MoE-style names such as ``35B-A3B`` or ``397B-A17B``, use the largest
    parameter count token because the total footprint is what matters for sizing.
    """
    pattern = re.compile(r"(?<!\d)(\d+(?:\.\d+)?)\s*[Bb](?![a-zA-Z])")
    matches = pattern.findall(model_name)
    if not matches:
        return None
    try:
        values = [float(m) for m in matches]
    except ValueError:
        return None
    return max(values)


def estimate_weight_footprint_gb(parameters_b: float, bytes_per_param: float = 2.0) -> float:
    return parameters_b * bytes_per_param


def estimate_min_tp(
    parameters_b: float | None,
    per_gpu_gib: float,
    bytes_per_param: float = 2.0,
    kv_headroom_fraction: float = 0.78,
    max_gpus: int | None = None,
) -> int:
    if not parameters_b or per_gpu_gib <= 0:
        return 1
    total_weight_gb = estimate_weight_footprint_gb(parameters_b, bytes_per_param)
    usable_per_gpu = per_gpu_gib * max(0.1, kv_headroom_fraction)
    required = max(1, math.ceil(total_weight_gb / usable_per_gpu))
    if max_gpus is not None:
        required = min(required, max_gpus)
    return max(1, required)


def homogeneous_signature(gpu: GPUInfo) -> tuple[str, int]:
    return (gpu.name, gpu.memory_total_mib)


def pick_homogeneous_pool(gpus: list[GPUInfo], count: int) -> list[GPUInfo]:
    if count <= 0:
        return []
    by_sig: dict[tuple[str, int], list[GPUInfo]] = {}
    for gpu in gpus:
        by_sig.setdefault(homogeneous_signature(gpu), []).append(gpu)

    candidates = sorted(
        by_sig.values(),
        key=lambda items: (len(items), items[0].memory_total_mib),
        reverse=True,
    )
    for group in candidates:
        if len(group) >= count:
            return sorted(group, key=lambda g: g.index)[:count]
    return sorted(gpus, key=lambda g: (g.memory_total_mib, -g.index), reverse=True)[:count]


def inventory_to_json(gpus: list[GPUInfo]) -> str:
    return json.dumps([g.to_dict() for g in gpus], indent=2)
