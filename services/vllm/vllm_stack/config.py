from __future__ import annotations

from pathlib import Path
from typing import Any

import yaml

from .hardware import GPUInfo, detect_gpus, max_gpu_memory_gib, sum_gpu_memory_gib


DEFAULT_CONFIG_PATH = Path("project.yaml")


def _default_storage_root() -> Path:
    preferred = Path("/data/service/docker/vllm-stack")
    if preferred.parent.exists():
        return preferred
    return Path.cwd() / "state"


def _derive_served_model_name(model: str) -> str:
    tail = model.split("/")[-1]
    return tail.lower().replace("/", "-")


def choose_default_qwen35_model(gpus: list[GPUInfo]) -> str:
    gpu_count = len(gpus)
    per_gpu = max_gpu_memory_gib(gpus)
    total = sum_gpu_memory_gib(gpus)

    # Conservative, public Qwen3.5 defaults.
    if gpu_count >= 2 and total >= 160 and per_gpu >= 40:
        return "Qwen/Qwen3.5-35B-A3B"
    if gpu_count >= 2 and total >= 96 and per_gpu >= 40:
        return "Qwen/Qwen3.5-27B"
    if per_gpu >= 18:
        return "Qwen/Qwen3.5-9B"
    if per_gpu >= 10:
        return "Qwen/Qwen3.5-4B"
    if per_gpu >= 6:
        return "Qwen/Qwen3.5-2B"
    return "Qwen/Qwen3.5-0.8B"


def default_config(gpus: list[GPUInfo] | None = None) -> dict[str, Any]:
    gpus = list(gpus or detect_gpus())
    inventory = [g.to_dict() for g in gpus]
    storage_root = _default_storage_root()
    default_model = choose_default_qwen35_model(gpus)
    served_name = _derive_served_model_name(default_model)
    return {
        "version": 1,
        "project_name": "vllm-stack",
        "paths": {
            "storage_root": str(storage_root),
            "hf_cache_dir": str(storage_root / "hf-cache"),
            "openwebui_data_dir": str(storage_root / "open-webui"),
            "postgres_data_dir": str(storage_root / "postgres"),
        },
        "runtime": {
            "compose_cmd": "docker compose",
            "timezone": "America/New_York",
        },
        "open_webui": {
            "enabled": True,
            "port": 14771,
            "webui_auth": True,
            "enable_persistent_config": False,
        },
        "postgres": {
            "enabled": True,
            "db": "openwebui",
            "user": "openwebui",
            "password_env": "POSTGRES_PASSWORD",
        },
        "serving_defaults": {
            "image": "vllm/vllm-openai:latest",
            "container_port": 8000,
            "api_key_env": "VLLM_API_KEY",
            "dtype": "auto",
            "distributed_executor_backend": "mp",
            "gpu_memory_utilization": 0.90,
            "max_model_len": 32768,
            "max_num_batched_tokens": 8192,
            "max_num_seqs": 16,
            "enable_prefix_caching": True,
            "performance_mode": "balanced",
            "optimization_level": 2,
            "trust_remote_code": False,
            "enforce_eager": False,
            "enable_expert_parallel": "auto",
            "extra_args": [],
        },
        "hardware": {
            "reserved_gpu_indices": [],
            "inventory": inventory,
        },
        "models": {
            "default_qwen": {
                "source": default_model,
                "served_model_name": served_name,
                "dtype": "auto",
                "max_model_len": 32768,
                "trust_remote_code": False,
                "extra_args": [],
            },
        },
        "deployments": [
            {
                "name": "default-chat",
                "enabled": True,
                "model_ref": "default_qwen",
                "api_port": 18000,
                "estimate": {
                    "parameters_b": "auto",
                    "bytes_per_param": 2.0,
                    "kv_headroom_fraction": 0.78,
                },
                "topology": {
                    "tp": "auto",
                    "dp": "auto",
                    "gpu_count": "auto",
                },
                "placement": {
                    "gpu_indices": "auto",
                },
                "tuning": {
                    "gpu_memory_utilization": None,
                    "max_model_len": None,
                    "max_num_batched_tokens": None,
                    "max_num_seqs": None,
                    "performance_mode": None,
                    "optimization_level": None,
                    "enable_prefix_caching": True,
                    "enable_expert_parallel": "auto",
                    "extra_args": [],
                },
            }
        ],
        "benchmark": {
            "host": "127.0.0.1",
            "api_key_env": "VLLM_API_KEY",
            "timeout_s": 300,
            "concurrency_levels": [1, 4, 8],
            "requests_per_level": 4,
            "prompt_tokens": 256,
            "completion_tokens": 256,
            "prompts_file": "benchmark_prompts.json",
            "stream": True,
        },
    }


def load_config(path: str | Path = DEFAULT_CONFIG_PATH) -> dict[str, Any]:
    with Path(path).open("r", encoding="utf-8") as file:
        data = yaml.safe_load(file) or {}
    return data


def save_config(config: dict[str, Any], path: str | Path = DEFAULT_CONFIG_PATH) -> None:
    with Path(path).open("w", encoding="utf-8") as file:
        yaml.safe_dump(config, file, sort_keys=False, default_flow_style=False)
