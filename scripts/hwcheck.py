#!/usr/bin/env python3
"""Read-only Linux hardware/storage health snapshot (Python 3.10+).

Targets Ubuntu 22.04, 24.04, and later Linux systems with the same tools.
No dependencies on third-party Python packages.
"""

from __future__ import annotations

import argparse
from collections import defaultdict
from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import platform
import re
import shutil
import subprocess
import sys
from typing import Any

VERSION = "0.1.0"
SECTIONS = ("disks", "md", "btrfs", "zfs", "ecc", "thermal", "logs")
STATUS_RANK = {"INFO": 0, "OK": 0, "UNKNOWN": 1, "WARN": 2, "FAIL": 3}


@dataclass
class Result:
    stdout: str = ""
    stderr: str = ""
    code: int | None = None
    error: str = ""

    @property
    def succeeded(self) -> bool:
        return self.code == 0 and not self.error


@dataclass
class Observation:
    section: str
    status: str
    target: str
    message: str
    metrics: dict[str, Any] = field(default_factory=dict)
    evidence: list[str] = field(default_factory=list)


@dataclass
class Report:
    observations: list[Observation] = field(default_factory=list)

    def add(self, section: str, status: str, target: str, message: str,
            metrics: dict[str, Any] | None = None,
            evidence: list[str] | None = None) -> None:
        assert section in SECTIONS and status in STATUS_RANK
        self.observations.append(Observation(section, status, target, message,
                                             metrics or {}, evidence or []))

    @property
    def overall(self) -> str:
        statuses = {o.status for o in self.observations}
        if "FAIL" in statuses:
            return "FAIL"
        if "WARN" in statuses:
            return "WARN"
        if "UNKNOWN" in statuses or not self.observations:
            return "PARTIAL"
        return "PASS"

    @property
    def exit_code(self) -> int:
        return {"PASS": 0, "WARN": 1, "FAIL": 2, "PARTIAL": 3}[self.overall]


def command(argv: list[str], timeout: float) -> Result:
    """Run a bounded, shell-free, locale-stable command."""
    if not shutil.which(argv[0]):
        return Result(error=f"{argv[0]} is not installed or is not in PATH")
    env = os.environ.copy()
    env["LC_ALL"] = "C"
    try:
        done = subprocess.run(argv, capture_output=True, text=True,
                              errors="replace", timeout=timeout, env=env,
                              check=False)
        return Result(done.stdout, done.stderr, done.returncode)
    except subprocess.TimeoutExpired:
        return Result(error=f"timed out after {timeout:g} seconds")
    except OSError as ex:
        return Result(error=f"{type(ex).__name__}: {ex}")


def diagnostic(result: Result) -> str:
    if result.error:
        return result.error
    msg = (result.stderr or result.stdout).strip().replace("\n", " ")
    return (msg[:190] + "...") if len(msg) > 190 else (msg or f"exit {result.code}")


def parse_json_result(result: Result) -> Any | None:
    try:
        return json.loads(result.stdout)
    except (TypeError, ValueError):
        return None


def as_int(value: Any) -> int | None:
    if isinstance(value, bool):
        return None
    if isinstance(value, int):
        return value
    if isinstance(value, str) and re.fullmatch(r"[+-]?\d+", value.strip()):
        return int(value.strip())
    return None


def get_text(path: Path) -> str | None:
    try:
        return path.read_text(encoding="utf8").strip()
    except (OSError, UnicodeError):
        return None


def summary_status(issues: list[tuple[str, str]]) -> str:
    if any(level == "FAIL" for level, _ in issues):
        return "FAIL"
    if any(level == "WARN" for level, _ in issues):
        return "WARN"
    if any(level == "UNKNOWN" for level, _ in issues):
        return "UNKNOWN"
    return "OK"


def smart_assessment(data: dict[str, Any], code: int | None) -> tuple[str, str, dict[str, Any]]:
    """Treat historical counters differently from live health failures."""
    issues: list[tuple[str, str]] = []
    metrics: dict[str, Any] = {}
    status = data.get("smart_status") or {}
    nvme = data.get("nvme_smart_health_information_log") or {}
    ata = data.get("ata_smart_attributes") or {}
    if not isinstance(status, dict):
        status = {}
    if not isinstance(nvme, dict):
        nvme = {}
    if not isinstance(ata, dict):
        ata = {}
    # ATA tables alone are not a substitute for a readable overall-health
    # result. NVMe critical_warning=0 is a valid successful health reading.
    available = (isinstance(status.get("passed"), bool) or
                 as_int(nvme.get("critical_warning")) is not None)

    if status.get("passed") is False:
        issues.append(("FAIL", "SMART overall-health assessment FAILED"))
    if code is not None:
        if code & (1 << 3):
            issues.append(("FAIL", "SMART reports disk failing"))
        if code & (1 << 4):
            issues.append(("FAIL", "ATA prefailure attribute at/below threshold"))
        if code & (1 << 5):
            issues.append(("WARN", "ATA attribute crossed threshold in the past"))
        if code & (1 << 6):
            issues.append(("WARN", "SMART error log has historical entries"))
        if code & (1 << 7):
            issues.append(("WARN", "SMART self-test log has recorded failures"))
        # smartctl's bit 2 indicates a command or SMART structure failed,
        # even when another part of the report was readable.
        if code & (1 << 2):
            issues.append(("WARN", "some SMART commands failed"))

    warning = as_int(nvme.get("critical_warning"))
    if warning is not None:
        metrics["nvme_critical_warning"] = warning
        if warning:
            issues.append(("FAIL", f"NVMe critical_warning=0x{warning:x}"))
    media = as_int(nvme.get("media_errors"))
    if media is not None:
        metrics["nvme_media_errors"] = media
        if media:
            issues.append(("WARN", f"NVMe lifetime media/data-integrity errors={media}"))
    used = as_int(nvme.get("percentage_used"))
    if used is not None:
        metrics["nvme_percentage_used"] = used
        if used >= 100:
            issues.append(("WARN", f"NVMe endurance estimate used={used}%"))
    spare = as_int(nvme.get("available_spare"))
    spare_threshold = as_int(nvme.get("available_spare_threshold"))
    if spare is not None:
        metrics["nvme_available_spare"] = spare
    if spare is not None and spare_threshold is not None and spare < spare_threshold:
        issues.append(("FAIL", f"NVMe available spare {spare}% below threshold {spare_threshold}%"))
    for key in ("num_err_log_entries", "unsafe_shutdowns"):
        val = as_int(nvme.get(key))
        if val is not None:
            metrics[f"nvme_{key}"] = val  # Informational; not independently a fault.

    ata_ids = {
        5: ("WARN", "reallocated sectors"),
        184: ("FAIL", "end-to-end errors"),
        187: ("WARN", "reported uncorrectable errors"),
        188: ("WARN", "command timeouts"),
        197: ("FAIL", "current pending sectors"),
        198: ("FAIL", "offline uncorrectable sectors"),
        199: ("WARN", "UDMA CRC errors (often cabling/link)"),
    }
    for attr in ata.get("table", []):
        if not isinstance(attr, dict):
            continue
        ident = as_int(attr.get("id"))
        if ident not in ata_ids:
            continue
        raw = attr.get("raw") or {}
        val = as_int(raw.get("value")) if isinstance(raw, dict) else None
        if val is None:
            continue
        metrics[f"ata_{ident}"] = val
        if val > 0:
            severity, name = ata_ids[ident]
            issues.append((severity, f"{name}={val} (lifetime counter)"))

    temp = data.get("temperature") or {}
    if isinstance(temp, dict):
        temp_c = as_int(temp.get("current"))
        if temp_c is not None:
            metrics["temperature_c"] = temp_c

    if not available:
        issues.append(("UNKNOWN", "SMART health data not available"))
    # Bit 0: command-line parse failure; bit 1: open failure (or standby);
    # these are not proof the hardware is broken.
    if code is not None and (code & 3):
        issues.append(("UNKNOWN", "SMART probe could not fully access the device"))

    level = summary_status(issues)
    notes = [text for _, text in issues]
    if level == "OK":
        notes.append("SMART data readable; no checked alarm conditions")
    if "temperature_c" in metrics:
        notes.append(f"{metrics['temperature_c']} C")
    if "nvme_percentage_used" in metrics and used is not None and used < 100:
        notes.append(f"{used}% endurance used")
    return level, "; ".join(notes), metrics


def discover_disks(timeout: float) -> tuple[list[dict[str, Any]], str | None]:
    result = command(["lsblk", "-d", "-J", "-b", "-o",
                      "NAME,PATH,TYPE,TRAN,ROTA,SIZE,MODEL,SERIAL"], timeout)
    data = parse_json_result(result)
    if not isinstance(data, dict) or not isinstance(data.get("blockdevices"), list):
        return [], f"lsblk discovery failed: {diagnostic(result)}"
    disks = [disk for disk in data["blockdevices"]
             if isinstance(disk, dict) and disk.get("type") == "disk"]
    return disks, None


def smart_target(text: str) -> tuple[str, str | None]:
    # Use DEVICE:TYPE (e.g. /dev/sdb:sat, /dev/sda:megaraid,0).
    if not text.startswith("/dev/"):
        raise argparse.ArgumentTypeError("target must start with /dev/")
    path, sep, typ = text.partition(":")
    if sep and not typ:
        raise argparse.ArgumentTypeError("device type cannot be empty")
    return path, typ if sep else None


def friendly_size(value: Any) -> str:
    size = as_int(value)
    if size is None or size < 0:
        return "size=?"
    for unit, scale in (("TiB", 1024**4), ("GiB", 1024**3), ("MiB", 1024**2)):
        if size >= scale:
            return f"{size / scale:.1f}{unit}"
    return f"{size}B"


def disks_check(report: Report, args: argparse.Namespace) -> None:
    disks, problem = discover_disks(args.timeout)
    if problem:
        report.add("disks", "UNKNOWN", "device discovery", problem)
        return
    by_device = {disk.get("path") or f"/dev/{disk.get('name')}": disk
                 for disk in disks}
    # A hardware RAID logical disk may expose many physical SMART targets
    # under the same /dev/sdX using different megaraid,N selectors.
    targets: dict[tuple[str, str | None], dict[str, Any]] = {
        (dev, None): disk for dev, disk in by_device.items()}
    for dev, typ in args.smart_target:
        targets.pop((dev, None), None)  # explicit target overrides autodetection
        targets[(dev, typ)] = by_device.get(dev, {})
    if not targets:
        report.add("disks", "INFO", "block devices", "no physical disk devices discovered")
        return
    if not shutil.which("smartctl"):
        for (dev, typ), disk in sorted(targets.items(), key=lambda entry: (entry[0][0], entry[0][1] or "")):
            label = f"{dev} [{typ}]" if typ else dev
            report.add("disks", "UNKNOWN", label,
                       "SMART unchecked: smartmontools (smartctl) is not installed",
                       {"model": disk.get("model"), "size_bytes": disk.get("size")})
        return

    for (dev, typ), disk in sorted(targets.items(), key=lambda entry: (entry[0][0], entry[0][1] or "")):
        label = f"{dev} [{typ}]" if typ else dev
        transport = disk.get("tran") or "?"
        rotating = disk.get("rota")
        kind = ("HDD" if rotating in (True, 1, "1") else
                "SSD/nonrotating" if rotating in (False, 0, "0") else "disk")
        identity = " ".join(x for x in (str(disk.get("model") or "").strip(),
                                       friendly_size(disk.get("size")), kind,
                                       f"transport={transport}") if x)

        def probe(dtype: str | None) -> Result:
            cmd = ["smartctl", "-j", "-a"]
            if not args.wake_drives:
                cmd += ["-n", "standby"]
            if dtype:
                cmd += ["-d", dtype]
            return command(cmd + [dev], args.timeout)

        result = probe(typ)
        data = parse_json_result(result)
        if (not isinstance(data, dict) or not any(k in data for k in
                ("smart_status", "ata_smart_attributes", "nvme_smart_health_information_log"))):
            # Most plain SATA USB bridges work with SAT passthrough.
            if transport == "usb" and typ is None and result.code is not None:
                retry = probe("sat")
                retry_data = parse_json_result(retry)
                if isinstance(retry_data, dict) and any(k in retry_data for k in
                        ("smart_status", "ata_smart_attributes", "nvme_smart_health_information_log")):
                    result, data = retry, retry_data
                    typ = "sat"

        if not isinstance(data, dict):
            report.add("disks", "UNKNOWN", label,
                       f"{identity}; SMART unavailable: {diagnostic(result)}",
                       {"model": disk.get("model"), "serial": disk.get("serial")})
            continue
        level, message, metrics = smart_assessment(data, result.code)
        if level == "UNKNOWN":
            mode = str(data.get("power_mode") or "")
            if not args.wake_drives and ("standby" in mode.lower() or
                                         "standby" in result.stdout.lower() or
                                         "standby" in result.stderr.lower()):
                message = "drive in standby; SMART skipped to avoid spin-up"
            elif result.error:
                message = f"SMART unavailable: {result.error}"
            else:
                controller_info = data.get("smartctl")
                failures = (controller_info.get("messages", [])
                            if isinstance(controller_info, dict) else [])
                if failures and isinstance(failures[0], dict):
                    message += "; " + str(failures[0].get("string", ""))[:130]
        metrics.update({"model": disk.get("model"), "serial": disk.get("serial"),
                        "size_bytes": disk.get("size"), "transport": transport,
                        "smart_device_type": typ, "smartctl_exit": result.code})
        report.add("disks", level, label, f"{identity}; {message}", metrics)


def md_check(report: Report, args: argparse.Namespace) -> None:
    md_dirs = sorted(p for p in Path("/sys/block").glob("md*/md") if p.is_dir())
    if not md_dirs:
        report.add("md", "INFO", "Linux md", "no active md RAID arrays exposed by sysfs")
    for md in md_dirs:
        dev = "/dev/" + md.parent.name
        fields = {key: get_text(md / key) for key in
                  ("level", "raid_disks", "degraded", "array_state",
                   "sync_action", "mismatch_cnt")}
        degraded = as_int(fields["degraded"])
        mismatch = as_int(fields["mismatch_cnt"])
        level = fields["level"] or "unknown-level"
        state = fields["array_state"] or "unknown"
        issues: list[tuple[str, str]] = []
        if degraded is None:
            issues.append(("UNKNOWN", "degraded count unavailable"))
        elif degraded > 0:
            issues.append(("FAIL", f"{degraded} missing/failed RAID device(s)"))
        if state in ("inactive", "clear", "suspended"):
            issues.append(("FAIL", f"array state={state}"))
        if mismatch is not None and mismatch > 0:
            issues.append(("WARN", f"last md consistency check mismatch_cnt={mismatch}"))
        sync = fields["sync_action"] or "unknown"
        base = f"{level} state={state} degraded={degraded if degraded is not None else '?'}"
        if sync != "idle":
            base += f" sync_action={sync}"
        if issues:
            base += "; " + "; ".join(desc for _, desc in issues)
        report.add("md", summary_status(issues), dev, base, fields)


def mounted_filesystems(timeout: float) -> tuple[list[dict[str, Any]], str | None]:
    result = command(["findmnt", "-J", "-l", "-t", "btrfs,zfs", "-o",
                      "TARGET,SOURCE,FSTYPE,UUID"], timeout)
    if result.code == 1 and not result.stdout.strip():
        return [], None  # findmnt returns 1 when nothing matches.
    data = parse_json_result(result)
    if not isinstance(data, dict) or not isinstance(data.get("filesystems"), list):
        return [], f"findmnt failed: {diagnostic(result)}"
    rows = [row for row in data["filesystems"] if isinstance(row, dict)]
    return rows, None


def unique_btrfs_mounts(mounts: list[dict[str, Any]]) -> list[dict[str, Any]]:
    seen: set[str] = set()
    result = []
    for mount in mounts:
        if mount.get("fstype") != "btrfs":
            continue
        source = str(mount.get("source") or "").split("[", 1)[0]
        ident = str(mount.get("uuid") or source or mount.get("target"))
        if ident not in seen:
            seen.add(ident)
            result.append(mount)
    return result


def parse_btrfs_stats(text: str) -> dict[str, dict[str, int]]:
    by_device: dict[str, dict[str, int]] = defaultdict(dict)
    pat = re.compile(r"^\[(.+?)\]\.([a-z_]+)\s+(\d+)\s*$")
    for line in text.splitlines():
        match = pat.match(line.strip())
        if match:
            by_device[match.group(1)][match.group(2)] = int(match.group(3))
    return dict(by_device)


def parse_btrfs_scrub(text: str) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key in ("Corrected", "Uncorrectable", "Unverified"):
        matches = re.findall(rf"^\s*{key}:\s*(\d+)\s*$", text, re.MULTILINE | re.IGNORECASE)
        if matches:
            result[key.lower()] = sum(map(int, matches))
    if re.search(r"no stats available|no scrub has been run|no scrub found", text, re.I):
        result["never_scrubbed"] = True
    if re.search(r"\brunning\b|\bin progress\b", text, re.I):
        result["in_progress"] = True
    return result


def btrfs_check(report: Report, args: argparse.Namespace,
                mounts: list[dict[str, Any]]) -> None:
    btrfs_mounts = unique_btrfs_mounts(mounts)
    if not btrfs_mounts:
        report.add("btrfs", "INFO", "Btrfs", "no mounted Btrfs filesystems found")
    for mount in btrfs_mounts:
        target = str(mount.get("target") or "")
        if not target:
            continue
        if not shutil.which("btrfs"):
            report.add("btrfs", "UNKNOWN", target, "btrfs-progs missing; filesystem unchecked")
            continue
        issues: list[tuple[str, str]] = []
        metrics: dict[str, Any] = {"uuid": mount.get("uuid"), "mount": target}
        stats_out = command(["btrfs", "device", "stats", target], args.timeout)
        stats = parse_btrfs_stats(stats_out.stdout)
        if stats_out.code != 0 or not stats:
            issues.append(("UNKNOWN", f"device stats unavailable: {diagnostic(stats_out)}"))
        else:
            nonzero = [f"{dev}.{key}={value}" for dev, counters in stats.items()
                       for key, value in counters.items() if value > 0]
            if nonzero:
                issues.append(("WARN", "persistent device error counters: " + ", ".join(nonzero[:8]) +
                               (f" (+{len(nonzero)-8} more)" if len(nonzero) > 8 else "")))
        metrics["device_stats"] = stats
        scrub_out = command(["btrfs", "scrub", "status", target], args.timeout)
        scrub = parse_btrfs_scrub(scrub_out.stdout + "\n" + scrub_out.stderr)
        metrics["scrub"] = scrub
        if scrub.get("uncorrectable", 0):
            issues.append(("FAIL", f"last scrub uncorrectable={scrub['uncorrectable']}"))
        elif scrub.get("corrected", 0) or scrub.get("unverified", 0):
            issues.append(("WARN", "last scrub: " + ", ".join(
                f"{k}={scrub[k]}" for k in ("corrected", "unverified") if scrub.get(k))))
        show = command(["btrfs", "filesystem", "show", target], args.timeout)
        if re.search(r"\bpath\s+missing\b|\bdevice\s+\d+\s+is\s+missing\b",
                     show.stdout + "\n" + show.stderr, re.I):
            issues.append(("FAIL", "Btrfs reports a missing device"))
        elif show.code != 0:
            issues.append(("UNKNOWN", f"filesystem show unavailable: {diagnostic(show)}"))
        if scrub_out.code != 0 and not scrub.get("never_scrubbed"):
            # Some btrfs releases emit an error code when no scrub history exists.
            if not re.search(r"no (?:stats|scrub)|not found", scrub_out.stdout + scrub_out.stderr, re.I):
                metrics["scrub_status_error"] = diagnostic(scrub_out)
        if issues:
            message = "; ".join(note for _, note in issues)
        else:
            message = "device error counters zero"
            if scrub.get("never_scrubbed"):
                message += "; no scrub history available"
            elif scrub.get("in_progress"):
                message += "; scrub in progress"
        report.add("btrfs", summary_status(issues), target, message, metrics)


def parse_zpool_status(text: str) -> dict[str, Any]:
    """Text parser works on OpenZFS 2.1 (Jammy) and 2.2 (Noble)."""
    lines = text.splitlines()
    parsed: dict[str, Any] = {"vdev_errors": [], "vdev_header_seen": False}
    header = False
    for line in lines:
        match = re.match(r"^\s*state:\s*(\S+)", line)
        if match:
            parsed["state"] = match.group(1)
        match = re.match(r"^\s*errors:\s*(.+)$", line)
        if match:
            parsed["errors"] = match.group(1).strip()
        if re.match(r"^\s*NAME\s+STATE\s+READ\s+WRITE\s+CKSUM\b", line):
            header = True
            parsed["vdev_header_seen"] = True
            continue
        if not header:
            continue
        if not line.strip():
            continue
        fields = line.split()
        if len(fields) < 5 or fields[1] not in (
                "ONLINE", "DEGRADED", "FAULTED", "UNAVAIL", "OFFLINE",
                "REMOVED", "AVAIL", "SUSPENDED"):
            if re.match(r"^\s*errors:", line):
                header = False
            continue
        nums = [as_int(field) for field in fields[2:5]]
        if all(value is not None for value in nums) and any(nums):
            parsed["vdev_errors"].append({"device": fields[0], "state": fields[1],
                                          "read": nums[0], "write": nums[1],
                                          "cksum": nums[2]})
        if fields[1] not in ("ONLINE", "AVAIL"):
            parsed.setdefault("unhealthy_vdevs", []).append(
                {"device": fields[0], "state": fields[1]})
    return parsed


def zfs_check(report: Report, args: argparse.Namespace,
              mounts: list[dict[str, Any]]) -> None:
    has_zfs_mounts = any(m.get("fstype") == "zfs" for m in mounts)
    if not shutil.which("zpool"):
        if has_zfs_mounts:
            report.add("zfs", "UNKNOWN", "ZFS", "ZFS mounted but zpool tool unavailable")
        else:
            report.add("zfs", "INFO", "ZFS", "zpool unavailable; no ZFS mounts found")
        return
    result = command(["zpool", "list", "-H", "-o", "name,health"], args.timeout)
    if result.code != 0:
        if re.search(r"no pools available", result.stderr + result.stdout, re.I):
            report.add("zfs", "INFO", "ZFS", "no imported ZFS pools")
            return
        report.add("zfs", "UNKNOWN", "ZFS pools", f"zpool list failed: {diagnostic(result)}")
        return
    for line in result.stdout.splitlines():
        fields = line.split()
        if len(fields) != 2:
            continue
        pool, health = fields
        state_result = command(["zpool", "status", "-p", "-P", pool], args.timeout)
        info = parse_zpool_status(state_result.stdout)
        issues: list[tuple[str, str]] = []
        if health != "ONLINE":
            issues.append(("FAIL", f"pool health={health}"))
        if state_result.code != 0:
            issues.append(("UNKNOWN", f"zpool status unavailable: {diagnostic(state_result)}"))
        elif not (info.get("state") and info.get("vdev_header_seen") and "errors" in info):
            issues.append(("UNKNOWN", "zpool status returned data the parser cannot fully interpret"))
        errors = info.get("errors", "")
        if errors and not re.fullmatch(r"No known data errors", errors, re.I):
            issues.append(("FAIL", f"ZFS data errors: {errors}"))
        vdevs = info["vdev_errors"]
        if vdevs:
            short = [f"{item['device']}(R={item['read']},W={item['write']},C={item['cksum']})"
                     for item in vdevs]
            issues.append(("WARN", "vdev error counters: " + ", ".join(short[:6]) +
                           (f" (+{len(short)-6} more)" if len(short) > 6 else "")))
        if info.get("unhealthy_vdevs") and health == "ONLINE":
            issues.append(("WARN", "non-online vdev(s) despite ONLINE pool"))
        message = "; ".join(note for _, note in issues) if issues else "ONLINE; no reported vdev/data errors"
        report.add("zfs", summary_status(issues), pool, message,
                   {"health": health, **info})


def ecc_check(report: Report, args: argparse.Namespace) -> None:
    controllers = sorted(Path("/sys/devices/system/edac/mc").glob("mc[0-9]*"))
    if not controllers:
        report.add("ecc", "INFO", "EDAC", "no exposed EDAC controllers; ECC not assessed")
    for ctrl in controllers:
        corrected = as_int(get_text(ctrl / "ce_count"))
        uncorrected = as_int(get_text(ctrl / "ue_count"))
        issues: list[tuple[str, str]] = []
        if uncorrected is not None and uncorrected > 0:
            issues.append(("FAIL", f"uncorrected ECC errors={uncorrected}"))
        if corrected is not None and corrected > 0:
            issues.append(("WARN", f"corrected ECC errors={corrected}"))
        if corrected is None and uncorrected is None:
            issues.append(("UNKNOWN", "ECC counters unreadable"))
        report.add("ecc", summary_status(issues), ctrl.name,
                   "; ".join(message for _, message in issues) or "reported ECC counters zero",
                   {"corrected": corrected, "uncorrected": uncorrected})


def thermal_check(report: Report, args: argparse.Namespace) -> None:
    readings: list[dict[str, Any]] = []
    for controller in sorted(Path("/sys/class/hwmon").glob("hwmon[0-9]*")):
        name = get_text(controller / "name") or controller.name
        for inp in sorted(controller.glob("temp[0-9]*_input")):
            stem = inp.name.removesuffix("_input")
            raw = as_int(get_text(inp))
            if raw is None:
                continue
            celsius = raw / 1000.0
            if not -50 <= celsius <= 200:
                continue  # Sensor may be uninitialized or disconnected.
            label = get_text(controller / (stem + "_label")) or stem
            max_c = as_int(get_text(controller / (stem + "_max")))
            crit_c = as_int(get_text(controller / (stem + "_crit")))
            max_val = max_c / 1000 if max_c is not None else None
            crit_val = crit_c / 1000 if crit_c is not None else None
            # Zero is commonly used when a limit is not implemented.
            max_val = max_val if max_val is not None and 0 < max_val <= 200 else None
            crit_val = crit_val if crit_val is not None and 0 < crit_val <= 200 else None
            readings.append({"sensor": f"{name}/{label}", "celsius": round(celsius, 1),
                             "max_c": max_val, "crit_c": crit_val})
    if not readings:
        report.add("thermal", "INFO", "hwmon sensors",
                   "no readable thermal sensors exposed; temperatures not assessed")
        return
    bad: list[dict[str, Any]] = []
    for reading in readings:
        crit = reading["crit_c"]
        maximum = reading["max_c"]
        temp = reading["celsius"]
        if crit is not None and temp >= crit:
            report.add("thermal", "FAIL", reading["sensor"],
                       f"{temp:g} C >= hardware critical limit {crit:g} C", reading)
            bad.append(reading)
        elif maximum is not None and temp >= maximum:
            report.add("thermal", "WARN", reading["sensor"],
                       f"{temp:g} C >= hardware maximum {maximum:g} C", reading)
            bad.append(reading)
    hottest = sorted(readings, key=lambda r: r["celsius"], reverse=True)[:5]
    preview = ", ".join(f"{row['sensor']}={row['celsius']:g}C" for row in hottest[:3])
    report.add("thermal", "INFO", "hwmon sensors",
               f"{len(readings)} reading(s); {len(bad)} above exposed sensor limits; "
               f"hottest: {preview}; no universal temperature threshold assumed",
               {"hottest": hottest})


# Require an error/hang event, not a generic keyword such as 'warning' or 'error'.
LOG_PATTERNS: tuple[tuple[str, str, re.Pattern[str]], ...] = (
    ("Machine check / uncorrected ECC", "FAIL", re.compile(
        r"\b(?:Machine Check Exception|mce:.*\[Hardware Error\]|EDAC[^\n]*(?:uncorrected error|\bUE\s*:\s*[1-9]))", re.I)),
    ("Filesystem corruption", "FAIL", re.compile(
        r"\b(?:BTRFS (?:error|critical)|EXT4-fs error|XFS[^\n]*corruption|ZFS[^\n]*permanent error)\b", re.I)),
    ("Block I/O failures", "WARN", re.compile(
        r"\b(?:I/O error|blk_update_request|critical medium error|medium error|blk_status=IOERR)\b", re.I)),
    ("NVMe timeouts / resets", "WARN", re.compile(
        r"\bnvme\S*[^\n]*(?:resetting controller|controller is down|I/O.*timeout|timeout.*reset|abort status)\b", re.I)),
    ("ATA / SATA link failures", "WARN", re.compile(
        r"\bata\d+(?:\.\d+)?:[^\n]*(?:failed command|hard resetting link|link is slow to respond|exception Emask|SError:)\b", re.I)),
    ("PCIe uncorrectable errors", "WARN", re.compile(
        r"(?:PCIe Bus Error:\s*severity=Uncorrected|AER:\s*Uncorrected)", re.I)),
    ("GPU hangs / resets", "WARN", re.compile(
        r"(?:NVRM:\s*Xid|amdgpu[^\n]*(?:GPU reset|ring [^\n]*timeout))", re.I)),
    ("Network adapter hangs", "WARN", re.compile(
        r"(?:Detected Hardware Unit Hang|reset adapter unexpectedly)", re.I)),
    ("Corrected ECC events", "WARN", re.compile(
        r"\bEDAC[^\n]*\b(?:corrected error|CE:\s*[1-9])", re.I)),
)


def classify_kernel_lines(text: str) -> dict[str, dict[str, Any]]:
    buckets: dict[str, dict[str, Any]] = {}
    for line in text.splitlines():
        for name, level, pattern in LOG_PATTERNS:
            if pattern.search(line):
                bucket = buckets.setdefault(name, {"status": level, "count": 0,
                                                   "samples": []})
                bucket["count"] += 1
                # First and last few samples make repeated failures visible.
                samples = bucket["samples"]
                if len(samples) < 4:
                    samples.append(line.strip()[:350])
                elif len(samples) == 4:
                    samples[-1] = line.strip()[:350]
                else:
                    samples[-1] = line.strip()[:350]
                break
    return buckets


def logs_check(report: Report, args: argparse.Namespace) -> None:
    if args.since:
        argv = ["journalctl", "-k", "--no-pager", "-o", "short-iso",
                "--since", args.since, "-n", str(args.log_lines)]
    else:
        argv = ["journalctl", "-k", "-b", "--no-pager", "-o", "short-iso",
                "-n", str(args.log_lines)]
    result = command(argv, args.timeout)
    scope = f"since {args.since!r}" if args.since else "current boot"
    source = "journalctl"
    def has_messages(output: Result) -> bool:
        return (output.code == 0 and bool(output.stdout.strip()) and
                not re.fullmatch(r"\s*-- No entries --\s*", output.stdout))

    if not has_messages(result):
        first_failure = diagnostic(result)
        if not args.since:
            fallback = command(["dmesg", "--color=never"], args.timeout)
            if has_messages(fallback):
                result, source = fallback, "dmesg"
            else:
                first_failure += f"; dmesg: {diagnostic(fallback)}"
        if not has_messages(result):
            report.add("logs", "UNKNOWN", "kernel log",
                       f"cannot read {scope} kernel messages: {first_failure}; "
                       "try sudo, or grant journal access")
            return
    buckets = classify_kernel_lines(result.stdout)
    for name, content in buckets.items():
        report.add("logs", content["status"], name,
                   f"{content['count']} matching kernel message(s), {scope} via {source}",
                   {"count": content["count"], "scope": scope, "source": source},
                   content["samples"])
    if not buckets:
        report.add("logs", "OK", "kernel log",
                   f"no configured error patterns in {len(result.stdout.splitlines())} "
                   f"available kernel log lines ({scope}, {source}); not a full log audit")


def hostname_metadata() -> dict[str, Any]:
    try:
        distro = platform.freedesktop_os_release()
    except (OSError, AttributeError):
        distro = {}
    return {"hostname": platform.node(), "kernel": platform.release(),
            "os": distro.get("PRETTY_NAME", platform.system()),
            "euid": os.geteuid(), "utc_time": datetime.now(timezone.utc).isoformat()}


def render_text(report: Report, metadata: dict[str, Any], verbose: bool) -> str:
    counts = {s: sum(o.status == s for o in report.observations)
              for s in ("FAIL", "WARN", "UNKNOWN")}
    header = (f"hwcheck {VERSION} | {metadata['hostname']} | {metadata['os']} "
              f"({metadata['kernel']})\n"
              f"RESULT: {report.overall} | FAIL={counts['FAIL']} WARN={counts['WARN']} "
              f"UNKNOWN={counts['UNKNOWN']} | euid={metadata['euid']}")
    lines = [header]
    for section in SECTIONS:
        rows = [item for item in report.observations if item.section == section]
        if not rows:
            continue
        lines.append("\n" + section.upper())
        for obs in rows:
            lines.append(f"  [{obs.status:7}] {obs.target}: {obs.message}")
            if obs.evidence:
                limit = 4 if verbose else 1
                for evidence in obs.evidence[:limit]:
                    lines.append("             example: " + evidence)
            if verbose and obs.metrics:
                lines.append("             metrics: " + json.dumps(obs.metrics,
                                                               ensure_ascii=True, sort_keys=True))
    lines.append("\nExit codes: 0=PASS 1=WARN 2=FAIL 3=PARTIAL (coverage unavailable)")
    return "\n".join(lines)


def positive_float(text: str) -> float:
    try:
        value = float(text)
    except ValueError as ex:
        raise argparse.ArgumentTypeError(str(ex)) from ex
    if not 0 < value <= 3600:
        raise argparse.ArgumentTypeError("must be >0 and <=3600 seconds")
    return value


def positive_int(text: str) -> int:
    try:
        value = int(text)
    except ValueError as ex:
        raise argparse.ArgumentTypeError(str(ex)) from ex
    if not 0 < value <= 100000:
        raise argparse.ArgumentTypeError("must be between 1 and 100000")
    return value


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Read-only Linux disk, RAID, filesystem and kernel hardware checks.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("--only", metavar="SECTIONS",
                        help="comma-separated selection: " + ",".join(SECTIONS))
    parser.add_argument("--since", metavar="DATE",
                        help="journalctl --since expression, including previous boots; "
                             "default uses the current boot")
    parser.add_argument("--timeout", type=positive_float, default=20.0,
                        help="per-command timeout in seconds")
    parser.add_argument("--log-lines", type=positive_int, default=20000,
                        help="maximum kernel journal lines to inspect")
    parser.add_argument("--wake-drives", action="store_true",
                        help="allow SMART probes to wake standby disks (default: -n standby)")
    parser.add_argument("--smart-target", type=smart_target, action="append", default=[],
                        metavar="DEVICE[:TYPE]",
                        help="extra/overridden SMART target, e.g. /dev/sda:megaraid,0")
    parser.add_argument("--json", action="store_true", help="emit machine-readable JSON")
    parser.add_argument("--verbose", action="store_true", help="include evidence and metrics")
    parser.add_argument("--version", action="version", version=VERSION)
    args = parser.parse_args(argv)
    selected = set(SECTIONS)
    if args.only:
        selected = set(s.strip() for s in args.only.split(",") if s.strip())
        invalid = sorted(selected - set(SECTIONS))
        if invalid or not selected:
            parser.error("--only must contain sections from: " + ",".join(SECTIONS))
    report = Report()
    mounts: list[dict[str, Any]] = []
    if "btrfs" in selected or "zfs" in selected:
        mounts, error = mounted_filesystems(args.timeout)
        if error:
            for section in ("btrfs", "zfs"):
                if section in selected:
                    report.add(section, "UNKNOWN", "mount discovery", error)
    if "disks" in selected:
        disks_check(report, args)
    if "md" in selected:
        md_check(report, args)
    if "btrfs" in selected:
        btrfs_check(report, args, mounts)
    if "zfs" in selected:
        zfs_check(report, args, mounts)
    if "ecc" in selected:
        ecc_check(report, args)
    if "thermal" in selected:
        thermal_check(report, args)
    if "logs" in selected:
        logs_check(report, args)

    metadata = hostname_metadata()
    if args.json:
        payload = {"schema": 1, "version": VERSION, "system": metadata,
                   "overall": report.overall, "exit_code": report.exit_code,
                   "observations": [asdict(item) for item in report.observations]}
        print(json.dumps(payload, indent=2, sort_keys=True))
    else:
        print(render_text(report, metadata, args.verbose))
    return report.exit_code


if __name__ == "__main__":
    sys.exit(main())
