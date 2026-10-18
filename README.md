# hexk-sv-sim-quirks

Minimal, self-checking SystemVerilog tests for places where a simulator or a front-end tool
does not do what IEEE 1800 says, or where tools disagree. Each entry shows the trigger, says
what the standard requires, and gives a workaround that runs on every tool tested.

Who it is for: anyone whose SystemVerilog or UVM code must run on more than one tool (library
and VIP authors, teams adding Verilator to a commercial flow, teams changing simulators), and
tool developers who want reduced test cases.

## How an entry works

Each directory under [`quirks/`](quirks/) holds:

- `test.sv`: a top module `top` that prints two lines:
  - `QUIRK_RESULT: AS_EXPECTED` or `QUIRK_RESULT: DIFFERS <detail>` for the trigger code;
  - `QUIRK_WORKAROUND: OK` or `QUIRK_WORKAROUND: FAILS <detail>` for the workaround.
  With `+define+QUIRK_NO_TRIGGER` the trigger code is left out, so a tool that rejects the
  trigger still checks the workaround.
- `quirk.toml`: description, IEEE clause, workaround and the expected outcome per tool.
- `README.md`: generated from the two.

Outcomes are measured against the standard:

| Outcome | Meaning |
|---|---|
| ok | the tool did what IEEE 1800 says |
| differs | it ran and gave another result |
| rejects | it rejected legal code |
| accepts | it accepted code the standard makes illegal |
| crash | internal error or signal in the tool |
| no-result | it compiled but printed no result |
| n/a | the test does not apply to the tool |

## Running

Python 3.11 or later, and any of: Verilator, Questa (`vlog`/`vsim` on `PATH`), VCS (`vcs` on
`PATH`), slang through the `pyslang` package, Verible (`verible-verilog-syntax`).

```bash
python3 runner/sqrun.py                         # every quirk on every tool found
python3 runner/sqrun.py --tools verilator,slang # some tools
python3 runner/sqrun.py --quirk verilator-001   # one quirk
python3 runner/sqrun.py --write-results         # also write results/<tool>-<version>.json
python3 runner/sqrun.py --matrix                # regenerate the matrix below and the entry READMEs
```

The runner prints a line per quirk and marks every outcome that differs from `quirk.toml`
(`CHANGED`), which is how a new tool version shows which quirks it fixed. Logs of Verilator,
slang and Verible go to `out/`. Questa and VCS runs work in a temporary directory that is
removed afterwards; `--keep-temp` keeps it for debugging.

## Results

Every result names the exact tool version it was seen on. Only the outcomes are published;
simulator logs are not.

<!-- matrix:begin -->
| Quirk | Title | verilator 5.046 | questa 2024.1 | vcs X-2025.06 | slang 12.0.0 | verible v0.0-4296-g0f262651 |
|---|---|---|---|---|---|---|
| [diff-001](quirks/diff-001-override-argument-names/) | An override of a virtual method with other argument names is accepted | accepts | ok | accepts | ok | n/a |
| [questa-001](quirks/questa-001-time-unit-in-specialization/) | $time in a type-parameterized class takes the time unit of the package that specializes it | ok | differs | ok | ok | ok |
| [questa-002](quirks/questa-002-cross-iff-later-instances/) | A cross with iff is counted wrong from the second covergroup instance on | n/a | differs | ok | ok | ok |
| [vcs-001](quirks/vcs-001-delay-in-type-param-class/) | A delay in a type-parameterized class is scaled by the time unit of the type argument's scope | ok | ok | differs | ok | ok |
| [vcs-002](quirks/vcs-002-string-method-on-parameter/) | A string method called on a string parameter of a class is not implemented | ok | ok | rejects | ok | ok |
| [vcs-003](quirks/vcs-003-covergroup-method-in-ternary/) | A covergroup method call inside ?: stops the compiler | ok | ok | crash | ok | ok |
| [vcs-004](quirks/vcs-004-bits-of-call-in-range/) | $bits of a function call in a declaration range is rejected when the function reads an outside variable | ok | ok | rejects | ok | ok |
| [verilator-001](quirks/verilator-001-stale-event/) | A class event triggered while nobody waits satisfies a later @(e) | differs | ok | ok | ok | ok |
| [verilator-002](quirks/verilator-002-fork-wait-automatic/) | A forked wait on a local of an automatic module task dereferences a null pointer | crash | ok | ok | ok | ok |
| [verilator-003](quirks/verilator-003-flag-around-call/) | A member set before a call and cleared after it reads 0 inside the call | differs | ok | ok | ok | ok |
| [verilator-004](quirks/verilator-004-new-arg-function/) | An argument of new() that calls a module function arrives as 0 | differs | ok | ok | ok | ok |
| [verilator-005](quirks/verilator-005-soft-not-overridden/) | A soft constraint is not overridden by randomize() with | differs | ok | ok | ok | ok |
| [verilator-006](quirks/verilator-006-soft-on-rand-mode-off/) | A soft constraint on a member with rand_mode(0) is enforced as a hard one | differs | ok | ok | ok | ok |
| [verilator-007](quirks/verilator-007-enum-wider-than-64/) | No enum methods for an enum wider than 64 bits | rejects | ok | ok | ok | ok |
| [verilator-008](quirks/verilator-008-cast-in-delay/) | A cast inside a delay expression is an internal error | crash | ok | ok | ok | ok |
| [verilator-009](quirks/verilator-009-type-of-unsized-literal/) | type() of an unsized literal is an internal error | crash | ok | ok | ok | ok |
| [verilator-010](quirks/verilator-010-vif-null-assign/) | A virtual interface cannot be assigned null | rejects | ok | ok | ok | ok |
| [verilator-011](quirks/verilator-011-kill-leaves-children/) | process::kill() does not end the processes the killed process forked | differs | ok | ok | ok | ok |
| [verilator-012](quirks/verilator-012-local-scope-param-class/) | local:: in randomize() with on a specialized parameterized class is rejected | rejects | ok | ok | ok | ok |
| [verilator-013](quirks/verilator-013-comment-taken-as-pragma/) | A comment that begins with the tool's name is read as a directive | rejects | ok | ok | ok | ok |
<!-- matrix:end -->

## Licence

Apache-2.0. See [LICENSE](LICENSE).
