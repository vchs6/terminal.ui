# TASK103 round2 independent regressions
Test-only `39ccddf89676ead9f109c45f17be68fc69a45196` (parent `198cc242c0674b6aa212d050f268fac41be82e79`); fixed product `5b08e34ded8d58b344706e8ffcf594225626f4b3`.
Only two public cases and existing B selectors were appended; original7/31/eight groups, true-out-of-extent guard and f57/692/758 assertions are unchanged.
Ordinary SDK1.2 `cjpm build`: exit0. Each new selector then ran in a separate process; no old matrix rerun.
I05-stable: initial `abcd` and final content13/4×1 controls passed; actual `InvalidProperty`, offset0, frame `abcd`; assertion exit1.
B.3 requires pending layout before ensure; literal target12 inside extent13 should yield offset9/frame `jklm`. Those subsequent checks were not reached after the first failure.
I08: initial `C/C/T/blank/blank` and full-M1 `C/C/C/T/blank` controls passed; cached frame remained `C/C/T/blank/blank`; assertion exit1.
A.2 measure dependencies and R004 same-input M1 define the literal I08 golden; no expected grid generator or private API was used.
Source/product/config input hashes match their pre-execution values; the fixed product tracked runtime files were unchanged.
`raw/commands.json` records exact commands/cwd/UTC/exits; `raw/prehash.json` binds inputs.
`raw/{build,I05-stable,I08}.{stdout,stderr,exit}` are original outputs; `raw/original/` preserves the supplied observation probe/exit0 output without relabeling it assertion RED.
`raw/manifest.json` SHA256 `3550a63acbf9f7e6fc61f854d5fc4fde72e43c704e04301fb800b3e95a4ebf2d` records output/source/binary hashes and executed/unreached boundaries.
No product, contract, main, old assertion or B acceptance status changed.
