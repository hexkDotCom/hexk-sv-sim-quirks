# diff-001: An override of a virtual method with other argument names is accepted

| | |
|---|---|
| Category | classes |
| Seen on | verilator 5.046, vcs X-2025.06 |
| IEEE 1800 | 1800-2017 8.20 |
| Trigger code | illegal |
| Test | [test.sv](test.sv) |

## What happens

An override of a virtual method must keep the argument names of the prototype. Code that
renames an argument compiles on some tools and fails on others, so it breaks when a project
moves between them. Questa 2024.1 (`vlog-2911`) and slang reject it; Verilator 5.046 and
VCS X-2025.06 accept it.

## Workaround

Keep the argument names of the base method in every override.

## Results

| Tool | Trigger | Workaround |
|---|---|---|
| verilator 5.046 | accepts | ok |
| questa 2024.1 | ok | ok |
| vcs X-2025.06 | accepts | ok |
| slang 12.0.0 | ok | ok |
| verible v0.0-4296-g0f262651 | n/a | - |

Run it: `python3 runner/sqrun.py --quirk diff-001`
