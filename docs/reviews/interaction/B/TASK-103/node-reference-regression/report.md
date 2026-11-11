# Baseline active NodeRef regression

Test-only `7589521b6eb43661e41d2b97d6069656cce846c6`; accepted f8a028b39daf8a341576f304335d262544b9cca5; existing suites unchanged.
Final normal build0; independent controls0; fresh500-cycle guard process1.
Actual fresh RED: iteration96 requestFocus returned StaleReference instead of ReentrantEvaluation in an active Text getter.
Controls pass ordinary queries, true unmount/new-generation behavior, observed public GC0→1, active Component.reference/sameNode and NodeRef.application owner stats.
Public SDK gc/getGCCount plus bounded polling are used; no progress exits2 as environment-insufficient, never product RED.
Fresh guard process has no preceding forced GC and retains the original public if-let/reference/requestFocus shape; failure iteration is not fixed by the oracle.
Earlier64-cycle GC and combined GC+500 variants were genuinely GREEN; all original outputs/source/prehash are retained, not rebranded as RED.
Author stale-base2 iteration28/exit1 remains external historical raw only; final iteration96 is this role's independent assertion RED.
No B diagnostic hooks, product/spec/main edits, author contact, subagents, whole suite or host matrix.
Pure raw manifest: raw/manifest.json; SHA256 `10ebebfd8b96b77fe0da5951fda7317d4a28e7eebe0ccf41ab6de2e89f101f9f`.
Manifest lists original commands/exits, source/test/config prehash, current ELF and all raw hashes. No post-fix conclusion.
