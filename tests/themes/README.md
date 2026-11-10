# TASK-085 public theme foundation contract tests

These are independent consumers of `cjtui`, `cjtui.style`, and `cjtui.theme`.
They do not access Runtime/LayoutNode/resolver internals or provide a substitute
Theme, TOML parser, renderer, or scheduler. Tests were authored from
`implement-theme-styles/design.md` §§2–6, 9–10, especially T001–T015, and the
four frozen fixture files. The original contract revision is
`d4a92238db8abe703f23d74bbbee18b4fbfbc7c4`.

The main agent subsequently froze the SDK-driven spelling `withValue` in place
of the unimplemented member `with`, with the same typed signature and semantics.
SDK 1.2 treats `with` as a keyword in both declarations and member calls; the
original compiler errors are preserved in the author's external evidence.
This test tree uses `withValue` throughout. The fixed clarification revision is
`5c150ec36bdbb275c722c970b7cc66ed6a4c8f36` (T016 and exact token/declaration
counts); the original T001–T015 semantics and all four fixture bytes are retained.

## Run

Use SDK 1.2.0 and the product's declared official stdx environment. The current
independent environment can be selected with:

```sh
source /workspace/work/validation/sdk/cangjie/envsetup.sh
source /workspace/work/linux-build-recon/env.sh
./tests/themes/run.sh all --logs /tmp/theme-foundation-evidence
```

For a clean external execution role, supply its own dependency cache and ignored
`cangjie-repo.toml` in the library, `values`, and `integration` projects. Neither
an author's target nor a declaration scratch library is an input to this runner.
The test manifests use only a normal relative path dependency on the library.
The commands `run.sh values` and `run.sh integration` select individual groups.
`run.sh negative` first builds **and executes both real positive consumers**;
then it checks the compile-failure fixtures. `all` has the same gate. A missing
package, SDK/configuration failure, or accepted forbidden program cannot count
as a passing negative test. Negative fixtures are never run as executables.

The runner saves independent UTC, exact argv/cwd, checked git SHA, stdout,
stderr, process exit, test-source hashes, and generated-input hashes under
`--logs` (or a fresh temporary directory). It invokes the built binary directly
so a failed test's actual exit cannot be concealed by `cjpm run`.

## Coverage and independent expected values

| Group | Contract and failure caught |
|---|---|
| `values/value_semantics` | Immutable content equality, insertion-order independence, presence of false/zero/Default, Unset versus Reset, state identity, typed value/enumeration equality, invalid programmatic numeric/alignment validation |
| `values/schema_fields` | Every one of the 36 v1 properties: literal, disabled state, Reset, wrong type, typed key name and direct state-slot value query; expected rules are written in typed Cangjie, never obtained by parsing a second source |
| `values/schema_references` | All ten variable value types, forward refs, all named colors, all 17 roles; semantic equivalents of quoted/dotted/inline keys |
| `values/schema_failures` | Required/version/unknown/type/name/range/applicability/ref failures, unused invalid variables/styles, source-order first error, duplicate normalized normal property, Int64 bounds and legal TOML numeric forms |
| `values/diagnostic_locations` | Stable code/source/keyPath, known ref location retained, Unicode Rune offsets consistent with line/column, reference-value rather than variable-declaration location, no fabricated read-error position |
| `values/source_paths` | Immutable read-only bridge values, missing/invalid name lookup, parse label versus File source, absolute frozen source identity, literal `~`, `$HOME`, `${HOME}`, and URI-like filename reads, empty/NUL paths, invalid UTF8 |
| `values/capacity_boundaries` | Byte, depth, cumulative effective path, token, declaration, key-byte, variable, and style limits; below/at/over cases where applicable; 10,000-deep small input must return CapacityExceeded rather than reach unsafe Parser recursion |
| `values/presets` | Both fixed TOML and built-in factories compared to independently transcribed text/decoration/spacing/named/modal/state rules for all four presets; absence and case-sensitive lookup tested |
| `integration/source_and_state_cascade` | Four sources resolve each text field independently; state fallback, later named normal over earlier disabled, Reset terminates, Unset reveals normal, Inline and non-text precedence |
| `integration/inheritance_and_fill` | Root seed versus child role, text-only inheritance, bg-only root fill versus full-style local Value/Reset fill, inherited background does not fill, Classic inverse/underline trailing blanks, root clip/visibility, equal background with changed fill source invalidates |
| `integration/decoration_cascade` | Derived border foreground Reset versus Value(Default), eight separate shadow slots, shadow convenience does not pollute body, non-inherited shadow |
| `integration/spacing_cascade` | Auto versus clearing explicit width, minimum/fixed constraints, all four padding zeros/Reset, theme gap/alignment/weights/text layout feed actual Frame |
| `integration/layout_and_wrap` | Actual Row/Column allocated width, natural heights and sibling positions, four padding sides, width-zero hard lines, oversized whole-cluster lines, CRLF, combining clusters, explicit height/viewport constraints, ellipsis at right edge without partial clusters or vertical-hidden indicators |
| `integration/rich_text_masks` | Span versus reusable source, explicit masks win fieldwise, same resolved base with changed explicit mask still repaints, false/Reset/Unset distinctions |
| `integration/applicability_and_aliases` | Names and actual primitive applicability, role cannot change primitive kind, capability-projected global defaults, styles input copied/cleared, post-mount role rejection |
| `integration/preset_frames` | Hand-written two-row grid and exact body/accent/blank Styles for Dark, Light, HighContrast, Classic |
| `negative/*.cj.txt` | Wrong key/value/getter types, string property bags, forged key constructors, public Theme construction, writable metadata and mutable rule/theme tables are rejected by the actual compiler |

All pixel golden strings and concrete Styles are hand-derived. No expected
Frame is rendered by the SUT, no expected rule is read back from it, and no
implementation-generated output is blessed as a snapshot. Four TOML inputs
are byte-for-byte copies of the design fixtures; `run.py` verifies their fixed
SHA-256 values before building. These inputs are not themselves evidence that
the product implements the themes.

`generate_inputs.py` only constructs source bytes. It does not scan/parse TOML
or compute schema/resolver results. Its token/declaration boundary arithmetic
was independently checked using the pinned upstream public `Lexer.nextToken()`:

| Generated input | non-EOF tokens | declarations |
|---|---:|---:|
| `tokens-at` / `tokens-over` | 65536 / 65537 | 3 / 3 |
| `declarations-at` / `declarations-over` | 49152 / 49155 | 16384 / 16385 |
| `variables-at` (4096) | 53259 | 12291 |
| `styles-at` (4096) | 20491 | 4099 |
| `comment-tokens-at` / `comment-tokens-over` | 65536 / 65538 | 2 / 2 |
| `string-brackets` | 8 | 2 |

The frozen budget counts every upstream non-EOF token, including CommentStart
and its payload Text token; EOF does not count. Each KeyStart, TableStart, or
ArrayTableStart counts once as a declaration, including inline member keys.
The exact declaration-at input intentionally reaches Parser's duplicate-table
SyntaxError, proving that the capacity guard accepted the boundary; the over
input must report CapacityExceeded first. Combined table/dotted/inline/array
inputs distinguish cumulative effective paths from local key counts and
exercise restoration of array/inline contexts. Quoted dots and punctuation in
strings/comments must not create path segments or containers.

## Current evidence and limits

Against the old library at the original contract SHA, ordinary root
`cjpm build` exits 0. The real `values` consumer build exits 1 because the
`cjtui.theme` package is absent. The positive gate therefore prevents any
compile-negative result from being counted as passed. This is missing-API RED,
not a runtime assertion failure or completed product verification.

Both consumer source trees also received a **declaration-only static compile**
check in a separate external scratch directory. The scratch binaries were never
executed, are not committed, are never selected by this runner, and prove only
Cangjie test syntax against the specified shapes. They do not prove the actual
public library API, preset parser, resolver, Frame behavior, or negative gates.

Actual integration execution waits for the fixed runtime/RichText dependencies
and the real theme product. The currently frozen high-level snapshot API does
not expose Frame's `ambiguousWide` option or an ASCII text-layout policy; Unicode
ellipsis is prepared here, while ASCII ellipsis fallback still requires a real
publicly reachable execution path. No new test-only public override is invented.
Full built-in control appearances and real four-theme host screenshots belong
to TASK-027 after its controls exist. Async load/reload/latest-requested-wins,
worker bounds, and transactional candidate submission belong to TASK-089/026
and are deliberately not claimed by foundation085.

Author role requested Sol/high; actual serving configuration is not verifiable.
TDD, verification-before-completion, and the fixed CangjieSkills search_docs
were used. Author development evidence is outside this repository at
`/workspace/work/theme-tests`; independent execution/acceptance remains required.
