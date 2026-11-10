#!/bin/sh
set -eu
base=/workspace/work/linux-console-hosts
recon=/workspace/work/cross-terminal-recon
display=:71
xpid=
hpid=
trap 'test -z "$hpid" || kill "$hpid" 2>/dev/null || true; test -z "$xpid" || kill "$xpid" 2>/dev/null || true' EXIT
Xorg "$display" -config "$recon/probes/xorg-dummy.conf" -nolisten tcp -noreset -logfile "$base/raw/mux-xorg.log" >"$base/raw/mux-xorg.stdout" 2>&1 &
xpid=$!
export DISPLAY=$display
tries=0
until xdpyinfo >/dev/null 2>&1; do tries=$((tries+1)); test "$tries" -le 100; sleep .1; done
for mux in tmux screen; do
 export MUX_HOST=$mux-x11 SCREENDIR=$base/raw/screen-sockets
 title="actual $mux readiness"
 case $mux in
 tmux) "$recon/hosts/xterm/usr/bin/xterm" -tn xterm-256color -geometry 100x28+20+20 -T "$title" -fa Monospace -fs 12 -e "$base/hosts/debian/usr/bin/tmux" -L cjtui-x11 -f /dev/null new-session -s readiness "$base/probes/mux-scene.sh" >"$base/raw/$mux-x11.stdout" 2>"$base/raw/$mux-x11.stderr" & ;;
 screen) "$recon/hosts/xterm/usr/bin/xterm" -tn xterm-256color -geometry 100x28+20+20 -T "$title" -fa Monospace -fs 12 -e "$base/hosts/debian/usr/bin/screen" -c /dev/null -S readiness "$base/probes/mux-scene.sh" >"$base/raw/$mux-x11.stdout" 2>"$base/raw/$mux-x11.stderr" & ;;
 esac
 hpid=$!
 tries=0
 until rg -q '^READY' "$base/raw/$mux-x11-child.log" 2>/dev/null; do tries=$((tries+1)); test "$tries" -le 100; sleep .1; done
 xwininfo -root -tree > "$base/raw/$mux-x11-tree.txt"
 window=$(awk -v t="$title" '$0 ~ t { print $1; exit }' "$base/raw/$mux-x11-tree.txt")
 xwininfo -id "$window" -all > "$base/raw/$mux-x11-window.txt"
 "$recon/probes/x11-xtest-inject" "$window" p 0 0 > "$base/raw/$mux-x11-input.txt"
 tries=0
 until rg -q '^INPUT=p' "$base/raw/$mux-x11-child.log"; do tries=$((tries+1)); test "$tries" -le 100; sleep .1; done
 import -window "$window" "$base/raw/$mux-x11.png"
 "$recon/probes/x11-xtest-inject" "$window" q 0 0 >> "$base/raw/$mux-x11-input.txt"
 wait "$hpid"
 hpid=
 printf '%s outer_exit=0\n' "$mux"
done
