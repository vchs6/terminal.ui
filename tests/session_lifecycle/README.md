# TASK020.a preparation only

Fixed exploratory base: `5a6819ffd2226ad31e725669209b94607f2b1e63`.
No Cangjie/native build, product binary, PTY, host, process matrix, RED or GREEN
has been run for these tests. These files do not admit TASK020 or close any AC.
The formal baseline will be the accepted008 product source and root admission
manifest, including actual008/152/117/122/112/162/I015 inputs. That rebind and
independent review precede runtime use. 008 retains sole build priority now.

`cases.json` prepares 13 exit scenarios × visible/hidden/Unknown I015 replies,
each through two runs of the same public Application in one process. It adds no
API, writer, terminal parser, runtime, renderer, mock TTY or product hook. The
small `Box` type stores UI callback state. `RuntimeStats.frames` is never used as
a device commit counter. This suite does not repeat 008's338 bytecut cases.

The consumer opens a real nonmodal layer using public APIs, moves focus into it,
changes logical caret visibility relative to the known initial native mode, and
exits. Runtime assertions check both sessions have zero mounts/bindings/
subscriptions/posts; root/layer cleanup is once-only; saved node references are
invalid; prior handles are guarded from the new session; stopped owner posts do
not run; inactive posts are refused; focus/caret are empty after close; Observable
mutation while closed evaluates no getter; and the next run starts with base
focus. Reentrant run on the same Application must report LifecycleReentry.

The prepared driver imports the existing A `Capture` PTY and exact termios
comparison. The runner links the unchanged Session152 `session_fault.c` wrapper,
which delegates to real native open/close. This proves only its captured handler
addresses/masks; flags/free-allocation proof and simultaneous competing native
owner remain explicit gaps. Close-error cases inject failure **after actual
restoration** and repeat that injection in run2; run2's reported cleanup failure
is expected. Assertion exit0 means the consumer checked the expected error;
`error-*`, `primary-*`, `extras-*`, native logs and direct process exit separately
retain the application outcome. It is not an assertion that the app had no error.

Preparation check (only tool syntax/manual literal fixtures):

```sh
bash tests/session_lifecycle/run.sh prepare-check
```

Only after actual root GO, a readable fixed admission manifest, baseline rebind,
and tool/source hash review, the independent executor can use:

```sh
source /workspace/work/validation/sdk/cangjie/envsetup.sh
export CJTUI_020_ROOT_GO=1 CJTUI_020_ADMISSION=/absolute/root-fixed-manifest.json
bash tests/session_lifecycle/run.sh build
bash tests/session_lifecycle/run.sh run --output /absolute/new-evidence-directory
```

The environment/file guard prevents accidental preparation execution; it does
not authenticate or manufacture admission. Root supplies the actual manifest;
the executor records its SHA, source/test commits and tool/dependency identities.
SDK1.2.0/stdx/UCD/cache stay at the readonly paths from the pinned008 input
manifest. No18973 relay, cache/SDK copying, cold build repetition or push.

`manual-coverage.md` lists full C004 expectations, including unprepared runtime
gaps. `reuse-map.json` binds unchanged helper/content hashes and precise historic
scope. Reuse is conditional on unchanged source/deps/env/config/scope under
AGENTS11.1; old host/raw results never certify these new consumers. Host evidence
must retain actual version/config/geometry, raw termios/mode/native results,
source/binary SHA/UTC, original PNG/hash and process exit. An alternate TERM on
the same PTY is not another host. A screenshot alone proves no terminal mode.
