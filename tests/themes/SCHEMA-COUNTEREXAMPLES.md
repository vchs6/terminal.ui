# TASK085 source-type / printable-name / source-order counterexamples

Test-only BASE `574c3a9166a649b5211c4a6c76f1515ea721d875`; canonical design
SHA256 `084b1623937055426e0e7c57c2cc5b9cfa2e474a787ce7e81fee3cea286c30a4`.
These public Theme.parse tests implement formal137,264,326,328. The separate
replay target is the unreviewed checkpoint
`0e46237c7e60d3d9e9fabb4587ac45c90321f4eb`; it is not accepted/integrated.

The former66 files keep their bytes/assertions, except three added calls at the
end of values/src/main.cj. T009151 inputs, original stress inputs, Glyph tests,
16 compile-negative fixtures and four preset bytes are unchanged.

```sh
# Existing full positive gate, including the appended functions when reached:
./tests/themes/run.sh all --logs /tmp/theme-full
# Isolated ordinary public consumer, same official assertion sources:
python tests/themes/run_schema_counterexamples.py --logs /tmp/theme-schema
```

The focused runner copies the exact new Cangjie source plus existing checks.cj
into ignored `.negative-run/schema-public`, derives an ordinary manifest from the
existing values manifest with only its relative library path adjusted, and
builds with normal CJPM. No product source is copied or changed. A real typed
Theme positive binary gate must exit0 first. It then runs three groups as
direct binaries and retains every actual exit/stdout/stderr/UTC/argv/source SHA.
Any failing group makes the runner exit1. Full original values/integration gates
are never bypassed or relabelled as passing by this focused consumer.

| Group | Independently specified assertions |
|---|---|
| source-types (139 cases) | Native offset/local datetime, date, time must be InvalidType in name, string-typed properties, nine variable literal kinds and ref-string records; all12 numeric slots reject bool/float/date/time and numeric strings; caller source label survives root variables=true |
| printable-name (7 cases) | Escaped U0001/ESC are InvalidValue; blank remains invalid; surrounding printable spaces, Unicode, emoji/ZWJ and quoted date names remain exact |
| source-order (18 cases) | Earliest error crosses dotted/explicit tables, named styles, variables, roles and refs; valid prefixes never drag later nested errors earlier; syntax/version/root-required priority and legal forward refs |

All inputs and code/keyPath/source expectations are hand-written from the
contract. Four native TOML spellings are unquoted `1979-05-27T07:32:00Z`,
`1979-05-27T07:32:00`, `1979-05-27`, `07:32:00`; quoted date name is legitimate,
while quoted date color is a string with InvalidValue. Width/height support
string `auto`, so their quoted numeric `1` is InvalidValue; plain cells/offset
slots use InvalidType. These domain distinctions must not turn native dates
into strings. Printable tests reject clear C0 controls, without banning valid
Unicode or ZWJ based on a newly invented format-character rule.

Diagnostic checks retain a non-path caller label, exact stable code/keyPath,
nonempty bounded Rune ranges where available, and line/column consistent with
source Runes. For explicitly specified literal markers with value scope, the
range must contain the corresponding raw literal. Nearest-parent/unavailable
metadata fallbacks remain allowed exactly as in the frozen contract; syntax
precedence does not invent a keyPath when the Parser cannot supply one.

Source-order interleaving uses valid new nested tables under earlier dotted
style prefixes; it does not redefine a table already defined by a dotted key.
A matching fully valid structural control proves the input shape through the
same public API. Variable collection must allow forward refs while preserving
an earlier real reference/type error. Unknown/value/ref first-error order is
measured across categories, not just within one map or table traversal.

No shadow Lexer/Parser/decoder, Theme stub, private hook, generated expectation,
product/contract/status edit or author-directory dependency is introduced.
Actual behavior evidence belongs to an independently built fixed replay, not
this source's main-branch product state. Missing API, compile failure and runtime
contract failure must be reported separately; partial-checkpoint results cannot
close085/013/025/088.
