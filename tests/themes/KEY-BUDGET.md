# TASK085 T009 encoded-key resource supplement

Append-only test source at BASE `51a22fee9732a6d53affd05dd1eaa63e3d58ce2e`,
from canonical frozen design SHA256
`084b1623937055426e0e7c57c2cc5b9cfa2e474a787ce7e81fee3cea286c30a4`.
The source budget measures each upstream key token's raw UTF8 `value`, excluding
Lexer-removed delimiters, preserving escape spelling. Semantic equivalence
applies after that budget. The independent schema identifier limit stays128.

Use the existing `./tests/themes/run.sh all --logs LOGDIR` (SDK1.2, official
stdx, private ignored registry/cache config). Existing generate_inputs imports
the new input-only generator, and capacityBoundaries calls the new public
Theme.parse assertions. All former assertions and Glyph/preset source remain.
Missing Theme prevents execution and must never pass the negative gate.

| Source payload | 1024-byte arithmetic | 1025-byte arithmetic |
|---|---|---|
| bare/basic/literal ASCII | 1024 a | 1025 a |
| basic/literal Unicode | 341×3 + 1 | 341×3 + 2 |
| mixed Unicode/ASCII | 170×3 + 514 | 170×3 + 515 |
| basic key with literal `\u0061` spelling | 170×6 + 4 | 170×6 + 5 |
| basic key with literal `\U00000061` spelling | 102×10 + 4 | 102×10 + 5 |
| escaped quote or backslash | 512×2 | 512×2 + 1 |
| quoted punctuation `a.[{}]` | 170×6 + 4 | 170×6 + 5 |

Each of the11 spellings appears at1024/1025 in all6 contexts: ordinary, dotted,
table header, array-table header, inline table and array-contained inline table
(132 inputs). Every1025 case expects CapacityExceeded before full Parser/schema.
Every1024 generic case expects downstream UnknownKey, except array-contained
inline under text which expects InvalidType at text. Those are budget admission,
not successful schema parsing; array-table acceptance is never required.

The generic keys intentionally are not supported root/property names. The
variables/styles identifier limit cannot obscure their1024 budget: generic
root/property keys have no identifier-length gate. Escaped quote/backslash/
Unicode semantic keys are independently transcribed in Cangjie for downstream
keyPath. Quoted punctuation stays one key segment, never a false path/depth.

Additional ordinary declarations under styles and variables use otherwise
valid schema: direct103 a is admitted;103 literal `\U00000061` spellings have
1030 source bytes and are CapacityExceeded despite the same valid103-character
semantic identifier.102 spellings plus4 a gives1024 source bytes and106 decoded
a: this is a real successful Theme, queried with the public typed StyleRule.
The same plus5 a is1025, decoded107, and must fail the lexical budget. No case
needs to cross the128-character identifier limit to demonstrate the difference.

Six legal within-budget key spellings have the same independently specified
bold=true rule.1030-byte escaped value,1025-byte literal value,1026-byte Unicode
value and two long-comment controls are valid. New documents are all<4096 bytes,
have at most a handful of declarations/containers, and stay far below token,
path16, depth16, variables4096 and styles4096 budgets. Comments still count
normal upstream tokens; this does not change the old comment-token boundary.

Capacity errors must retain source identity and a nonempty bounded Rune range
overlapping the offending raw key spelling; line/column must agree with those
source Runes. No decoder is used to predict guard keyPath, and no unstated
exact delimiter-length convention is imposed. Schema errors check the decoded
semantic keyPath. No fake Theme, shadow Lexer/Parser/guard or expected-output
snapshot generator is provided. Generator assertions only check byte arithmetic.

These are future product assertions until actual cjtui.theme is available.
Missing-package RED is distinct from escaped-budget behavior RED, and neither
missing API nor generated input arithmetic constitutes a product GREEN.
