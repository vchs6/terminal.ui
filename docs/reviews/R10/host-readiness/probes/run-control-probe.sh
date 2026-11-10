#!/bin/sh
set -eu

if [ "$#" -ne 2 ]; then
    printf '%s\n' "usage: $0 PROFILE DISPLAY_NUMBER" >&2
    exit 2
fi

profile=$1
display_number=$2
root=/workspace/work/cross-terminal-recon
raw_dir=$root/raw
display=:$display_number
title="TASK065 control $profile"
raw_file=$raw_dir/control-$profile-child.txt
tree_file=$raw_dir/control-$profile-tree.txt
tree_after_file=$raw_dir/control-$profile-tree-after.txt
before_file=$raw_dir/control-$profile-before.txt
after_file=$raw_dir/control-$profile-after.txt
inject_file=$raw_dir/control-$profile-inject.txt
image_file=$raw_dir/control-$profile-after.png
ansi_file=$raw_dir/control-$profile-ansi.log
outer_file=$raw_dir/control-$profile-outer.txt
xorg_pid=
host_pid=
wm_pid=

cleanup() {
    test -n "$host_pid" && kill "$host_pid" 2>/dev/null || true
    test -n "$wm_pid" && kill "$wm_pid" 2>/dev/null || true
    test -n "$xorg_pid" && kill "$xorg_pid" 2>/dev/null || true
}

wait_for() {
    pattern=$1
    file=$2
    tries=0
    while ! grep -q "$pattern" "$file" 2>/dev/null; do
        tries=$((tries + 1))
        if [ "$tries" -gt 100 ]; then
            printf 'timed out waiting for %s in %s\n' "$pattern" "$file" >&2
            exit 1
        fi
        sleep 0.1
    done
}

reacquire_window() {
    tries=0
    while :; do
        DISPLAY=$display xwininfo -root -tree > "$tree_after_file"
        candidate=$(awk -v title="$title" '$0 ~ title {print $1; exit}' "$tree_after_file")
        if [ -n "$candidate" ] && DISPLAY=$display xwininfo -id "$candidate" -all > "$after_file" 2>/dev/null && \
            grep -q 'Map State: IsViewable' "$after_file"; then
            printf '%s\n' "$candidate"
            return 0
        fi
        tries=$((tries + 1))
        if [ "$tries" -gt 100 ]; then
            printf 'timed out reacquiring visible window titled %s\n' "$title" >&2
            return 1
        fi
        sleep 0.1
    done
}

trap cleanup EXIT
for output in "$raw_file" "$tree_file" "$tree_after_file" "$before_file" "$after_file" "$inject_file" "$image_file" "$ansi_file" "$outer_file"; do
    if [ -e "$output" ]; then
        printf 'refusing to overwrite existing evidence: %s\n' "$output" >&2
        exit 1
    fi
done
Xorg "$display" -config "$root/probes/xorg-dummy.conf" -nolisten tcp -noreset \
    -logfile "/tmp/task065-control-$profile-xorg.log" >/tmp/task065-control-xorg.stdout 2>&1 &
xorg_pid=$!
tries=0
until DISPLAY=$display xdpyinfo >/dev/null 2>&1; do
    tries=$((tries + 1))
    test "$tries" -le 100 || exit 1
    sleep 0.1
done

case $profile in
    xterm-default)
        TASK065_CONTROL_RAW=$raw_file TASK065_HOST_LABEL=$profile DISPLAY=$display \
            "$root/hosts/xterm/usr/bin/xterm" -geometry 100x28+20+20 -T "$title" \
            -fa Monospace -fs 12 -e /bin/sh "$root/probes/scene-control.sh" \
            >/tmp/task065-control-xterm.stdout 2>/tmp/task065-control-xterm.err &
        host_pid=$!
        target_width=1204
        target_height=650
        ;;
    xterm-256color|xterm-256color-stable|xterm-256color-final)
        TASK065_CONTROL_RAW=$raw_file TASK065_HOST_LABEL=$profile DISPLAY=$display \
            "$root/hosts/xterm/usr/bin/xterm" -tn xterm-256color -geometry 100x28+20+20 \
            -T "$title" -fa Monospace -fs 12 -e /bin/sh "$root/probes/scene-control.sh" \
            >/tmp/task065-control-xterm256.stdout 2>/tmp/task065-control-xterm256.err &
        host_pid=$!
        target_width=1204
        target_height=650
        ;;
    xterm-default-recorded|xterm-default-recorded-stable|xterm-default-recorded-final|xterm-default-recorded-outer|xterm-default-recorded-graceful)
        TASK065_CONTROL_RAW=$raw_file TASK065_OUTER_RAW=$outer_file TASK065_ANSI_RAW=$ansi_file \
            TASK065_HOST_LABEL=$profile DISPLAY=$display \
            "$root/hosts/xterm/usr/bin/xterm" -geometry 100x28+20+20 -T "$title" \
            -fa Monospace -fs 12 -e /bin/sh "$root/probes/scene-recorder-wrapper.sh" \
            >/tmp/task065-control-xterm-recorded.stdout 2>/tmp/task065-control-xterm-recorded.err &
        host_pid=$!
        target_width=1204
        target_height=650
        ;;
    xfce-vte|xfce-vte-reacquire|xfce-vte-wm|xfce-vte-stable|xfce-vte-final)
        mkdir -p /tmp/task065-xdg-cache /tmp/task065-xdg-config
        if [ "$profile" = xfce-vte-wm ]; then
            DISPLAY=$display xfwm4 --compositor=off >/tmp/task065-control-xfwm4.out 2>/tmp/task065-control-xfwm4.err &
            wm_pid=$!
        fi
        TASK065_CONTROL_RAW=$raw_file TASK065_HOST_LABEL=$profile DISPLAY=$display \
            XDG_CACHE_HOME=/tmp/task065-xdg-cache XDG_CONFIG_HOME=/tmp/task065-xdg-config \
            dbus-run-session -- xfce4-terminal --disable-server --geometry=100x28+20+20 \
            --title="$title" --command="/bin/sh $root/probes/scene-control.sh" \
            >/tmp/task065-control-xfce.stdout 2>/tmp/task065-control-xfce.err &
        host_pid=$!
        target_width=1217
        target_height=675
        ;;
    *)
        printf 'unknown profile: %s\n' "$profile" >&2
        exit 2
        ;;
esac

wait_for '^ready_tty_size=' "$raw_file"
DISPLAY=$display xwininfo -root -tree > "$tree_file"
window_id_before=$(awk -v title="$title" '$0 ~ title {print $1; exit}' "$tree_file")
test -n "$window_id_before"
DISPLAY=$display xwininfo -id "$window_id_before" -all > "$before_file"
grep -q 'Map State: IsViewable' "$before_file"
DISPLAY=$display "$root/probes/x11-xtest-inject" "$window_id_before" p "$target_width" "$target_height" > "$inject_file"
wait_for '^input_ack=p ' "$raw_file"
wait_for '^resize_ack=' "$raw_file"
window_id_after=$(reacquire_window)
before_size=$(awk '/^  Width:/{w=$2} /^  Height:/{h=$2} END{print w "x" h}' "$before_file")
after_size=$(awk '/^  Width:/{w=$2} /^  Height:/{h=$2} END{print w "x" h}' "$after_file")
test "$before_size" != "$after_size"
before_tty=$(awk -F= '/^ready_tty_size=/{print $2; exit}' "$raw_file")
after_tty=$(awk -F= '/^resize_ack=/{print $2; exit}' "$raw_file")
test "$before_tty" != "$after_tty"
DISPLAY=$display import -window "$window_id_after" "$image_file"
DISPLAY=$display "$root/probes/x11-xtest-inject" "$window_id_after" q 0 0 >> "$inject_file"
wait_for '^input_ack=q ' "$raw_file"
case $profile in
    xterm-default-recorded*)
        wait_for '^exit_termios=' "$raw_file"
        wait_for '^outer_exit_termios=' "$outer_file"
        ;;
esac
printf 'profile=%s window_before=%s window_after=%s geometry_before=%s geometry_after=%s tty_before=%s tty_after=%s\n' \
    "$profile" "$window_id_before" "$window_id_after" "$before_size" "$after_size" "$before_tty" "$after_tty"
