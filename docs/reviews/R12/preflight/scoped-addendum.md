# R016 scoped contract review

Verdict: **ready / design_reviewed** for the R016 addition at `7e2c055e93311cfa27cd9825c1695ae503ffec01`. No new Critical/Important finding in the requested scope. Original `report.md`, `findings.json` and original hashes remain unchanged.

Scope: only the diff from `a947857c1ba89ce088c7fe4909239e8a2a85089d` to the new revision, and its interaction with existing event, lifecycle, evaluation and UI-domain contracts. The design diff adds R016 only; the other changed file is the workflow ledger. No test-author reasoning, implementation report, new product code or test results were used. No suites or probes were run.

## Consistency checks

- R010 already specifies that an unprevented interrupt exits. R016 gives the headless dispatch completion boundary: route/default action finishes, then the safe UI boundary disposes the session before successful dispatch return. It does not permit cleanup during event propagation or partially invalidate the fixed route.
- R012 remains authoritative for cleanup: revoke tokens/subscriptions/queued work, then child-to-parent cleanup, trying all registered callbacks. R016 does not override exception preservation or native close containment. If cleanup throws, the existing failure policy applies; a normal-return assertion is conditional on no callback/cleanup failure.
- Cross-thread stop remains a request under §3.2. Cleanup at the next headless UI boundary preserves the owner-thread rule. Idle headless sessions require a subsequent public UI boundary or owner-side dispose to perform the requested teardown; no background cleanup execution or hidden event loop is promised.
- R011 and R005 remain intact: dispose is idempotent, lifecycle actions occur at safe boundaries, and an active callback cannot enter another session. R016 explicitly retains WrongUIContext for that crossing rather than silently pumping the other session.
- The final-rulings priority at §6 makes the new error-code split effective over the earlier generic drafting in §3.1/§4.3: typed attribute getter snapshot/dispatch/state writes produce ReentrantEvaluation; condition/items/key/body recursive snapshot/dispatch/NodeRef structure actions produce ReentrantStructure; direct Observable writes during evaluation still produce ReentrantEvaluation. No new error type or incompatible public signature is introduced.
- Event completion still expires its propagation mutators; preventDefault/consume continues to prevent interrupt shutdown, whereas stopPropagation alone does not. Hidden-target rejection under R015 happens before routing and remains unchanged.

The narrow clarification leaves the original DQ-01–14 design readiness conclusion intact. TASK-071/076 can freeze these explicit observations; implementation and execution acceptance still require their own fixed-source evidence. This is contract review, not a claim that runtime behavior exists or passes.

Identity disclosure: requested Astra/high; actual serving model variant/effort cannot be independently verified. Review was performed by the independently delegated preflight role without further delegation.

Evidence: `scoped-addendum-sha256.json` records the old/new commit IDs, exact design diff and new contract hashes. Commands were read-only git show/diff/rg plus writing these independent review artifacts; no repository files were edited by this role.
