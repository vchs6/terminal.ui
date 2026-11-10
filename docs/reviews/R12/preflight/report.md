# Reactive runtime independent builder/preflight

Final verdict: **ready / design_reviewed** for the contract and TASK-071 test-author admission at `a947857c1ba89ce088c7fe4909239e8a2a85089d`. Two Important contract gaps in `1492b0e0ef5154d2c470e94fd58d2a238702967b` are resolved by R015. No unresolved Critical/Important findings remain in this bounded review. Product TASK-072 still requires TASK-071 frozen RED; later tasks retain their recorded prerequisites. This is not implementation, compiler, test, release, or full Linux acceptance.

Review date: 2026-11-10 UTC. Product baseline: `6a7b240bfc89bb054b11306f257ebed519a26b5f`. Requested role/configuration: independent builder/preflight, Astra/high; actual serving variant/effort cannot be independently verified. Visible identity is Codex based on GPT-6. Review budget approximately ten minutes. No subagents, product edits, test edits, old-suite reruns or new language probes. Main-agent rulings were treated as proposed contract changes and checked against the final diff, not as implementation evidence.

## Evidence and applicability

Read repository AGENTS, ENGINEERING_TASK_DECOMPOSITION, BATTLE_PROTOCOL; candidate proposal/design/tasks/spec and the workflow/skill ledger; relevant construction/architecture/requirements/acceptance/task mappings; actual Component, Application, KeyEvent, exports, layout, LayoutNode and manifest. Reused the supplied independent language, supplement, names and normal CJPM macro/bundle reports. The language reports prove individual mechanisms, not the full new public API. Official formal tests must still exercise exact public signatures through normal CJPM and source-bundle consumption.

Skills: loaded `superpowers:using-superpowers`; its SUBAGENT-STOP explicitly excludes delegated workers from that workflow. Loaded `cloud-environment:cloud-environment-runtime` and inspected its environment status: running, current observations, enforced unrestricted network policy. No installs/network operations were needed. Project skill/OpenSpec mapping is retained in the change ledger; this review does not invent product-stage skill execution.

The candidate and source hashes are in `reviewed-files-sha256.json`; final contract snapshot hashes are separately recorded in `contract-sha256.txt`. Fixed commits preserve the initial and corrected contract. All review conclusions are source/contract inspection, not fabricated execution results.

## Findings and corrections

1. **PREFLIGHT-001 / Important, verified at design level.** Initial §2.1 specified public Component and macro build collection but did not decide whether the custom root was a vertical box, horizontal box, or transparent fragment. Counterexample: a custom build emits Text("A") then Text("B"); the independent test cannot determine one versus two rows, or where root padding/border applies. Existing code has explicit Text/Column/Row kinds and LayoutNode chooses aggregation by kind; no generic composition behavior supplies the missing answer. R015 now defines a real Column-semantic node, declaration-order children and ordinary layout/style behavior. This is implementable by the existing primitive path without a new business component kind.

2. **PREFLIGHT-002 / Important, verified at design level.** Initial event contract fully defined explicit headless target routing and Ctrl-C behavior but omitted how device run chooses its nonoptional UIKeyEvent.target before focus exists. The baseline device loop only has an application-level KeyEvent callback, so no prior target-selection rule can be reused. Visible(false) also forbids input targeting, including when the root is hidden. R015 now chooses visible active root for run; rejects explicit hidden target/hidden ancestor with UIException(InvalidProperty); suppresses new/node events when device root is hidden while preserving legacy noninterrupt handling and interrupt stop. It also fixes the current event path across property changes. These rules give independently assertable traces without pretending focus TASK-017 is delivered.

Minor correction also verified: R008 now counts each node paint call instead of naming a nonexistent LayoutNode.paint member; baseline painting is a free function in layout.cj. No gratuitous member-method refactor is required.

## Feasibility and boundary checks

- Public construction: existing constant factory/chain APIs remain; typed getter overloads are enumerated by existing supported parameter types, with text/visible and widthAuto/heightAuto replacement semantics. Macro generic/interface/parameter-init support, namespace imports, WeakRef and ThreadLocal have supplied language evidence. Constructor return rejection must distinguish nested function/lambda scope; this remains a formal negative/positive test obligation rather than an unproven claim of compiler inability.
- Lifecycle: delayed one-time build, remount generations, per-mount effects, child-to-parent cleanup and terminal-finally containment are mutually implementable. WeakRef is combined with session/generation validity, not treated as validity by itself. Temporary render uses the same implementation and suppresses effects; snapshots own Frame copies.
- Concurrency: state slots and subscription metadata synchronize independently of user evaluation; read/install/version recheck closes subscription races. Dedicated dirty state avoids dropping updates when posts are full. Turn cutoffs distinguish background producers from synchronous stabilization loops. Session nonce plus thread ownership allows idle same-thread sessions while refusing active cross-session entry.
- Application compatibility: the existing cjt_open/try/catch/nonthrowing-finally/cjt_close recovery boundary is explicitly retained. Interrupt bypasses the old handler. Dirty/resize scheduling retires unconditional poll rendering. Existing colorMode/colorModeAuto must still affect terminal output under the general compatibility commitment; normal affected consumer regressions must check this when integrating the dirty loop.
- Dynamic structure: a unique committed sequence plus private markers can express the slot table, including moved nodes beyond markers. Stable ListItem slots support same-key replacement without rebuilding. Single-command validation, whole-session failure cleanup and explicitly nontransactional business batches are compatible. No duplicate rendering tree or parallel list authority is required.
- File responsibilities/retirement: runtime node identity is separate from existing LayoutNode measurements; Component descriptions, Observable slots, session scheduling and ChildSequence each have one owner. Global parents+Mutex and unconditional render retire; Frame/Style/Unicode/ansies stay canonical. A+B then C is coherent because mounting, subscriptions and cleanup need one usable runtime; C can be separately observed on that completed substrate.
- Prerequisites: corrected R001 identifies TASK-008 as diff/failure handling and TASK-009 as rich text; existing diff plus D027 stop/error/restore is the admitted subset. Theme, focus/modal, complete failure matrix, rich text and M2 remain explicit downstream obligations. No full parent AC is closed by this preflight.

## DQ-01–14

| Check | Final result | Reason |
|---|---|---|
| DQ-01 | pass | Coding units are 072 and 077 L3, with WP parents; L1/L2 are not direct coding units. |
| DQ-02 | pass | A+B delivers one usable persistent reactive core; C delivers shared dynamic structure against it. Test/review/execution/acceptance have separately observable artifacts. |
| DQ-03 | pass | Shared admission card plus per-task L4 supplies equivalent required fields and fixed references; R015 closes the two missing externally visible rules. |
| DQ-04 | pass | Includes/excludes, compatibility and affected Component/Application/Layout paths are explicit; no hidden focus/overlay/theme/M2 implementation. |
| DQ-05 | pass | Construction, generations, cleanup, concurrency, binding equality, directed notification and slot-table edge cases have independent observations. R015 supplies root layout and device/hidden-event expected results. |
| DQ-06 | pass | 071→072→073→074→075, then 076/075→077→078→079→080 is acyclic. C test preparation may overlap; its RED waits for fixed A+B. Ready applies only when each recorded dependency is actually satisfied. |
| DQ-07 | pass | Partial parent coverage is explicit; 014 awaits overlay and other parent ACs retain their full conditions. No premature Linux closure. |
| DQ-08 | pass | Product versus tests versus review roles are distinct; sequential A+B/C edits avoid competing runtime ownership. |
| DQ-09 | pass | 074/079 execute integration and public/bundle consumption; 075/080 check bounded acceptance. R015 closes the run/headless event bridge gap. |
| DQ-10 | pass | Foundational language/build uncertainties have independent reports; formal exact APIs remain explicit RED/compile obligations, not falsely claimed delivered. |
| DQ-11 | pass | L4 names concrete files, assertions, fixed-source reviews, direct binary exit/raw/hash and packaging checks. |
| DQ-12 | pass | Stable requirement/task/AC references and single change task-state authority are retained; evidence plan is distinct from actual result. |
| DQ-13 | pass | Authorized execution classification is traceable to adopted contract decisions and workflow/skill ledger. This preflight closes the outstanding contract decisions before tests/product. |
| DQ-14 | pass | Canonical ownership, necessity, old-path retirement, compatibility and risks are explicit; no unsupported runtime/TOML dependency is introduced. |

Initial DQ-03/DQ-05/DQ-09 were blocked by the two findings; the narrow `1492b0e..a947857` correction was reread to resolve them. No implementation verdict is implied by their design verification.
