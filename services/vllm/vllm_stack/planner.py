from __future__ import annotations

from dataclasses import dataclass
from typing import Any

from .hardware import (
    GPUInfo,
    estimate_min_tp,
    infer_parameter_count_b,
    looks_like_moe_model,
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
    gpu_uuids: list[str]
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
            "gpu_uuids": self.gpu_uuids,
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


def _resolve_model_entry(config: dict[str, Any], deployment: dict[str, Any]) -> dict[str, Any]:
    models = config.get("models", {}) or {}
    model_ref = deployment.get("model_ref")

    # Backward compatibility with old inline deployments.
    if not model_ref:
        model = deployment.get("model")
        if not model:
            raise PlanningError(
                f"Deployment {deployment.get('name')!r} must define either 'model_ref' or 'model'."
            )
        return {
            "name": None,
            "source": model,
            "served_model_name": deployment.get("served_model_name", model),
            "dtype": None,
            "max_model_len": None,
            "trust_remote_code": None,
            "extra_args": [],
        }

    if model_ref not in models:
        raise PlanningError(
            f"Deployment {deployment.get('name')!r} references unknown model_ref {model_ref!r}."
        )

    entry = dict(models[model_ref] or {})
    source = entry.get("source")
    if not source:
        raise PlanningError(f"Model entry {model_ref!r} must define 'source'.")

    entry.setdefault("served_model_name", source)
    entry.setdefault("dtype", None)
    entry.setdefault("max_model_len", None)
    entry.setdefault("trust_remote_code", None)
    entry.setdefault("extra_args", [])
    entry["name"] = model_ref
    return entry


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


def _enabled_deployments(config: dict[str, Any]) -> list[dict[str, Any]]:
    return [d for d in config.get("deployments", []) if d.get("enabled", True)]


def _resolve_parameters_b(config: dict[str, Any], deployment: dict[str, Any], model_entry: dict[str, Any]) -> float | None:
    estimate = deployment.get("estimate", {})
    explicit = estimate.get("parameters_b", "auto")
    if explicit not in (None, "auto"):
        return float(explicit)
    return infer_parameter_count_b(str(model_entry.get("source", "")))


def _resolve_gpu_count(
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
        return max(min_tp, len(remaining_gpus))
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


def _resolve_enable_expert_parallel(model: str, serving_defaults: dict[str, Any], tuning: dict[str, Any], tp: int) -> bool:
    value = tuning.get("enable_expert_parallel", serving_defaults.get("enable_expert_parallel", "auto"))
    if value == "auto":
        return tp > 1 and looks_like_moe_model(model)
    return bool(value)


def _build_vllm_args(
    *,
    container_port: int,
    model_source: str,
    served_model_name: str,
    tp: int,
    dp: int,
    api_key_env: str,
    enable_expert_parallel: bool,
    runtime_settings: dict[str, Any],
) -> list[str]:
    args = [
        "--host", "0.0.0.0",
        "--port", str(container_port),
        "--model", model_source,
        "--served-model-name", served_model_name,
        "--dtype", str(runtime_settings["dtype"]),
        "--tensor-parallel-size", str(tp),
        "--data-parallel-size", str(dp),
        "--data-parallel-backend", "mp",
        "--distributed-executor-backend", str(runtime_settings["dist_backend"]),
        "--gpu-memory-utilization", str(runtime_settings["gpu_memory_utilization"]),
        "--max-model-len", str(runtime_settings["max_model_len"]),
        "--max-num-batched-tokens", str(runtime_settings["max_num_batched_tokens"]),
        "--max-num-seqs", str(runtime_settings["max_num_seqs"]),
        "--performance-mode", str(runtime_settings["performance_mode"]),
        "--optimization-level", str(runtime_settings["optimization_level"]),
        "--api-key", f"${{{api_key_env}}}",
        "--disable-access-log-for-endpoints", "/health,/metrics,/ping",
    ]

    if runtime_settings["enable_prefix_caching"]:
        args.append("--enable-prefix-caching")
    else:
        args.append("--no-enable-prefix-caching")

    if runtime_settings["trust_remote_code"]:
        args.append("--trust-remote-code")

    if runtime_settings["enforce_eager"]:
        args.append("--enforce-eager")

    if enable_expert_parallel:
        args.append("--enable-expert-parallel")

    args.extend(runtime_settings["extra_args"])
    return args

def _effective_runtime_settings(
    config: dict[str, Any],
    deployment: dict[str, Any],
    model_entry: dict[str, Any],
) -> dict[str, Any]:
    serving_defaults = config.get("serving_defaults", {})
    tuning = deployment.get("tuning", {}) or {}

    gpu_memory_utilization = tuning.get("gpu_memory_utilization")
    if gpu_memory_utilization is None:
        gpu_memory_utilization = serving_defaults.get("gpu_memory_utilization", 0.9)

    max_model_len = tuning.get("max_model_len")
    if max_model_len is None:
        max_model_len = model_entry.get("max_model_len")
    if max_model_len is None:
        max_model_len = serving_defaults.get("max_model_len", 32768)

    max_num_batched_tokens = tuning.get("max_num_batched_tokens")
    if max_num_batched_tokens is None:
        max_num_batched_tokens = serving_defaults.get("max_num_batched_tokens", 8192)

    max_num_seqs = tuning.get("max_num_seqs")
    if max_num_seqs is None:
        max_num_seqs = serving_defaults.get("max_num_seqs", 16)

    performance_mode = tuning.get("performance_mode")
    if performance_mode is None:
        performance_mode = serving_defaults.get("performance_mode", "balanced")

    optimization_level = tuning.get("optimization_level")
    if optimization_level is None:
        optimization_level = serving_defaults.get("optimization_level", 2)

    enable_prefix_caching = tuning.get("enable_prefix_caching")
    if enable_prefix_caching is None:
        enable_prefix_caching = serving_defaults.get("enable_prefix_caching", True)

    trust_remote_code = model_entry.get("trust_remote_code")
    if trust_remote_code is None:
        trust_remote_code = serving_defaults.get("trust_remote_code", False)
    trust_remote_code = bool(trust_remote_code)

    enforce_eager = serving_defaults.get("enforce_eager", False)
    enforce_eager = bool(enforce_eager)

    dtype = deployment.get("dtype")
    if dtype is None:
        dtype = model_entry.get("dtype")
    if dtype is None:
        dtype = serving_defaults.get("dtype", "auto")

    dist_backend = serving_defaults.get("distributed_executor_backend", "mp")

    extra_args: list[str] = []
    extra_args.extend(str(x) for x in serving_defaults.get("extra_args", []))
    extra_args.extend(str(x) for x in model_entry.get("extra_args", []))
    extra_args.extend(str(x) for x in tuning.get("extra_args", []))

    return {
        "gpu_memory_utilization": gpu_memory_utilization,
        "max_model_len": max_model_len,
        "max_num_batched_tokens": max_num_batched_tokens,
        "max_num_seqs": max_num_seqs,
        "performance_mode": performance_mode,
        "optimization_level": optimization_level,
        "enable_prefix_caching": enable_prefix_caching,
        "trust_remote_code": trust_remote_code,
        "enforce_eager": enforce_eager,
        "dtype": dtype,
        "dist_backend": dist_backend,
        "extra_args": extra_args,
    }


def _plan_single_deployment(
    *,
    config: dict[str, Any],
    deployment: dict[str, Any],
    free_pool: list[GPUInfo],
    enabled_count: int,
    container_port: int,
    image: str,
    api_key_env: str,
) -> tuple[DeploymentPlan, list[GPUInfo]]:
    serving_defaults = config.get("serving_defaults", {})
    estimate = deployment.get("estimate", {}) or {}
    topo = deployment.get("topology", {}) or {}
    tuning = deployment.get("tuning", {}) or {}

    model_entry = _resolve_model_entry(config, deployment)
    model_source = str(model_entry["source"])
    served_model_name = str(
        deployment.get("served_model_name")
        or model_entry.get("served_model_name")
        or model_source
    )

    parameters_b = _resolve_parameters_b(config, deployment, model_entry)
    bytes_per_param = float(estimate.get("bytes_per_param", 2.0))
    kv_headroom_fraction = float(estimate.get("kv_headroom_fraction", 0.78))

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

    gpu_count = _resolve_gpu_count(deployment, free_pool, enabled_count, tp)
    if gpu_count < tp:
        gpu_count = tp
    if gpu_count > len(free_pool):
        raise PlanningError(
            f"Deployment {deployment.get('name')!r} wants {gpu_count} GPUs, but only {len(free_pool)} remain."
        )

    pool = _resolve_gpu_pool(deployment, free_pool, gpu_count)
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
            f"Deployment {deployment.get('name')!r} resolved tp={tp} but only {len(pool)} GPUs were allocated."
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
        raise PlanningError(f"Deployment {deployment.get('name')!r} resolved to zero GPUs.")

    used_indices = {g.index for g in pool}
    next_free_pool = [g for g in free_pool if g.index not in used_indices]

    runtime_settings = _effective_runtime_settings(config, deployment, model_entry)

    enable_expert_parallel = _resolve_enable_expert_parallel(
        model_source,
        serving_defaults,
        tuning,
        tp,
    )

    args = _build_vllm_args(
        container_port=container_port,
        model_source=model_source,
        served_model_name=served_model_name,
        tp=tp,
        dp=dp,
        api_key_env=api_key_env,
        enable_expert_parallel=enable_expert_parallel,
        runtime_settings=runtime_settings,
    )

    plan = DeploymentPlan(
        name=str(deployment["name"]),
        service_name=_sanitize_service_name(str(deployment["name"])),
        model=model_source,
        served_model_name=served_model_name,
        host_port=int(deployment.get("api_port", container_port)),
        tp=tp,
        dp=dp,
        gpu_indices=sorted(int(g.index) for g in pool),
        gpu_uuids=[g.uuid for g in sorted(pool, key=lambda x: x.index)],
        total_gpu_count=len(pool),
        container_port=container_port,
        image=image,
        api_key_env=api_key_env,
        args=args,
        environment={
            "HF_HOME": "/root/.cache/huggingface",
            "HF_HUB_CACHE": "/root/.cache/huggingface/hub",
            "TZ": str(config.get("runtime", {}).get("timezone", "UTC")),
        },
        labels={
            "vllm-stack.deployment": str(deployment["name"]),
            "vllm-stack.model": model_source,
            "vllm-stack.model_ref": str(deployment.get("model_ref", "")),
            "vllm-stack.tp": str(tp),
            "vllm-stack.dp": str(dp),
        },
    )
    return plan, next_free_pool


def build_plan(config: dict[str, Any]) -> dict[str, Any]:
    gpus = _as_gpu_info_list(config)
    reserved = set(int(x) for x in config.get("hardware", {}).get("reserved_gpu_indices", []))
    available = [g for g in gpus if g.index not in reserved]
    available = sorted(available, key=lambda g: g.index)

    serving_defaults = config.get("serving_defaults", {})
    container_port = int(serving_defaults.get("container_port", 8000))
    image = str(serving_defaults.get("image", "vllm/vllm-openai:latest"))
    api_key_env = str(serving_defaults.get("api_key_env", "VLLM_API_KEY"))
    enabled = _enabled_deployments(config)

    if enabled and not available:
        raise PlanningError(
            "No GPUs detected or all GPUs were reserved. Run on a GPU host or set hardware.inventory in project.yaml."
        )

    deployments: list[DeploymentPlan] = []
    free_pool = list(available)

    for dep in enabled:
        if not free_pool:
            raise PlanningError(f"No GPUs remain for deployment {dep.get('name')!r}.")

        plan, free_pool = _plan_single_deployment(
            config=config,
            deployment=dep,
            free_pool=free_pool,
            enabled_count=len(enabled),
            container_port=container_port,
            image=image,
            api_key_env=api_key_env,
        )
        deployments.append(plan)

    openai_base_urls = [f"http://{dep.service_name}:{dep.container_port}/v1" for dep in deployments]

    return {
        "project_name": config.get("project_name", "vllm-stack"),
        "paths": config.get("paths", {}),
        "runtime": config.get("runtime", {}),
        "open_webui": config.get("open_webui", {}),
        "postgres": config.get("postgres", {}),
        "serving_defaults": serving_defaults,
        "deployments": [dep.to_dict() for dep in deployments],
        "openai_base_urls": openai_base_urls,
    }
