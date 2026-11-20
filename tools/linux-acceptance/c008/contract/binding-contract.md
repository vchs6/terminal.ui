# Executable binding handoff (source-only, NOTEXECUTED)

Use this directory's `frozen-loader.mjs` and `run-frozen.mjs` together. The operator's loader/runner are interface references only; they do not supply expected-data transformations. Example command shape for later root-authorized execution, from the final source checkout:

```
C008_TEST_INPUT_ROOT=/workspace/work/linux-final-host-test-contract/inputs \
C008_EXPECTED_PROFILE=/absolute/operator-owned/profile.json \
node --loader /workspace/work/linux-final-host-test-contract/frozen-loader.mjs \
  /workspace/work/linux-final-host-test-contract/run-frozen.mjs composition startup /absolute/owned/evidence 80 24
```

This document does not grant actual GO. Runner retains `C008_ROOT_ACTUAL_GO=1` gate and existing transport admission variables, requires cwd=`C008_SOURCE`, verifies every fixed input SHA, all four frozen transport-interface hashes, and each loaded test module's exact source before any transformation. Root's independently frozen source/SDK/dependency/binary admission and original screenshot requirements remain unchanged. Interface paths/hashes are copied verbatim in `transport-interfaces.json`; a transport revision requires explicit test-role interface rebind.

Supported group/case names: composition `{startup,interactions,minimal}`; showcase `{startup,fullCycle,retainedState,fileReload,absentFile}`; modal `{previewSwitch,popupSwitch}`. The common C008 apps are composition and showcase; minimal is additional on variable hosts and has no admitted fixed-VT profile. Startup accepts width/height; later case functions keep original signatures. VT only admits80x24 shorthand or80x25 request, both actual80x25; smaller physical startup requests fail ORACLE_GAP. Variable hosts keep exact requested dimensions.

`transform.mjs` is a frozen, exact-anchor/count-checked transformation manifest. It exports original module-local cases, guards synthetic Session.start until an actual transport is installed, and reuses original WireScreen and Screen without changing their parsers. Only colors/pty.mjs top-level synthetic artifact-directory creation is suppressed on import. Its executable entrypoint remains unchanged and uncalled. All retained full-grid comparisons, raw input expressions except the one PASTE002 multiline LF binding, worker result numbers, negative states, full-frame equality, style assertions and finalization remain in the transformed source. `validated-source/` is a syntax-checked preview, not the executable authority; loader regenerates from verified fixed originals.

Color expectation tables and80x25 literal grids are test-author artifacts. The operator cannot supply replacement expected colors, capabilities, attributes or grids. `binding.config()` reads raw facts, hashes them, derives mode/source/reason and exact standard-SGR support itself, then selects only frozen tables. Unsupported/NCV-removed attributes must be absent; exact remaining declared role attributes and logical role colors/backgrounds at those assertion cells are also checked against the independent theme palette. Missing map/unknown tokens fail closed. Native map lacking ordinary printable ASCII except`?` is an explicit ORACLE_GAP because the existing semantic predicates cannot establish business state there. `?` missing still follows formal space fallback; there is no guessed glyph oracle.

One attribute-only navigation point (modal-keys popup Down) can have no visible row update when both focus accent and underline project away. In that exact case `navigationKey` retains ordered Down/Enter delivery, applies the existing focus predicate to exact projected style, keeps full post-action modal equality, and records UNOBSERVABLE_ATTRIBUTE; it does not claim the focused Confirm or disabled-skip choice was visually proved. Other key barriers retain original update requirements. Composition's equivalent style-only wait likewise records the unavailable indication; following selection replacement/routing proofs remain required. If yellow/green Done colors project identically, exact projected equality remains asserted and UNOBSERVABLE_COLOR prevents a false distinct-color claim. Every limitation is emitted to `oracle-status.json`, console result and finalAcceptance=false; it cannot be flattened into an unqualified host pass.

## PASTE002 explicit real-host input revision

The sole real-host multiline literal in composition/interactions is now `qrcvzy\nreview 中文 👩‍💻` for every actual host. This is an authorized source binding from original CRLF to one logical LF; it is not clipboard normalization by the helper or a rewrite of captured bytes. The original47 inputs, synthetic CRLF coverage, parser/decoder, all expected grids/business/state/style/lifecycle assertions and F001 admission logic remain byte-exact. `paste-revision/packet-contract.md` and `packet-policy.mjs` freeze independent predeclared route policies and exact newly received full-packet verification. The operator helper must adopt those fixed artifacts only after independent scoped review. Four existing transport interface hashes remain unchanged until a separately admitted helper rebind. Prior actual raw failures remain failures; neither this source revision nor replay automatically upgrades an old tuple.

## F001 case admission (round1)

For a proven native VT with mapKnown=true and U+003F absent, `composition/interactions` is rejected with error.code=`ORACLE_GAP`, finding=`F001`, and case=`composition/interactions` **at the original function entry before Session construction or any input**. Space fallback legally maps `Confirm?` to `Confirm `, which collides with the still-open popup label plus padding. This binding does not replace the original confirmation-open or nested-close negative assertion, fabricate a layer state, wait for a misleading timeout, or classify this legal product profile as a product failure. Both assertions remain represented for profiles whose case is admitted. Other cases remain admitted under the earlier policy; mapped-U+003F and map-failure/Ascii profiles are unchanged. Full common nested-layer coverage is an explicit ORACLE_GAP on this conditional profile until independently specified observable evidence exists. `validate-f001.mjs` covers pre-input rejection, unchanged mapped-question-mark admission and retention of both original assertions using pure source/fixtures only. This fix awaits independent scoped re-review.

## Profile envelope schema

`C008_EXPECTED_PROFILE` points to operator-owned JSON:

```
{"hostKind":"vt|xterm|vte|tmux|screen|ssh",
 "sourceCommit":"d7e9d1445f98021a798d223de97b97b45239de93",
 "factsPath":"/absolute/path/facts.json", "factsSha256":"<64 lowercase hex>"}
```

`facts.json` must contain independently captured actual app-environment/stdout facts, not product-rendered pixels or renderer-generated expected data:

```
{"term":"linux", "colorterm":"", "terminfoKnown":true,
 "colors":8, "RGB":false, "Tc":false, "ncv":18,
 "attributeStrings":{"bold":"\u001b[1m","dim":"\u001b[2m",
   "sitm":null,"smul":"\u001b[4m","rev":"\u001b[7m","smxx":null},
 "failureReason":"", "nativeVt":true,"mapKnown":true,
 "mappedCodePoints":[32,33,34],
 "provenance":{"actualStdoutDevice":"/dev/tty1", "rawEvidence":"..."}}
```

Numbers above illustrate schema, never actual profile claims; the map example is deliberately incomplete and fails admission. Supply **all**actual mapped BMP code points (duplicates permitted) when mapKnown=true. Supply nativeVt=false/mapKnown=false for genuine app PTYs, or explicit nativeVt=true/mapKnown=false with failed-query provenance for proven VT map failure. Host kind and native stdout identity must agree; naming a process VT never creates a map. Record same-device concrete-VT/text-mode checks, kernel/map count/hash/errno, genuine UTF-8 prerequisites, actual dimensions and host/version/config/TERMINFO chain in provenance and linked immutable originals. For terminfoKnown=false, supply a nonempty formal failureReason and ncv=-1; null unavailable attribute strings. For successful entries, all six keys must be raw capability strings or null. Strings accept only corresponding exact SGR1/2/3/4/7/9 after documented ncurses padding removal. Arbitrary strings are not executed or treated supported. Invalid/unset/dumb TERM ignores direct-color declarations and has no attributes. No envelope colorMode or supportedAttributes value overrides the resolver.

## Per-session lifecycle evidence schema

Before `Session.stop` completes, the operator must materialize `<session.dir>/lifecycle-evidence.json` from existing native supervisor/transport facts, without adding an application hook:

```
{"beforeTermios":"<exact nonempty same-app-tty pre-run stty/native serialization>",
 "afterTermios":"<exact same serialization after app exit>",
 "directExit":0,"directSignal":null,
 "initialCursor":"KnownVisible|KnownHidden|Unknown",
 "cursorRestore":"KnownVisible|KnownHidden|PreservedUnknown",
 "syntheticReplyInjected":false,
 "evidence":[{"kind":"termios","path":"relative-or-absolute-original","sha256":"<hash>"},
 {"kind":"exit","path":"...","sha256":"<hash>"},
 {"kind":"cursor","path":"...","sha256":"<hash>"},
 {"kind":"input-wire","path":"...","sha256":"<hash>"}]}
```

The binding verifies exact before/after equality, real direct exit0/no signal, known cursor restoration or Unknown preservation, explicit no synthetic reply, presence of all four evidence kinds and actual linked-file hashes. Each original must identify the app process/tty and UTC; termios originals must be captured from that app's actual endpoint rather than a wrapper tty. Cursor originals must contain genuine query/reply and applicable exit controls, or genuine no-reply/timeout and no invented restoration. Input-wire originals must distinguish controlled user input from actual host replies and prove no injected DECRQM response. Hash checks establish file identity, not independently authenticate the operator's semantic transcription; acceptance reviews those raw originals. Missing/unsupported transport fields fail INSUFFICIENT_EVIDENCE rather than silently removing the assertions. Existing VT keyboard restoration and2004 wire checks remain in addition to these lifecycle assertions.

The external transport may add only evidence collection/materialization needed by these fixed schemas; it must not alter test/profile oracles. `save()` additionally archives `oracle-status.json` even when original assertions fail. Actual failed assertions retain the existing exceptions/timeouts and original raw/frames capture. No exception/cancel/shortwrite host duplication is introduced; previously accepted unchanged full-offset evidence remains a separately linked requirement.

## Preparation validation scope

`node validate-source.mjs` is permitted pure test-source/fixture arithmetic validation: it checks all exact replacement anchors, independent profile resolution, color literal selection, VT glyph facts,80x25 frame selection and unknown-token/dimension rejection. It writes transformed previews only. `node --check` on five binding/validation modules and seven previews checks ESM syntax. Neither imports/runs the application test modules, transports, Screen parser, product binary, probes or real hosts. These preparation checks passed; all actual-host cases remain NOTEXECUTED and final acceptance false.
