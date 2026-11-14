TASK021 supplemental TESTONLY theme-wait review — 2026-11-14
BASE 6dbece66e2989849d87729a5da10d95b4fbb0a24 → HEAD d07a6933be8ff2429ee9799ee32043642e0dfeb4.
SPEC: passed for the bounded theme-wait correction. QUALITY: passed for the three-file test delta; no findings.
Existing public loadTheme/ThemeRequest contract permits pending results; ThemeLoader submits preset work to a worker and accepts its candidate later in the UI session.
The sealed initial executor frame shows footer Light with root/footer backgrounds and footer foreground still default. This frame alone cannot establish eventual theme success or failure.
All six F3 waits now require the requested footer label plus expected last-root-cell background, footer-tail background and footer-leading foreground within the unchanged 12-second deadline.
Light expectations match #FFFFFF/#182028; Classic requires default background/foreground. The original exact root-background assertion and selection/undo/scroll/modal/business assertions are retained.
The helper samples defined sentinel cells; it does not claim every component style has been certified. Missing theme colors cannot pass through a label-only wait or a fixed delay.
New predicate tests reject requested-label/old-colors, wrong label, missing foreground and stale sampled root background, and accept the stated Classic/Light combinations.
Recorded replay rejects the actual captured Light/default frame without modifying colors; recorded infrastructure controls pass. These are reused fixture evidence, not new application execution or proof of eventual Applied.
No sleeps, fake application state, relaxed colors, new timeout, core/example changes, or removed interaction assertions occur in this diff. No source edits, builds, reruns, subagents or author report/diagnosis were used.
Original product and PTY reviews remain byte-identical and are reused; their historical provenance limitation remains intact. Product e3016afe is outside this supplemental review.
Final test-author seal 204e0fa8d91ed8b471601312d59e4e8d9bee64bba0cff27367c7db5b70d8a0ad was explicitly confirmed by root before binding; raw/source hashes are in index.json.
Eventual actual theme application and remaining ordinary/actual-host acceptance belong to the independent executor/acceptance gates; later focus diagnosis is outside this scope.
