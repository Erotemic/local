#!/usr/bin/env python3
"""
lean_build_report.py (colored)

LLM-friendly wrapper around: lake build <file.lean>

- Parses Lean/Lake diagnostics: error/warning/info/trace.
- Default include: info + error. (Optional: warnings/trace)
- Groups nearby diagnostics (by file + line proximity).
- Prints ONE context snippet per cluster, with labeled carets [I#] / [E#].
- Colors:
  * Lean source: ub.highlight_code(..., lexer_name='lean4', backend='pygments')
  * Labels/headers: ub.color_text(...)
- Color mode: auto (tty only) / always / never

Requirements:
  pip install ubelt pygments

Note:
  Pygments provides lexer short name 'lean4' (added in pygments 2.18). :contentReference[oaicite:2]{index=2}
  ub.highlight_code supports backend='pygments'. :contentReference[oaicite:3]{index=3}
"""

from __future__ import annotations

import argparse
import os
import re
import shlex
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Optional, Tuple, List, Dict, Sequence


ANSI_RE = re.compile(r"\x1b\[[0-9;]*m")
CR_RE = re.compile(r"\r")

DIAG_RE = re.compile(r"^(?P<sev>error|warning|info|trace):(?:\s+(?P<rest>.*))?$")
LOC_RE = re.compile(r"^(?P<file>.*?):(?P<line>\d+):(?P<col>\d+):\s*(?P<msg>.*)$")

KEEP_ALWAYS_RE = re.compile(
    r"""^(
        [\s]*([✓✔✖✗]\s+)?\[\d+/\d+\]        # progress lines
      | Some\ required\ targets             # lake summary
      | -\s+                                # list items under summary
      | error:\ Lean\ exited\ with\ code     # lean exit
      | error:\ build\ failed               # lake final error
    )""",
    re.VERBOSE,
)

SEV_ORDER = {"error": 3, "warning": 2, "info": 1, "trace": 0}


def strip_ansi(s: str) -> str:
    s = CR_RE.sub("", s)
    return ANSI_RE.sub("", s)


def find_lake_root(start: Path) -> Path:
    start = start.resolve()
    for p in [start] + list(start.parents):
        if (p / "lakefile.lean").exists() or (p / "lakefile.toml").exists():
            return p
    return start.parent


# ---- optional ubelt / pygments support ----
try:
    import ubelt as ub  # type: ignore
except Exception:
    ub = None


def can_colorize() -> bool:
    if ub is None:
        return False
    # ubelt util_colors relies on pygments; avoid its warning by checking first
    try:
        return bool(ub.modname_to_modpath("pygments"))
    except Exception:
        return False


def ctext(text: str, color: Optional[str], enabled: bool) -> str:
    if not enabled or ub is None or not color:
        return text
    try:
        return ub.color_text(text, color)
    except Exception:
        return text


def hlean(text: str, enabled: bool, preferred_lexer: str = "lean4") -> str:
    """
    Highlight Lean code using Pygments via ubelt.
    Fallback to 'lean' if 'lean4' not available.
    """
    if not enabled or ub is None or not can_colorize():
        return text
    for lexer in (preferred_lexer, "lean", "lean3"):
        try:
            out = ub.highlight_code(text, lexer_name=lexer, backend="pygments")
            # ub.highlight_code may add a trailing newline depending on input; keep stable
            return out.rstrip("\n")
        except Exception:
            continue
    return text


@dataclass
class DiagBlock:
    severity: str
    header_raw: str
    file: Optional[str] = None
    line: Optional[int] = None
    col: Optional[int] = None
    head_msg: str = ""
    body_raw_lines: List[str] = None

    def __post_init__(self):
        if self.body_raw_lines is None:
            self.body_raw_lines = []


@dataclass
class Item:
    kind: str            # "info"/"error"/"warning"/"trace"
    idx: int             # per-kind index
    file: Optional[str]
    line: Optional[int]
    col: Optional[int]
    msg: str
    diag_text: str       # ansi-stripped, header+body


@dataclass
class Cluster:
    file: str
    min_line: int
    max_line: int
    items: List[Item]


def parse_blocks(lines: Iterable[str]) -> Tuple[List[DiagBlock], Dict[str, int]]:
    blocks: List[DiagBlock] = []
    counts = {"error": 0, "warning": 0, "info": 0, "trace": 0}
    current: Optional[DiagBlock] = None

    def flush():
        nonlocal current
        if current is not None:
            blocks.append(current)
            current = None

    for raw in lines:
        raw = raw.rstrip("\n")
        plain = strip_ansi(raw)

        m = DIAG_RE.match(plain)
        if m:
            flush()
            sev = m.group("sev")
            counts[sev] = counts.get(sev, 0) + 1
            rest = (m.group("rest") or "").strip()

            blk = DiagBlock(severity=sev, header_raw=raw)
            blk.body_raw_lines.append(raw)

            loc = LOC_RE.match(rest)
            if loc:
                blk.file = loc.group("file")
                blk.line = int(loc.group("line"))
                blk.col = int(loc.group("col"))
                blk.head_msg = loc.group("msg").strip()
            else:
                blk.head_msg = rest

            current = blk
            continue

        if current is not None:
            current.body_raw_lines.append(raw)

    flush()
    return blocks, counts


def resolve_source_path(root: Path, file_str: str) -> Optional[Path]:
    p = Path(file_str)
    if p.is_absolute() and p.exists():
        return p
    cand = (root / p).resolve()
    if cand.exists():
        return cand
    cand2 = (Path.cwd() / p).resolve()
    if cand2.exists():
        return cand2
    return None


def cluster_items(items: Sequence[Item], cluster_gap: int) -> List[Cluster]:
    per_file: Dict[str, List[Item]] = {}
    orphans: List[Item] = []

    for it in items:
        if it.file and it.line:
            per_file.setdefault(it.file, []).append(it)
        else:
            orphans.append(it)

    clusters: List[Cluster] = []
    for f, its in per_file.items():
        its_sorted = sorted(its, key=lambda x: (x.line or 0, x.col or 0, SEV_ORDER.get(x.kind, 0), x.idx))
        cur: Optional[Cluster] = None
        for it in its_sorted:
            if cur is None:
                cur = Cluster(file=f, min_line=it.line or 1, max_line=it.line or 1, items=[it])
                continue
            if (it.line or 1) <= cur.max_line + cluster_gap:
                cur.items.append(it)
                cur.min_line = min(cur.min_line, it.line or cur.min_line)
                cur.max_line = max(cur.max_line, it.line or cur.max_line)
            else:
                clusters.append(cur)
                cur = Cluster(file=f, min_line=it.line or 1, max_line=it.line or 1, items=[it])
        if cur is not None:
            clusters.append(cur)

    if orphans:
        clusters.append(Cluster(file="(no location)", min_line=0, max_line=0, items=orphans))

    clusters.sort(key=lambda c: (c.file, c.min_line))
    return clusters


def tag_for(it: Item) -> str:
    prefix = {"info": "I", "error": "E", "warning": "W", "trace": "T"}.get(it.kind, it.kind[:1].upper())
    return f"{prefix}{it.idx}"


def color_for_kind(kind: str) -> Optional[str]:
    # stick to commonly available names in ubelt docs :contentReference[oaicite:4]{index=4}
    return {
        "error": "red",
        "warning": "yellow",
        "info": "blue",
        "trace": "brown",
    }.get(kind, None)


def render_context_snippet(
    source_lines: List[str],
    start_line: int,
    end_line: int,
    items_by_line: Dict[int, List[Item]],
    color_enabled: bool,
    preferred_lexer: str = "lean4",
    tabsize: int = 2,
) -> str:
    end_line = min(end_line, len(source_lines))
    start_line = max(1, start_line)
    width = len(str(end_line))

    out: List[str] = []

    for ln in range(start_line, end_line + 1):
        src = source_lines[ln - 1].rstrip("\n").expandtabs(tabsize)

        line_items = items_by_line.get(ln, [])
        # highest severity on that line decides marker color
        top_kind = None
        if line_items:
            top_kind = max(line_items, key=lambda it: SEV_ORDER.get(it.kind, 0)).kind

        marker = ">" if line_items else " "
        if top_kind:
            marker = ctext(marker, color_for_kind(top_kind), color_enabled)

        prefix = f"{marker}{ln:>{width}}| "

        # highlight just the Lean code portion
        code_h = hlean(src, color_enabled, preferred_lexer=preferred_lexer)
        out.append(prefix + code_h)

        # Carets / labels (Lean columns behave like 0-based in practice; use +col, not col-1)
        for it in sorted(line_items, key=lambda x: (SEV_ORDER.get(x.kind, 0), x.col or 0, x.idx), reverse=True):
            col = it.col if it.col is not None else 0
            caret_pad = len(strip_ansi(prefix)) + max(0, col)
            caret = "^"
            lbl = f"[{tag_for(it)}]"
            caret = ctext(caret, color_for_kind(it.kind), color_enabled)
            lbl = ctext(lbl, color_for_kind(it.kind), color_enabled)
            out.append(" " * caret_pad + caret + " " + lbl)

    return "\n".join(out)


def run_lake_build(root: Path, file_arg: str, extra_lake_args: List[str]) -> Tuple[int, List[str]]:
    cmd = ["lake", "build"] + extra_lake_args + [file_arg]
    proc = subprocess.Popen(
        cmd,
        cwd=str(root),
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
        env=os.environ.copy(),
    )
    assert proc.stdout is not None
    lines: List[str] = list(proc.stdout)
    rc = proc.wait()
    return rc, lines


def main() -> int:
    ap = argparse.ArgumentParser(description="LLM-friendly lake build reporter (grouped + colored)")
    ap.add_argument("lean_file", help="Path to .lean file to build (passed to `lake build`)")
    ap.add_argument("--context", type=int, default=4, help="Lines of source context around each cluster (default: 4)")
    ap.add_argument("--cluster-gap", type=int, default=None, help="Line gap to merge into a cluster (default: 2*context)")
    ap.add_argument("--max-diag-lines", type=int, default=120, help="Max lines printed per diagnostic block")
    ap.add_argument("--keep-tail", action="store_true", help="Keep lake summary/progress lines at end")

    ap.add_argument("--no-info", action="store_true", help="Do not include info diagnostics")
    ap.add_argument("--include-warnings", action="store_true", help="Include warning diagnostics")
    ap.add_argument("--include-trace", action="store_true", help="Include trace diagnostics")

    ap.add_argument("--lexer", default="lean4", help="Pygments lexer name for source highlighting (default: lean4)")
    ap.add_argument("--tabsize", type=int, default=2, help="Tab expansion for caret alignment (default: 2)")

    ap.add_argument(
        "--color",
        choices=["auto", "always", "never"],
        default="auto",
        help="Color output mode (default: auto)",
    )

    ap.add_argument("lake_args", nargs=argparse.REMAINDER, help="Extra args for lake, after `--`")
    ns = ap.parse_args()

    extra_lake_args = ns.lake_args
    if extra_lake_args and extra_lake_args[0] == "--":
        extra_lake_args = extra_lake_args[1:]

    file_path = Path(ns.lean_file)
    root = find_lake_root(file_path)
    cluster_gap = ns.cluster_gap if ns.cluster_gap is not None else max(2, 2 * ns.context)

    # decide color
    if ns.color == "never":
        color_enabled = False
    elif ns.color == "always":
        color_enabled = True
    else:
        color_enabled = bool(getattr(os, "isatty", lambda fd: False)(1)) or (hasattr(__import__("sys"), "stdout") and __import__("sys").stdout.isatty())

    # if pygments/ubelt not available, silently disable color
    if color_enabled and (ub is None or not can_colorize()):
        color_enabled = False

    rc, out_lines = run_lake_build(root, ns.lean_file, extra_lake_args)
    blocks, counts = parse_blocks(out_lines)

    keep = {"error"}
    if not ns.no_info:
        keep.add("info")
    if ns.include_warnings:
        keep.add("warning")
    if ns.include_trace:
        keep.add("trace")

    # Build items with per-kind indices
    per_kind_counter: Dict[str, int] = {}
    items: List[Item] = []
    for b in blocks:
        if b.severity not in keep:
            continue
        per_kind_counter[b.severity] = per_kind_counter.get(b.severity, 0) + 1
        idx = per_kind_counter[b.severity]
        diag_text = "\n".join(strip_ansi(x) for x in b.body_raw_lines)
        items.append(Item(b.severity, idx, b.file, b.line, b.col, b.head_msg or "", diag_text))

    # Optional tail
    tail_lines: List[str] = []
    if ns.keep_tail:
        for raw in out_lines:
            plain = strip_ansi(raw.rstrip("\n"))
            if KEEP_ALWAYS_RE.match(plain):
                tail_lines.append(plain)

    cmd_display = " ".join(map(shlex.quote, ["lake", "build", *extra_lake_args, ns.lean_file]))

    # Header
    title = ctext("# Lean Build Report (grouped diagnostics)", "green", color_enabled)
    print(title)
    print()
    print(f"- project_root: `{root}`")
    print(f"- command: `{cmd_display}`")
    print(f"- exit_code: `{rc}`")
    print(f"- included: error={per_kind_counter.get('error',0)} info={per_kind_counter.get('info',0)} warning={per_kind_counter.get('warning',0)} trace={per_kind_counter.get('trace',0)}")
    print(f"- grouping: cluster_gap={cluster_gap}, context={ns.context}")
    if color_enabled:
        print(f"- color: enabled (lexer={ns.lexer}, backend=pygments)")
    else:
        print("- color: disabled")
    print()

    if not items:
        print("✅ No included diagnostics detected.")
        return 0 if rc == 0 else rc

    clusters = cluster_items(items, cluster_gap=cluster_gap)

    # order within cluster: info then error then warning then trace
    kind_order = {"info": 0, "error": 1, "warning": 2, "trace": 3}

    for ci, cl in enumerate(clusters, 1):
        print("---")
        hdr = f"## Cluster {ci}: {cl.file}" + (f" (lines {cl.min_line}–{cl.max_line})" if cl.file != "(no location)" else "")
        print(ctext(hdr, "green", color_enabled))
        print()

        cl.items.sort(key=lambda it: (kind_order.get(it.kind, 99), it.line or 10**9, it.col or 0, it.idx))

        if cl.file != "(no location)":
            src_path = resolve_source_path(root, cl.file)
            if src_path and src_path.exists():
                src_lines = src_path.read_text(encoding="utf-8", errors="replace").splitlines()
                start = max(1, cl.min_line - ns.context)
                end = min(len(src_lines), cl.max_line + ns.context)

                items_by_line: Dict[int, List[Item]] = {}
                for it in cl.items:
                    if it.line:
                        items_by_line.setdefault(it.line, []).append(it)

                print(ctext("### Source context", "green", color_enabled))
                print()
                snippet = render_context_snippet(
                    src_lines, start, end, items_by_line,
                    color_enabled=color_enabled,
                    preferred_lexer=ns.lexer,
                    tabsize=ns.tabsize,
                )
                print(snippet)
                print()
            else:
                print("### Source context\n\n*(could not read source file for context)*\n")

        print(ctext("### Items (info first)", "green", color_enabled))
        print()
        for it in cl.items:
            tag = ctext(f"[{tag_for(it)}]", color_for_kind(it.kind), color_enabled)
            loc = f"{it.file}:{it.line}:{it.col}" if (it.file and it.line is not None and it.col is not None) else \
                  f"{it.file}:{it.line}" if (it.file and it.line is not None) else "(no location)"
            msg = it.msg or "(no message)"
            print(f"- {tag} `{loc}` — {msg}")
        print()

        print(ctext("### Diagnostics", "green", color_enabled))
        print()
        for it in cl.items:
            tag = ctext(f"{tag_for(it)}", color_for_kind(it.kind), color_enabled)
            print(ctext(f"#### {tag}", "green", color_enabled))
            print()
            lines = it.diag_text.splitlines()
            shown = lines[: ns.max_diag_lines]
            # color the first line (header) lightly by kind
            if shown:
                shown0 = ctext(shown[0], color_for_kind(it.kind), color_enabled)
                print(shown0)
                for ln in shown[1:]:
                    print(ln)
            if len(lines) > ns.max_diag_lines:
                print(f"... (truncated; {len(lines) - ns.max_diag_lines} more lines)")
            print()

    if tail_lines:
        print("---")
        print(ctext("## Build tail", "green", color_enabled))
        print()
        for ln in tail_lines[-200:]:
            print(ln)

    return 0 if rc == 0 else rc


if __name__ == "__main__":
    raise SystemExit(main())
