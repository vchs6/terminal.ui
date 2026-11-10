# Ordinary example capture plan

Spec: openspec/changes/implement-color-style-output/design.md D031–D033.
Coordinator approved the minimal design in-thread. Execution stays in this independent test clone; no delegation, product edits, generated screenshots, or fake application.

Goal: collect actual examples/colors c/t/q and resize PNG/raw/termios evidence on the same xterm and XFCE/VTE hosts as the existing fixture matrix.
Architecture: retain one host-launch/recorder/metadata spine in tests/terminals/run.sh, add a scene selector and a separate positive-output observer. Default fixture interactions and assertions remain intact.
Alternatives: a copied second matrix would duplicate host logic; replacing only BIN would falsely rely on fixture ack files. Neither is used.

- [x] Write black-box tests for the positive-output observer using literal byte files: complete row accepted; incomplete row, no growth and non-CUP noise rejected; delayed completion waits.
- [x] Observe RED before implementing observer.
- [x] Add wait-output.mjs RAW OFFSET [TIMEOUT_MS], requiring actual byte growth, CUP and final SGR0 plus 100ms stable output; emit byte range/hash/time metadata only.
- [x] Add scene=example entry to the same matrix: build normal examples/colors, initial/c/c/c/t/t/resize captures, q, exact nonempty inner/outer termios and successful statuses.
- [x] Preserve raw stage bytes and original PNGs plus SHA256, source/binary/harness metadata and actual grid. Mark product capability diagnostics absent in ordinary example scene.
- [x] Run observer tests, sh syntax, node syntax and git diff --check. Final real-host matrix execution belongs to the independent executor; no complete product acceptance claim from static tests.

Review focus: no fixture ack/diagnostics for example; no timeout accepted as success; no PNG rewriting; resize must alter actual window/grid; no empty restoration evidence comparing equal; normal source/build path and immutable source commit attribution.

Ledger: fixed 3385157; 18/18 tool tests, shell/Node syntax and diff checks pass. Real host execution remains independent executor scope.
