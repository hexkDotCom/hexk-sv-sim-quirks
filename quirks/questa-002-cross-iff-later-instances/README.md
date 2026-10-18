# questa-002: A cross with iff is counted wrong from the second covergroup instance on

| | |
|---|---|
| Category | coverage |
| Seen on | questa 2024.1 |
| IEEE 1800 | 1800-2017 19.6 |
| Trigger code | legal |
| Test | [test.sv](test.sv) |

## What happens

A per-instance covergroup has a coverpoint and a cross, both guarded by the same `iff`
condition. Each of three instances is sampled four times with the condition false, so the
cross must stay at 0 %. Questa 2024.1 reports 0 % for the first instance and 25 % for the
second and third.

## Workaround

Move the cross into a covergroup of its own and sample that covergroup only when the condition
holds, instead of guarding with `iff`.

## Results

| Tool | Trigger | Workaround |
|---|---|---|
| verilator 5.046 | n/a | - |
| questa 2024.1 | differs | ok |
| vcs X-2025.06 | ok | ok |
| slang 12.0.0 | ok | ok |
| verible v0.0-4296-g0f262651 | ok | - |

Run it: `python3 runner/sqrun.py --quirk questa-002`
