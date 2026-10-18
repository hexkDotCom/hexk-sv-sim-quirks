# verilator-005: A soft constraint is not overridden by randomize() with

| | |
|---|---|
| Category | randomization |
| Seen on | verilator 5.046 |
| IEEE 1800 | 1800-2017 18.5.14 |
| Trigger code | legal |
| Test | [test.sv](test.sv) |

## What happens

A class has `constraint c {soft size == 5;}`. `randomize() with {size == 7;}` must succeed
with size 7: a soft constraint gives way to a hard one that contradicts it. Verilator 5.046
treats the soft constraint as hard, and the randomization fails.

## Workaround

Switch the block with the soft constraint off with `constraint_mode(0)` before the
randomization that overrides it, or assign the member and switch its randomization off.

## Results

| Tool | Trigger | Workaround |
|---|---|---|
| verilator 5.046 | differs | ok |
| questa 2024.1 | ok | ok |
| vcs X-2025.06 | ok | ok |
| slang 12.0.0 | ok | ok |
| verible v0.0-4296-g0f262651 | ok | - |

Run it: `python3 runner/sqrun.py --quirk verilator-005`
