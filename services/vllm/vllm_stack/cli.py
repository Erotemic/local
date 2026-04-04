from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from .benchmark import run_benchmark
from .config import DEFAULT_CONFIG_PATH, default_config, load_config, save_config
from .docker_utils import compose_down, compose_up, wait_for_http_ok
from .env_utils import parse_env_file
from .hardware import detect_gpus
from .planner import PlanningError, build_plan
from .renderer import render_files
from .tuning import tune_deployment


PROJECT_ROOT = Path(__file__).resolve().parent.parent
TEMPLATE_DIR = PROJECT_ROOT / "vllm_stack" / "templates"
GENERATED_DIR = PROJECT_ROOT / "generated"


def _config_path(args: argparse.Namespace) -> Path:
    return Path(args.config or DEFAULT_CONFIG_PATH)


def _load_and_refresh(path: Path) -> dict[str, Any]:
    config = load_config(path)
    return config


def cmd_init(args: argparse.Namespace) -> int:
    path = _config_path(args)
    if path.exists() and not args.force:
        raise SystemExit(f"Refusing to overwrite existing {path}. Use --force if you want to replace it.")
    config = default_config(detect_gpus())
    save_config(config, path)
    print(f"Wrote starter config to {path}")
    return 0


def cmd_detect_gpus(args: argparse.Namespace) -> int:
    gpus = [g.to_dict() for g in detect_gpus()]
    print(json.dumps(gpus, indent=2))
    return 0


def cmd_plan(args: argparse.Namespace) -> int:
    config = _load_and_refresh(_config_path(args))
    plan = build_plan(config)
    print(json.dumps(plan, indent=2))
    return 0


def cmd_render(args: argparse.Namespace) -> int:
    config_path = _config_path(args)
    config = _load_and_refresh(config_path)
    save_config(config, config_path)
    plan = build_plan(config)
    rendered = render_files(plan, GENERATED_DIR, TEMPLATE_DIR)
    print(json.dumps({k: str(v) for k, v in rendered.items()}, indent=2))
    return 0


def cmd_up(args: argparse.Namespace) -> int:
    config = _load_and_refresh(_config_path(args))
    compose_cmd = config.get("runtime", {}).get("compose_cmd", "docker compose")
    compose_file = GENERATED_DIR / "docker-compose.yml"
    env_file = GENERATED_DIR / ".env"
    if not compose_file.exists():
        raise SystemExit("No generated/docker-compose.yml found. Run `python manage.py render` first.")
    compose_up(compose_cmd, compose_file, env_file)
    print("Stack started.")
    return 0


def cmd_down(args: argparse.Namespace) -> int:
    config = _load_and_refresh(_config_path(args))
    compose_cmd = config.get("runtime", {}).get("compose_cmd", "docker compose")
    compose_file = GENERATED_DIR / "docker-compose.yml"
    env_file = GENERATED_DIR / ".env"
    if not compose_file.exists():
        raise SystemExit("No generated/docker-compose.yml found. Run `python manage.py render` first.")
    compose_down(compose_cmd, compose_file, env_file)
    print("Stack stopped.")
    return 0


def _resolve_deployment_plan(plan: dict[str, Any], name: str) -> dict[str, Any]:
    for dep in plan.get("deployments", []):
        if dep["name"] == name:
            return dep
    raise SystemExit(f"Deployment {name!r} not found in plan.")


def cmd_benchmark(args: argparse.Namespace) -> int:
    config = _load_and_refresh(_config_path(args))
    plan = build_plan(config)
    dep_plan = _resolve_deployment_plan(plan, args.deployment)
    benchmark_cfg = config.get("benchmark", {})
    host = benchmark_cfg.get("host", "127.0.0.1")
    api_key_env = benchmark_cfg.get("api_key_env", config.get("serving_defaults", {}).get("api_key_env", "VLLM_API_KEY"))
    env_values = parse_env_file(GENERATED_DIR / ".env")
    api_key = env_values.get(api_key_env, "change_me")
    base_url = f"http://{host}:{dep_plan['host_port']}/v1"
    wait_for_http_ok(f"http://{host}:{dep_plan['host_port']}/health", timeout_s=benchmark_cfg.get("timeout_s", 300))
    result = run_benchmark(
        base_url=base_url,
        api_key=api_key,
        model=dep_plan["served_model_name"],
        prompts_file=benchmark_cfg.get("prompts_file", "benchmark_prompts.json"),
        concurrency_levels=list(benchmark_cfg.get("concurrency_levels", [1, 4, 8])),
        requests_per_level=int(benchmark_cfg.get("requests_per_level", 4)),
        prompt_tokens=int(benchmark_cfg.get("prompt_tokens", 256)),
        completion_tokens=int(benchmark_cfg.get("completion_tokens", 256)),
        timeout_s=int(benchmark_cfg.get("timeout_s", 300)),
        stream=bool(benchmark_cfg.get("stream", True)),
    )
    print(json.dumps(result, indent=2))
    return 0


def cmd_tune(args: argparse.Namespace) -> int:
    config_path = _config_path(args)
    config = _load_and_refresh(config_path)
    compose_cmd = config.get("runtime", {}).get("compose_cmd", "docker compose")
    result = tune_deployment(
        config=config,
        deployment_name=args.deployment,
        template_dir=TEMPLATE_DIR,
        compose_cmd=compose_cmd,
        objective=args.objective,
        tuning_profile=args.profile,
        apply=args.apply,
        output_dir=GENERATED_DIR,
    )
    if args.apply:
        save_config(config, config_path)
    print(json.dumps(result, indent=2))
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Manage a local vLLM stack")
    parser.add_argument("--config", default=str(DEFAULT_CONFIG_PATH), help="Path to project.yaml")
    sub = parser.add_subparsers(dest="command", required=True)

    init_p = sub.add_parser("init", help="Create a starter config")
    init_p.add_argument("--force", action="store_true", help="Overwrite an existing config")
    init_p.set_defaults(func=cmd_init)

    detect_p = sub.add_parser("detect-gpus", help="Print detected GPUs as JSON")
    detect_p.set_defaults(func=cmd_detect_gpus)

    plan_p = sub.add_parser("plan", help="Show the computed deployment plan")
    plan_p.set_defaults(func=cmd_plan)

    render_p = sub.add_parser("render", help="Render Docker Compose files into generated/")
    render_p.set_defaults(func=cmd_render)

    up_p = sub.add_parser("up", help="Bring up the rendered stack")
    up_p.set_defaults(func=cmd_up)

    down_p = sub.add_parser("down", help="Bring down the rendered stack")
    down_p.set_defaults(func=cmd_down)

    bench_p = sub.add_parser("benchmark", help="Benchmark a running deployment")
    bench_p.add_argument("--deployment", required=True, help="Deployment name from project.yaml")
    bench_p.set_defaults(func=cmd_benchmark)

    tune_p = sub.add_parser("tune", help="Run tuning trials for one deployment")
    tune_p.add_argument("--deployment", required=True, help="Deployment name from project.yaml")
    tune_p.add_argument("--objective", choices=["latency", "throughput", "balanced"], default="balanced")
    tune_p.add_argument("--profile", choices=["safe", "balanced", "aggressive"], default="balanced")
    tune_p.add_argument("--apply", action="store_true", help="Write the winning candidate back to project.yaml")
    tune_p.set_defaults(func=cmd_tune)

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    try:
        return int(args.func(args))
    except PlanningError as ex:
        raise SystemExit(f"Planning error: {ex}")


if __name__ == "__main__":
    raise SystemExit(main())
