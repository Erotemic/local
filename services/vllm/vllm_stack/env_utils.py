from __future__ import annotations

import secrets
from pathlib import Path


def parse_env_file(path: str | Path) -> dict[str, str]:
    env: dict[str, str] = {}
    file_path = Path(path)
    if not file_path.exists():
        return env
    for raw_line in file_path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        env[key.strip()] = value.strip()
    return env


def random_secret(length_bytes: int = 24) -> str:
    return secrets.token_urlsafe(length_bytes)


def ensure_secret(env: dict[str, str], key: str, *, blank_ok: bool = False) -> None:
    value = env.get(key, "").strip()
    if blank_ok and not value:
        env[key] = ""
        return
    if not value or value in {"change_me", "changeme", "example", "replace_me", "None", "none"}:
        env[key] = random_secret()


def write_env_file(path: str | Path, env: dict[str, str], comments: list[str] | None = None) -> None:
    lines: list[str] = []
    for comment in comments or []:
        lines.append(f"# {comment}")
    if lines:
        lines.append("")
    for key in sorted(env):
        lines.append(f"{key}={env[key]}")
    Path(path).write_text("\n".join(lines) + "\n", encoding="utf-8")
