# TASK027.d independent deterministic execution

- Source: b5de3dd6610e90fcdcd951c5703a1429ec13b417; isolated clean source except generated ignored lock/config/target. Product version 0.0.0.
- SDK: Cangjie Compiler and CJPM 1.2.0, x86_64-unknown-linux-gnu; official registry and shared read cache are recorded in local ignored configs.
- Prebuild: selftest, preset-contract, modal-close-oracle, delivery all exit 0.
- Normal example build once: exit 0. ELF SHA256 3887d29ff5728afae5cb9ab2b5a344ed10274645fd3079ae7a2a6659e50d4940; 19139536 bytes.
- Direct smoke: exit 0; four literal preset grids at three sizes. Invalid unknown/missing-path/mixed direct exits 1/1/1; each diagnosed as expected.
- Synthetic PTY: 7/7 cases exit 0. New modal keys: 2/2 cases exit 0. All nine direct process exits 0 and exact termios before/after equal.
- PTY profile: TERM=xterm-256color, COLORTERM=truecolor with native default Auto; fixture includes synthetic DECRQM response. This is not real-host certification.
- Nine frame files losslessly gzipped, preserving original byte counts and SHA256 in frames-gzip-map.json. Raw input events, stdout, stderr, direct exits and termios remain.
- Scope limit: functional Linux synthetic PTY evidence only; separate real GUI four-theme images and AC-027/M1/M2/full-Linux acceptance remain pending.
