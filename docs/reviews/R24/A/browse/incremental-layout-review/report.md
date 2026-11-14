TASK125 independent source review — Unit A
SPEC: PASS for the fixed Unit A source scope; no blocking contract finding.
QUALITY: PASS; one nonblocking ownership-cleanup observation, no demonstrated public failure.
Reviewed base b4ccd47c9cf883288e9613d9c06f73f087788717 through 4f7e853f821c334318e2038d4e20ab26e72c16c8, all three commits and ten changed files.
Actual tree: 0b72a9e87a2abc1fc7e19ba031bba9554000537b; all ten on-disk changed files match the fixed commit; tracked diff is empty.
Requirements: AGENTS.md; incremental-rendering tasks Global Constraints/A123–127 and design §3/9/10/14; R004/R008; frozen public-interaction Canvas/geometry/viewport/caret contracts.
Single kernel: LayoutNode measurement, allocateMain and arrange supply geometry consumed by paint; node allocation is no longer performed by paint.
RuntimeNode.sequence remains the ordering authority; children() derives views from it. publish() stores each node result and clears its table reference; removed/closed nodes clear layout.
M1 mounted references construct fresh result tables, execute complete measurement/arrangement/painting, and never publish those results or reuse the persistent root layout.
Reference computations preserve persistent geometry, viewport offsets/ensures, overlay lifecycle, glyph policy, Canvas measured values/subscriptions and Application caret; initial binding/theme stabilization remains permitted.
Canvas transient observers retain the evaluation guard and collect reads without subscribe/unsubscribe/publication; natural, constrained and final reference measurements use the same kernel.
Root finite overflow negotiation, explicit viewport axes and mounted-subtree handling follow the existing algorithms; no additional component tree or remount path was introduced.
Exactly three public readonly Int64 stats were added; the constructor remains package-private with compatible eight positional arguments and optional trailing values.
arranges counts executed node allocation passes; no-output theme candidate preflight remains outside owned target generation. Repeated actual arrangement work is charged.
Frame constructor and transfer are the generation/copy Cell storage allocation sites; successful slot capacities are charged after allocation. Every target assignment routes through writeCell, plus initialization.
Copies charge their actual target initialization, transfer storage and target writes. Reference frames/layers charge their owning session. Encoder projection rows are outside the supplied M003 scope.
Public independent Frames/copies have no owner; returned targets/snapshots release owner. Object-scoped ownership cannot charge independent objects merely because another application is generating.
New sessions initialize counters to zero; stats snapshots are immutable values; close clears stocks and Application retains cumulative totals through sessionClosed.
Q1 observation: layer Frames retain their private owner until unreachable, and exceptional target exits bypass releaseOwner (layout.cj:490–504). Expired PaintContext blocks all access and already retained the session before this change; no new lifetime extension or post-scope charge route was established. Explicit finally-based release would improve cleanup clarity; not a blocker.
Evidence: read actual development raw outputs for fixed 7 baseline + 2 stats cases, theme/Canvas finite/control/subtree, old layout and normal bundle; independently rechecked all 17 compressed and payload hashes.
Recorded final outputs show those development cases pass and bundle succeeds with existing lint warnings/zero discovered bundle tests; initial bundle failure remains preserved. These are reused development facts, not TASK126 independent execution.
No product/test edits, author self-assessment, subordinate agents, diagnostic compile or suite reruns. No TASK127 acceptance, B/C/D, performance, full M2 or Linux completion claim.
Skills used: requesting-code-review review workflow and verification-before-completion; actual serving model/effort not independently observable.
Concrete blockers: none. Supporting verification.json and findings.json are bound by index.json.
