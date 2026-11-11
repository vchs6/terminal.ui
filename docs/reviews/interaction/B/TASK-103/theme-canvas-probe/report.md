# Limited public Theme/Canvas integration probe

**REPRODUCED_T008_INTEGRATION_COUNTEREXAMPLE** on accepted f8a028b39daf8a341576f304335d262544b9cca5. No formal B test, product or contract was changed; no author/other-role contact or subagent. Only the three requested minimal public cases ran. Internal root cause was not inspected or inferred.

Ordinary CJPM build0; same binary, three separate direct observational processes exit0. Exit0 means the observer recorded the outcome, not that the bad product behavior passed. All use identical themes/tree: root Row contains Canvas(measure None→Size(1,0), bounded→constrain(Size(Max,0))) and a weight1 inner Row with two grow-styled Text nodes. Old grow weight/min-width are0; candidate values are1/Max. Text business value is a.

| Case | Actual result |
| --- | --- |
| Finite4×0 positive | Applied1, no error; Candidate/1/1, post and both refs true; next snapshot succeeds |
| Max×0 control without Canvas export | Failed InvalidCandidate, no error; Old/0/0, post and both refs true; next snapshot succeeds |
| Max×0 root snapshot → mounted Canvas render(Max,0) → same candidate | Applied1, then `minimum sum overflow`; Candidate/1/1, post/rootRef/canvasRef false; state a, mounts1 |

Thus mounted Canvas export changes the observed candidate-preflight/root-layout outcome. The public result publishes Applied before a predictable layout overflow stops the session, whereas the otherwise identical control rejects and preserves it. T008 requires pre-commit rejection and old Theme/session retention for predictable effective-layout failures. No user measure/draw/getter in this probe deliberately throws; draw is empty and the measure returns the specified constrained finite values. No device output, giant Frame allocation or renderer-derived expected data was used: all Frames have height0.

Exact commands/UTC/exits and original stdout/stderr are in raw/commands.json and raw/{build,finite,control,subtree}.*. Source/test/config prehash, source/SDK/dependency applicability reference, binary/lock/formal and raw hashes are indexed in raw/manifest.json (SHA256 `bc3fba519cee7ae96282914ef97464f04f898b1729a33ed2b048d0d960df5bae`). The yield only gives the loader worker scheduling opportunities; completion is determined by the public result or the actual thrown layout exception. No old suite or further exploratory matrix was run.
