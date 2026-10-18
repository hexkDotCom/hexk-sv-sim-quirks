# verilator-011: process::kill() does not end the processes the killed process forked

| | |
|---|---|
| Category | processes |
| Seen on | verilator 5.046 |
| IEEE 1800 | 1800-2017 9.7 |
| Trigger code | legal |
| Test | [test.sv](test.sv) |

## What happens

A process forks a child with `join_none` and is then killed. `kill()` ends the process and
all its subprocesses, so the child must not run on. In Verilator 5.046 the child keeps running.

## Workaround

Keep the handles of the child processes and kill them explicitly.

## Results

| Tool | Trigger | Workaround |
|---|---|---|
| verilator 5.046 | differs | ok |
| questa 2024.1 | ok | ok |
| vcs X-2025.06 | ok | ok |
| slang 12.0.0 | ok | ok |
| verible v0.0-4296-g0f262651 | ok | - |

Run it: `python3 runner/sqrun.py --quirk verilator-011`
