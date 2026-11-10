# F007 independent regression handoff

Fixed test-only output: `fc690c68ee4240a4b94e55aa163e9d12b76404a0`, 3 test files, 92 added lines. Earlier assertions are unchanged. Cherry-pick only this test commit. Local dependency pin `6da9c0c1444d1ac98a38adeecfff4fca1a981755` is not part of the test output.

The tested library source is fixed main candidate `19b620f206e37be42ef387020ee8b441b27246f3`, equivalent to original product `0aa92652e9756770a8b4c6942fd80c5e86af6e76`. Git blob listings for src/native/build.cj/cjpm.toml from all three locations (main/original/local) compare identically. Listings are raw/f007-{original,author,local}-product-tree.txt; SHA-256 `2cc32cedcf3941552c053e8cc32700906754b726551843583372355e495b69f4`. Only fixed-version metadata/source dependencies were used; no product-author analysis, probe implementation, or development repair was read/run.

The independent public cases distinguish the owner A failure boundary from B's correct precondition rejection. An A post or getter tries B.snapshot. The test records/rethrows the actual UIException object, and checks B's original ref/subscriptions plus a later B→B2 update before checking A. A must dispose its own generation, cleanup, bindings/subscriptions and queued owner work; no-cleanup errors must retain exact original WrongUIContext object/type. With cleanup failure, UICleanupException must retain that exact object as primary and the original cleanup exception as its single additional failure. Object identity uses SDK std.core.refEq, whose exact public signature was confirmed with Cangjie Skill search_docs. The getter case uses ordinary saved getter data plus public Content notify, then A.snapshot. No private hooks, source-name assertions, random scheduling or generated expectations participate.

## Commands / actual exits

Each raw prefix includes exact command/cwd, UTC start/end, HEAD/source hash, stdout, stderr and actual exit.

| Prefix | Result |
| --- | --- |
| `f007-product-normal-build` | ordinary fixed library CJPM build **0** |
| `f007-core-normal-build` | ordinary independent consumer CJPM build **0**; only two previously retained test warnings |
| `f007-red-post-cross-session` | focused direct binary **1** |
| `f007-red-post-cross-session-cleanup` | separately selected focused direct binary **1** |
| `f007-red-getter-cross-session` | separately selected focused direct binary **1** |
| `f007-facility-check` | syntax/whitespace facility checks **0** |

All three REDs first pass B's correct WrongUIContext rejection, retained original ref/subscription and successful B2 frame assertions. Actual A state in all three is: ref valid, cleanup count 0, mountedNodes 1, activeBindings 1, subscriptions 1, pendingPosts 0, queuedRuns 0. Each fails explicitly at `uncaught WrongUIContext from owner callback/getter disposes A`. The raw primary message is `another session owns the active callback`. The post+cleanup variant does not reach cleanup or aggregation on the fixed candidate; the future passing source assertions still require primary identity and additional cleanup aggregation. No failure is inferred for B or for cancellation of the already extracted later queued action.

Focused selections are `CJTUI_RUNTIME_CASE=post-cross-session`, `post-cross-session-cleanup`, and `getter-cross-session`, executed directly from the ordinary built binary under a 30-second timeout. Each ran in its own process and ended by assertion failure, not timeout. No full old suite or CPU baseline was repeated. The prior explicit cross-session rejection tests were retained.

Fixed source manifest: raw/f007-test-source.sha256; SHA-256 `03b618ef98a9b796f358cbe3e54d4fadd047e416b599a0d5c705bfe84e21872f`. Generated lockfiles were retained under raw/f007-locks and removed from the clean working tree. Requested role configuration remains Sol/high; actual serving identity remains independently unobservable. This handoff records fixed-candidate behavioral RED, not repaired-product GREEN or acceptance.
