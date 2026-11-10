from pathlib import Path
import json,hashlib,re,datetime,subprocess,shutil
b=Path('/workspace/work/rich-text-execution');e=b/'evidence';summary=json.loads((e/'execution-summary.json').read_text());p=Path((b/'clean-product-path').read_text().strip())
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
artifacts={}
for name,f in [('product_cjp',b/'source/target/cjtui-0.0.0.cjp'),('source_rich_consumer',b/'source/tests/rich-text/target/release/bin/main'),('clean_rich_consumer',b/'clean-consumers/tests/rich-text/target/release/bin/main'),('source_example',b/'source/examples/rich-text/target/release/bin/main'),('packaged_example_gui_binary',p/'examples/rich-text/target/release/bin/main')]:
 artifacts[name]=dict(path=str(f),sha256=h(f),size=f.stat().st_size)
(e/'external-product-artifacts.json').write_text(json.dumps(artifacts,indent=2)+'\n')
rows=[]
for r in summary['fresh_results']:
 if 'start' not in r:continue
 stdout=(e/r['name']/'stdout').read_text();stderr=(e/r['name']/'stderr').read_text()
 rows.append(f"| {r['name']} | {r['exit']} | {sum(x.startswith('PASS') for x in stdout.splitlines())} | {len(re.findall(r'warning(?:\x1b\[[0-9;]*m)*:',stderr))} |")
files=json.loads((e/'clean-package-source-equality.json').read_text())
lint=json.loads((e/'bundle-warning-audit.json').read_text())
counts={n:sum(x.startswith('PASS') for x in (e/n/'stdout').read_text().splitlines()) for n in ['core-direct','dynamic-direct','runtime-session','contract','coordinates','layout','decoration','composition','colors','macro-positive-direct']}
report=f'''# TASK083 independent execution — FAIL: actual GUI row corruption

Fixed product `91c22f82adcd2412d9509b9872ff63450ba81af9`, tree `d5b0e4c34cf2400415980450a1178400f7885d2b`, version `0.0.0`. Independent execution directory: `/workspace/work/rich-text-execution`. Execution only; no product, formal test, main repository, status or commit changes; no subagents or author communication. Inputs were the TASK083 brief, formal final7a33ddc design/tasks/AGENTS, fixed product/tests, and prior raw factual evidence. Author reports, reasoning and self-assessment were not inputs.

Fresh source and clean packaged public consumers each passed the original **11 rich groups + 98 new CSI UTF8 cases**, with **0 first-fault failures**, direct executable exit **0**. The normal root build/check and `cjpm bundle` passed with lint enabled. Both hosts completed 5 captured stages, q exit0, exact inner/outer termios restoration and process reaping. The independent raw-output logical model matches the 5 expected full text/cell/style grids per host, but original PNG inspection shows **actual visible row corruption on both hosts after t**. A logical-model PASS is not an actual host-grid PASS. TASK083 therefore fails required GUI untouched-row validation.

**R14T083001 (blocking):** initial/full-resize PNGs show the fourth row `ANSI styles remain structured` intact; after the first `t`, both actual host PNGs show the first two characters `AN` erased and `S` under a cursor block. The output delta addresses only the third row, so the fourth row should be untouched. See [finding](evidence/gui-visible-finding.json), [XTerm failing green original](evidence/gui-rich/xterm-default/q/example-green.png), [VTE failing green original](evidence/gui-rich/xfce-vte/q/example-green.png), and the [VTE resized-green original](evidence/gui-rich/xfce-vte/q/example-resized-green.png). The product emits the full Unicode cluster and pads row3 according to width2; a host advancing the ZWJ cluster by4 columns could wrap two extra spaces into row4. This is an unverified causal hypothesis, not a proven fix direction. No product/formal test was modified. Root was notified promptly, and no final PASS was dispatched.

The preserved whole-archive boundary checker exits **1** at missing `examples/composition/cjpm.toml`; `benchmarks/rendering/cjpm.toml` is also absent. These future whole-product deliverables were neither implemented nor silently skipped. This is a limited rich-text integration result, not whole Linux release acceptance, TASK010 completion, or a pass for future TASK148/113/098. Glyph/VT matrix remains TASK097/final041.

## Reproducibility and fixed inputs

- SDK/compiler/project manager 1.2.0, x86_64 GNU/Linux; environment, SDK env hash, UCD17 hash, source tree and dependency bytes are in [environment provenance](evidence/environment-provenance.json), [dependency inventory](evidence/dependency-inventory.json), and [versions raw](evidence/versions/stdout).
- Fixed source was `git archive` extracted into the independent source directory. Every tracked byte was checked after execution against [source inventory](evidence/source-inventory.json); [formal source proof](evidence/formal-test-source-proof.json) and [fixed content proof](evidence/fixed-content-proof.json) show the frozen tests and unchanged macro-negative scope.
- Every project/consumer received an own `cangjie-repo.toml`, own normal cache seeded read-only from `/workspace/work/validation/replay-dependencies/cache`, and the existing relay `http://127.0.0.1:18973`. No relay was created, no rescue FFI flags or lint skip were used.
- Skills actually read/applied: cloud runtime environment inspection; verification-before-completion; systematic-debugging after visible GUI anomaly (facts preserved, no fix proposed); CangjieSkills cangjie-coding at `277f2e1` (batched search via supplied script, SDK1.2.0 actual behavior authoritative); cangjie-rules at `40bacab` under project conventions. No new checker was promoted into a gate, no production/test code was written. The using-superpowers skill explicitly exempts dispatched execution subagents.

## Fresh execution and reused evidence

[Execution summary](evidence/execution-summary.json) contains actual UTC start/end, cwd, command, exits and stdout/stderr hashes. Each named directory contains the unabridged raw streams. Build commands use normal CJPM; every runtime result is the actual executable exit, not a `cjpm run` status.

| Command/evidence directory | Actual exit | Lines beginning PASS | Compiler warning headers in stderr |
|---|---:|---:|---:|
{chr(10).join(rows)}

The PASS-line column counts emitted observations, not a claimed number of independent test cases. Only the rich contract explicitly has the formal 11+98 grouping. Observed regression PASS lines: `{json.dumps(counts,sort_keys=True)}`. Runtime PTY deliberately expects exit 1 for failure-path scenarios; the harness itself exits 0 and verifies exact restoration with failures=0.

Fresh checks cover the changed typed Frame/Component/layout/runtime measurement and invalidation paths: rich public APIs, runtime core A+B, dynamic structures, runtime sessions, macro-positive public consumer, Frame contract/coordinates, layout, decoration, composition snapshots/files and color behavior. Root build stderr is empty; root check succeeds. Macro-positive reports two fixture unused diagnostics; layout reports two fixture unused-expression diagnostics. Normal bundle lint emits **{lint['warning_count']} advisory warnings** in stdout, with rules/counts `{json.dumps(lint['by_rule'],sort_keys=True)}`; [all lint warning records](evidence/bundle-warning-audit.json) preserve locations/messages. Full stderr and normal bundle output are retained; warnings were inspected, not suppressed. Successful bundle does not mean lint-clean source.

Per AGENTS11.1, **15 macro compiler-negative cases** are reused from fixed prior raw evidence. The macro parser/expander and negative fixtures are byte unchanged, SDK/ABI/dependency versions match, and every nonzero exit/location/diagnostic was independently audited in [reuse audit](evidence/macro-negative-reuse-audit.json). Changed public integration is freshly checked by the positive consumer. No unchanged cold all-runtime negative suite was rerun; no historical aggregate regression PASS is claimed. The pre-existing historical raw results remain preserved.

## Normal source package and clean public use

The fresh `.cjp` contains **{len(files['files'])} regular files**, every product file byte equal to its tracked fixed source. [Package inventory/equality](evidence/clean-package-source-equality.json) records all hashes, no extra files, and explicit nonproduct `.gitkeep` omissions: `{files['nonproduct_gitkeep_omissions']}`. Fresh extraction, clean own cache/config, root build/check, copied public rich consumer build/direct, and packaged rich example build/direct `--smoke` all exit 0. The consumer source is copied exactly; only the dependency manifest path changes, proven in [consumer equality](evidence/clean-consumer-source-equality.json).

Product `.cjp`, binaries and the extracted checkout remain outside the curated archive; actual paths, sizes and SHA256 are bound in [external artifact hashes](evidence/external-product-artifacts.json). GUI uses the packaged example binary in that file, unmodified, without terminal branches, manual framework flush or any product override. Source-example smoke is separate evidence. The source `.cjp` is normal CJPM output, not an invented declaration-only package.

[Whole archive checker stderr](evidence/whole-archive-boundary/stderr) and actual exit1 are retained separately. The checker requires unfinished composition/benchmark example deliveries and therefore cannot be called a whole-product PASS.

## Actual GUI evidence

| Actual terminal | Version / profile | Captured events and logical model grid sizes (actual visible FAIL) | Evidence |
|---|---|---|---|
| XTerm | 398; actual TERM=xterm, terminfo8, Basic8 projection | initial100×28 → t Green → t Red → 120×34 → t Green → q0 | [metadata](evidence/gui-rich/xterm-default/q/metadata.json), [grid verification](evidence/gui-rich/xterm-default/q/rich-state-verification.json), [original initial PNG](evidence/gui-rich/xterm-default/q/example-initial.png), [original resized PNG](evidence/gui-rich/xterm-default/q/example-resized.png) |
| XFCE Terminal / VTE | XFCE1.1.4 / VTE0.80.1; actual truecolor declarations | initial100×28 → t Green → t Red → 120×34 → t Green → q0 | [metadata](evidence/gui-rich/xfce-vte/q/metadata.json), [grid verification](evidence/gui-rich/xfce-vte/q/rich-state-verification.json), [original initial PNG](evidence/gui-rich/xfce-vte/q/example-initial.png), [original resized PNG](evidence/gui-rich/xfce-vte/q/example-resized.png) |

The original PNGs are the actual host evidence and contradict untouched-row success after t. The JSON checker models the declared width2 policy; it cannot detect the actual host width/wrap mismatch. Every stage retains the actual PNG, raw delta, capture UTC, independent expected full cell/style JSON, actual full cell/style JSON and full text grid. The literal expected rows/style ranges were written from the formal contract in [independent grid checker](commands/verify-rich-grid.mjs), before reading actual rich GUI output. Expected RGB(80,180,255) is preserved in VTE and projects to White for XTerm's actual Basic8 policy; component Yellow overrides only foreground. In the raw-output expected/actual logical model, the first cluster `e+combining` is one cell with the first scalar's Red/Green style; CJK and ZWJ emoji are complete width2 clusters with continuation cells, never scalar-expanded. Entire logical-model grids and untouched rows are compared before/after toggles; original host PNGs expose the corruption that this model misses. PNGs are real host screenshots, not generated reconstructions; logical grid correctness does not claim universal installed-font glyph coverage.

Host/locale/config/version/ABI, source/binary SHA256, event output barriers, X11/PTY size transitions, exit/q status, exact termios and process reaping are retained. [Host environment raw](evidence/host-environment/stdout) includes actual terminfo. Final GUI per-file hashes are sampled **after host and Xorg exit** in each `final-artifacts.json`; capture timestamps remain actual per-stage capture times, with separate final hash timestamps. There is no SSH/key/clipboard or C# GUI path.

## Helper attempts and remaining limits

The first external key-helper compile added an unnecessary `-lX11` and failed because the development symlink is absent; [attempt1](evidence/helper-compile-attempt1/stderr) is retained separately. The existing dlsym-based helper compiled normally with `-ldl`. This is capture-tool evidence, not a product defect. Any later helper attempts are retained in evidence without replacing original failures.

The defined TASK083 matrix **fails actual GUI untouched-row validation (R14T083001)**. A fix and scoped independent real-host retest are required before acceptance; this executor did not self-repair product code. Whole source-package boundary has the explicit future composition/benchmark limitation above; full Linux/other OS and final glyph/VT coverage remain unclaimed. Independent TASK084 acceptance must wait for resolution of R14T083001; no closure is claimed.

The curated directory includes this report, scope, execution commands, raw evidence, source/dependency hashes and original GUI PNGs/metadata. It excludes product checkout/cache/CJP/ELF/SDK and repository Markdown snapshots. `artifacts.sha256` excludes itself; `archive-proof.json` reports manifest entry and plus-self counts separately, with the manifest self-hash saved outside the curated directory.
'''
(b/'report.md').write_text(report)
print('report generated with bound product artifacts and actual counts')
