# Generic overlay test PREPARATION (TASK108)

**PREPARATION/BLOCKED. Not a complete TASK108, TASK109 admission, product RED,
product PASS, native PASS or host PASS.** Independent test-only scope is
`tests/interaction_c/` plus its evidence. Product/spec/main and old tests are
unchanged. No standard Modal/Menu wrapper, mouse, Scrollbar or window manager.

Frozen starting source: `27f9c8c01dd4caf92dc2389a2f386231fce6464b`.
Authority: `openspec/changes/implement-public-interaction/design.md`, C with
intersecting I001–I015; tasks TASK108.S1–S4/C-01–C-05, plus its three specs. The
separate I014/I015/F007 reviews are design evidence only. Actual dependency
acceptance/source and interface-map are still missing from this test handoff.
Older accepted runtime/Rich work may exist elsewhere; this role has not received
their fixed accepting hashes and does not replace root's acceptance record.

Source consumers deliberately use normal public `cjtui.*`, Component subclass
build, Column/Canvas, NodeRef, Application and exact formal C options/handles.
`SettingsPanel` is one class in its own file, reused as distinct ordinary/layer
instances with one business Observable. There are no private nodes/hooks, extra
renderer, cloned business model or product repairs. No declaration stub is run.
Prepared source is syntax-formatted but **not type-compiled or executed against
actual A/B/C**. All source and recipe status is enumerated in case-matrix.md.
golden.md records manually derived literal grids, trace, focus and identity.
native-host-recipe.md explicitly separates future real evidence and infrastructure
negative controls. Recipe-only vectors must be finished before a formal freeze.

Source SDK1.2 environment, then use the ordinary entry:

```sh
source /workspace/work/validation/sdk/cangjie/envsetup.sh
bash tests/interaction_c/run.sh preparation
# Current expected status: 77; prints every actual-source/test-freeze blocker.
bash tests/interaction_c/run.sh
# Current expected status: 77, with NO overlay build/execution.

# Separate existing-public-API sanity only, already available at the base:
bash tests/interaction_c/run.sh baseline
# Internally: cd tests/interaction_c/baseline; cjpm build
# TERM=dumb COLORTERM= timeout 45s ./target/release/bin/main </dev/null
# Expected direct status: 0. Does not use any overlay API or prove C behavior.
```

Own ignored `cangjie-repo.toml` is needed in root, this consumer and baseline,
using an own writable cache seeded read-only from
`/workspace/work/validation/replay-dependencies/cache` and existing registry
`http://127.0.0.1:18973`. No SDK, relay or product dependency is added. Tests do not
modify the seed. Current role's cache is `/workspace/work/overlay-tests/cache`.

When root supplies actual accepted inputs and public signature mapping, this
same test role resumes: finish recipe sources through those public APIs, compile
normally, retain baseline GREEN and actual missing-C RED/error classification,
freeze test-only commit/manifest. Only then update admission.tsv with accepted
source commits present in the tested history and actual fixed evidence paths.
`TEST_FREEZE` remains PREPARATION until that work is done. There is no environment
bypass. Root must not mark all rows accepted just to run these prepared sources.
With real inputs frozen, formal entry internally runs:

```sh
cd tests/interaction_c
cjpm build
TERM=dumb COLORTERM= timeout 45s ./target/release/bin/main </dev/null
```

Compiler/linker errors, nonzero actual binary exits, timeouts and missing binary
are failures. Missing accepted upstream APIs before that barrier are BLOCKED,
not target overlay RED. Declaration-only compile can prove SDK language shape
only, must use separate isolated paths, and must never be run as product.
`cjfmt` may report syntax errors while returning0: both stdout/stderr must be
checked; formatting alone never proves type correctness.

Tools-only gate negative control: `bash tests/interaction_c/gate-selftest.sh`.
It confirms both entry modes return77 without invoking a sentinel compiler,
and invalid mode returns64. It does not build or execute any product stub and
cannot establish overlay/native/host results.
