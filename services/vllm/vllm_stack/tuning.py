from __future__ import annotations

import copy
import tempfile
from pathlib import Path
from typing import Any

from .benchmark import run_benchmark
from .docker_utils import compose_down, compose_up, wait_for_http_ok
from .env_utils import parse_env_file
from .planner import build_plan
from .renderer import render_files


PROFILE_CANDIDATES = {
    "safe": [
        {"performance_mode": "interactivity", "optimization_level": 1, "gpu_memory_utilization": 0.88, "max_num_batched_tokens": 4096, "max_num_seqs": 8},
        {"performance_mode": "balanced", "optimization_level": 2, "gpu_memory_utilization": 0.90, "max_num_batched_tokens": 8192, "max_num_seqs": 16},
    ],
    "balanced": [
        {"performance_mode": "interactivity", "optimization_level": 1, "gpu_memory_utilization": 0.90, "max_num_batched_tokens": 4096, "max_num_seqs": 8},
        {"performance_mode": "balanced", "optimization_level": 2, "gpu_memory_utilization": 0.92, "max_num_batched_tokens": 8192, "max_num_seqs": 16},
        {"performance_mode": "throughput", "optimization_level": 2, "gpu_memory_utilization": 0.94, "max_num_batched_tokens": 16384, "max_num_seqs": 32},
    ],
    "aggressive": [
        {"performance_mode": "balanced", "optimization_level": 2, "gpu_memory_utilization": 0.94, "max_num_batched_tokens": 16384, "max_num_seqs": 32},
        {"performance_mode": "throughput", "optimization_level": 3, "gpu_memory_utilization": 0.95, "max_num_batched_tokens": 24576, "max_num_seqs": 48},
        {"performance_mode": "throughput", "optimization_level": 3, "gpu_memory_utilization": 0.96, "max_num_batched_tokens": 32768, "max_num_seqs": 64},
    ],
}


class TuneError(RuntimeError):
    pass


def _candidate_list(profile: str) -> list[dict[str, Any]]:
    if profile not in PROFILE_CANDIDATES:
        raise TuneError(f"Unknown tuning profile {profile!r}. Choose from {sorted(PROFILE_CANDIDATES)}")
    return copy.deepcopy(PROFILE_CANDIDATES[profile])


def _select_target(config: dict[str, Any], deployment_name: str) -> dict[str, Any]:
    for dep in config.get("deployments", []):
        if dep.get("name") == deployment_name:
            return dep
    raise TuneError(f"Deployment {deployment_name!r} not found in config.")


def tune_deployment(
    config: dict[str, Any],
    deployment_name: str,
    template_dir: str | Path,
    compose_cmd: str,
    objective: str,
    tuning_profile: str,
    apply: bool,
    output_dir: str | Path,
) -> dict[str, Any]:
    target = _select_target(config, deployment_name)
    benchmark_cfg = config.get("benchmark", {})
    prompts_file = benchmark_cfg.get("prompts_file", "benchmark_prompts.json")
    api_key_env = benchmark_cfg.get(
        "api_key_env",
        config.get("serving_defaults", {}).get("api_key_env", "VLLM_API_KEY"),
    )
    host = benchmark_cfg.get("host", "127.0.0.1")

    trials = []
    best: dict[str, Any] | None = None
    best_score: float | None = None

    base_env = parse_env_file(Path(output_dir) / ".env")
    api_key = base_env.get(api_key_env, "change_me")

    with tempfile.TemporaryDirectory(prefix="vllm-stack-tune-") as temp_dir_str:
        temp_dir = Path(temp_dir_str)
        for idx, candidate in enumerate(_candidate_list(tuning_profile), start=1):
            trial_config = copy.deepcopy(config)
            trial_dep = _select_target(trial_config, deployment_name)
            trial_dep.setdefault("tuning", {}).update(candidate)
            for dep in trial_config.get("deployments", []):
                dep["enabled"] = dep.get("name") == deployment_name

            plan = build_plan(trial_config)
            rendered = render_files(plan, temp_dir / f"trial-{idx}", template_dir)
            dep_plan = plan["deployments"][0]
            base_url = f"http://{host}:{dep_plan['host_port']}/v1"
            result: dict[str, Any] | None = None
            score: float | None = None

            compose_up(compose_cmd, rendered["compose"], rendered["env"])
            try:
                wait_for_http_ok(f"http://{host}:{dep_plan['host_port']}/health", timeout_s=1800)
                trial_env = parse_env_file(rendered["env"])
                api_key = trial_env.get(api_key_env, api_key)
                result = run_benchmark(
                    base_url=base_url,
                    api_key=api_key,
                    model=dep_plan["served_model_name"],
                    prompts_file=prompts_file,
                    concurrency_levels=list(benchmark_cfg.get("concurrency_levels", [1, 4, 8])),
                    requests_per_level=int(benchmark_cfg.get("requests_per_level", 4)),
                    prompt_tokens=int(benchmark_cfg.get("prompt_tokens", 256)),
                    completion_tokens=int(benchmark_cfg.get("completion_tokens", 256)),
                    timeout_s=int(benchmark_cfg.get("timeout_s", 300)),
                    stream=bool(benchmark_cfg.get("stream", True)),
                )
                score = float(result["scores"][objective])
            finally:
                compose_down(compose_cmd, rendered["compose"], rendered["env"])

            trial_record = {
                "candidate": candidate,
                "objective": objective,
                "score": score,
                "benchmark": result,
            }
            trials.append(trial_record)
            if score is not None and (best_score is None or score > best_score):
                best = trial_record
                best_score = score

    if best is None:
        raise TuneError("No tuning trials completed successfully.")

    if apply:
        target.setdefault("tuning", {}).update(best["candidate"])

    return {
        "objective": objective,
        "profile": tuning_profile,
        "best": best,
        "trials": trials,
    }
