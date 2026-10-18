# vcs-003: A covergroup method call inside ?: stops the compiler

| | |
|---|---|
| Category | coverage |
| Seen on | vcs X-2025.06 |
| IEEE 1800 | 1800-2017 19.8, 11.4.11 |
| Trigger code | legal |
| Test | [test.sv](test.sv) |

## What happens

`return enabled ? cg.get_inst_coverage() : 0.0;` in a class method. VCS X-2025.06 stops with
an internal assertion failure.

## Workaround

Use an `if` statement instead of `?:`.

## Results

| Tool | Trigger | Workaround |
|---|---|---|
| verilator 5.046 | ok | ok |
| questa 2024.1 | ok | ok |
| vcs X-2025.06 | crash | ok |
| slang 12.0.0 | ok | ok |
| verible v0.0-4296-g0f262651 | ok | - |

Run it: `python3 runner/sqrun.py --quirk vcs-003`
