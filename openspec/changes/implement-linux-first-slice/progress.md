# SDD ledger — plan: openspec/changes/implement-linux-first-slice/tasks.md

Baseline 868a3f6722e89e03232785469940a0e510a12103. Main coordinates only; no product/test source authored by main. User explicitly authorized Linux implementation, direct-main integration and independent stage roles. Latest user: dependency license statement conflicts are not project blockers; usable packages suffice, keep actual attribution.

Preflight: design narrows delivery to an additive first executable slice; all broader requirements retained. Existing full TASK001–004 completion is not asserted; this slice freezes its finite API and its own admission. Docs-only historical checker R5 is inapplicable once product code exists; normal repository/OpenSpec checks remain. Native input checksums and adapter-owned FFI reuse R7. No product source baseline, no backwards migration. Five role isolation required, actor self-tests not acceptance. No material question needs user choice; defaults are documented engineering decisions.

Ruling: execute the already authorized implementation continuously — user has asked for actual code after repeated planning, so skill-level stop-after-plan prompts do not withdraw that authorization. The design does not change the agreed product goals. Cost if a slice detail is wrong: reversible API/test adjustment before release.

Skill sources: OpenSpec1.14.3/local propose/apply; Superpowers using-superpowers, brainstorming, writing-plans, subagent-driven-development, using-git-worktrees read through cloud provider this turn. Reuse installed local7.0.0/tool lock and R7 setup; original design direction already approved, no repeated brainstorming approval. Cloud skills do not provide version SHA; do not equate with local copy. Isolated clones satisfy user role isolation; main checkout remains integration owner, direct main push already authorized. Technical users receive code, not another planning-only completion.

Preflight conflict scan: dependencies license gate superseded by latest user; main/global plan completed-doc-state is historical only; implementation goes in new concrete change; original source include rules must include new native/build entrypoints. Unicode algorithms remain external; no application callback background threading yet promised. No new OS backend or GUI assumptions.

Progress: plan/API frozen for first slice; next independent test author, then sequential implementation, review, execution and acceptance. Record exact role commits below as they arrive.
