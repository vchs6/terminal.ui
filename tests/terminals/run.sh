#!/bin/sh
# TASK-066 real-host collection for the public no-override fixture.
set -eu
root=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
tdir=$root/tests/terminals
fixture=$tdir/fixture
sdk=${CJTUI_SDK_ENV-}
hosts=${CJTUI_TERMINAL_HOST_ROOT-}
evidence=${CJTUI_TERMINAL_CAPTURE_DIR-}
xorg=${CJTUI_XORG-Xorg}
usage() { printf '%s\n' 'usage: CJTUI_SDK_ENV=... CJTUI_TERMINAL_HOST_ROOT=... CJTUI_TERMINAL_CAPTURE_DIR=/new/dir tests/terminals/run.sh [profiles]' >&2; exit 2; }
test -r "$sdk" && test -d "$hosts" && test -n "$evidence" || usage
test ! -e "$evidence" || { printf 'refusing to overwrite evidence directory: %s\n' "$evidence" >&2; exit 2; }
case "$evidence" in *' '*|*'"'*) printf '%s\n' 'insufficient_evidence: capture path contains spaces or quotes' >&2; exit 2;; esac
test -x "$hosts/probes/x11-xtest-inject" && test -r "$hosts/probes/xorg-dummy.conf" || { printf '%s\n' 'insufficient_evidence: host bundle incomplete' >&2; exit 2; }
for command in "$xorg" xwininfo import identify script node cc; do command -v "$command" >/dev/null 2>&1 || { printf 'insufficient_evidence: %s unavailable\n' "$command" >&2; exit 2; }; done
mkdir "$evidence"
. "$sdk"
bin=${CJTUI_TERMINAL_FIXTURE_BIN-}
if test -z "$bin"; then (cd "$fixture" && cjpm build); bin=$fixture/target/release/bin/main; fi
test -x "$bin" || { printf '%s\n' 'fixture binary missing' >&2; exit 1; }
interrupt=${CJTUI_XTEST_INTERRUPT-$evidence/x11-xtest-interrupt}
if test ! -x "$interrupt"; then cc -O2 -Wall -Wextra -Werror "$tdir/x11-xtest-interrupt.c" -ldl -o "$interrupt"; fi
test -x "$interrupt" || { printf '%s\n' 'insufficient_evidence: Ctrl-C injector unavailable' >&2; exit 2; }
profiles=${*:-"xterm-default xterm-256color xfce-vte"}
scenarios=${CJTUI_TERMINAL_SCENARIOS-"q exception interrupt"}
fixture_sha=$(sha256sum "$fixture/src/main.cj" | awk '{print $1}')
harness_sha=$(sha256sum "$tdir/run.sh" "$tdir/verify-sgr.mjs" "$tdir/outer-recorder.sh" "$tdir/inner-recorder.sh" "$tdir/x11-xtest-interrupt.c" | sha256sum | awk '{print $1}')
source_commit=$(git -C "$root" rev-parse HEAD)
fixture_commit=$(git -C "$root" log -1 --format=%H -- tests/terminals/fixture/src/main.cj)
binary_sha=$(sha256sum "$bin" | awk '{print $1}')
wait_file() { f=$1; label=$2; n=0; while test ! -e "$f"; do n=$((n+1)); test "$n" -le 150 || { printf 'timed out: %s\n' "$label" >&2; return 1; }; sleep .1; done; }
wait_ack() { f=$1; label=$2; n=0; while test "$(cat "$f" 2>/dev/null || true)" != ack; do n=$((n+1)); test "$n" -le 150 || { printf 'timed out: %s\n' "$label" >&2; return 1; }; sleep .1; done; }
window() { d=$1; title=$2; tree=$3; info=$4; n=0; while :; do DISPLAY=$d xwininfo -root -tree > "$tree"; id=$(awk -v t="$title" '$0 ~ t {print $1;exit}' "$tree"); if test -n "$id" && DISPLAY=$d xwininfo -id "$id" -all > "$info" 2>/dev/null && grep -q 'Map State: IsViewable' "$info"; then printf '%s\n' "$id"; return; fi; n=$((n+1)); test "$n" -le 150 || { printf 'timed out: visible window %s\n' "$title" >&2; return 1; }; sleep .1; done; }
pixels() { awk '/^  Width:/{w=$2} /^  Height:/{h=$2} END{print w "x" h}' "$1"; }
termios() { sed -n 's/^'"$2"'_termios=//p' "$1" | tail -1; }
tty_size() { sed -n 's/^'"$2"'_size=//p' "$1" | tail -1; }
metadata() {
  dir=$1; profile=$2; host=$3; version=$4; before=$5; after=$6; cap=$7; scenario=$8
  capline=$(tr '\n' ' ' < "$cap" | sed 's/"/\\\\"/g')
  versionline=$(tr '\n' ' ' < "$version" | sed 's/"/\\\\"/g')
  cat > "$dir/metadata.json" <<EOF
{"schema":"cjtui-terminal-matrix-v1","profile":"$profile","scenario":"$scenario","host":"$host","host_version":"$versionline","captured_at_utc":"$(date -u +%Y-%m-%dT%H:%M:%SZ)","x11_pixels_before":"$(pixels "$before")","x11_pixels_after":"$(pixels "$after")","outer_tty_before":"$(tty_size "$dir/outer-tty.txt" ready)","outer_tty_after":"$(tty_size "$dir/outer-tty.txt" exit)","inner_tty_before":"$(tty_size "$dir/inner-tty.txt" ready)","inner_tty_after":"$(tty_size "$dir/inner-tty.txt" exit)","scene":"tests/terminals/fixture/src/main.cj Application(root)","source_commit":"$source_commit","fixture_commit":"$fixture_commit","fixture_source_sha256":"$fixture_sha","fixture_binary_sha256":"$binary_sha","harness_source_sha256":"$harness_sha","capability_record":"$capline","original_png_before":"original-before-resize.png","original_png_before_sha256":"$(sha256sum "$dir/original-before-resize.png" | awk '{print $1}')","original_png_after":"original-after-resize.png","original_png_after_sha256":"$(sha256sum "$dir/original-after-resize.png" | awk '{print $1}')","inner_tty_raw_sha256":"$(sha256sum "$dir/inner-tty.raw" | awk '{print $1}')","outer_tty_raw_sha256":"$(sha256sum "$dir/outer-tty.txt" | awk '{print $1}')","inner_tty_state_sha256":"$(sha256sum "$dir/inner-tty.txt" | awk '{print $1}')"}
EOF
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
  "$cmd" -version >"$dir/host-version.txt" 2>&1 || "$cmd" --version >"$dir/host-version.txt" 2>&1 || true
  if test "$profile" = xfce-vte; then
    mkdir -p "$dir/xdg-cache" "$dir/xdg-config"
    TASK066_OUTER_RAW=$dir/outer-tty.txt TASK066_INNER_RAW=$dir/inner-tty.raw TASK066_INNER_STATE=$dir/inner-tty.txt TASK066_FIXTURE=$bin TASK066_INNER_RUNNER=$dir/inner-recorder.sh CJTUI_TERMINAL_EVIDENCE=$dir DISPLAY=$display XDG_CACHE_HOME=$dir/xdg-cache XDG_CONFIG_HOME=$dir/xdg-config dbus-run-session -- "$cmd" $args --title="$title" --command="/bin/sh $dir/outer-recorder.sh" >"$dir/host.stdout" 2>"$dir/host.stderr" &
  else
    TASK066_OUTER_RAW=$dir/outer-tty.txt TASK066_INNER_RAW=$dir/inner-tty.raw TASK066_INNER_STATE=$dir/inner-tty.txt TASK066_FIXTURE=$bin TASK066_INNER_RUNNER=$dir/inner-recorder.sh CJTUI_TERMINAL_EVIDENCE=$dir DISPLAY=$display "$cmd" $args -T "$title" -e /bin/sh "$dir/outer-recorder.sh" >"$dir/host.stdout" 2>"$dir/host.stderr" &
  fi
  hostpid=$!; wait_file "$dir/outer-tty.txt" 'outer recorder'; grep -q '^ready_size=' "$dir/outer-tty.txt"; before=$(window "$display" "$title" "$dir/window-before.tree.txt" "$dir/window-before.txt")
  DISPLAY=$display "$hosts/probes/x11-xtest-inject" "$before" p 0 0 >"$dir/xtest-1-startup.txt"; wait_ack "$dir/event-1.ack" 'startup render fence'; wait_file "$dir/capabilities-1.txt" 'first capabilities'; DISPLAY=$display import -window "$before" "$dir/original-before-resize.png"; identify "$dir/original-before-resize.png" >"$dir/original-before-resize.identify.txt"
  for e in 2 3 4; do DISPLAY=$display "$hosts/probes/x11-xtest-inject" "$before" c 0 0 >"$dir/xtest-$e-c.txt"; wait_ack "$dir/event-$e.ack" "c $e"; done
  DISPLAY=$display "$hosts/probes/x11-xtest-inject" "$before" t 0 0 >"$dir/xtest-5-t.txt"; wait_ack "$dir/event-5.ack" t
  DISPLAY=$display "$hosts/probes/x11-xtest-inject" "$before" p "$width" "$height" >"$dir/xtest-6-resize.txt"; wait_ack "$dir/event-6.ack" 'resize render fence'; cap=$dir/capabilities-6.txt; wait_file "$cap" 'post-resize capabilities'
  after=$(window "$display" "$title" "$dir/window-after.tree.txt" "$dir/window-after.txt"); test "$(pixels "$dir/window-before.txt")" != "$(pixels "$dir/window-after.txt")" || { printf '%s\n' 'X11 resize had no geometry change' >&2; return 1; }; DISPLAY=$display import -window "$after" "$dir/original-after-resize.png"; identify "$dir/original-after-resize.png" >"$dir/original-after-resize.identify.txt"
  quiet_before=$(wc -c < "$dir/inner-tty.raw"); DISPLAY=$display "$hosts/probes/x11-xtest-inject" "$after" n 0 0 >"$dir/xtest-7-noop.txt"; wait_ack "$dir/event-7.ack" 'no-op'; DISPLAY=$display "$hosts/probes/x11-xtest-inject" "$after" p 0 0 >"$dir/xtest-8-quiet-fence.txt"; wait_ack "$dir/event-8.ack" 'quiet render fence'; quiet_after=$(wc -c < "$dir/inner-tty.raw"); test "$quiet_before" = "$quiet_after" || { printf 'no-op emitted bytes before fence (%s -> %s)\n' "$quiet_before" "$quiet_after" >&2; return 1; }
  node "$tdir/verify-sgr.mjs" "$cap" "$dir/inner-tty.raw" >"$dir/sgr-verification.txt"
  case "$scenario" in
    q) DISPLAY=$display "$hosts/probes/x11-xtest-inject" "$after" q 0 0 >"$dir/xtest-9-q.txt"; wait_ack "$dir/event-9.ack" q; expected=0;;
    exception) DISPLAY=$display "$hosts/probes/x11-xtest-inject" "$after" e 0 0 >"$dir/xtest-9-exception.txt"; wait_ack "$dir/event-9.ack" exception; expected=nonzero;;
    interrupt) DISPLAY=$display "$interrupt" "$after" >"$dir/xtest-9-ctrl-c.txt"; expected=0;;
    *) return 2;;
  esac
  set +e; wait "$hostpid"; status=$?; set -e; if test "$expected" = 0; then test "$status" -eq 0; else test "$status" -ne 0; fi
  wait_file "$dir/inner-tty.txt" 'inner restoration'; test "$(termios "$dir/outer-tty.txt" ready)" = "$(termios "$dir/outer-tty.txt" exit)"; test "$(termios "$dir/inner-tty.txt" ready)" = "$(termios "$dir/inner-tty.txt" exit)"
  metadata "$dir" "$profile" "$host" "$dir/host-version.txt" "$dir/window-before.txt" "$dir/window-after.txt" "$cap" "$scenario"
  trap - INT TERM EXIT; kill "$xpid" 2>/dev/null || true; printf 'PASS profile=%s scenario=%s evidence=%s\n' "$profile" "$scenario" "$dir"
}
i=0; for p in $profiles; do for s in $scenarios; do i=$((i+1)); run "$p" "$((96+i))" "$s"; done; done
printf 'PASS real-host matrix evidence=%s\n' "$evidence"
