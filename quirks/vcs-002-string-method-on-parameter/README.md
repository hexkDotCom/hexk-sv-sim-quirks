# vcs-002: A string method called on a string parameter of a class is not implemented

| | |
|---|---|
| Category | strings |
| Seen on | vcs X-2025.06 |
| IEEE 1800 | 1800-2017 6.16 |
| Trigger code | legal |
| Test | [test.sv](test.sv) |

## What happens

`NAME.len()` where `NAME` is a string parameter of a class. VCS X-2025.06 rejects it
(`Error-[NYI]`, not yet implemented).

## Workaround

Copy the parameter to a string variable and call the method on the variable.

## Results

| Tool | Trigger | Workaround |
|---|---|---|
| verilator 5.046 | ok | ok |
| questa 2024.1 | ok | ok |
| vcs X-2025.06 | rejects | ok |
| slang 12.0.0 | ok | ok |
| verible v0.0-4296-g0f262651 | ok | - |

Run it: `python3 runner/sqrun.py --quirk vcs-002`
