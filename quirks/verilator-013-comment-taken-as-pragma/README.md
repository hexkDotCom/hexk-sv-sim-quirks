# verilator-013: A comment that begins with the tool's name is read as a directive

| | |
|---|---|
| Category | preprocess |
| Seen on | verilator 5.046 |
| IEEE 1800 | 1800-2017 5.4 |
| Trigger code | legal |
| Test | [test.sv](test.sv) |

## What happens

A plain comment such as `// Verilator users: ...` is read as a Verilator directive and
rejected as unknown (`%Error-BADVLTPRAGMA`). The standard ignores the text of comments. This is
how Verilator's own directives work, so it is documented behaviour, but it surprises people
who write prose about the tool in their sources.

## Workaround

Start such a comment with another word.

## Results

| Tool | Trigger | Workaround |
|---|---|---|
| verilator 5.046 | rejects | ok |
| questa 2024.1 | ok | ok |
| vcs X-2025.06 | ok | ok |
| slang 12.0.0 | ok | ok |
| verible v0.0-4296-g0f262651 | ok | - |

Run it: `python3 runner/sqrun.py --quirk verilator-013`
