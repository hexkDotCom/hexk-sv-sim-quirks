# verilator-002: A forked wait on a local of an automatic module task dereferences a null pointer

| | |
|---|---|
| Category | processes |
| Seen on | verilator 5.046 |
| IEEE 1800 | 1800-2017 6.21, 9.3.2 |
| Trigger code | legal |
| Test | [test.sv](test.sv) |

## What happens

An automatic task in a module forks a branch that waits with `wait (count != seen)`, where
`seen` is a local of the task, and a second branch that times out; `join_any` and
`disable fork` follow. The simulation stops with "Null pointer dereferenced" at the line of
the `wait`, with or without the `disable fork`. Automatic variables must stay alive as long as
a forked process refers to them. The same code in a method of a class runs correctly.

## Workaround

Put the wait in a method of a class (class methods are automatic too and are not affected),
or use variables with static lifetime.

## Results

| Tool | Trigger | Workaround |
|---|---|---|
| verilator 5.046 | crash | ok |
| questa 2024.1 | ok | ok |
| vcs X-2025.06 | ok | ok |
| slang 12.0.0 | ok | ok |
| verible v0.0-4296-g0f262651 | ok | - |

Run it: `python3 runner/sqrun.py --quirk verilator-002`
