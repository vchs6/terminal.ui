#!/usr/bin/env bash
# TASK-066 real-host collection for the public no-override fixture.
set -eu
root=/workspace/work/runtime-execution/source
tdir=$root/tests/terminals
fixture=$tdir/fixture
scene=${CJTUI_TERMINAL_SCENE-fixture}
case "$scene" in fixture) scene_source=tests/terminals/fixture/src/main.cj;; example) fixture=$root/examples/reactive; scene_source=examples/reactive/src/main.cj;; *) printf 'unknown scene: %s\n' "$scene" >&2; exit 2;; esac
sdk=${CJTUI_SDK_ENV-}
hosts=${CJTUI_TERMINAL_HOST_ROOT-}
evidence=${CJTUI_TERMINAL_CAPTURE_DIR-}
xorg=${CJTUI_XORG-Xorg}
usage() { printf '%s\n' 'usage: CJTUI_SDK_ENV=... CJTUI_TERMINAL_HOST_ROOT=... CJTUI_TERMINAL_CAPTURE_DIR=/new/dir tests/terminals/run.sh [profiles]' >&2; exit 2; }
test -r "$sdk" && test -d "$hosts" && test -n "$evidence" || usage
test ! -e "$evidence" || { printf 'refusing to overwrite evidence directory: %s\n' "$evidence" >&2; exit 2; }
case "$evidence" in *' '*|*'"'*) printf '%s\n' 'insufficient_evidence: capture path contains spaces or quotes' >&2; exit 2;; esac
test -x /workspace/work/runtime-execution/gui-key && test -r "$hosts/probes/xorg-dummy.conf" || { printf '%s\n' 'insufficient_evidence: host bundle incomplete' >&2; exit 2; }
for command in "$xorg" xwininfo import identify script node cc; do command -v "$command" >/dev/null 2>&1 || { printf 'insufficient_evidence: %s unavailable\n' "$command" >&2; exit 2; }; done
mkdir "$evidence"
. "$sdk"
bin=${CJTUI_TERMINAL_FIXTURE_BIN-}
if test "$scene" = example; then bin=${CJTUI_TERMINAL_EXAMPLE_BIN-}; fi
if test -z "$bin"; then (cd "$fixture" && cjpm build); bin=$fixture/target/release/bin/main; fi
test -x "$bin" || { printf '%s\n' 'fixture binary missing' >&2; exit 1; }
interrupt=${CJTUI_XTEST_INTERRUPT-$evidence/x11-xtest-interrupt}
if test ! -x "$interrupt"; then cc -O2 -Wall -Wextra -Werror "$tdir/x11-xtest-interrupt.c" -ldl -o "$interrupt"; fi
test -x "$interrupt" || { printf '%s\n' 'insufficient_evidence: Ctrl-C injector unavailable' >&2; exit 2; }
profiles=${*:-"xterm-default xterm-256color xfce-vte"}
scenarios=${CJTUI_TERMINAL_SCENARIOS-"q exception interrupt"}
if test "$scene" = example; then scenarios=interrupt; fi
fixture_sha=$(sha256sum "$fixture/src/main.cj" | awk '{print $1}')
harness_sha=$(sha256sum "$tdir/run.sh" "$tdir/verify-sgr.mjs" "$tdir/verify-exit.mjs" "$tdir/outer-recorder.sh" "$tdir/inner-recorder.sh" "$tdir/x11-xtest-interrupt.c" "$tdir/wait-output.mjs" "$tdir/wait-fence.mjs" | sha256sum | awk '{print $1}')
source_commit=$(git -C "$root" rev-parse HEAD)
fixture_commit=$(git -C "$root" log -1 --format=%H -- "$scene_source")
(cd "$root" && git ls-files -z -- "${scene_source%/src/main.cj}" | xargs -0 sha256sum) > "$evidence/consumer-source-sha256.txt"
binary_sha=$(sha256sum "$bin" | awk '{print $1}')
wait_file() { f=$1; label=$2; n=0; while test ! -e "$f"; do n=$((n+1)); test "$n" -le 150 || { printf 'timed out: %s\n' "$label" >&2; return 1; }; sleep .1; done; }
wait_ack() { f=$1; label=$2; n=0; while test "$(cat "$f" 2>/dev/null || true)" != ack; do n=$((n+1)); test "$n" -le 150 || { printf 'timed out: %s\n' "$label" >&2; return 1; }; sleep .1; done; }
wait_field() { field_file=$1; field_key=$2; field_attempt=0; until grep -q "^${field_key}=." "$field_file" 2>/dev/null; do field_attempt=$((field_attempt+1)); test "$field_attempt" -le 150 || { printf 'timed out: recorder field %s\n' "$field_key" >&2; return 1; }; sleep .1; done; }
window() { d=$1; title=$2; tree=$3; info=$4; n=0; while :; do DISPLAY=$d xwininfo -root -tree > "$tree"; id=$(awk -v t="$title" '$0 ~ t {print $1;exit}' "$tree"); if test -n "$id" && DISPLAY=$d xwininfo -id "$id" -all > "$info" 2>/dev/null && grep -q 'Map State: IsViewable' "$info"; then printf '%s\n' "$id"; return; fi; n=$((n+1)); test "$n" -le 150 || { printf 'timed out: visible window %s\n' "$title" >&2; return 1; }; sleep .1; done; }
pixels() { awk '/^  Width:/{w=$2} /^  Height:/{h=$2} END{print w "x" h}' "$1"; }
termios() { sed -n 's/^'"$2"'_termios=//p' "$1" | tail -1; }
tty_size() { sed -n 's/^'"$2"'_size=//p' "$1" | tail -1; }
metadata() {
  dir=$1; profile=$2; host=$3; version=$4; before=$5; after=$6; cap=$7; scenario=$8
  capline=$(tr '\n' ' ' < "$cap" | sed 's/"/\\\\"/g')
  versionline=$(tr '\n' ' ' < "$version" | sed 's/"/\\\\"/g')
  cat > "$dir/metadata.json" <<EOF
{"schema":"cjtui-terminal-matrix-v1","profile":"$profile","scenario":"$scenario","host":"$host","host_version":"$versionline","captured_at_utc":"$(date -u +%Y-%m-%dT%H:%M:%SZ)","x11_pixels_before":"$(pixels "$before")","x11_pixels_after":"$(pixels "$after")","outer_tty_before":"$(tty_size "$dir/outer-tty.txt" ready)","outer_tty_after":"$(tty_size "$dir/outer-tty.txt" exit)","inner_tty_before":"$(tty_size "$dir/inner-tty.txt" ready)","inner_tty_after":"$(tty_size "$dir/inner-tty.txt" exit)","scene":"$scene_source Application(root)","source_commit":"$source_commit","fixture_commit":"$fixture_commit","fixture_source_sha256":"$fixture_sha","fixture_binary_sha256":"$binary_sha","harness_source_sha256":"$harness_sha","capability_record":"$capline","original_png_before":"original-before-resize.png","original_png_before_sha256":"$(sha256sum "$dir/original-before-resize.png" | awk '{print $1}')","original_png_after":"original-after-resize.png","original_png_after_sha256":"$(sha256sum "$dir/original-after-resize.png" | awk '{print $1}')","inner_tty_raw_sha256":"$(sha256sum "$dir/inner-tty.raw" | awk '{print $1}')","outer_tty_raw_sha256":"$(sha256sum "$dir/outer-tty.txt" | awk '{print $1}')","inner_tty_state_sha256":"$(sha256sum "$dir/inner-tty.txt" | awk '{print $1}')"}
EOF
}
capture_example() {
  stage_name=$1; stage_offset=$2; stage_window=$3
  node "$tdir/wait-output.mjs" "$dir/inner-tty.raw" "$stage_offset" 15000 "$dir/example-$stage_name.raw" > "$dir/example-$stage_name-output.json"
  DISPLAY=$display import -window "$stage_window" "$dir/example-$stage_name.png"
  identify "$dir/example-$stage_name.png" > "$dir/example-$stage_name.identify.txt"
  sha256sum "$dir/example-$stage_name.png" "$dir/example-$stage_name.raw" >> "$dir/example-stage-sha256.txt"
}
example_key() {
  stage_name=$1; stage_key=$2; stage_start=$(wc -c < "$dir/inner-tty.raw")
  DISPLAY=$display /workspace/work/runtime-execution/gui-key "$before" "$stage_key" 0 0 > "$dir/xtest-example-$stage_name.txt"
  capture_example "$stage_name" "$stage_start" "$before"
}
fixture_key() {
  fixture_event=$1; fixture_window=$2
  fixture_serial=$((fixture_serial+1))
  DISPLAY=$display /workspace/work/runtime-execution/gui-key "$fixture_window" "$fixture_event" 0 0 > "$dir/xtest-$fixture_serial-$fixture_event.txt"
  wait_ack "$dir/event-$fixture_serial.ack" "callback $fixture_serial $fixture_event"
}
fixture_action() {
  action_name=$1; action_key=$2; action_window=$3; action_mode=${4-updates}
  action_offset=$(wc -c < "$dir/inner-tty.raw")
  fixture_key "$action_key" "$action_window"
  fixture_key p "$action_window"
  if test "$fixture_bold" = true; then fixture_bold=false; else fixture_bold=true; fi
  action_columns=$(stty -F "$inner_tty" size | awk '{print $2}')
  node "$tdir/wait-fence.mjs" "$dir/inner-tty.raw" "$action_offset" "$fixture_bold" "$action_columns" "$action_mode" > "$dir/fence-$action_name.json"
}
wait_grid_change() {
  initial_grid=$1; grid_attempt=0
  while test "$(stty -F "$inner_tty" size)" = "$initial_grid"; do
    grid_attempt=$((grid_attempt+1)); test "$grid_attempt" -le 150 || { printf '%s\n' 'timed out: actual PTY resize' >&2; return 1; }; sleep .1
  done
}
wait_host_exit() {
  exit_attempt=0
  while kill -0 "$hostpid" 2>/dev/null; do exit_attempt=$((exit_attempt+1)); test "$exit_attempt" -le 150 || { printf '%s\n' 'timed out: terminal host exit' >&2; return 1; }; sleep .1; done
}
run() {
  profile=$1; number=$2; scenario=$3
  case "$profile" in
    xterm-default) host=xterm; cmd=$hosts/hosts/xterm/usr/bin/xterm; args='-geometry 100x28+20+20 -fa Monospace -fs 12'; width=1204;height=650;;
    xterm-256color) host=xterm; cmd=$hosts/hosts/xterm/usr/bin/xterm; args='-tn xterm-256color -geometry 100x28+20+20 -fa Monospace -fs 12'; width=1204;height=650;;
    xfce-vte) host=xfce-terminal-vte; cmd=$(command -v xfce4-terminal || true); args='--disable-server --geometry=100x28+20+20'; width=1217;height=675;;
    *) printf 'unknown profile: %s\n' "$profile" >&2; return 2;;
  esac
  test -x "$cmd" || { printf 'insufficient_evidence: %s host unavailable\n' "$profile" >&2; return 2; }
  dir=$evidence/$profile/$scenario
  mkdir -p "$dir"; cp "$tdir/outer-recorder.sh" "$dir/outer-recorder.sh"; cp "$tdir/inner-recorder.sh" "$dir/inner-recorder.sh"; chmod 700 "$dir/"*.sh
  display=:$number; title="TASK066 $profile $scenario"; hostpid=
  "$xorg" "$display" -config "$hosts/probes/xorg-dummy.conf" -nolisten tcp -noreset -logfile "$dir/xorg.log" >"$dir/xorg.stdout" 2>&1 & xpid=$!
  cleanup() { test -n "$hostpid" && kill "$hostpid" 2>/dev/null || true; kill "$xpid" 2>/dev/null || true; }
  trap cleanup INT TERM EXIT
  n=0; until DISPLAY=$display xdpyinfo >/dev/null 2>&1; do n=$((n+1)); test "$n" -le 150 || return 1; sleep .1; done
  version_arg=-version; test "$host" != xfce-terminal-vte || version_arg=--version; DISPLAY=$display "$cmd" "$version_arg" >"$dir/host-version.txt" 2>&1 || true
  if test "$profile" = xfce-vte; then
    mkdir -p "$dir/xdg-cache" "$dir/xdg-config"
    TASK066_OUTER_RAW=$dir/outer-tty.txt TASK066_INNER_RAW=$dir/inner-tty.raw TASK066_INNER_STATE=$dir/inner-tty.txt TASK066_FIXTURE=$bin TASK066_INNER_RUNNER=$dir/inner-recorder.sh CJTUI_TERMINAL_EVIDENCE=$dir DISPLAY=$display XDG_CACHE_HOME=$dir/xdg-cache XDG_CONFIG_HOME=$dir/xdg-config dbus-run-session -- env -u COLORTERM "$cmd" $args --title="$title" --command="/bin/sh $dir/outer-recorder.sh" >"$dir/host.stdout" 2>"$dir/host.stderr" &
  else
    TASK066_OUTER_RAW=$dir/outer-tty.txt TASK066_INNER_RAW=$dir/inner-tty.raw TASK066_INNER_STATE=$dir/inner-tty.txt TASK066_FIXTURE=$bin TASK066_INNER_RUNNER=$dir/inner-recorder.sh CJTUI_TERMINAL_EVIDENCE=$dir DISPLAY=$display env -u COLORTERM "$cmd" $args -T "$title" -e /bin/sh "$dir/outer-recorder.sh" >"$dir/host.stdout" 2>"$dir/host.stderr" &
  fi
  hostpid=$!; wait_field "$dir/outer-tty.txt" ready_size; before=$(window "$display" "$title" "$dir/window-before.tree.txt" "$dir/window-before.txt")
  wait_file "$dir/inner-tty.txt" 'inner recorder'; wait_file "$dir/inner-tty.raw" 'raw recorder'
  wait_field "$dir/inner-tty.txt" tty
  inner_tty=$(sed -n 's/^tty=//p' "$dir/inner-tty.txt" | head -1)
  test -n "$inner_tty" || { printf '%s\n' 'missing actual inner tty' >&2; return 1; }
  initial_grid=$(stty -F "$inner_tty" size)
  if test "$scene" = example; then
    capture_example initial 0 "$before"
    DISPLAY=$display import -window "$before" "$dir/original-before-resize.png"; identify "$dir/original-before-resize.png" > "$dir/original-before-resize.identify.txt"
    example_key increment-one c; example_key increment-two c
    : # reactive example has no attribute toggle
    resize_start=$(wc -c < "$dir/inner-tty.raw")
    DISPLAY=$display /workspace/work/runtime-execution/gui-key "$before" n "$width" "$height" > "$dir/xtest-example-resize.txt"
    wait_grid_change "$initial_grid"
    after=$(window "$display" "$title" "$dir/window-after.tree.txt" "$dir/window-after.txt")
    test "$(pixels "$dir/window-before.txt")" != "$(pixels "$dir/window-after.txt")" || { printf '%s\n' 'X11 resize had no geometry change' >&2; return 1; }
    capture_example resized "$resize_start" "$after"
    DISPLAY=$display import -window "$after" "$dir/original-after-resize.png"; identify "$dir/original-after-resize.png" > "$dir/original-after-resize.identify.txt"
    cap=$dir/example-capability-scope.txt
    printf '%s\n' 'Unavailable in unmodified ordinary example; no fixture diagnostic is attributed to this scene. Host TERM/COLORTERM declarations are in outer-tty.txt; fixture matrix supplies separate capability verification.' > "$cap"
    DISPLAY=$display "$interrupt" "$after" > "$dir/xtest-example-ctrl-c.txt"
    expected=0
  else
  fixture_serial=0; fixture_bold=false
  fixture_action startup n "$before"
  wait_file "$dir/capabilities-$fixture_serial.txt" 'first capabilities'; DISPLAY=$display import -window "$before" "$dir/original-before-resize.png"; identify "$dir/original-before-resize.png" >"$dir/original-before-resize.identify.txt"
  for e in 1 2 3; do fixture_action "color-$e" c "$before"; done
  fixture_action attributes t "$before"
  DISPLAY=$display /workspace/work/runtime-execution/gui-key "$before" n "$width" "$height" > "$dir/xtest-resize.txt"
  fixture_serial=$((fixture_serial+1)); wait_ack "$dir/event-$fixture_serial.ack" 'resize input'
  wait_grid_change "$initial_grid"
  fixture_action resized n "$before"
  cap=$dir/capabilities-$fixture_serial.txt; wait_file "$cap" 'post-resize capabilities'
  after=$(window "$display" "$title" "$dir/window-after.tree.txt" "$dir/window-after.txt"); test "$(pixels "$dir/window-before.txt")" != "$(pixels "$dir/window-after.txt")" || { printf '%s\n' 'X11 resize had no geometry change' >&2; return 1; }; DISPLAY=$display import -window "$after" "$dir/original-after-resize.png"; identify "$dir/original-after-resize.png" >"$dir/original-after-resize.identify.txt"
  fixture_action noop n "$after" quiet
  node "$tdir/verify-sgr.mjs" "$cap" "$dir/inner-tty.raw" "$profile" >"$dir/sgr-verification.txt"
  case "$scenario" in
    q) fixture_key q "$after"; expected=0;;
    exception) fixture_key e "$after"; expected=nonzero;;
    interrupt) DISPLAY=$display "$interrupt" "$after" >"$dir/xtest-9-ctrl-c.txt"; expected=0;;
    *) return 2;;
  esac
  fi
  wait_field "$dir/inner-tty.txt" exit_status; wait_field "$dir/outer-tty.txt" exit_status; wait_host_exit
  set +e; wait "$hostpid"; status=$?; set -e
  printf '%s\n' "$status" > "$dir/host-wait-status.txt"
  node "$tdir/verify-exit.mjs" "$dir/inner-tty.txt" "$dir/outer-tty.txt" "$dir/host-wait-status.txt" "$expected" > "$dir/exit-verification.json"
  wait_file "$dir/inner-tty.txt" 'inner restoration'; test "$(termios "$dir/outer-tty.txt" ready)" = "$(termios "$dir/outer-tty.txt" exit)"; test "$(termios "$dir/inner-tty.txt" ready)" = "$(termios "$dir/inner-tty.txt" exit)"
  if test "$scene" = example; then
    test -n "$(termios "$dir/outer-tty.txt" exit)"; test -n "$(termios "$dir/inner-tty.txt" exit)"
    grep -q '^exit_status=0$' "$dir/inner-tty.txt"; grep -q '^exit_status=0$' "$dir/outer-tty.txt"
    test "$(tty_size "$dir/inner-tty.txt" ready)" != "$(tty_size "$dir/inner-tty.txt" exit)" || { printf '%s\n' 'PTY grid did not resize' >&2; return 1; }
  fi
  metadata "$dir" "$profile" "$host" "$dir/host-version.txt" "$dir/window-before.txt" "$dir/window-after.txt" "$cap" "$scenario"
  trap - INT TERM EXIT; kill "$xpid" 2>/dev/null || true; printf 'PASS profile=%s scenario=%s evidence=%s\n' "$profile" "$scenario" "$dir"
}
i=0; for p in $profiles; do for s in $scenarios; do i=$((i+1)); run "$p" "$((180+i))" "$s"; done; done
printf 'PASS real-host matrix evidence=%s\n' "$evidence"
