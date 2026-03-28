from __future__ import annotations

import shlex
import subprocess
import time
from pathlib import Path
from typing import Iterable

import requests


def split_compose_cmd(value: str) -> list[str]:
    return shlex.split(value)


def run(cmd: list[str], cwd: str | Path | None = None) -> None:
    subprocess.run(cmd, cwd=cwd, check=True)


def compose_base_cmd(compose_cmd: str, compose_file: str | Path, env_file: str | Path | None = None) -> list[str]:
    cmd = split_compose_cmd(compose_cmd)
    cmd.extend(["-f", str(compose_file)])
    if env_file is not None:
        cmd.extend(["--env-file", str(env_file)])
    return cmd


def compose_up(compose_cmd: str, compose_file: str | Path, env_file: str | Path | None = None, services: Iterable[str] | None = None) -> None:
    cmd = compose_base_cmd(compose_cmd, compose_file, env_file)
    cmd.extend(["up", "-d"])
    if services:
        cmd.extend(list(services))
    run(cmd)


def compose_down(compose_cmd: str, compose_file: str | Path, env_file: str | Path | None = None) -> None:
    cmd = compose_base_cmd(compose_cmd, compose_file, env_file)
    cmd.extend(["down", "--remove-orphans"])
    run(cmd)


def wait_for_http_ok(url: str, timeout_s: int = 600, interval_s: float = 2.0) -> None:
    deadline = time.time() + timeout_s
    last_error: Exception | None = None
    while time.time() < deadline:
        try:
            response = requests.get(url, timeout=10)
            if response.status_code == 200:
                return
        except Exception as ex:  # pragma: no cover - network path
            last_error = ex
        time.sleep(interval_s)
    raise TimeoutError(f"Timed out waiting for {url}. Last error: {last_error}")
