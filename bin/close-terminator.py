#!/usr/bin/env python3
"""Preview or close idle Terminator windows on X11 or Wayland.

A terminal is considered idle only when:
  * its direct Terminator child is a recognized interactive shell;
  * that shell owns the terminal's foreground process group; and
  * no other live process inherited that terminal's TERMINATOR_UUID.

By default, only windows containing exactly one terminal are candidates.
Use --all-idle to include multi-tab/split windows when every terminal is idle.
The default action is a dry run. Pass --close to send SIGHUP to candidate shells.
"""

from __future__ import annotations

import argparse
import concurrent.futures
import os
import re
import signal
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Mapping, Optional, Sequence, Set, Tuple

UUID_RE = re.compile(r"^urn:uuid:[0-9a-fA-F-]+$")
KNOWN_SHELLS = {
    "bash", "dash", "fish", "ksh", "mksh", "nu", "sh", "tcsh", "zsh",
}


class RemotinatorError(RuntimeError):
    """A single Remotinator lookup failed."""


@dataclass(frozen=True)
class Proc:
    pid: int
    ppid: int
    pgrp: int
    tpgid: int
    state: str
    comm: str
    uuid: str
    cpu_ticks: int


@dataclass(frozen=True)
class TerminalState:
    uuid: str
    idle: bool
    root_pid: Optional[int]
    cpu_ticks: Optional[int]
    reason: str


def progress(message: str) -> None:
    print(f"[close-terminator] {message}", file=sys.stderr, flush=True)


def run_remotinator(*args: str) -> str:
    try:
        completed = subprocess.run(
            ["remotinator", *args],
            check=True,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=10,
        )
    except FileNotFoundError:
        raise SystemExit(
            "remotinator was not found. Install the Ubuntu 'terminator' package."
        )
    except subprocess.TimeoutExpired as ex:
        raise RemotinatorError(
            f"remotinator timed out after {ex.timeout} seconds"
        ) from ex
    except subprocess.CalledProcessError as ex:
        detail = ex.stderr.strip() or ex.stdout.strip() or str(ex)
        raise RemotinatorError(detail) from ex
    return completed.stdout.strip()


def terminal_uuids() -> List[str]:
    try:
        text = run_remotinator("get_terminals")
    except RemotinatorError as ex:
        raise SystemExit(f"remotinator failed: {ex}") from ex
    return [
        line.strip()
        for line in text.splitlines()
        if UUID_RE.match(line.strip())
    ]


def terminal_window(uuid: str) -> str:
    return run_remotinator("--uuid", uuid, "get_window").strip()


def terminal_window_title(uuid: str) -> str:
    return run_remotinator("--uuid", uuid, "get_window_title").strip()


def _parallel_results(
    label: str,
    work: Mapping[str, "concurrent.futures.Future[str]"],
) -> Tuple[Dict[str, str], Dict[str, str]]:
    """Collect futures with visible progress and per-item failures."""
    results: Dict[str, str] = {}
    errors: Dict[str, str] = {}
    pending = set(work.values())
    reverse = {future: key for key, future in work.items()}
    total = len(pending)
    done_count = 0

    progress(f"{label}: 0/{total}")
    while pending:
        done, pending = concurrent.futures.wait(
            pending,
            timeout=0.5,
            return_when=concurrent.futures.FIRST_COMPLETED,
        )
        for future in done:
            key = reverse[future]
            done_count += 1
            try:
                results[key] = future.result()
            except RemotinatorError as ex:
                errors[key] = str(ex)
            except Exception as ex:
                errors[key] = f"{type(ex).__name__}: {ex}"
        if done or pending:
            progress(f"{label}: {done_count}/{total}")
    return results, errors


def collect_windows_and_titles(
    uuids: Sequence[str],
    jobs: int,
) -> Tuple[Dict[str, List[str]], Dict[str, str]]:
    """Map panes to windows without serial Remotinator startup delays.

    This keeps the original Remotinator-based approach, but runs independent
    pane lookups concurrently. A pane closed during the scan is skipped.
    """
    windows: Dict[str, List[str]] = {}
    titles: Dict[str, str] = {}

    worker_count = max(1, min(jobs, len(uuids)))
    with concurrent.futures.ThreadPoolExecutor(
        max_workers=worker_count
    ) as executor:
        window_work = {
            uuid: executor.submit(terminal_window, uuid)
            for uuid in uuids
        }
        window_by_uuid, window_errors = _parallel_results(
            "Mapping panes to windows",
            window_work,
        )

        for uuid in uuids:
            window = window_by_uuid.get(uuid)
            if window:
                windows.setdefault(window, []).append(uuid)

        if window_errors:
            progress(
                f"Skipped {len(window_errors)} pane(s) that vanished "
                "or failed during window lookup"
            )

        # Query one title per window. If that pane disappears, try another pane
        # from the same window before giving up on the title.
        def title_for_members(members: Sequence[str]) -> str:
            last_error: Optional[Exception] = None
            for uuid in members:
                try:
                    return terminal_window_title(uuid)
                except RemotinatorError as ex:
                    last_error = ex
            if last_error is not None:
                raise last_error
            return ""

        title_work = {
            window: executor.submit(title_for_members, members)
            for window, members in windows.items()
        }
        title_by_window, title_errors = _parallel_results(
            "Reading window titles",
            title_work,
        )
        titles.update(title_by_window)

        if title_errors:
            progress(
                f"Could not read {len(title_errors)} window title(s); "
                "those windows will be shown as '(untitled)'"
            )

    return windows, titles


def read_environ(pid: int) -> Mapping[str, str]:
    try:
        data = Path(f"/proc/{pid}/environ").read_bytes()
    except (FileNotFoundError, PermissionError, ProcessLookupError):
        return {}
    result: Dict[str, str] = {}
    for item in data.split(b"\0"):
        if b"=" not in item:
            continue
        key, value = item.split(b"=", 1)
        result[key.decode(errors="replace")] = value.decode(errors="replace")
    return result


def read_proc(pid: int, uuid: str) -> Optional[Proc]:
    try:
        text = Path(f"/proc/{pid}/stat").read_text()
    except (FileNotFoundError, PermissionError, ProcessLookupError):
        return None

    # /proc/PID/stat contains "pid (comm) state ..."; comm may contain spaces.
    close_paren = text.rfind(")")
    if close_paren < 0:
        return None
    prefix = text[:close_paren + 1]
    rest = text[close_paren + 2:].split()
    try:
        comm = prefix[prefix.index("(") + 1:-1]
        state = rest[0]
        ppid = int(rest[1])
        pgrp = int(rest[2])
        tpgid = int(rest[5])
        cpu_ticks = int(rest[11]) + int(rest[12])
    except (ValueError, IndexError):
        return None
    return Proc(pid, ppid, pgrp, tpgid, state, comm, uuid, cpu_ticks)


def snapshot_processes(wanted_uuids: Set[str]) -> Dict[str, Dict[int, Proc]]:
    grouped: Dict[str, Dict[int, Proc]] = {uuid: {} for uuid in wanted_uuids}
    for entry in Path("/proc").iterdir():
        if not entry.name.isdigit():
            continue
        pid = int(entry.name)
        uuid = read_environ(pid).get("TERMINATOR_UUID")
        if uuid not in wanted_uuids:
            continue
        proc = read_proc(pid, uuid)
        if proc is not None:
            grouped[uuid][pid] = proc
    return grouped


def classify_terminal(uuid: str, processes: Mapping[int, Proc]) -> TerminalState:
    live = {pid: proc for pid, proc in processes.items() if proc.state != "Z"}
    if not live:
        return TerminalState(uuid, False, None, None, "no live process found")

    roots = [proc for proc in live.values() if proc.ppid not in live]
    if len(roots) != 1:
        return TerminalState(
            uuid, False, None, None, f"expected one root process; found {len(roots)}"
        )

    root = roots[0]
    shell_name = root.comm.removeprefix("-")
    if shell_name not in KNOWN_SHELLS:
        return TerminalState(
            uuid, False, root.pid, root.cpu_ticks,
            f"root process is {root.comm}, not a known shell",
        )

    others = sorted(
        (proc for pid, proc in live.items() if pid != root.pid),
        key=lambda proc: proc.pid,
    )
    if others:
        summary = ", ".join(f"{proc.comm}[{proc.pid}]" for proc in others[:4])
        if len(others) > 4:
            summary += f", plus {len(others) - 4} more"
        return TerminalState(
            uuid, False, root.pid, root.cpu_ticks,
            f"has child/job processes: {summary}",
        )

    if root.tpgid <= 0:
        return TerminalState(
            uuid, False, root.pid, root.cpu_ticks,
            "terminal has no foreground process group",
        )
    if root.pgrp != root.tpgid:
        return TerminalState(
            uuid,
            False,
            root.pid,
            root.cpu_ticks,
            f"foreground process group is {root.tpgid}, shell group is {root.pgrp}",
        )

    if root.state not in {"S", "I"}:
        return TerminalState(
            uuid, False, root.pid, root.cpu_ticks,
            f"shell state is {root.state}, not sleeping at a prompt",
        )

    return TerminalState(uuid, True, root.pid, root.cpu_ticks, f"idle {shell_name} shell")


def classify_twice(
    uuids: Sequence[str], pause: float
) -> Tuple[Dict[str, TerminalState], Dict[str, TerminalState]]:
    wanted = set(uuids)
    progress("Taking first process snapshot")
    first_processes = snapshot_processes(wanted)
    first = {
        uuid: classify_terminal(uuid, first_processes.get(uuid, {}))
        for uuid in uuids
    }
    progress(f"Waiting {pause:g}s for idle stability")
    time.sleep(pause)
    progress("Taking second process snapshot")
    second_processes = snapshot_processes(wanted)
    second = {
        uuid: classify_terminal(uuid, second_processes.get(uuid, {}))
        for uuid in uuids
    }
    return first, second


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--close",
        action="store_true",
        help="actually close candidate windows; otherwise only preview",
    )
    parser.add_argument(
        "--all-idle",
        action="store_true",
        help="also close multi-terminal windows when every terminal is idle",
    )
    parser.add_argument(
        "--sample-delay",
        type=float,
        default=1.0,
        help="seconds between two idle checks (default: 1.0)",
    )
    parser.add_argument(
        "--jobs",
        type=int,
        default=8,
        help="parallel Remotinator lookups (default: 8)",
    )
    args = parser.parse_args()

    if args.jobs < 1:
        parser.error("--jobs must be at least 1")
    if args.sample_delay < 0:
        parser.error("--sample-delay must be nonnegative")

    progress("Starting DRY RUN" if not args.close else "Starting LIVE CLOSE")
    progress("Querying Terminator terminal list")
    uuids = terminal_uuids()

    if not uuids:
        raise SystemExit(
            "No D-Bus-controlled Terminator terminals were found. "
            "Terminator may be running with D-Bus disabled or with -u."
        )

    progress(f"Found {len(uuids)} terminal pane(s)")
    windows, titles = collect_windows_and_titles(uuids, args.jobs)

    # Only classify panes that still mapped to a live window.
    live_uuids = [
        uuid
        for members in windows.values()
        for uuid in members
    ]
    first, second = classify_twice(live_uuids, args.sample_delay)

    candidates: List[Tuple[str, List[str]]] = []
    print("Terminator windows:\n")
    for index, (window, members) in enumerate(windows.items(), start=1):
        stable_idle = all(
            first[u].idle
            and second[u].idle
            and first[u].root_pid == second[u].root_pid
            and first[u].cpu_ticks == second[u].cpu_ticks
            for u in members
        )
        shape_ok = args.all_idle or len(members) == 1
        candidate = stable_idle and shape_ok
        marker = "CANDIDATE" if candidate else "keep"
        print(f"[{index}] {marker}: {titles.get(window) or '(untitled)'}")
        print(f"    terminals: {len(members)}")
        for uuid in members:
            state = second[uuid]
            changed = (
                first[uuid].idle != second[uuid].idle
                or first[uuid].root_pid != second[uuid].root_pid
                or first[uuid].cpu_ticks != second[uuid].cpu_ticks
            )
            suffix = " (changed during sampling)" if changed else ""
            print(f"    - {uuid}: {state.reason}{suffix}")
        if stable_idle and not shape_ok:
            print("      not selected: multiple tabs/splits; use --all-idle")
        if candidate:
            candidates.append((window, members))

    print()
    if not candidates:
        print("No trivial windows matched.")
        return 0

    if not args.close:
        print(
            f"Dry run: {len(candidates)} window(s) would close. "
            "Re-run with --close to close them."
        )
        return 0

    killed: Set[int] = set()
    for _window, members in candidates:
        for uuid in members:
            pid = second[uuid].root_pid
            if pid is None or pid in killed:
                continue
            try:
                os.kill(pid, signal.SIGHUP)
            except ProcessLookupError:
                print(f"Shell {pid} already exited.", file=sys.stderr)
            except PermissionError as ex:
                print(f"Could not signal shell {pid}: {ex}", file=sys.stderr)
            else:
                killed.add(pid)

    print(f"Sent SIGHUP to {len(killed)} idle shell(s).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
