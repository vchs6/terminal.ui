# TASK103 viewport tests — independent preparation

Status: **BLOCKED, preparation only**. This is not completed TASK103, admitted TASK104, or product PASS/strong B RED. Fixed base is `27f9c8c01dd4caf92dc2389a2f386231fce6464b`. Actual accepted A102, Theme088 and Session152 are unavailable; current base lacks both A and B APIs. No declaration stubs, private-node hooks, fake offset getters, cloned renderer, or forced root Frame are present.

Formal authority: `openspec/changes/implement-public-interaction/{design,tasks}.md`, B and I001–I015, TASK103.S1–S4/B01–04; Theme T004 wraps Text, input K002 codes pageup/pagedown (root binding clarification). Frozen contract hashes are in the external preparation evidence. Global task checkboxes remain unchanged.

`cases.json` maps executable preparation and explicit unfinished recipes to B01–04. `recipes.md` carries remaining actual-source integration work, including same-turn resize/new caret, Unicode/damage output, read-only contexts and error cases. Cangjie consumers use only public constructors/API, with literal expected grid/offset/trace/identity data. Mounted render and snapshot are each checked against the same explicit literal grid in the dedicated policy case.

Run after loading SDK1.2 and providing the local ignored CJPM repository config:

```sh
source /workspace/work/validation/sdk/cangjie/envsetup.sh
bash tests/interaction_b/run.sh
```

The script runs ordinary `cjpm build` in `tests/interaction_b`, then directly `TERM=dumb COLORTERM= timeout 60s tests/interaction_b/target/release/bin/main </dev/null`; expected eventual exit0 is only for assertions actually implemented in these files. Current expected build exit1 is **upstream BLOCKED**, not accepted behavior RED. No `cjpm run` exit is used. Building successfully later does not validate unfinished recipes or automatically remove admission barriers.

Real PTY recorder and limits are described in recipes. `python tests/interaction_b/pty_driver.py --self-test` checks harness resize/readback only; it never launches a product and never proves B behavior. Product mode refuses a missing binary.

Preserve existing tests. Integration must rebind this test-only diff to the actual accepted A fixed SHA, resolve any actual signature mismatch through root, compile/execute assertions without stubs, finish deferred recipes, obtain real B RED against that accepted baseline, then freeze new source/test/raw hashes. Current source syntax/type validation is incomplete because compilation stops at missing public upstream symbols.
