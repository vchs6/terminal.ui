# TASK027 modal-close test oracle correction
Status: TEST_ONLY_CORRECTED; root will rerun against the same corrected product ELF.
Parent: 71afd32e43e279a9693c6d5c22a6dce4102960a2; test commit: dd483163bfe31ed4251ff533a005a5e2582289f6.
Cause: permanent HorizontalMenu entry `Preview` makes `!text(rows).includes('Preview')` false even after the modal closes.
Pre-fix source/manual check v1 exit 1: all four literal closed startup frames still have `Preview`; all four open modal frames also have it.
Corrected `matchesGrid` waits use existing full literal startup/modal frames for popup close, modal close and R1 modal persistence; no goldens, keys, product or core changed.
Post-fix literal oracle v2 exit 0: all four closed frames accepted, all four open frames rejected as closed, and single uncleared modal-row negatives rejected.
`node --check` modified JS, `bash -n` runner and `git diff --check` exit 0; source clean after test-only commit.
Actual corrected ELF, app build, complete PTY and GUI execution were intentionally left to the root's separate run.
Prior bb2/0648 source, reports, indices and raw evidence remain untouched.
