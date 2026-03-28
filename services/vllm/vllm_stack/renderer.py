from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from jinja2 import Environment, FileSystemLoader

from .env_utils import ensure_env_values


def _template_env(template_dir: Path) -> Environment:
    return Environment(
        loader=FileSystemLoader(str(template_dir)),
        trim_blocks=True,
        lstrip_blocks=True,
    )


def render_files(plan: dict[str, Any], output_dir: str | Path, template_dir: str | Path) -> dict[str, Path]:
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)
    template_path = Path(template_dir)
    env = _template_env(template_path)

    env_file = output_path / ".env"
    required_secret_keys = [str(plan.get("serving_api_key_env", "VLLM_API_KEY"))]
    postgres_env_name = str(plan.get("postgres", {}).get("password_env", "POSTGRES_PASSWORD"))
    if bool(plan.get("postgres", {}).get("enabled", False)):
        required_secret_keys.append(postgres_env_name)
    env_values = ensure_env_values(
        env_file,
        required_secret_keys=required_secret_keys,
        optional_keys=["HF_TOKEN"],
    )

    compose_text = env.get_template("docker-compose.yml.j2").render(plan=plan)
    env_text = env.get_template("env.j2").render(plan=plan, env_values=env_values)

    compose_file = output_path / "docker-compose.yml"
    plan_file = output_path / "plan.json"

    compose_file.write_text(compose_text + "\n", encoding="utf-8")
    env_file.write_text(env_text + "\n", encoding="utf-8")
    plan_file.write_text(json.dumps(plan, indent=2) + "\n", encoding="utf-8")

    return {
        "compose": compose_file,
        "env": env_file,
        "plan": plan_file,
    }
