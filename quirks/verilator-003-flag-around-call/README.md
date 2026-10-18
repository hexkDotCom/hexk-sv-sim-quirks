# verilator-003: A member set before a call and cleared after it reads 0 inside the call

| | |
|---|---|
| Category | classes |
| Seen on | verilator 5.046 |
| IEEE 1800 | - |
| Trigger code | legal |
| Test | [test.sv](test.sv) |

## What happens

A method sets a member bit to 1, calls a package function that reaches a virtual method of
the same object, and sets the bit back to 0. Inside the call the bit must read 1. Verilator
5.046 drops the first write, so the code reached through the call reads 0.

## Workaround

Do not guard a call with a set/clear member flag. A counter incremented before the call and
decremented after it is read correctly.

## Results

| Tool | Trigger | Workaround |
|---|---|---|
| verilator 5.046 | differs | ok |
| questa 2024.1 | ok | ok |
| vcs X-2025.06 | ok | ok |
| slang 12.0.0 | ok | ok |
| verible v0.0-4296-g0f262651 | ok | - |

Run it: `python3 runner/sqrun.py --quirk verilator-003`
