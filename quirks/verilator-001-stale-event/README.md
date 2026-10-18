# verilator-001: A class event triggered while nobody waits satisfies a later @(e)

| | |
|---|---|
| Category | events |
| Seen on | verilator 5.046 |
| IEEE 1800 | 1800-2017 9.4.2, 15.5 |
| Trigger code | legal |
| Test | [test.sv](test.sv) |

## What happens

An event that is a member of a class is triggered while no process waits on it. 10 ns later a
task of the class waits with `@(e)`. The wait must block until the next trigger: an event is
triggered only in the time step of the `->`. Verilator 5.046 keeps the event triggered and the
later `@(e)` returns at once.

## Workaround

Count notifications instead of triggering an event: the notifier increments a counter, the
waiter remembers the value and blocks on `wait (count != seen)`. This form also cannot miss a
notification made between the start of two fork branches.

## Results

| Tool | Trigger | Workaround |
|---|---|---|
| verilator 5.046 | differs | ok |
| questa 2024.1 | ok | ok |
| vcs X-2025.06 | ok | ok |
| slang 12.0.0 | ok | ok |
| verible v0.0-4296-g0f262651 | ok | - |

Run it: `python3 runner/sqrun.py --quirk verilator-001`
