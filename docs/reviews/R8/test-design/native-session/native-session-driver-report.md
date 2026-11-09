# Native-session driver integration

Input integrated revision: 32010ce.
Independent test-only commit: 1f6210e2ea39cf9a4e17dd51e26098d904943fdc.
Only tests/run-slice.sh and tests/README.md changed. No product or assertion changes.

The unified driver now accepts native-session and default all runs that mode first,
which calls tests/native-session/run.sh without arguments (both owner/setup-signal).
The existing CI slice -> all path therefore includes both native regression cases.

Verification:

- bash -n tests/run-slice.sh tests/native-session/run.sh: exit 0.
- git diff --check and staged diff check: exit 0.
- source SDK 1.2.0 then ./tests/run-slice.sh native-session: exit 0.
  Actual owner open1=0/open2=-1, restored=1; setup signal read=-2, restored=1.
  Raw log: native-session-driver.log. This runs only the lightweight C tests;
  no unchanged full SDK consumer build/suite was repeated.

Existing RED evidence remains native-session-red.log/native-session-report.md at
product baseline 2794136. The entire tests/native-session subtree is unchanged
from its frozen e2cdf963 test commit (git diff empty). Thus those RED observations
remain evidence that these same assertions detect the original bugs; they are not
misrepresented as current product behavior. The new current driver run verifies
connection/status propagation and the two C outcomes, not full product acceptance.

Working tree clean after commit; no remote push or additional delegated work.
