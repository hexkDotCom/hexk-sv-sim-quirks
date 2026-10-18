# verilator-010: A virtual interface cannot be assigned null

| | |
|---|---|
| Category | interfaces |
| Seen on | verilator 5.046 |
| IEEE 1800 | 1800-2017 25.9 |
| Trigger code | legal |
| Test | [test.sv](test.sv) |

## What happens

`vif = null;` for a virtual interface variable. Verilator 5.046 rejects the assignment;
comparing a virtual interface with `null` works.

## Workaround

Keep a separate flag that says whether the handle is valid.

## Results

| Tool | Trigger | Workaround |
|---|---|---|
| verilator 5.046 | rejects | ok |
| questa 2024.1 | ok | ok |
| vcs X-2025.06 | ok | ok |
| slang 12.0.0 | ok | ok |
| verible v0.0-4296-g0f262651 | ok | - |

Run it: `python3 runner/sqrun.py --quirk verilator-010`
