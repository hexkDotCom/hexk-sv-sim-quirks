# verilator-007: No enum methods for an enum wider than 64 bits

| | |
|---|---|
| Category | types |
| Seen on | verilator 5.046 |
| IEEE 1800 | 1800-2017 6.19.5 |
| Trigger code | legal |
| Test | [test.sv](test.sv) |

## What happens

`name()`, `next()` and `prev()` on a variable of an enum whose base type is wider than 64
bits. Verilator 5.046 rejects them (`%Error-UNSUPPORTED`).

## Workaround

Keep enums at 64 bits or less, or turn values into names with a `case` statement.

## Results

| Tool | Trigger | Workaround |
|---|---|---|
| verilator 5.046 | rejects | ok |
| questa 2024.1 | ok | ok |
| vcs X-2025.06 | ok | ok |
| slang 12.0.0 | ok | ok |
| verible v0.0-4296-g0f262651 | ok | - |

Run it: `python3 runner/sqrun.py --quirk verilator-007`
