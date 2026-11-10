# Exit oracle fixround2 evidence

Fixed test commit: 4c879e28187644cdf3d5c891858629555a7a4cf9 (parent 3385157).

The old decision branch is preserved exactly in historical-run.sh and executed by legacy-exit-oracle.mjs through /bin/sh. This is a narrow black-box execution of the existing exit predicate, with legal materialized recorder/host input files; no terminal matrix, fake product, or generated screenshot is involved.

Commands from /workspace/work/auto-harness-repair:

```sh
CJTUI_EXIT_ORACLE=/workspace/work/auto-harness-repair/evidence/fixround2/legacy-exit-oracle.mjs \
  node --test tests/terminals/verify-exit.test.mjs  # RED: 6 failures, including both requested counterexamples
node --test tests/terminals/verify-exit.test.mjs   # GREEN: 7/7
node --test tests/terminals/*.test.mjs             # GREEN: 25/25 tool checks
sh -n tests/terminals/run.sh
node --check tests/terminals/verify-exit.mjs
git diff --check
```

The input files under cases/ and counterexample-results.json retain exact commands, stdout, stderr, and exit status for independent replay:

| Recorded child | Recorded outer | Host wait | Expected application outcome | Old decision | Fixed decision |
| --- | --- | --- | --- | --- | --- |
| 7 | 7 | 0 | exception/nonzero | exit 1: wrongly rejected | exit 0: accepted |
| 0 | 0 | 7 | exception/nonzero | exit 0: wrongly accepted | exit 1: rejected |

The fixed helper validates one legal 0..255 exit_status in each recorder, requires equality, and then checks the expected application result. It validates and records host wait evidence without using it to infer the application's result. Further black-box tests cover normal-success expectation, inconsistent recorder values, malformed/missing/duplicate/out-of-range values, malformed host evidence and invalid expected outcomes.

The two case input files are controlled oracle fixtures, not claimed real host execution. No matrix, product build, or GUI was rerun. Existing timeout, restoration, fence and screenshot assertions remain in place. run.sh includes verify-exit.mjs in the harness hash and saves both host-wait-status.txt and exit-verification.json per real execution.
