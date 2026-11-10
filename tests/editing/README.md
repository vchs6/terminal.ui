# TASK118 public editing contract

`cjpm.toml` is a normal path-dependent executable consumer. `bash run.sh` builds the current `cjtui` library and executes the consumer's **direct binary** only after all E001–E005 prerequisites are present. A failure from missing Session/Canvas/interaction/Keyboard prerequisites is not editing RED. `bash run.sh --selftest` only checks independent fixture mechanics and hand-written oracle rows.

`src/` tests the planned public surface without private editor imports or synthetic session results. The source is prepared for TASK118, not admitted as a passing suite. The current executable intentionally does not run `Applied`: no actual adapter supports confirmed clipboard application. The table in `fixtures/oracle.py` records the exact future policy expectation without faking a production backend.

`handshake.mjs` creates a real concurrent Worker gate with explicit READY/GO/WRITE/COMMIT messages and no timing sleeps. `pty.mjs --selftest` sends exact paste bytes through a real PTY. These prove fixture mechanics only. The editor currently exposes no public point between Observable source snapshot and conditional write. When 119 offers the actual operation, attach the UI actor and background writer to the gate; accept a race case only when the trace proves the source version changed inside that window and the editor reports `ConcurrentValueChanged` without overwrite, local undo, or `onChange`. Until that trace exists, this scenario stays blocked. Do not add a public test hook or fake Observable.

Additional integration recipes requiring fixed upstream interfaces are in `recipes.md`.
