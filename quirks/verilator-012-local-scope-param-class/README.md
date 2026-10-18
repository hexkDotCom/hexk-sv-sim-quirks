# verilator-012: local:: in randomize() with on a specialized parameterized class is rejected

| | |
|---|---|
| Category | randomization |
| Seen on | verilator 5.046 |
| IEEE 1800 | 1800-2017 18.7.1 |
| Trigger code | legal |
| Test | [test.sv](test.sv) |

## What happens

`s.randomize() with {n == local::n;}` where `s` is a handle of a specialized parameterized
class (`seq #(16)`). Verilator 5.046 reports "Illegal 'local::' outside 'randomize() with'".
The same code with a class that has no parameters is accepted.

## Workaround

Use a name in the calling scope that cannot hit a member of the class, without `local::`.

## Results

| Tool | Trigger | Workaround |
|---|---|---|
| verilator 5.046 | rejects | ok |
| questa 2024.1 | ok | ok |
| vcs X-2025.06 | ok | ok |
| slang 12.0.0 | ok | ok |
| verible v0.0-4296-g0f262651 | ok | - |

Run it: `python3 runner/sqrun.py --quirk verilator-012`
