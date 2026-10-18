# questa-001: $time in a type-parameterized class takes the time unit of the package that specializes it

| | |
|---|---|
| Category | timing |
| Seen on | questa 2024.1 |
| IEEE 1800 | 1800-2017 3.14.2, 20.3.1 |
| Trigger code | legal |
| Test | [test.sv](test.sv) |

## What happens

A class with a type parameter is declared in a package with time unit 1 ps and returns `$time`.
A package with time unit 1 ns declares an item class and a class that extends the
parameterized class with it. At 295 ns the method must return 295000 (ps, the unit of the
scope where the method is written). Questa 2024.1 returns 295, the value in the unit of the
specializing package. A specialization written in a module reads the time correctly. `%t`
is affected the same way.

## Workaround

Read the time through a static function of a class without a type parameter, declared in the
package with the intended time unit.

## Results

| Tool | Trigger | Workaround |
|---|---|---|
| verilator 5.046 | ok | ok |
| questa 2024.1 | differs | ok |
| vcs X-2025.06 | ok | ok |
| slang 12.0.0 | ok | ok |
| verible v0.0-4296-g0f262651 | ok | - |

Run it: `python3 runner/sqrun.py --quirk questa-001`
