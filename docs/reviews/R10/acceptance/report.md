# R10 independent acceptance — final integration pending

Status: **finite functional evidence accepted and reusable to final technical target 8af39f6; integration metadata pending; no integrated pass verdict issued**. Prepared 2026-11-10 UTC in the independent `/workspace/work/auto-final-acceptance` directory. Product and test files have not been edited; functional suites have not been rerun. No product-author analysis or self-assessment has been read. The current cumulative independent review at the supplied fixed SHA has now been read as an authorized acceptance input. The latest verdict table is in “Execution evidence acceptance”, supplemented by the final technical target checks; the earlier tables preserve preparation/history.

Role: independent requirements acceptance (TASK-064). Requested scheduling: **Astra/high**. This agent has no authoritative runtime model/effort identifier available in its tools; the requested scheduling must not be reported as independently observed runtime identity. The generic system identity describes Codex/GPT-6 and does not establish the selected serving model.

## Contract and scope

Read main-repository AGENTS.md, acceptance AC-006/061–066, the color change design (D031–D033 supersede the historic manual-default sections), and tasks Global constraints. The observed main HEAD during preparation was `78ae76c7129bb903ebb6b3b6861c3a7a0851b06b`; this is a contract-reading observation, **not the final accepted code SHA**.

| Contract file | SHA-256 at preparation |
|---|---|
| AGENTS.md | `262e6e870226dd626a80a40f64b7ce75aea76d4e4c0a33235b529029e89345dd` |
| docs/acceptance.md | `e504dc044dbec8fc0ebcb2e339cb48bf69e939f3c9c03c8fa3ca57bcaab4c9d9` |
| openspec/changes/implement-color-style-output/design.md | `f04d61528ceed056e942521fc71973eff18c8344e89d275a2e93242e1db9ac88` |
| openspec/changes/implement-color-style-output/tasks.md | `15e6f8fe13a831f0c8ccbcbddba70abafd150bfc9d026f2d88602a51c03ee735` |

Acceptance covers this color/six-attribute/automatic adaptation increment, the real xterm and XFCE/VTE matrix, original PNGs, normal bundle, and the bounded clean-consumer path. It cannot establish all Linux functionality, four-platform support, physical Linux console, tmux/screen, themes/M2, or full release readiness. xterm default and xterm-256color are two configurations of one implementation, not two independent terminal kernels. Unavailable real-host cases stay pending.

## Per-AC evidence plan

| AC | Current verdict | Required fixed/raw evidence and acceptance scope | Unresolved |
|---|---|---|---|
| AC-006 | pending | Fixed technical source and independent test raw output: Default/Basic8/16/256/TrueColor/Monochrome mapping, six attributes, original Style/Cell preservation, shared ansies encoding, inheritance and explicit false, effective-diff silence, success-only baseline commit; automatic Application default versus pure RGB/six-attribute snapshot; no required example override | Final SHA, test/evidence hashes and source inspection |
| AC-061 | pending | Independently frozen tests and genuine RED; D031–33 API/default updates; hand-calculated mapping expectations and old assertions preserved; synthetic terminfo/NCV/native-isolation/failure evidence explicitly distinguished from real hosts | Frozen test SHA, RED/raw hashes, executed final test identity |
| AC-062 | review gate satisfied; final integration pending | Current cumulative independent review fixes `bf308bf`, closes F1–F8, retains the adjudicated minor duplication boundary; original and archived report/findings are byte-identical (hashes below) | Does not certify execution, package or real GUI results; final integration remains pending |
| AC-063 | pending | Independent cold all-entrypoint logs/exits; real PTY including handshake and recovery; normal bundle without skip flags; package contents and clean public consumer build/run with ordinary dependency/link path | Exact commands/environment, exit codes/raw hashes, actual cjp hash and consumer evidence |
| AC-064 | pending | This per-AC independent mapping; fixed source to reviewed/tested bytes; final copied raw evidence byte identity; final direct-main integration metadata/state consistency | All final evidence plus final integration SHA/copy manifests; no pass before these exist |
| AC-065 | pending | Actual capability source probes and environment provenance supporting safe optional private-namespace libtinfo strategy, unknown downgrade, real host matrix and capture method | Raw probe/source hashes; source interpretation must remain database/host declaration, not physical hardware discovery |
| AC-066 | pending | Same no-override application/binary on real xterm default, xterm-256color and XFCE/VTE; original unmodified window PNG plus metadata, raw terminal recording, diagnostic capability source, sizes, refresh/resize/q/Ctrl-C/error recovery and termios | Actual original files and hashes, implementation/version/config/backend, SHA/time/stage, binary identity and restoration evidence |

## Evidence integrity checks to perform at handoff

1. Obtain immutable reviewed technical SHA, frozen tests SHA, independent executor checkout SHA, and any final integration SHA. Establish source/test content equivalence rather than assuming a later commit invalidates or proves tests. Record changed metadata separately.
2. Hash actual files; match manifest claims and final repository copies to the independent originals. Include command logs, raw terminal recordings, before/after termios, capabilities records, PNG metadata, native probe output, clean-consumer output and cjp bytes. Record missing artifacts as insufficient evidence rather than inventing hashes.
3. Inspect original PNG bytes visually. Confirm the collection path records real Xorg terminal windows and preserves originals; a generated diagram, reconstructed screenshot or old host-only probe cannot prove the framework rendering. Screenshots supplement functional/recovery logs.
4. Verify each matrix row binds host implementation/version/configuration and character-grid size to the same no-override executable, tested SHA, capture time/stage and original PNG hash. Count two independent implementations. Distinguish fixture/synthetic TERM branches from real terminal tests.
5. Read exact detection/profile evidence: TERM validation; COLORTERM declaration; terminfo-known/color-known/source/reason; six supported SGR capabilities; NCV interaction; conservative unknown behavior; isolated optional loading without product GUI/runtime dependency. Explicit color override must leave attribute gating automatic.
6. Verify normal bundle and clean-consumer commands use normal build hooks and no private link flags. Bound any positive package conclusion to the actual tested archive and consumer, retaining full-release omissions.
7. Final metadata review checks AC/task status, product scope, actual model provenance, evidence links and byte hashes against the final integrated tree. Reuse still-valid fixed evidence; do not rerun the functional suite merely because the reviewer role or metadata commit changed.

Skills actually read: `superpowers:using-superpowers` (explicit subagent-stop applies) and `cloud-environment:cloud-environment-runtime` (read-only runtime status inspected; no test host started). Preparation is execution of the established acceptance contract, not new product design.

## Static handoff verification at bf308bf

Fixed technical target: `bf308bfccb43d0e88305c6d0ec64b4a92adbc892`. Observed main HEAD: `b28a1facc71326a24155b526b42b3c3ced15ce6b`, whose committed delta from bf308bf contains only review/repair evidence and task/progress documentation. The later inventory corrections described below were still working-tree metadata at the time checked. This is not the final integrated SHA.

`verification-before-completion` was read for this phase. Fresh verification here means checking actual immutable sources, raw files, and hashes; established AGENTS §11 and the assigned acceptance role require reuse of valid independent functional execution rather than rerunning its suite.

Read fixed source at bf308bf for Application, TerminalCapabilities decoding, TerminalRenderProfile, optional native capability detection, normal colors example, build hook, manifest and slice entrypoint. The inspected path has the ordinary `Application(root)` constructor; optional named override and return-to-Auto; one detection after successful open inside the cleanup fence; automatic attribute gating even under color override; private-namespace optional libtinfo; diagnostics; and ordinary no-override example. This is source-contract mapping, not a substitute for the pending independent execution.

Source reuse was independently checked across ead6a8d and bf308bf using recursive Git object listings for `src`, `native`, `examples`, `docs/product`, `build.cj`, `cjpm.toml`, LICENSE/NOTICE/CHANGELOG, benchmarks, third-party licenses, `tests/run-slice.sh`, and all slice-called test directories. Those listings are identical; their SHA-256 is `857a983daebef142ee8ea5a8babc14349298d04b9179cd16534e857917ba7395`. The product subtree Git IDs are src `fad646653995b292ba289b6e3cab3b72188daa2d`, native `71ab5df0ee88eb20c2b900da2b0bb892cfcaa7ae`, examples `45dd311edee68fb2eff928bff17c789b368d9041`. The four changed technical files are only the real-terminal exit verifier/runner/test/README. This permits a content-based stage-A reuse assessment once the executor supplies its actual checkout/build evidence; it does not yet certify stage A.

### Independent review and archive integrity

The supplied current cumulative report reviews baseline `96bdb9b7c5b1f58c5ec223a0475be3d86cfae660..bf308bf`; it records spec pass and quality pass with adjudicated minor localized row-emission duplication deferred. F1–F8 are closed and no Critical/Important remains. It explicitly excludes actual GUI, PNG, consumer and final acceptance results. The reviewer identifies `gpt-6-astra/high` as controller-confirmed dispatch with no additional visible runtime identifier.

Actual original-versus-copy `cmp` checks succeeded for:

| Original under `/workspace/work/auto-final-review/` and archived basename | Actual SHA-256 |
|---|---|
| round-2-review.md | `0e555e135ec6b2ae6cf4122fe94d9f7b350c947f2e0a4d10f990533bca075f43` |
| final-findings-bf308bf.json | `94058ca237987a1e9a3278f095e431e16f96cbeae11528bac2edf24a11914e65` |

Five archived manifests were freshly checked against all named files (162 total), and each file is tracked. Manifest SHA-256 values and mismatch counts are in `static-evidence.json` (actual SHA-256 `ce7b3f09788680559d8d731f5ab89111f9eb7e063063fe8cc561f1d5a6ab4f85`). Counts: auto-test-design 2; terminal-test-design 1; auto-capability 36; host-readiness 119; auto-review/final 4. All matched. This establishes these archive bytes, not semantic completeness of their contents.

The host-readiness inventory initially named an outdated report hash. This was reported to the controller, which regenerated only the two derived inventories from checked manifest files and added the previously omitted capability probe source. Fresh independent checks now confirm all 36 capability and 119 host inventory paths, sizes and hashes match actual files. No original report/PNG/source/raw was altered by this repair. Final integration must retain these corrected metadata bytes.

### Investigation and RED limits

AC-065 evidence inspected includes original capability probe output for separate base/private loaded addresses, unchanged base `cur_term`, 500 repeated and concurrent operations with zero errors, and a successful Cangjie direct binary producing packed value `4295033088`. The actual raw hashes are `3f0e3b5379351a743a6d2f0bd5f7e5f7d465a4a432c2132f6697e72ae592782d` (C isolation) and `a5aa1b18a149cf7144d9ccfccd3c971c650c83e94dc4bb6f76ecb81f5241f3f3` (Cangjie call). The restricted-environment probe still found the system terminfo entry: it is correctly not evidence of database failure. Host probe child files explicitly distinguish xterm/TERM=xterm/empty COLORTERM from XFCE-VTE/TERM=xterm-256color/COLORTERM=truecolor; these are readiness evidence only. No old readiness PNG is accepted as the framework's Auto rendering result.

The independent Auto test design report (actual hash `d22f500c92ed58f05d260bb608db4b26e97784937233d87507b7dc2daa8840cc`) states missing-API, pure-snapshot-default and ordinary-example RED outcomes. Its archive currently contains that report and one golden calculation, not the described RED logs. The terminal test design archive similarly contains only its report (actual hash `c469b84c303d1185f9e28ef512304c0c7a8ccc62b776836b02bcf2f4b39e41e4`). Required initial Auto RED raw-log locations and fixed code/command/exit provenance were requested from the controller; AC-061 remains pending rather than promoting report prose to raw execution evidence. Existing old explicit-color RED hashes do not replace the revised Auto RED obligation.

AC-006 still awaits final independent behavior execution; AC-063/064/066 still await the final matrix, ordinary-example captures, original PNGs/metadata/raw/termios, actual cjp/clean-consumer evidence, and final copied-byte/integration checks. No functional suite was repeated by this acceptance role.

## Execution evidence acceptance (supersedes preparation verdicts)

The independent original `/workspace/work/auto-final-execution` now contains stage A at `ead6a8d732c96fc108a52df3775dea8f84a84c59` and real-host stage B at `bf308bfccb43d0e88305c6d0ec64b4a92adbc892`. I read the original command metadata, relevant raw logs, terminal records and screenshots, and independently verified source/manifest/archive/copy hashes. I did not rerun the product suite.

| AC | Verdict at the tested source | Actual evidence | Remaining boundary |
|---|---|---|---|
| AC-006 | **pass, finite color/six-attribute/Auto contract** | Original cold log E1; 18 synthetic capability artifact sets; 14-action explicit-mode fixture; ordinary automatic example; real-host E3/E4 and twelve raw/metadata rows; fixed source and independent review mapping above | No all-Linux/platform/theme/M2 conclusion; final metadata not yet accepted |
| AC-061 | **pass, independent test contract and actual historical-code RED reproduction** | E6–E9; exact old product and effective test archives matched Git contents; API compile exit 1; successful consumer/example builds followed by intended snapshot and ordinary-example assertion exits 1 | Original initial RED logs remain unavailable; reproduction proves rejection now, not the original execution timestamp/test-first chronology |
| AC-062 | **pass for cumulative reviewed bf308bf** | Current review and findings hashes above, F1–F8 closed | Future shell/version metadata repair still requires its independent delta review; accepted minor localized duplication remains disclosed |
| AC-063 | **pass, bounded executed Linux slice/package/consumer** | E1/E2/E5; all required actual command exits 0; unpacked package and public consumer build/check; snapshot bytes and real PTY exit/resize/restoration | Complete release checker actually exits 1 for absent composition, benchmark also absent; no complete release pass |
| AC-064 | **pending final integration** | Source equivalence, original evidence and current copied-byte checks recorded here and in JSON artifacts | Final technical delta/review/reuse proof, full final evidence copy scope, final AC/task/status/link metadata and integrated SHA remain required |
| AC-065 | **pass, bounded capability-source and host-readiness investigation** | Actual source probes and private-namespace/Cangjie raw hashes above; host/version supplement E10 ties real executable/library bytes to twelve rows | Source means host declaration/terminfo database; no physical hardware detection or unsupported ABI guarantee |
| AC-066 | **pass for the executed bf308bf real-host program/evidence** | E3/E4; 9 fixture scenarios + 3 ordinary-example profiles; 45 original PNGs; raw SGR/profile/fence/resize/exit/termios; all accepted archived copies byte-identical | Two implementations, three configurations; shell-entry/version-capture delta and final integration still pending; console/tmux/screen untested |

### Evidence hash anchors

Paths E1–E5/E10 are relative to the independent execution directory. E6–E9 are relative to the original independent `auto-harness-repair/evidence/red-reproduction` directory and match the archived `docs/reviews/R10/test-repairs/evidence/red-reproduction` bytes.

| ID | Actual original | SHA-256 |
|---|---|---|
| E1 | raw/stage-a-cold-slice.log | `ad862a8c68dd4652203a24b6f8a683cabd0340f84e3feeec3c6668cca51dff84` |
| E2 | raw/stage-a-bundle.log | `440940102c84718af2943319479498e2e9a89c8bfd77091448952b529c5da98e` |
| E3 | raw/stage-b-real-fixture-bash.log | `209211c8c9a69af95a1b6dfb2e1c2ec3f33244b0ca187dbe266746437a5d642f` |
| E4 | raw/stage-b-real-example.log | `44cce37e8b98c3581d739c1ce08c858157ef772f22c0d8971e5bb3be7ae5b4d4` |
| E5 | stage-a-cjtui-0.0.0.cjp | `fe5c09e082012e83cfcfa38c194027b558b02c80596f1aad9e7d032c71c63f95` |
| E6 | summary.json | `2afc79244edd3500b284fca27e28b6e086d2e614ebb0c6499577f29647d688d8` |
| E7 | api-build-red/stderr.log | `77ccd5f7ff425c9bbf8cdb5b21f41e9915c5675e4a221449de88086af3aa20a4` |
| E8 | snapshot-red/stderr.log | `ce7b6e341ca6e5d70682874536b7ea7a8c260cd8c8a013d332c2cf943ab87e9e` |
| E9 | example-red/stderr.log | `18cd2ba4a176e2c21363b2271c58155f1618981f544484597b6bae579de1cd50` |
| E10 | host-version-supplement.json | `c9775072b32caafaeed46be64490f3c69fbbfb70b98700274e10f2c7c730283a` |

The original execution `SHA256SUMS` (`a38caba83db53975fa7138a7a78d7b190d15d21592a62afbfdbb80cd5888d020`) passed fresh `sha256sum --quiet -c`. Original command `.meta` files record cwd, full command, source SHA, environment scope, UTC time and actual exit. The independent executor reports GPT-6.1 Sol/medium as its dispatch; this acceptance agent has not independently observed that serving-model identity.

`execution-evidence.json` records individual raw-log hashes and all twelve metadata/PNG/raw/termios/resize/exit checks. The 95-file stage-A source inventory matches its recorded ead6a8d source; the 19-file stage-B harness inventory matches bf308bf. Two terminal harness files differ between stages and belong to the separately executed stage B; they are not covered by stage-A reuse. All earlier product/slice/package equivalence checks remain applicable.

### Real-host and original-image findings

| Host/configuration | Actual declaration and resolved capability | Actual character grid | Binary identity |
|---|---|---|---|
| XTerm(398), default | TERM=xterm; COLORTERM empty; Basic8 / terminfo | 100×28 → 120×34 | Same fixture / ordinary binaries as other rows |
| XTerm(398), -tn xterm-256color | TERM=xterm-256color; COLORTERM empty; Indexed256 / terminfo | 100×28 → 120×34 | Same xterm executable as default, not another implementation |
| XFCE Terminal 1.1.4-1 / VTE 0.80.1-1 | TERM=xterm-256color; COLORTERM=truecolor; TrueColor / terminfo+COLORTERM | 100×28 → 120×34 | Actual XFCE executable and VTE library hashes independently match E10 |

All nine fixture rows share binary SHA-256 `283224c0295a91e8d8fc0bb536919a1066d45ccd8af7dfc1c259e3f0110e407f`; all three ordinary-example rows share `fabfe6974113ef05c6e827c552978e89216f1e49b78d44e5541ead6b0f820a73`. Both use normal `Application(root)` without override. The ordinary example intentionally lacks fixture capability files and ACKs; its positive-output capture evidence is not attributed a no-op proof. The separate fixture has explicit raw row fences, including no-op records with zero preceding bytes.

Fresh checks against actual original bytes confirm every row's source SHA, before/after PNG hashes, raw bytes hash, inner/outer recorder hashes, 100×28→120×34 sizes, exact ready/exit termios, and expected application exit. q and interrupt application/recorder exits are 0; exception exits are 1 even when the terminal host exits 0. Host wait status remains independent.

I visually inspected the original ordinary initial PNG for each of the three profiles, the original resized fixture PNG for each profile, and the ordinary VTE attributes-off PNG. They show real terminal windows and the expected sample text, Unicode row, color/attribute output and resized scene. Xterm and VTE palette/background appearance differs; bright/basic mappings and font shaping are not pixel-equality promises. The image observations supplement raw behavior evidence rather than proving cleanup themselves. All 45 PNGs were byte-hash checked, including unviewed stage images.

The original VTE `host_version` field contains a Gtk display warning because that query lacked DISPLAY. It has not been rewritten. E10 records the actual installed version evidence and hashes of `/usr/bin/xfce4-terminal` and the resolved VTE library, and binds all twelve original metadata paths. Those actual executable/library hashes match. This is adequate bounded host identification with the original capture defect disclosed; future collection correction remains a separate reviewed change.

The supplied GUI archive was checked against originals: 688 fixture files (18 PNGs, including all 141 ACKs) and 175 example files (27 PNGs) match exactly. `gui-copy-evidence.json` records zero mismatches. Only two generated XTEST test executables and twelve XDG cache files are excluded; they are test runtime artifacts, not original PNG/raw/profile/restore evidence. The initially omitted ACK text files were supplied during acceptance and freshly compared. Final integrated copy coverage outside GUI is still pending.

### Normal package and honest RED boundaries

The normal `cjpm bundle` command returns 0 with its lint output retained. I independently opened the actual 62-file cjp and compared every file with the fixed bf308bf Git source: all bytes match. The standard full-release checker remains unchanged and actually reports `Incomplete product bundle: examples/composition/cjpm.toml` with exit 1. The finite archive audit and clean consumer evidence do not override that failure. Consumer `cjpm.toml` contains only a normal cjtui path dependency; no private FFI/link flags. Build/check/direct snapshot and real PTY command exits are 0, with actual 40×6→54×9 resize and exact termios restoration.

The reproduced RED uses unchanged product `187e126fc20b13a4f5526a28a9189cc0acb4037f` and effective independent tests `0d2f6c77621cafdd0be267f3837f80652c9fc66b`; archive contents were independently compared to those exact commits (the latter in the independent reproduction clone). All 29 old-product and 15 effective-test source files match. Source-only archives contain no ELF/cache/target payload. The 73 archived reproduction evidence files match independent originals. Missing Auto API diagnostics are the actual seven compiler errors; successfully built snapshots then fail the pure TrueColor default assertion; the normally built old example fails the expected first rich RGB assertion in an actual PTY. These are real current negative executions, transparently dated 11:43–11:46 UTC, not recovered original logs. `archive-evidence.json` records the actual archive hashes and zero content mismatches.

The direct `/bin/sh` GUI runner attempt at bf308bf really failed in SDK shell setup; the subsequent explicit `bash tests/terminals/run.sh` executions succeeded without source alteration. The failed command/log is retained. Acceptance therefore applies to the actual bash commands. The proposed future shebang/version-query repair must be reviewed and proven semantically compatible before accepting the final integrated metadata; no repeated GUI/slice suite is justified merely by that metadata/entrypoint adjustment.

## Final technical target and selected archive verification

Final technical target is now `8af39f6c8882772b946ae1d9507361f8a6082388`. The third independent cumulative review reports finite spec/quality pass, F1–F8 closed and the same adjudicated minor duplication deferral. I read that report and its findings/reuse record, and compared their originals to main-repository copies: all are byte-identical.

| Current review original | Actual SHA-256 |
|---|---|
| round-3-review.md | `ac3e3e7b31cd2e7a9babf4462b18252f93f8e91807d7468b310ad3a0f31a3a4c` |
| final-findings-8af39f6.json | `69c7a80017c8b6354f8167182f81c3ab1fcb93ac88aad140c3019679e7256b0b` |
| round-3-reuse-check.json | `f461cfda3316482aa5339ee95f708b7a9c74bc1e37fa6891299ee552e66e48b4` |

Independent direct Git comparison confirms only runner lines 1 and 105 changed, with identical total line count and every other line identical. These changes select Bash as the direct entry shell and select the supported host-version option under the existing live DISPLAY. Product, slice and package paths are unchanged. I also read the actual narrow fix evidence: direct-entry probe passed SDK setup and reached intended `fixture binary missing` (exit 1, no application run); actual XFCE `--version` on fresh Xorg :219 exited 0. This is entry/query evidence, not a new GUI matrix execution.

AC-062 is therefore **pass at 8af39f6**, and the finite AC-006/061/063/065/066 conclusions are reusable to that final target within the stated bounds. Stage A remains an ead6a8d execution and stage B remains a bf308bf explicit-Bash execution; neither original is relabelled as an 8af39f6 run. The standalone version supplement remains attached to the unmodified original metadata.

Fresh final selected-copy checking verified all **1,202** entries of `execution/SOURCE_SHA256SUMS.txt` (manifest SHA-256 `884ed6d0546bd9ecd0a87dfd6323648d09e47d5735fb006366c78a871af3b732`) against archive bytes. Every mapped original file also matches the independent execution directory, including logs, report, snapshots, consumer evidence and inventories. The only local-only entry is the derived GUI manifest. The GUI manifest has **864** entries and SHA-256 `76c79036a1df4df7e4706f2620d62f895ccb7c420d01a1ad51520de403a78cd0`. `final-technical-evidence.json` (SHA-256 `4260562bf309bc4905b824c06a348837e8ca30a02d6efb8503c172f5155c4495`) records these fresh zero-mismatch results and the independent delta check.

**Remaining AC-064 hold:** final controller metadata projection, copy-scope explanation, aggregated report/link correctness and final direct-main integrated SHA. No further product or matrix test run is requested by this acceptance role.
