# verilator-009: type() of an unsized literal is an internal error

| | |
|---|---|
| Category | types |
| Seen on | verilator 5.046 |
| IEEE 1800 | 1800-2017 6.23 |
| Trigger code | legal |
| Test | [test.sv](test.sv) |

## What happens

`var type(5) a;` declares a 32-bit signed variable (an unsized decimal literal is a 32-bit
signed integer). Verilator 5.046 stops with an internal error in its width pass.

## Workaround

Give the literal a size (`32'sd5`) or name the type directly.

## Results

| Tool | Trigger | Workaround |
|---|---|---|
| verilator 5.046 | crash | ok |
| questa 2024.1 | ok | ok |
| vcs X-2025.06 | ok | ok |
| slang 12.0.0 | ok | ok |
| verible v0.0-4296-g0f262651 | ok | - |

Run it: `python3 runner/sqrun.py --quirk verilator-009`
