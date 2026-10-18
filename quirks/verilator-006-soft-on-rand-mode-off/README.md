# verilator-006: A soft constraint on a member with rand_mode(0) is enforced as a hard one

| | |
|---|---|
| Category | randomization |
| Seen on | verilator 5.046 |
| IEEE 1800 | 1800-2017 18.5.14, 18.8 |
| Trigger code | legal |
| Test | [test.sv](test.sv) |

## What happens

A member has `soft size == 5;`, its randomization is switched off with `rand_mode(0)`, and it
is assigned 3. `randomize()` must succeed and leave it at 3: a soft constraint that cannot be
met is dropped. Verilator 5.046 enforces it, and the randomization fails.

## Workaround

Switch the block with the soft constraint off with `constraint_mode(0)` as well.

## Results

| Tool | Trigger | Workaround |
|---|---|---|
| verilator 5.046 | differs | ok |
| questa 2024.1 | ok | ok |
| vcs X-2025.06 | ok | ok |
| slang 12.0.0 | ok | ok |
| verible v0.0-4296-g0f262651 | ok | - |

Run it: `python3 runner/sqrun.py --quirk verilator-006`
