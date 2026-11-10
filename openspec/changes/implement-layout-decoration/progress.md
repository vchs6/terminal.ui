# SDD ledger — plan: openspec/changes/implement-layout-decoration/tasks.md

Baseline c502c9fe64422095d7a37e741d8756af3bbc9873, clean integration checkout. User continuation authorizes existing Linux goals and direct-main integration. Independent clones/roles as AGENTS13.2, no controller product/test code. Model choice: test Sol/high, implement Terra/high, code review Astra/high (local task review scaled appropriately), execution Sol/medium, acceptance Sol/high. Only fixed contracts/artifacts shared.

Skills read this turn: cloud using-superpowers/brainstorming/writing-plans; new feature shape already approved in long-running user requirements and autonomy instruction, engineering defaults announced. OpenSpec1.14.3 creates concrete change and reads schema design/tasks instructions; no new requirement behavior, skip_specs=true. Local lockedSuperpowers7.0.0/tools setup and SDK1.2.0 reused fromR8, no reinstall. Use subagent-driven-development, review, TDD and verification per stage, record role evidence as delivered. Cloud has no semantic revision, do not equate with local pin.

Preflight decision Battle D023–25: compare independent panel renderer vs commonFrame path vs only low-level primitives; choose sameFrame and declarativeAPI. Transfer stable011/012 into change, narrow obsolete prerequisite to current tested050; future layers and missing full contracts not declared completed. Bounds/rounding/defaults/clip/shadow semantics frozen. Legacy no-property visible output retained, explicit containerBG now fills allocatedbox as documented, glyph inheritance unchanged. Current plain-container overflow clips; full default scrolling remains tracked037 and not claimed. No GUI/otherOS or business ordering decisions.

Execution continues through authorized implementation in this turn; do not convert skill planning handoff into a new approval gate. Source implementation/tests remain separate agents; main only contracts/status/integration. This ledger is not a second task-status authority.

## Preflight interface scan

| tasks | producer → consumer / self-consistency | ruling |
|---|---|---|
| 054 / 011 | frozen layout consumer → implementation | tests originate from design; source untouched during RED |
| 054 / 012 | frozen decoration consumers → implementation | independent author continues after layout tests freeze; source remains unread |
| 011 / 012 | Rect, constraints, single layout tree → decoration insets/paint | sequential implementation with local review before012, no competing kernels |
| 011 / 055 / 056 | source + public API → review + execution | review and execution only consume fixed commits |
| 012 / 055 / 056 | decoration + example → whole review + PTY | existing slice checks remain; newly added example must run |
| 054 | separate test projects/runner, RED then freeze | coherent; build/direct binary preserves actual exit status |
| 011 | layout scope, no decoration implementation | coherent; Rect is shared interface, border insets deferred explicitly |
| 012 | consumes reviewed layout, adds shared Frame operations | coherent; replacement stays one render path |
| 055 | independent task and whole reviews | coherent; findings require contract and reproducer |
| 056 | independent execution without edits | coherent; valid unchanged evidence reused |
| 057 | contract/evidence/metadata integration | coherent; no full-framework claim |

Ruling: retain the checked-in OpenSpec progress file as the sole recovery ledger and link it from the skill workspace, avoiding duplicate status. Local Superpowers7 scripts use a task-basename scratch path; this plan has its own unused directory now. Independent clones satisfy already-authorized isolation; no baseline tests repeat because c502 source/deps/environment are unchanged before this slice. Read subagent-driven-development and using-git-worktrees skills; no new permission gate introduced.

Dispatched independent test author /root/layout_test_author (Sol/high) and layout implementer /root/layout_implementer (Terra/high, prepare-only until frozen test artifact). Both use fresh clones; no cross-role edits.

Ruling: layout example uses d to toggle border/shadow and q to exit, making the already-required demonstration testable; product API unaffected. Plan/configuration/link checks and strict OpenSpec all pass at8f0f0b5; this is documentation evidence only.
