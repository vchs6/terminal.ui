# Theme / Canvas integration regression

Independent public regression for T008, separate from the B31 cases/eight groups.
Same measured tree/themes as the original limited probe, with contract assertions.
No private hook, changed formal oracle, declaration API or renderer golden.

Load the normal SDK1.2/official stdx and ignored own registry/cache config, then:

```sh
bash tests/theme_canvas_integration/run.sh
```

One ordinary CJPM build is followed by three direct timeout60s binaries. On a
correct product all exit0. Optional finite/control/subtree selects one case.

- finite4×0: legal clipped Max minima applies once, retains session/refs/state.
- Max×0 without export: candidate Failed, Old theme/ref/session retained.
- Max×0 root snapshot, mounted Canvas render(Max,0), same candidate: also Failed
  and Old retained, no later root layout exception or session stop.

On accepted baseline f8a028b: build0, finite0, control0, subtree1 at the T008
assertion after observed Applied/minimum-sum-overflow/session-close. The old
observer's process0 was observation only; this package provides actual RED.
All Frames have zero height, so no giant output allocation. Public result
determines completion;1ms yield only gives the loader worker CPU time.
No B behavior was executed or accepted by these regressions.
