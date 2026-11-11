# TASK086 scoped round1 review

**Spec: PASS_SCOPED. Quality: PASS_SCOPED_WITH_DEFERRED_MINOR.** All four original findings are **ADDRESSED** at `95c1186a8ec5b184d5d2f15af0cac2e81499ce68`. No new Critical/Important regression or blocking correction was found in the scoped diff. One unused-helper cleanup is recorded below without extending this review loop. This is not TASK087 or full Linux acceptance.

Scope: `97df09638e2912cbee3313c23c4254e0a1708a5e..95c1186a8ec5b184d5d2f15af0cac2e81499ce68`, two commits/12 changed paths, including independent regression overlay `a4d339c` = `61e531`. Theme contract SHA-256 remains `084b1623937055426e0e7c57c2cc5b9cfa2e474a787ce7e81fee3cea286c30a4`. Reviewed this complete correction diff, its immediate control-flow dependencies, regression expectations/wiring and the permitted pure raw evidence. Did not re-read the original226k diff, author reports or self-assessments; did not modify source/tests/contracts, use subagents or rerun suites. Original sealed review remains unchanged.

| Original finding | Disposition | Evidence and reasoning |
|---|---|---|
| T086-I01 root priority | ADDRESSED | ThemeDecoder constructor now uses an empty table. After schema_version/name checks, it makes the parsed variables table available for forward references; ordinary schema traversal diagnoses a non-table variables value. Three regression cases now return UnsupportedVersion/MissingRequired at the required root key, retaining source labels. |
| T086-I02 variable field order | ADDRESSED | Unknown record fields are collected rather than thrown before value validation. The existing source-order selector can now compare both errors. Forward and reversed declarations return InvalidType(value) and UnknownKey(extra), respectively; expected code/path/source/Rune locations all pass. |
| T086-I03 rejected mutation | ADDRESSED | Both setStyle overloads call checkDefinitionChange before any padding ownership mutation. Both constant/getter attempted setters are rejected with ReentrantEvaluation; subsequent original padding updates place X at(2,2), clear old positions and preserve mounted node count. Ordinary value validation still precedes replacement. |
| T086-M01 public explanation | ADDRESSED | Product theme docs explicitly say visualStates(disabled:true) only selects appearance and does not disable events/change business state; the root[text] seed example explains red parent inheritance and blue child-role override. |

The independent tests are correctly added to normal values/integration entry points. The focused runner builds two ordinary public consumers, executes each positive control before the relevant groups, preserves actual exits, and fails if any group fails. No fake Theme/parser, skipped existing assertion or generated expected result is introduced. All five test overlay files are identical to the independent61e531 artifacts and final95 source.

## Same-batch lint changes

`containsAxis` replaces a conjunction with an early rejection and the same saturating bound comparison. verifyStyleTarget computes the same pure slot predicates within the applicable primitive branch. Computing seedBackgroundDeclared eagerly reads an immutable rule and preserves the local-fill/root-seed condition. These transformations do not change behavior or duplicate resolution logic. Targeted G.ENU.01 suppressions cover the established public Text overloads and the unrelated internal ANSI Text enum case; there is no global lint bypass or public rename. Normal `cjpm bundle` ran without skip flags, exited0 and retained warnings in its original output. Its embedded zero-test summary is not counted as theme coverage.

## Independently checked evidence identity

`pre-source-tests.json` was captured at2026-11-11T04:17:32.485030+00:00, before the first focused build at04:17:32.530770. Independently compared **all201 entries** against fixed95 git blobs: all match. All12 recorded focused/values/integration/bundle commands occur after that capture and exit0. The command HEAD is the test overlay because fixes were then uncommitted; matching pre-execution hashes and the post-commit identity resolve that fact without pretending the commit existed earlier. Five environment/config records and all five focused input-source hashes also match their recorded bytes.

Read the actual positive/priority/order/binding stdout and final values/integration results. The three focused groups and both positive controls succeed; the normal values/integration consumers also succeed. The reviewer executed no runtime rerun because these source/environment/scope identities are sufficient for this correction review.

The normal bundle command is `source .../theme-glyph-tests/env.sh && exec cjpm bundle`, exit0. Compared **all175 member-hash records** with fixed95 repository contents: all match. The recorded package SHA-256 is `a093941b79d15cd61a64eb3e216494d5d1155a62c8d5414a8ebeac3dc6929e10`. This is a verified member-record comparison and inspected normal bundle result; the reviewer did not unpack/re-hash the CJP itself. The earlier bundle-c failure is retained historical evidence, not reclassified as success.

Clean unpacked SDK/stdx consumer and the broader TASK087 execution remain outside this scoped verification; no complete T012/feature acceptance is inferred merely from bundle success. This review does not retroactively remove the temporal identity limits documented for the earlier C1 logs.

## Deferred cleanup (non-blocking)

D01 / Minor: `src/theme/theme_decoder.cj:193` still defines `literalTable`, whose last call was removed by I01. Fixed95 `git grep` finds only the definition. It is unreachable internal code containing the old `<memory>` diagnostic branch. Delete it during the lead's next appropriate local cleanup; no functional regression is demonstrated and no additional review/test loop is requested for this observation. Original I01 remains addressed.

## Handoff

The original four findings may be closed for fixed95 and passed to the independent087 execution role, with D01 recorded as deferred and clean-consumer/remaining acceptance evidence tracked separately. Lightweight artifacts record hashes/commands and selected raw regression outputs; they omit source checkouts, SDKs, CJP/ELF, caches, generated fixtures and old raw trees.
