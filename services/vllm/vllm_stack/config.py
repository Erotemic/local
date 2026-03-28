from __future__ import annotations

from pathlib import Path
from typing import Any

import yaml

from .hardware import GPUInfo, detect_gpus, median_gpu_memory_gib


DEFAULT_CONFIG_PATH = Path("project.yaml")


def _pick_default_qwen35_model(gpus: list[GPUInfo]) -> tuple[str, str]:
    if not gpus:
        return ("Qwen/Qwen3.5-2B", "qwen3.5-2b")

    per_gpu_gib = median_gpu_memory_gib(gpus)
    total_gib = sum(g.memory_total_gib for g in gpus)
    gpu_count = len(gpus)

    if gpu_count >= 4 and per_gpu_gib >= 80 and total_gib >= 300:
        return ("Qwen/Qwen3.5-27B", "qwen3.5-27b")
    if per_gpu_gib >= 40:
        return ("Qwen/Qwen3.5-9B", "qwen3.5-9b")
    if per_gpu_gib >= 16:
        return ("Qwen/Qwen3.5-4B", "qwen3.5-4b")
    if per_gpu_gib >= 8:
        return ("Qwen/Qwen3.5-2B", "qwen3.5-2b")
    return ("Qwen/Qwen3.5-0.8B", "qwen3.5-0.8b")


def default_config(gpus: list[GPUInfo] | None = None) -> dict[str, Any]:
    gpus = list(gpus or detect_gpus())
    inventory = [g.to_dict() for g in gpus]
    default_model, default_served_name = _pick_default_qwen35_model(gpus)
    return {
        "version": 1,
        "project_name": "vllm-stack",
        "paths": {
            "hf_cache_dir": "/data/service/docker/hf-cache",
            "openwebui_data_dir": "/data/service/docker/open-webui",
            "postgres_data_dir": "/data/service/docker/open-webui-postgres",
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
            "max_model_len": "auto",
            "max_num_batched_tokens": 8192,
            "max_num_seqs": 16,
            "enable_prefix_caching": True,
            "performance_mode": "balanced",
            "trust_remote_code": False,
            "enforce_eager": False,
            "extra_args": [],
        },
        "hardware": {
            "auto_detect": True,
            "reserved_gpu_indices": [],
            "inventory": inventory,
        },
        "deployments": [
            {
                "name": "default-chat",
                "enabled": True,
                "model": default_model,
                "served_model_name": default_served_name,
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
                    "max_model_len": "auto",
                    "max_num_batched_tokens": None,
                    "max_num_seqs": None,
                    "performance_mode": None,
                    "enable_prefix_caching": True,
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


def merge_inventory_if_needed(config: dict[str, Any]) -> dict[str, Any]:
    hardware = config.setdefault("hardware", {})
    if hardware.get("auto_detect", True):
        hardware["inventory"] = [g.to_dict() for g in detect_gpus()]
    return config
