# TASK027 accepted M1 theme showcase evidence

AC027 is **PASS_AC027_M1_THEME_SHOWCASE: 16/16 conditions passed**, accepted by the independent acceptance role. This directory mechanically publishes the existing sealed proof; no build, suite, GUI action or acceptance was rerun here. It does not certify all M1, M2, all Linux capabilities, the final C008 host matrix, TASK023/024/041, cross-platform support, clean-cache release packaging, or release readiness.

The accepted fixed source is `b5de3dd6610e90fcdcd951c5703a1429ec13b417`, integrated as `d654ae59da4749a43c946e1541c21b08e9b3ffba` with identical product/test bytes. Original product `954d7492b91c2f490dcb15d2d42190af5dbe52ae` and modal fix `46dc8e2badcb352f0619f6566231285009378a28` remain distinct historical inputs. Source/test snapshots in the archive resolve their expected SHA from exact Git objects; they never substitute the current contents of an old source worktree. Generated local `cangjie-repo.toml`/example lock data remains identified as physical input, not Git source.

Start with [acceptance report](browse/theme-showcase-acceptance/report.md), [condition evidence](browse/theme-showcase-acceptance/conditions.json), [GUI report](browse/theme-showcase-gui/report.md), [finite execution report](browse/theme-showcase-execution/report.md), [original review](browse/theme-showcase-review/report.md), and [scoped review](browse/theme-showcase-review/round1/report.md). Original reports and indices are byte-identical copies. Their historical relative/absolute references are logical identifiers: resolve them through `original-manifest.json.gz`, rather than assuming the old filesystem layout exists here.

| Accepted condition | Status |
| --- | --- |
| 01_canonical_presets | passed |
| 02_same_public_gallery | passed |
| 03_complete_controls | passed |
| 04_visual_states | passed |
| 05_auto_degradation | passed |
| 06_actual_narrow_layout | passed |
| 07_physical_resize | passed |
| 08_retained_nodes_models | passed |
| 09_edit_selection_undo | passed |
| 10_focus_scroll_pending | passed |
| 11_modal_popup_hierarchy | passed |
| 12_global_modal_keys | passed |
| 13_explicit_file_atomicity | passed |
| 14_independent_build_run | passed |
| 15_source_cjp_delivery | passed |
| 16_original_gui_provenance_restoration | passed |

The actual new GUI host was X.Org `:199`, xfce4-terminal `1.1.4`, loaded VTE `0.80.1`, using the independently built ELF SHA `3887d29ff5728afae5cb9ab2b5a344ed10274645fd3079ae7a2a6659e50d4940`. The finite executor used nine synthetic PTY processes; these are not nine GUI hosts. Prior accepted XTerm/basic-SGR and VM tty1/font fallback evidence is reused only for unchanged core paths and remains explicitly referenced in the prior R22/021 archive; those older PNGs are not relabeled or duplicated here. See the sealed acceptance reused-base audit inside the raw archive for exact bounds.

The 23 original, unmodified full GUI PNGs remain individually browsable under `browse/theme-showcase-gui/raw/session/`; 21 are 817×458, one 417×230, and one 177×116. Their individual SHA, byte count and dimensions appear in the original manifest and unchanged `png-manifest.json`. Four-theme prepared/modal/popup, explicit file load/failure/reload and physical resize evidence includes complete grid/style/raw bindings. The 28 GUI gzip mappings and finite frame mappings retain both unchanged gzip/map data and verified original decompressed raw members.

Main-session terminal restoration, termios equality, cursor-mode reply and direct product exit evidence are primary. Main `/proc` maps/exe reads were denied; a separate short same-ELF/profile live launch supplies provenance only and does not repeat the four-theme interaction matrix. Original failed access attempts and the initial incorrect HighContrast spelling predicate are preserved. Selection is proven by selected `Q`, subsequent `X→Xuery`, and `Ctrl+Z→Query`; an older undo-history entry was not separately exercised in GUI. The sample Run action shows pending state, not completed worker work; AC021 supplies separate worker proof. Original review R1 and red attempts remain preserved alongside its independently reviewed modal-dispatch closure.

`raw-evidence.tar.gz` is one lossless archive with safe relative regular members. `original-manifest.json.gz` maps each original absolute path plus SHA to its member, original bytes and mode (or explicitly unavailable historical mode), Git/gzip resolution and identical retained browse copy. It also maps sealed index references, exclusions and prior-proof references. `archive-index.json` pins the sealed intake hashes, artifact hashes and counts; `checksums.sha256` covers all publication files. No original report/index has been rewritten and no old R22/027 or archive baseline has been replaced.

Generated artifacts are explicitly excluded with original path/SHA/bytes/reason: producer old/final gzip ELF witnesses, direct historical ELF paths, the finite ELF, generated native link archives, SDK/runtime/host tools and CJP `29cab0f8de79a3b42ebc6a8bf7e2c2648217b565ccbc0e03f77f4cb915852c7a` (179148 bytes). Producer ELF `dc10aee0…` is physically absent at its old path; its gzip witness was verified before exclusion. Finite ELF `3887d29f…` is physical. Witness maps and decompression SHA audits are retained; excluded bytes are not deleted from intake. This payload does not provide portable total dependency closure or public recovery of excluded binaries. Input data archives are retained as data, rather than excluded by extension. Canonical source/package baseline publication is separate.

Publication checks verify all archive members and browse copies against the manifest, original PNG count/hash/dimensions, Git snapshot bytes, raw gzip mappings, and unchanged old worktree files. Repository/configuration/link/task checks pass on the main checkout; sparse archive worktree validation separately checks all added Markdown links without changing sparse configuration. No input inconsistency or publication blocker remains.
