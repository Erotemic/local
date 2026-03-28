from __future__ import annotations

from dataclasses import dataclass
from typing import Any

from .hardware import (
    GPUInfo,
    estimate_min_tp,
    infer_parameter_count_b,
    median_gpu_memory_gib,
    pick_homogeneous_pool,
)


@dataclass(slots=True)
class DeploymentPlan:
    name: str
    service_name: str
    model: str
    served_model_name: str
    host_port: int
    tp: int
    dp: int
    gpu_indices: list[int]
    total_gpu_count: int
    container_port: int
    image: str
    api_key_env: str
    args: list[str]
    environment: dict[str, str]
    labels: dict[str, str]

    def to_dict(self) -> dict[str, Any]:
        return {
            "name": self.name,
            "service_name": self.service_name,
            "model": self.model,
            "served_model_name": self.served_model_name,
            "host_port": self.host_port,
            "tp": self.tp,
            "dp": self.dp,
            "gpu_indices": self.gpu_indices,
            "total_gpu_count": self.total_gpu_count,
            "container_port": self.container_port,
            "image": self.image,
            "api_key_env": self.api_key_env,
            "args": self.args,
            "environment": self.environment,
            "labels": self.labels,
        }


class PlanningError(RuntimeError):
    pass


def _sanitize_service_name(name: str) -> str:
    safe = []
    for ch in name.lower():
        safe.append(ch if ch.isalnum() else "-")
    value = "".join(safe).strip("-")
    return f"llm-{value or 'service'}"


def _as_gpu_info_list(config: dict[str, Any]) -> list[GPUInfo]:
    result = []
    for item in config.get("hardware", {}).get("inventory", []):
        result.append(
            GPUInfo(
                index=int(item["index"]),
                uuid=str(item.get("uuid", "")),
                name=str(item.get("name", "GPU")),
                memory_total_mib=int(item.get("memory_total_mib", 0)),
            )
        )
    return result


def _first_enabled_deployments(config: dict[str, Any]) -> list[dict[str, Any]]:
    return [d for d in config.get("deployments", []) if d.get("enabled", True)]


def _resolve_parameters_b(deployment: dict[str, Any]) -> float | None:
    estimate = deployment.get("estimate", {})
    explicit = estimate.get("parameters_b", "auto")
    if explicit not in (None, "auto"):
        return float(explicit)
    return infer_parameter_count_b(deployment.get("model", ""))


def _resolve_gpu_count(
    config: dict[str, Any],
    deployment: dict[str, Any],
    remaining_gpus: list[GPUInfo],
    enabled_count: int,
    min_tp: int,
) -> int:
    topo = deployment.get("topology", {})
    gpu_count = topo.get("gpu_count", "auto")
    explicit_dp = topo.get("dp", "auto")
    placement = deployment.get("placement", {})
    explicit_indices = placement.get("gpu_indices", "auto")

    if isinstance(explicit_indices, list):
        return len(explicit_indices)
    if gpu_count not in (None, "auto"):
        return int(gpu_count)
    if explicit_dp not in (None, "auto"):
        return max(min_tp, int(explicit_dp) * min_tp)

    if enabled_count <= 1:
        return max(min_tp, (len(remaining_gpus) // min_tp) * min_tp or min_tp)
    return min_tp


def _resolve_gpu_pool(
    deployment: dict[str, Any],
    remaining_gpus: list[GPUInfo],
    gpu_count: int,
) -> list[GPUInfo]:
    explicit = deployment.get("placement", {}).get("gpu_indices", "auto")
    if isinstance(explicit, list):
        explicit_set = set(int(x) for x in explicit)
        pool = [g for g in remaining_gpus if g.index in explicit_set]
        if len(pool) != len(explicit_set):
            raise PlanningError(
                f"Deployment {deployment.get('name')} requested GPUs {sorted(explicit_set)} but some were unavailable."
            )
        return sorted(pool, key=lambda g: g.index)
    return pick_homogeneous_pool(remaining_gpus, gpu_count)


def build_plan(config: dict[str, Any]) -> dict[str, Any]:
    gpus = _as_gpu_info_list(config)
    reserved = set(int(x) for x in config.get("hardware", {}).get("reserved_gpu_indices", []))
    available = [g for g in gpus if g.index not in reserved]
    available = sorted(available, key=lambda g: g.index)
    serving_defaults = config.get("serving_defaults", {})
    container_port = int(serving_defaults.get("container_port", 8000))
    image = str(serving_defaults.get("image", "vllm/vllm-openai:latest"))
    api_key_env = str(serving_defaults.get("api_key_env", "VLLM_API_KEY"))
    enabled = _first_enabled_deployments(config)

    deployments: list[DeploymentPlan] = []
    free_pool = list(available)

    for dep in enabled:
        if not free_pool:
            raise PlanningError(f"No GPUs remain for deployment {dep.get('name')!r}.")

        estimate = dep.get("estimate", {})
        parameters_b = _resolve_parameters_b(dep)
        bytes_per_param = float(estimate.get("bytes_per_param", 2.0))
        kv_headroom_fraction = float(estimate.get("kv_headroom_fraction", 0.78))

        topo = dep.get("topology", {})
        tp_value = topo.get("tp", "auto")
        if tp_value in (None, "auto"):
            tp = estimate_min_tp(
                parameters_b,
                median_gpu_memory_gib(free_pool),
                bytes_per_param=bytes_per_param,
                kv_headroom_fraction=kv_headroom_fraction,
                max_gpus=len(free_pool),
            )
        else:
            tp = max(1, int(tp_value))

        gpu_count = _resolve_gpu_count(config, dep, free_pool, len(enabled), tp)
        if gpu_count < tp:
            gpu_count = tp
        if gpu_count > len(free_pool):
            raise PlanningError(
                f"Deployment {dep.get('name')} wants {gpu_count} GPUs, but only {len(free_pool)} remain."
            )

        pool = _resolve_gpu_pool(dep, free_pool, gpu_count)
        per_gpu_memory = median_gpu_memory_gib(pool)
        if tp_value in (None, "auto"):
            tp = max(
                tp,
                estimate_min_tp(
                    parameters_b,
                    per_gpu_memory,
                    bytes_per_param=bytes_per_param,
                    kv_headroom_fraction=kv_headroom_fraction,
                    max_gpus=len(pool),
                ),
            )
        if len(pool) < tp:
            raise PlanningError(
                f"Deployment {dep.get('name')} resolved tp={tp} but only {len(pool)} GPUs were allocated."
            )

        dp_value = topo.get("dp", "auto")
        if dp_value in (None, "auto"):
            dp = max(1, len(pool) // tp)
        else:
            dp = max(1, int(dp_value))

        required = tp * dp
        if required > len(pool):
            dp = max(1, len(pool) // tp)
            required = tp * dp
        if required < len(pool):
            pool = pool[:required]
        if required == 0:
            raise PlanningError(f"Deployment {dep.get('name')} resolved to zero GPUs.")

        used_indices = {g.index for g in pool}
        free_pool = [g for g in free_pool if g.index not in used_indices]

        tuning = dep.get("tuning", {})
        gpu_memory_utilization = tuning.get("gpu_memory_utilization")
        if gpu_memory_utilization is None:
            gpu_memory_utilization = serving_defaults.get("gpu_memory_utilization", 0.9)
        max_model_len = tuning.get("max_model_len", serving_defaults.get("max_model_len", "auto"))
        max_num_batched_tokens = tuning.get(
            "max_num_batched_tokens",
            serving_defaults.get("max_num_batched_tokens", 8192),
        )
        if max_num_batched_tokens is None:
            max_num_batched_tokens = serving_defaults.get("max_num_batched_tokens", 8192)
        max_num_seqs = tuning.get("max_num_seqs", serving_defaults.get("max_num_seqs", 16))
        if max_num_seqs is None:
            max_num_seqs = serving_defaults.get("max_num_seqs", 16)
        performance_mode = tuning.get("performance_mode") or serving_defaults.get("performance_mode", "balanced")
        enable_prefix_caching = tuning.get(
            "enable_prefix_caching",
            serving_defaults.get("enable_prefix_caching", True),
        )
        trust_remote_code = bool(serving_defaults.get("trust_remote_code", False))
        enforce_eager = bool(serving_defaults.get("enforce_eager", False))
        dtype = serving_defaults.get("dtype", "auto")
        dist_backend = serving_defaults.get("distributed_executor_backend", "mp")

        args = [
            "--host", "0.0.0.0",
            "--port", str(container_port),
            "--model", str(dep["model"]),
            "--served-model-name", str(dep.get("served_model_name", dep["model"])),
            "--dtype", str(dtype),
            "--tensor-parallel-size", str(tp),
            "--data-parallel-size", str(dp),
            "--distributed-executor-backend", str(dist_backend),
            "--gpu-memory-utilization", str(gpu_memory_utilization),
            "--max-model-len", str(max_model_len),
            "--max-num-batched-tokens", str(max_num_batched_tokens),
            "--max-num-seqs", str(max_num_seqs),
            "--performance-mode", str(performance_mode),
            "--api-key", f"${{{api_key_env}}}",
            "--disable-access-log-for-endpoints", "/health,/metrics,/ping",
        ]
        if enable_prefix_caching:
            args.append("--enable-prefix-caching")
        else:
            args.append("--no-enable-prefix-caching")
        if trust_remote_code:
            args.append("--trust-remote-code")
        if enforce_eager:
            args.append("--enforce-eager")
        args.extend(str(x) for x in serving_defaults.get("extra_args", []))
        args.extend(str(x) for x in tuning.get("extra_args", []))

        plan = DeploymentPlan(
            name=str(dep["name"]),
            service_name=_sanitize_service_name(str(dep["name"])),
            model=str(dep["model"]),
            served_model_name=str(dep.get("served_model_name", dep["model"])),
            host_port=int(dep.get("api_port", 18000)),
            tp=int(tp),
            dp=int(dp),
            gpu_indices=sorted(int(g.index) for g in pool),
            total_gpu_count=len(pool),
            container_port=container_port,
            image=image,
            api_key_env=api_key_env,
            args=args,
            environment={
                "HF_HOME": "/root/.cache/huggingface",
                "HF_HUB_CACHE": "/root/.cache/huggingface/hub",
                "TZ": str(config.get("runtime", {}).get("timezone", "UTC")),
                "NVIDIA_DRIVER_CAPABILITIES": "compute,utility",
            },
            labels={
                "project": str(config.get("project_name", "vllm-stack")),
                "deployment": str(dep["name"]),
            },
        )
        deployments.append(plan)

    openai_urls = [f"http://{d.service_name}:{d.container_port}/v1" for d in deployments]
    return {
        "project_name": config.get("project_name", "vllm-stack"),
        "deployments": [d.to_dict() for d in deployments],
        "openai_base_urls": openai_urls,
        "serving_api_key_env": api_key_env,
        "paths": config.get("paths", {}),
        "runtime": config.get("runtime", {}),
        "open_webui": config.get("open_webui", {}),
        "postgres": config.get("postgres", {}),
        "remaining_gpu_indices": [g.index for g in free_pool],
        "detected_gpu_indices": [g.index for g in available],
    }
