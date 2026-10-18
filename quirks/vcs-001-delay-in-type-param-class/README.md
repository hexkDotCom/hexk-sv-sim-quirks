# vcs-001: A delay in a type-parameterized class is scaled by the time unit of the type argument's scope

| | |
|---|---|
| Category | timing |
| Seen on | vcs X-2025.06 |
| IEEE 1800 | 1800-2017 3.14.2 |
| Trigger code | legal |
| Test | [test.sv](test.sv) |

## What happens

A class with a type parameter, in a package with time unit 1 ps, waits `#(delay_ps)`. It is
specialized with a class declared in a module with time unit 1 ns. A delay of 30000 must take
30 ns (the unit of the scope where the delay is written). VCS X-2025.06 scales it by the unit
of the scope that declares the type argument and waits 1000 times longer. `$time` in the same
class reads correctly; writing `#(delay_ps * 1ps)` or moving the delay into a local task does
not help.

## Workaround

Delay through a static task of a class without a type parameter, declared in the package with
the intended time unit.

## Results

| Tool | Trigger | Workaround |
|---|---|---|
| verilator 5.046 | ok | ok |
| questa 2024.1 | ok | ok |
| vcs X-2025.06 | differs | ok |
| slang 12.0.0 | ok | ok |
| verible v0.0-4296-g0f262651 | ok | - |

Run it: `python3 runner/sqrun.py --quirk vcs-001`
