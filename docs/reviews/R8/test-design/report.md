# TASK-048 independent test delivery

Contract input: 09f3e513cd62fb16ae85633c11ee2d3e15bb7d52 (public slice design plus separate Unicode-adapter APIs).
Independent checkout: /workspace/work/first-slice-tests/repo
Branch: task048-independent-contract-tests
Only tests/test documentation changed; no product source, native sources, build hook, design, task state, or shared cache was changed. No implementation author's reasoning or self-test conclusion was read. No subagent was spawned. This is test design and RED evidence, not product execution/acceptance.

Frozen commits (apply in order):

- c96f9248946d8bd43209786880966da2553f071c — tests/native-smoke standalone external Unicode consumer.
- 3b5639b8e0efa20f788003f060c5d86bf6f51935 — Frame/style/component consumer, public-API session fixture, Node+util-linux PTY harness, execution script, and tests/README.md.

Entries after sourcing /workspace/work/validation/sdk/cangjie/envsetup.sh:

- ./tests/run-slice.sh native-smoke
- ./tests/run-slice.sh contract
- ./tests/run-slice.sh integration
- ./tests/run-slice.sh all
- node tests/integration/pty.mjs /absolute/path/to/compatible/application

Environment: Cangjie compiler/project manager 1.2.0, x86_64 Linux; Node v24.22.1; util-linux script 2.41.5; GNU stty 9.7. Existing official cache /workspace/work/validation/replay-dependencies/cache was referenced through ignored consumer-local cangjie-repo.toml files; no shared package modification.

## Actual RED

| Actual command | Exit | Evidence / interpretation |
| --- | --- | --- |
| ./tests/run-slice.sh native-smoke | 1 | red-native-smoke.log: cjtui src has no .cj, dependency cjtui unavailable |
| ./tests/run-slice.sh contract | 1 | red-contract.log: same missing product package |
| ./tests/run-slice.sh integration | 1 | red-integration-build.log: fixture cannot build missing product package |
| node tests/integration/pty.mjs | 1 | red-integration-runtime.log: real executable ENOENT; no simulated product |

No assertion or actual PTY product behavior has passed. The only product blocker at this frozen baseline is missing formal product implementation and executable. Do not classify these runs as functional pass or accepted product.

## Syntax/facility checks

- bash -n tests/run-slice.sh: exit 0.
- node --check tests/integration/pty.mjs: exit 0.
- git diff --check and staged diff check: exit 0.
- cjc built each of the three exact consumer sources against a temporary isolated signature-only cjtui stub: exit 0, logs syntax-contract.log, syntax-native-smoke.log, syntax-fixture.log.
- The stub resides only in /workspace/work/first-slice-tests/syntax-only, outside the repository. Stub binaries were never run. The stub has no correctness behavior, is not committed, and cannot substitute for actual consumers linking the product.

OpenSpec apply status/instructions were read for existing implement-linux-first-slice; TASK-048 is execution work under frozen design. TDD and verification-before-completion skills were read/applied. Main coordinator owns authoritative task-state integration. Independent test expectations are frozen; product authors must report issues through the coordinator and cannot change assertions.

Scope limits are explicit in tests/README.md: public API has no device writer fault injection, so this suite does not claim write-failure baseline coverage, Unicode official conformance, concurrency exhaustiveness, future full-framework/M2 behavior, or final product acceptance. No public API syntax contradiction was found in SDK compilation.
