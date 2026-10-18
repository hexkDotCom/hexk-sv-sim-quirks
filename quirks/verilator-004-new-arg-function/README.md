# verilator-004: An argument of new() that calls a module function arrives as 0

| | |
|---|---|
| Category | classes |
| Seen on | verilator 5.046 |
| IEEE 1800 | 1800-2017 8.7 |
| Trigger code | legal |
| Test | [test.sv](test.sv) |

## What happens

`h = new(twice(21));` where `twice` is a function declared in the module: the constructor
receives 0 instead of 42. The same call as an argument of an ordinary method passes the right
value.

## Workaround

Assign the call to a variable first and pass the variable to `new()`.

## Results

| Tool | Trigger | Workaround |
|---|---|---|
| verilator 5.046 | differs | ok |
| questa 2024.1 | ok | ok |
| vcs X-2025.06 | ok | ok |
| slang 12.0.0 | ok | ok |
| verible v0.0-4296-g0f262651 | ok | - |

Run it: `python3 runner/sqrun.py --quirk verilator-004`
