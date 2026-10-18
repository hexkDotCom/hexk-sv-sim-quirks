#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2026 HEXK
"""Run the quirk tests on every tool that is installed and compare with the expected outcomes.

    sqrun.py [--tools verilator,slang,...] [--quirk ID ...] [--write-results] [--matrix]

Each quirk directory holds quirk.toml (metadata and expected outcomes) and test.sv (a top
module named 'top'). A test prints two lines:

    QUIRK_RESULT: AS_EXPECTED | DIFFERS <detail>     what the tool did with the trigger code
    QUIRK_WORKAROUND: OK | FAILS <detail>            what it did with the workaround code

The trigger code is left out when QUIRK_NO_TRIGGER is defined. A tool that rejects or
crashes on the trigger is run a second time with that define, so the workaround is checked
on every tool.

Outcomes, always measured against IEEE 1800:
    ok        the tool did what the standard says
    differs   it ran and gave another result
    rejects   it rejected legal code
    accepts   it accepted code the standard makes illegal
    crash     internal error or signal in the tool
    no-result it compiled but printed no result (hang, time limit, early exit)
    n/a       the test does not apply to the tool (listed in 'skip')
"""

import argparse
import datetime
import json
import os
import platform
import re
import shutil
import subprocess
import sys
import tempfile
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
QUIRKS = ROOT / "quirks"
RESULTS = ROOT / "results"
OUT = ROOT / "out"
README = ROOT / "README.md"

# Logs of these tools are not kept (licence terms): their runs work in a temporary directory
# outside the repository, removed after the run unless --keep-temp is given.
NO_LOG_TOOLS = {"questa", "vcs"}
SIMULATORS = {"verilator", "questa", "vcs"}
ALL_TOOLS = ["verilator", "questa", "vcs", "slang", "verible"]

COMPILE_TIMEOUT_S = 300
RUN_TIMEOUT_S = 60
CRASH_RE = re.compile(
    r"internal error|segmentation fault|sigsegv|core dumped|assertion .* failed|stack trace|pt\.c:"
    r"|null pointer dereferenced",
    re.IGNORECASE)
RESULT_RE = re.compile(r"^\s*(?:#\s*)?QUIRK_RESULT:\s*(AS_EXPECTED|DIFFERS)(.*)$", re.MULTILINE)
WORKAROUND_RE = re.compile(r"^\s*(?:#\s*)?QUIRK_WORKAROUND:\s*(OK|FAILS)(.*)$", re.MULTILINE)

SLANG_SCRIPT = """
import sys
from pyslang.driver import Driver
d = Driver()
d.addStandardArgs()
line = " ".join('"' + a.replace("\\\\", "\\\\\\\\").replace('"', '\\\\"') + '"' for a in sys.argv)
ok = d.parseCommandLine(line) and d.processOptions() and d.parseAllSources()
sys.exit(0 if ok and d.runFullCompilation(False) else 1)
"""


def run(cmd, cwd, timeout):
    """Runs a command; returns (return code or None on time-out, combined output)."""
    try:
        proc = subprocess.run(cmd, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                              timeout=timeout, text=True, errors="replace")
        return proc.returncode, proc.stdout
    except subprocess.TimeoutExpired as exc:
        out = exc.stdout or ""
        if isinstance(out, bytes):
            out = out.decode(errors="replace")
        return None, out + "\n[sqrun: time limit]\n"


def first_match(pattern, text):
    m = re.search(pattern, text)
    return m.group(1) if m else "unknown"


# ---------------------------------------------------------------------------------------------
# Tool adapters: available(), version(), compile(src, defines, work) and, for simulators, sim(work).
# ---------------------------------------------------------------------------------------------

class Verilator:
    name = "verilator"

    def available(self):
        return shutil.which("verilator") is not None

    def version(self):
        return first_match(r"Verilator (\S+)", run(["verilator", "--version"], None, 30)[1])

    def compile(self, src, defines, work):
        cmd = ["verilator", "--binary", "--timing", "-j", "0", "--timescale", "1ns/1ps",
               "-Wno-fatal", "-Wno-lint", "-Wno-style", "--top-module", "top",
               "-Mdir", "obj", "-o", "sim"]
        cmd += ["+define+" + d for d in defines] + [str(src)]
        return run(cmd, work, COMPILE_TIMEOUT_S)

    def sim(self, work):
        return run([str(work / "obj" / "sim")], work, RUN_TIMEOUT_S)


class Questa:
    name = "questa"

    def available(self):
        return shutil.which("vlog") is not None and shutil.which("vsim") is not None

    def version(self):
        return first_match(r"vlog (\d[\w.]*)", run(["vlog", "-version"], None, 30)[1])

    def compile(self, src, defines, work):
        rc, out = run(["vlib", "work"], work, 60)
        if rc != 0:
            return rc, out
        cmd = ["vlog", "-sv", "-timescale", "1ns/1ps", "-work", "work"]
        cmd += ["+define+" + d for d in defines] + [str(src)]
        return run(cmd, work, COMPILE_TIMEOUT_S)

    def sim(self, work):
        return run(["vsim", "-c", "-work", "work", "top", "-do", "run -all; quit -f"], work,
                   RUN_TIMEOUT_S)


class Vcs:
    name = "vcs"

    def available(self):
        return shutil.which("vcs") is not None

    def version(self):
        return first_match(r"script version\s*:\s*(\S+)", run(["vcs", "-full64", "-ID"], None, 60)[1])

    def compile(self, src, defines, work):
        cmd = ["vcs", "-full64", "-sverilog", "-timescale=1ns/1ps", "-top", "top", "-o", "simv"]
        cmd += ["+define+" + d for d in defines] + [str(src)]
        return run(cmd, work, COMPILE_TIMEOUT_S)

    def sim(self, work):
        return run([str(work / "simv")], work, RUN_TIMEOUT_S)


class Slang:
    name = "slang"

    def available(self):
        try:
            import pyslang  # noqa: F401
            return True
        except ImportError:
            return False

    def version(self):
        import pyslang
        return getattr(pyslang, "__version__", "unknown")

    def compile(self, src, defines, work):
        cmd = [sys.executable, "-c", SLANG_SCRIPT, "--top", "top", "--timescale", "1ns/1ps"]
        cmd += ["-D" + d for d in defines] + [str(src)]
        return run(cmd, work, COMPILE_TIMEOUT_S)


class Verible:
    name = "verible"

    def available(self):
        return shutil.which("verible-verilog-syntax") is not None

    def version(self):
        return first_match(r"(v\d[\w.\-]*)", run(["verible-verilog-syntax", "--version"], None, 30)[1])

    def compile(self, src, defines, work):
        # Verible parses without preprocessing; defines do not apply.
        return run(["verible-verilog-syntax", str(src)], work, COMPILE_TIMEOUT_S)


ADAPTERS = {a.name: a for a in (Verilator(), Questa(), Vcs(), Slang(), Verible())}


# ---------------------------------------------------------------------------------------------
# Running one quirk on one tool
# ---------------------------------------------------------------------------------------------

def load_quirks(selected):
    quirks = []
    for path in sorted(QUIRKS.glob("*/quirk.toml")):
        with open(path, "rb") as f:
            q = tomllib.load(f)
        q["dir"] = path.parent
        if q.get("uvm", "none") != "none":
            sys.exit(f"sqrun: {q['id']}: UVM quirks are not supported by the runner yet")
        if not selected or q["id"] in selected:
            quirks.append(q)
    return quirks


def killed(rc):
    """A signal on POSIX (negative code) or an exception code on Windows (0xC0000000 and up)."""
    return rc is not None and (rc < 0 or rc >= 0xC0000000)


def failed_compile(rc, out):
    if rc is None:
        return "no-result"
    if killed(rc) or CRASH_RE.search(out):
        return "crash"
    return None if rc == 0 else "rejected"


def run_quirk(q, tool, outdir):
    """Returns (outcome, workaround, log text)."""
    if tool.name in q.get("skip", []):
        return "n/a", "-", ""
    src = q["dir"] / "test.sv"
    legal = q.get("trigger_legal", True)
    log = []
    work = outdir / q["id"] / tool.name / "trigger"
    shutil.rmtree(work, ignore_errors=True)
    work.mkdir(parents=True)
    rc, out = tool.compile(src, [], work)
    log.append(f"== compile with trigger (rc={rc})\n{out}")
    status = failed_compile(rc, out)
    if status == "crash":
        outcome = "crash"
    elif status == "rejected":
        outcome = "ok" if not legal else "rejects"
    elif status == "no-result":
        outcome = "no-result"
    elif not legal:
        outcome = "accepts"
    elif tool.name not in SIMULATORS or q.get("kind") == "compile":
        outcome = "ok"
    else:
        outcome = None  # decided by the simulation below

    workaround = "-"
    sim_out = None
    if tool.name in SIMULATORS and status is None:
        rc, sim_out = tool.sim(work)
        log.append(f"== simulate with trigger (rc={rc})\n{sim_out}")
        if outcome is None:
            m = RESULT_RE.search(sim_out)
            if m:
                outcome = "ok" if m.group(1) == "AS_EXPECTED" else "differs"
            elif killed(rc) or CRASH_RE.search(sim_out):
                outcome = "crash"
            else:
                outcome = "no-result"

    # The workaround: from the same run when the trigger simulated, else from a second build.
    if sim_out is None or not WORKAROUND_RE.search(sim_out):
        work = outdir / q["id"] / tool.name / "workaround"
        shutil.rmtree(work, ignore_errors=True)
        work.mkdir(parents=True)
        defines = ["QUIRK_NO_TRIGGER"]
        if tool.name == "verible":
            return outcome, "-", "\n".join(log)
        rc, out = tool.compile(src, defines, work)
        log.append(f"== compile without trigger (rc={rc})\n{out}")
        if failed_compile(rc, out) is not None:
            return outcome, "fails", "\n".join(log)
        if tool.name not in SIMULATORS:
            return outcome, "ok", "\n".join(log)
        rc, sim_out = tool.sim(work)
        log.append(f"== simulate without trigger (rc={rc})\n{sim_out}")
    m = WORKAROUND_RE.search(sim_out)
    workaround = "ok" if m and m.group(1) == "OK" else "fails"
    return outcome, workaround, "\n".join(log)


# ---------------------------------------------------------------------------------------------
# Results files and the README matrix
# ---------------------------------------------------------------------------------------------

def results_path(tool, version):
    return RESULTS / f"{tool}-{version}.json"


def latest_results():
    """Newest results file per tool (by its date field)."""
    best = {}
    for f in RESULTS.glob("*.json"):
        data = json.loads(f.read_text())
        old = best.get(data["tool"])
        if old is None or data["date"] > old["date"]:
            best[data["tool"]] = data
    return best


def matrix_text(quirks):
    best = latest_results()
    tools = [t for t in ALL_TOOLS if t in best]
    head = "| Quirk | Title | " + " | ".join(f"{t} {best[t]['version']}" for t in tools) + " |"
    rule = "|---|---|" + "---|" * len(tools)
    rows = [head, rule]
    for q in quirks:
        cells = []
        for t in tools:
            r = best[t]["results"].get(q["id"])
            if r is None:
                cells.append(" ")
            else:
                w = "" if r["workaround"] in ("ok", "-") else f" (workaround {r['workaround']})"
                cells.append(r["outcome"] + w)
        link = f"[{q['id']}](quirks/{q['dir'].name}/)"
        rows.append(f"| {link} | {q['title']} | " + " | ".join(cells) + " |")
    return "\n".join(rows)


def quirk_readme(q, best):
    """The README of one quirk, from its quirk.toml and the newest results."""
    seen = ", ".join(f"{t} {v}" for t, v in q.get("first_seen", {}).items())
    lines = [f"# {q['id']}: {q['title']}", "",
             "| | |", "|---|---|",
             f"| Category | {q.get('category', '')} |",
             f"| Seen on | {seen} |",
             f"| IEEE 1800 | {q.get('ieee') or '-'} |",
             f"| Trigger code | {'legal' if q.get('trigger_legal', True) else 'illegal'} |",
             "| Test | [test.sv](test.sv) |", "",
             "## What happens", "", q["description"].strip(), "",
             "## Workaround", "", q["workaround"].strip(), ""]
    rows = []
    for t in ALL_TOOLS:
        if t in best and q["id"] in best[t]["results"]:
            r = best[t]["results"][q["id"]]
            rows.append(f"| {t} {best[t]['version']} | {r['outcome']} | {r['workaround']} |")
    if rows:
        lines += ["## Results", "", "| Tool | Trigger | Workaround |", "|---|---|---|"] + rows + [""]
    lines += ["Run it: `python3 runner/sqrun.py --quirk " + q["id"] + "`", ""]
    return "\n".join(lines)


def write_matrix(quirks):
    best = latest_results()
    for q in quirks:
        (q["dir"] / "README.md").write_bytes(quirk_readme(q, best).encode())
    text = README.read_text()
    begin, end = "<!-- matrix:begin -->", "<!-- matrix:end -->"
    a, b = text.index(begin) + len(begin), text.index(end)
    README.write_bytes((text[:a] + "\n" + matrix_text(quirks) + "\n" + text[b:]).encode())


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--tools", default="", help="comma-separated tools (default: all installed)")
    ap.add_argument("--quirk", nargs="*", default=[], help="quirk IDs (default: all)")
    ap.add_argument("--write-results", action="store_true", help="write results/<tool>-<version>.json")
    ap.add_argument("--matrix", action="store_true", help="regenerate the README matrix and stop")
    ap.add_argument("--keep-temp", action="store_true",
                    help="keep the temporary directory of Questa and VCS runs and print its path")
    args = ap.parse_args()

    quirks = load_quirks(set(args.quirk))
    if args.matrix:
        write_matrix(quirks)
        return 0

    names = [t for t in args.tools.split(",") if t] or ALL_TOOLS
    tools = [ADAPTERS[n] for n in names if ADAPTERS[n].available()]
    if not tools:
        sys.exit("sqrun: none of the tools is installed: " + ", ".join(names))
    changed = 0
    for tool in tools:
        version = tool.version()
        print(f"== {tool.name} {version}")
        no_logs = tool.name in NO_LOG_TOOLS
        if no_logs:
            outdir = Path(tempfile.mkdtemp(prefix=f"sqrun-{tool.name}-"))
        else:
            outdir = OUT / f"{tool.name}-{version}"
        results = {}
        for q in quirks:
            outcome, workaround, log = run_quirk(q, tool, outdir)
            (outdir / q["id"]).mkdir(parents=True, exist_ok=True)
            (outdir / q["id"] / f"{tool.name}.log").write_bytes(log.encode())
            expected = q.get("expected", {}).get(tool.name)
            note = ""
            if expected is not None and expected != outcome:
                note = f"   CHANGED (expected {expected})"
                changed += 1
            if workaround == "fails":
                note += "   WORKAROUND FAILS"
                changed += 1
            print(f"   {q['id']:<34} {outcome:<10} workaround {workaround:<6}{note}")
            results[q["id"]] = {"outcome": outcome, "workaround": workaround}
        if no_logs:
            if args.keep_temp:
                print(f"   logs kept in {outdir} (not for publication)")
            else:
                shutil.rmtree(outdir, ignore_errors=True)
        if args.write_results:
            path = results_path(tool.name, version)
            path.parent.mkdir(parents=True, exist_ok=True)
            data = {"tool": tool.name, "version": version,
                    "date": datetime.datetime.now().isoformat(timespec="seconds"),
                    "os": f"{platform.system()} {platform.release()}", "results": results}
            path.write_bytes((json.dumps(data, indent=2) + "\n").encode())
            print(f"   wrote {path.relative_to(ROOT)}")
    print(f"{changed} difference(s) from the expected outcomes" if changed else "all as expected")
    return 1 if changed else 0


if __name__ == "__main__":
    sys.exit(main())
