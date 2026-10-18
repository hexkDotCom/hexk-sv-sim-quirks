# vcs-004: $bits of a function call in a declaration range is rejected when the function reads an outside variable

| | |
|---|---|
| Category | types |
| Seen on | vcs X-2025.06 |
| IEEE 1800 | 1800-2017 20.6.2 |
| Trigger code | legal |
| Test | [test.sv](test.sv) |

## What happens

`logic [$bits(shifted(0))-1:0] wide;` where `shifted` is a module function that reads a module
variable. `$bits` of an expression of a fixed-size type is a constant and the call is not
evaluated, so the declaration is legal. VCS X-2025.06 treats the call as a constant function
call and rejects it (`Error-[INLD]`). `$bits` of the same call inside an expression is
accepted.

## Workaround

Take `$bits` of the return type (a typedef) instead of the call.

## Results

| Tool | Trigger | Workaround |
|---|---|---|
| verilator 5.046 | ok | ok |
| questa 2024.1 | ok | ok |
| vcs X-2025.06 | rejects | ok |
| slang 12.0.0 | ok | ok |
| verible v0.0-4296-g0f262651 | ok | - |

Run it: `python3 runner/sqrun.py --quirk vcs-004`
