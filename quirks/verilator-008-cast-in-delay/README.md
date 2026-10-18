# verilator-008: A cast inside a delay expression is an internal error

| | |
|---|---|
| Category | timing |
| Seen on | verilator 5.046 |
| IEEE 1800 | 1800-2017 9.4.1 |
| Trigger code | legal |
| Test | [test.sv](test.sv) |

## What happens

`#(longint'(steps) * 1ns);` stops Verilator 5.046 with an internal error ("Unexpected Call").

## Workaround

Compute the delay into a variable first and write `#(amount * 1ns)`.

## Results

| Tool | Trigger | Workaround |
|---|---|---|
| verilator 5.046 | crash | ok |
| questa 2024.1 | ok | ok |
| vcs X-2025.06 | ok | ok |
| slang 12.0.0 | ok | ok |
| verible v0.0-4296-g0f262651 | ok | - |

Run it: `python3 runner/sqrun.py --quirk verilator-008`
