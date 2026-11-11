# TASK086 independent final-source review

**Spec compliance: CHANGES_REQUIRED. Code quality: CHANGES_REQUIRED.** Three Important defects were reproduced through a small public-API consumer; one Minor documentation omission was confirmed statically. Complete this correction set before TASK087. This is a complete code-review disposition for the fixed source, not a product acceptance or package-verification PASS.

Reviewed BASE `81cd29cdf173cd02a390f3d992037de395caafaf` through HEAD `97df09638e2912cbee3313c23c4254e0a1708a5e`, all seven commits/full diff, against theme design SHA-256 `084b1623937055426e0e7c57c2cc5b9cfa2e474a787ce7e81fee3cea286c30a4`. Test overlays51986bb→dc77f8c and241a099→0185c9d are byte-identical. Source identities, fixture comparisons, probe inputs/environment and inspected raw evidence hashes are in reviewed-hashes.json. There are56 changed paths with rename detection,57 entries when the Alignment move is represented as deletion/addition.

## Findings

### T086-I01 — variables type validation runs before version/root-required checks

Location: `src/theme/theme_decoder.cj:24` (constructor), before `decode` lines29–38. Contract: design§6/line328; schema/version/root-required validation precedes remaining declaration errors.

Minimal input:

```toml
schema_version=2
name="x"
variables=1
```

Expected `UnsupportedVersion` at `schema_version`; actual public Theme.parse returns `InvalidType` at `variables`. Removing schema_version, or removing name with schema_version=1, also incorrectly returns variables InvalidType instead of the relevant MissingRequired. The version-only control correctly returns UnsupportedVersion. The constructor materializes/validates the variables table before decode can apply the root checks. Move that validation behind the required initial phase while retaining legal forward references. Source identity is preserved in these actual cases by parseTheme's outer diagnostic enrichment; the earlier suspected `<memory>` source loss was not confirmed and is not a finding.

### T086-I02 — an unknown variable-record field hides an earlier value error

Location: `src/theme/theme_decoder.cj:114` and119–132. Contract: design§6/line328 requires the first unknown/value/reference error in source declaration order after the initial root checks.

```toml
schema_version=1
name="x"
[variables.v]
type="bool"
value="bad"
extra=true
```

Expected `InvalidType` at `variables.v.value`; actual is `UnknownKey` at `variables.v.extra`. validateVariables scans unknown fields first and throws before validating type/value. Only the later error reaches schema.errors, so throwFirstError cannot recover the earlier declaration. The reversed extra-before-value control correctly reports extra. Preserve all eligible record-field failures or otherwise validate their declared order before selecting the first; do not fix this by globally prioritizing value errors over unknown fields.

### T086-I03 — a rejected style setter partially detaches uniform padding binding

Location: `src/component.cj:87` and95; mutation at37–46 occurs before removeBinding/bind checks the mutation context. Contract: theme§2.1/T004 preserves the uniform padding getter and per-slot replacement; reactive-runtime design line109 forbids getter mutation and requires ReentrantEvaluation.

The public probe creates `Text("X").padding({=> pad.get()})` with pad=1. A text getter conditionally calls `setStyle(paddingLeft, Value(9))` and catches ReentrantEvaluation. After that rejected call, setting pad=2 should update all four original bound sides. Actual snapshot places X at(x=1,y=2), not(x=2,y=2): left remains1 while the other sides become2. detachPaddingSlot sets its flag false before the operation is rejected. The getter overload has the same ordering. Check mutation/reentrancy/session permissions before changing any padding flags or binding ownership, and retain validation-before-replacement semantics for ordinary invalid values. Add a focused rejected-call regression for constant and getter overloads.

### T086-M01 — public theme documentation omits two explicitly required semantics

Location: `docs/product/theme.md:9`; no product document mentions visualStates. Contract: theme§2.1 explicitly requires explaining that visualStates is appearance projection and does not focus/select/disable events; §5 requires explaining root[text] as the inherited text seed rather than reinjecting it into every child.

Add these statements with one short parent/child example. `visualStates(disabled:true)` must not be presented or inferred as event disabling. Explain that a parent's resolved foreground reaches an otherwise undeclared child even when root[text] has a foreground, while the child's own role/named/explicit declaration can override inheritance. The implemented behavior need not change for this item.

## Complete reviewed scope

| Contract area | Source review result |
|---|---|
| T001/T002/T013/T016 typed values, unforgeable keys, immutable rules, package direction | All closed slots/state equality/copy semantics inspected; no Any/downcast bypass. Alignment moves to style with root re-export. No second style tree/renderer. |
| §2.1/T003/T004 component APIs and mutation ownership | Old getters/constant signatures retained, actual primitive applicability checked, roles do not alter kind, state and styles invalidate layout; I03 requires correction. |
| §5/§9/T011/T013/T015 cascade, spans and fill | Single per-property resolver uses explicit, reversed reuse list, role/global, inheritance/default order; state priority and Reset stop fallback. Explicit mask overrides spans only locally. Root seed fill uses background-only Style; local background uses full resolved Style. Presence changes invalidate despite equal rendered values. |
| T005/T014 allocated-width wrapping and layout | Shared allocateMain used by measurement/paint; Column constrains available width and Row allocated widths remeasure height. Four insets saturate; zero width keeps hard-line height; oversized whole clusters advance without spurious trailing soft line. Ellipsis chooses generated marker policy before selecting source-cluster prefix; only horizontal clipping signals a marker. |
| §3–6/T009 TOML closed schema and guard | Upstream public Lexer guard before Parser; encoded1024 key measure, comments/nonEOF/declaration counters, stack/path/depth handling, UTF8/file limits inspected. No copied lexer/escape decoder. Literal types, references, names,17 roles and states checked. I01/I02 affect diagnostic order; existing new source-type tests are valid but do not cover these combinations. |
| T010 presets | All four product TOML files equal original frozen fixtures and the embedded literal text. Presets use the same parse/schema path and no cwd read. |
| T012 package/dependency route | Manifest fixes normal TOML0.2.3, includes /themes and retained licenses, uses the documented environment-relative official stdx layout. No developer absolute path embedded. Normal bundle/clean-consumer execution remains separately pending. |
| Application/runtime compatibility | Both existing init families append theme; current runtime/session/glyph options preserved. Node identities, bindings and existing Frame/Unicode/ANSI path are retained. Async T006–T008 and related ThemeRequest/Source/Info work belong to026; full controls showcase027 is not claimed complete here. |
| Original085 plus both supplements | Existing assertions/negative fixtures/presets retained; fixed overlay equivalence checked. Reviewed source-type/order/printability expectations and ordinary positive-first focused runner without a fake parser/Theme. Test pass does not cover the three new counterexamples. |
| Public product docs | Actual lexical key measure/stdx prerequisites and deferred loading disclosed; M01 remains. |

## Verification, provenance and limits

The environment disconnected during review (exec-server recovery timeout, then no usable environment). While unavailable, GitHub fixed-object reads completed the remaining preset/manifest/doc inspection. No alternate GitHub report was written. After recovery, the same isolated fixed source was checked again by hashes and a small SDK1.2 public consumer was compiled/run with its own normal dependency cache and official stdx setup. No product/tests/contracts were edited; no subagents or author reports/self-assessments were used. Earlier sealed decision/test-asset reviews remain untouched.

`bash run-final-probe.sh`: clean `cjpm build -i` exit0; direct binary exit0. The six diagnostic cases and one binding scenario observed the three failures above. Raw commands, UTC, outputs and exits are in raw/final; probe-analysis.json checks the observed output. A successful probe process exit means observations were collected, not that the product passed. Initial probe scaffold compilation failed on an illegal captured mutable local. A follow-up launch overlapped completion of the first build and contaminated preliminary shared logs. Those captured initial logs/source and completion observations are preserved and explicitly excluded from verdict evidence; after both ended, the final isolated log directory recorded a clean build and run. No full suite was rerun.

Existing pure raw evidence was inspected and137 files hashed: values/integration logs end in success; all16 negative compiler results are intended type/visibility diagnostics, not dependency/environment failures; seven controlled Glyph result.json files record code0. The retained checkpoint helper127 and previously reported ENOSPC are environmental history, not product passes. The author reports were never used.

Two product-input inventories have131 records each at2026-11-11T03:26:21.505075+00:00. All128 tracked paths match97df096; three ignored cangjie-repo files are configuration records outside git, not source mismatches. The inventories were captured after the earlier values/integration/Glyph runs, whose command logs name3a52f55. This supports a final-content snapshot but does not independently prove the exact product bytes used by those earlier runs. Only layout.cj/layout_node.cj/layout_allocation.cj differ between that commit and97df096; retain the temporal qualification, especially for final layout claims. TASK087 must establish the tested final/fixed content identity without inventing a historical pre-run hash. This review neither discards those development logs nor upgrades them to independently verified final acceptance.

Normal bundle/clean SDK+stdx unpacked consumer and final old-regression execution were still in progress outside this review. Their absent final proof is **cannot-verify/pending**, not a source defect. It does not cause the ChangesRequired verdict, which is based on reproduced I01–I03; even after corrections, T012 execution evidence remains necessary for completion.

## Handoff

Correct I01–I03 together, complete M01, and add independent focused regressions. Re-review the correction diff and rerun only affected evidence before independent087. Do not mark013/025 or parent Linux acceptance complete from this review.

Lightweight archive: report.md, findings.json, reviewed-hashes.json, the small public probe source/manifests/scripts, final raw probe evidence and classified initial failure material. Fixed source, full design, old raw trees,151 generated inputs, SDK/cache/checkouts/CJP/ELF are referenced by commit/hash rather than copied into curated/.
