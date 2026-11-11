# T009 key-byte budget: independent decision review

Decision ID: T009-KEY-BYTES-20261111. Scope: only the 1024-byte key-segment resource budget, upstream public API facts, and required test additions. This is a decision review, not a product implementation review or acceptance of TASK-013/025. No fixed candidate product was supplied or reviewed. No product Parser was executed; no upstream Parser.parse was executed, including on small inputs.

**Recommendation: A is legally implementable with an explicit contract clarification.** No existing explicit decoded-byte promise or mandatory fixture contradiction was found. The existing wording does not yet specify encoded versus decoded key bytes; do not silently implement A under the ambiguous wording. The authorized lead may adopt this reversible engineering clarification after recording the decision. B cannot be implemented through a public segment-decoding API in the fixed upstream version under the current constraints. C changes frozen budgets or creates an unapproved parsing route.

## Independent inputs and method

Read the sole candidate, formal design line 139, T009 (406–408), T016 (432–434), original 085 generator/capacity assertions, and unchanged upstream cangjie_toml 0.2.3 sources. Read project governance and Battle protocol. Did not inspect theme implementation author directories, author reports, or self-assessments. Evidence is frozen by input-hashes.json; repository commit at capture was 51a22fee9732a6d53affd05dd1eaa63e3d58ce2e. Main files were read only. No subagents used.

Used configured R11 normal SDK environment, cjc/cjpm 1.2.0, x86_64-unknown-linux-gnu, official stdx 1.2.0-beta.02.1, and a private dependency cache at /workspace/work/theme-key-budget-review/cache. The dependency manifest uses ordinary version dependency cangjie_toml=0.2.3; original registry index and source were copied to this independent cache. Every upstream .cj source is byte-identical (dependency-source-identity.json). No fake lexer or hand-written TOML escape decoder. The Cangjie probe only reads a fixture and emits public Lexer.nextToken() fields. Python generates literal inputs and checks exact output payloads; it does not parse or decode TOML. Decoder visibility probes compile, but never execute, calls to the two private members.

## Evidence and observed facts

- Final build: exit 0. Compiler and manager versions and UTC are in raw/sdk.txt; commands are build.sh and run_negative.sh; per-command UTC/exit/output files are in raw/.
- 40/40 public Lexer probes: exit 0 and exact expected token payload/type/UTF-8 length. Each record in probe-results.json includes command, UTC start/end, exit, input SHA-256, expectations and all raw tokens. Raw byte payloads are emitted in decimal, preserving escaping unambiguously. run_probe.py is the runner.
- First probe build failed solely because a Cangjie Int64 main requires a final return after while(true); its source/logs/exit 1 remain in raw/build-attempt-1. Final source adds return 3. This was probe scaffolding, not an upstream failure.
- Bare key -> Text; basic quoted unescaped -> String; basic escaped -> StringEsc; literal quoted -> RawString. Quotes are excluded from token.value. Empty quoted key has zero-byte payload.
- Backslash-u spelling `\u0061` is six ASCII bytes in StringEsc; `\U0001F600` is ten, not four; escaped quote and backslash retain both bytes. Literal `'\u0061'` remains six bytes of RawString, with no escape semantics. Mixed raw Unicode and escape spellings preserve their original UTF-8 bytes.
- Same token payload behavior holds in ordinary keys, dotted keys, table and array-table headers, inline tables and inline tables in arrays. Dot/bracket punctuation inside a quoted key stays inside one token. Value tokens can have the same token types and lengths: StringEsc alone does not identify a key.
- String.size equals token.value.toArray().size for every observed token, including raw Unicode 1024/1025 fixtures. Implementing UTF-8 size with these SDK fields does not count runes or delimiters. Explicit toArray().size is semantically clear but unnecessary allocation when String.size is used under this SDK contract.
- Source public-api-inventory.txt plus parser excerpts show Parser.keyString, value, asciiEscapeToUnicode and replaceEscapes are private. External SDK builds calling keyString and replaceEscapes both exit 1 with “is not a member of class Parser.” Parser.current only exposes lexical text. Key.raw/lastRaw return supplied values; Key.iterator/toString and public escapeKey encode key spelling and cannot decode Lexer payload. FromToml/DataModel.fromToml execute the full Parser, so they are not a guard decoding route.

The source/API inventory and negative compile probes establish absence of a usable public TOML key-segment decoding API in this fixed package. They do not prove that no future upstream version can expose one.

## Battle: alternatives and contract tension

| Option | Feasibility under frozen constraints | Decision |
|---|---|---|
| A: byte count of upstream key token.value, excluding delimiters, retaining escapes | Direct public field; no decoder, new parser, tree, or dependency; all original 085 key boundary assertions preserved | Recommend after explicit wording and independent test extension |
| B: decoded key UTF-8 byte count | Lexer does not supply decoded keys; decoder is private; public parse routes execute Parser | Blocked under current fixed dependency/API constraints; reopen if upstream public bounded segment decoding becomes available or dependency adaptation is expressly approved |
| C: remove/raise key bound, or parse synthetic per-token documents | Changes 1024 budget, or adds parsing during guard and semantic work outside its frozen role | Reject for this narrow clarification |

Line 139 says equal parsed trees have equal semantics. It must not be read as guaranteeing identical admission for all textual representations: existing total input bytes, token count (including comments), declaration count and structural budgets already depend on lexical spelling. T009 also explicitly allows resource/lexical diagnostics before semantic/schema checks. Consequently A can be clarified as a lexical admission bound while retaining equal semantics for admitted equivalent trees; it does not change identifier/schema semantics. No statement specifically promised decoded key bytes, and original 085 raw Unicode samples have identical encoded and decoded sizes.

The cost is real and must be stated: a schema-valid variable name of 103 ASCII a characters written as 103 copies of `\U00000061` has 1030 token bytes and fails A, while its plain spelling has 103 bytes and passes this resource gate (also within the separate 128-byte name policy). This input is in the evidence as schema-valid-escaped-1030 and schema-valid-plain-103. The upstream lexer facts are executed evidence; full schema success and product diagnostics are test requirements, not product results claimed here. Implementing A without clarifying this domain would leave a misleading equivalence statement. The lead must make that wording concrete before handing the budget implementation to the author.

B would preserve representation-independent key size, but adds no protection against expensive encoded spelling beyond the already separate 1 MiB input bound and cannot be sourced from the current public Lexer. Copying replaceEscapes, counting decoded bytes with a new escape scanner, or round-tripping a synthetic TOML document are not harmless implementations of B: they violate the fixed single-lexer/pre-Parser guard boundary. An upstream change could be legitimate future work but is not needed to resolve this narrow resource policy now.

## Exact recommended wording

T009 replacement/addition:

> 单个键段的词法资源预算为 1024 个 UTF-8 字节（含边界）。计数对象是固定上游 public Lexer 发出的、处于键位置的段 token 的 value；语法引号不计，反斜杠转义及 Unicode 转义按其原始拼写计数，不解码、不规范化。普通键、dotted key 的各段、普通表/数组表头各段、inline table 内的键段使用同一规则；字符串值与注释内容不作为键段计数。超过预算返回 CapacityExceeded；达到预算仅表示通过该资源门限，仍需满足其他预算、TOML 语法及 schema。该词法预算不同于解析后 variable/style 名称的 1–128 字节语义约束。

Line 139 clarification:

> 输入通过全部资源预算后，字面 key、quoted key、dotted key、inline table、普通 table 只要解析后的树完全相同就语义相同。资源预算按各自规定的输入/词法对象计量；等价的转义拼写不保证具有相同的预算占用。

Public user documentation should state the same 1024-byte lexical measure, including an escaped-versus-plain example. Keep all other budgets, schema keys, name limits, diagnostics precedence, and Parser responsibility unchanged. No authorization question is necessary under the supplied engineering-decision delegation.

## Minimal independent product-test additions

All cases remain well below unrelated limits. “Admit” below means pass the key-byte gate, not necessarily a valid theme. Preserve original 085 assertions and fixtures unchanged. Full product tests belong to the independent test role; the probe here did not implement a guard.

| Input family | Payload construction | Expected gate / independent assertion |
|---|---|---|
| Original raw Unicode, basic quotes | 界×341 + x / xx | 1024 admit (original UnknownKey); 1025 CapacityExceeded |
| Bare and literal quoted boundary | a×1024 / a×1025 | 1024 admit; 1025 CapacityExceeded; delimiters excluded |
| Short Unicode escape boundary | `\u0061`×170 + a×4 / a×5 | 1024 admit; 1025 CapacityExceeded although decoded sizes 174/175 |
| Long Unicode escape boundary | `\U0001F600`×102 + a×4 / a×5 | 1024 admit; 1025 CapacityExceeded although decoded sizes 412/413 |
| Escaped quote and backslash | `\"`×512 or `\\`×512, with/without final a | 1024 admit; 1025 CapacityExceeded; no delimiter stripping from payload |
| Every key context | Repeat short-Unicode pair at dotted, table, array-table, inline, array-containing-inline position | Every 1025 rejected; every 1024 passes this gate; no partial/missing context coverage |
| Value-position control | schema_version=1; name set to a 1025-byte raw or escaped printable value | Does not fail key-byte gate; use a schema-valid display name and expect successful parse |
| Comment control | Valid minimal theme plus comment containing >1024 bytes or quote/dot/bracket sequences | Does not fail key-byte gate; comment still counted by existing token budget |
| Exact equivalence-domain boundary | Valid [variables] entry using a×103 versus `\U00000061`×103 | Plain accepted; escaped 1030-byte key CapacityExceeded; 128-byte semantic name limit is unchanged |
| Within-budget equivalence | A short valid variable name spelled plain, basic/literal quoted, and with u/U escapes | Same parsed Theme semantics and resolution after admission |
| Literal backslash / quoted punctuation | `'\u0061'`, `"a.b[{]"`, empty quoted key | Preserve literal payload, no path inflation; downstream schema diagnostic rather than false capacity |
| Mixed Unicode and escapes | Raw 界 plus `\u0061`, padded to 1024/1025 bytes | Count UTF-8 bytes, not rune count or decoded bytes |

The existing 40-case upstream probe covers token facts for most of these families. It does not substitute for public Theme.parse tests proving gate routing, diagnostic position, schema results, or unchanged budget precedence.

## Readiness and remaining obligations

Decision readiness: sufficient evidence to select A; no blocking existing explicit contract contradiction. Implementation readiness is conditional on the lead recording the choice and applying the exact lexical-domain clarification plus independent test handoff. This is not a request for additional user permission. No product quality/PASS result is issued. B remains blocked by public API availability, and C remains outside current scope.

Reopen if a previously overlooked decoded-byte promise or mandatory decoded-boundary fixture is produced, upstream token payload semantics change, or a safe public decoding API is adopted. Preserve decoder privacy and keep syntax/duplicate-key semantics in the original Parser.

Archival package: curated/ contains only report/findings, manifests and source-text probes, generator/runner, fixed inputs, text/JSON logs, source excerpts and hashes. It excludes SDK, CJP, ELF, dependency cache/checkouts and credentials. artifacts.sha256 covers curated files and is itself outside the hash list; copy the directory with its manifest together.

## Final formal wording verification after lead decision

The lead selected A and requested a narrowly scoped reread of the actual formal wording. Checked the new line 139 plus the appended T009 key-segment clarification at the UTC in final-wording-review.json. **PASS_NARROW_FORMAL_WORDING**: the clarification accurately satisfies the formal wording condition above. It explicitly retains escapes, excludes Lexer-removed quotes, measures only key positions, includes every specified key context, distinguishes semantic name limits, and gives the correct 1030/103 representation example. The inline escape example contains one literal backslash, as required. The product-documentation obligation is explicitly recorded.

Frozen final design SHA-256: `084b1623937055426e0e7c57c2cc5b9cfa2e474a787ce7e81fee3cea286c30a4`. Complete final design snapshot and exact diff against base commit are in source-evidence/final-formal-design.md and final-formal-design.patch. This subsequent verification closes the formal wording prerequisite described earlier; those paragraphs describe the original candidate review. Independent product test additions and eventual product documentation/implementation verification remain required, and this review still makes no product PASS claim.
