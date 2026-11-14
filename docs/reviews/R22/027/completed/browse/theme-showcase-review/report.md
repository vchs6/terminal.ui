TASK027 fixed-source independent review
Product: e0711b288f932fa84eb3aed169aec5d01b8f4588 → 954d7492b91c2f490dcb15d2d42190af5dbe52ae.
Corrected independent tests: 1a5812dc68001ebbcd68f87a37815110ec9e71d9; product source/core/preset bytes unchanged.
Declined to judge: independent runtime/GUI/AC027 acceptance awaits its assigned execution evidence; full M1/M2/final Linux/release are explicitly outside this gate.
Source SPEC: CHANGES REQUIRED — one Important finding, TASK027-R1.
Source QUALITY: CHANGES REQUIRED — modal dispatch incompletely applies the shared command mapping; no other blocking quality finding.
R1: examples/theme_showcase/src/commands.cj:61 handles only F9/F10 inside Preview and its owned PopupMenu.
Binding requirement: corrected tests/theme_showcase/public-api-basis.md:50 says “F-keys are global”.
Source counterexample: Classic → F5 → F2 (also F5 → Enter → F2) never calls the Dark action: src/application.cj:436 suppresses the application callback while modal is present.
Consequence: F1–F8 are unavailable in the modal domain, including theme/file operations while inspecting Preview.
Bounded fix: dispatch documented F-keys once from the existing modal handler and consume them, preserving ordinary menu/editor input, current Preview guard and owner ancestry; add independent real-key regression coverage.
Strengths: ordinary relative-dependency project, thin main, cohesive data/commands/gallery/preview/smoke responsibilities, one entity per file, public blocks/chains and no private rendering path.
Reviewed all four identity/palette sources, basic widget slots, rich/named styles, actual 80×24/40×12/16×6 weighted/clipped layout, retained controllers, and loader failure/current-file provenance; no additional blocking source finding.
ThemeInfo and latest ThemeRequest.result are pure tracked reads; modal ThemeRole delegates border/padding/shadow to canonical presets; popup ownership and close/focus restoration use the public lifecycle.
Corrected manual oracles match canonical source: High contrast footer clipping, every modal’s horizontal padding=1, Classic/High contrast ASCII without shadow, Dark/Light rounded with shadow; no output-recorded expectations or removed genuine assertions identified.
Evidence bounds: candidate-index-v2 SHA256 f2355282c404eec53b739865637b5f852895bc5c5c3635cdca9c0216f8bf01f9; independent test index SHA256 bb2c97abd49dfbe04143b545c3c9f2989623e0e46ebf62e10e82eaee9054c215.
Build-v3 raw says normal example build success; factual candidate ELF SHA256 92dd71989fe12658477dc9aceef8a62c633318f74d99bcc336aed62ce0398bb5. Original smoke/PTY failures are corrected-fixture conflicts, not a corrected-suite success claim.
Fixed-test reruns and successful bundle remain pending at seal; normal bundle-v1 failed ENOSPC after test/lint. No CJP success or actual four-GUI/AC027 pass inferred.
Read-only source review; no builds/tests/source edits/checkouts/subagents. Author reasoning/reports excluded; Superpowers code-review checklist applied.
Immutable input snapshots and output SHA256/bytes are in index.json; finding detail is in findings.json. Root routes the bounded fix before scoped re-review.
