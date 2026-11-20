#!/usr/bin/env bash
# Caller owns DISPLAY, terminal config and all session/socket paths.
set -euo pipefail
[[ ${C008_ROOT_ACTUAL_GO:-} == 1 ]] || { echo 'NOTEXECUTED: root actual GO required' >&2; exit 2; }
: "${C008_147_ADMISSION:?}" "${C008_PROVENANCE:?}"
[[ -f $C008_147_ADMISSION && -f $C008_PROVENANCE ]]
if [[ ${1:-} != vt && ${1:-} != ssh ]]; then [[ -x ${C008_LAUNCHER:?} ]]; fi
case "${1:?xterm|vte|tmux|screen|ssh|vt}" in
 xterm) exec "${C008_XTERM:?}" -geometry "${C008_GEOMETRY:-80x24}" -T 'C008 owned xterm' -e "$C008_LAUNCHER" ;;
 vte) exec dbus-run-session -- "${C008_XFCE:?}" --disable-server --geometry="${C008_GEOMETRY:-80x24}" --title='C008 owned VTE' --command="$C008_LAUNCHER" ;;
 tmux) exec "${C008_XTERM:?}" -geometry "${C008_GEOMETRY:-80x24}" -T 'C008 owned tmux' -e "${C008_TMUX:?}" -S "${C008_TMUX_SOCKET:?}" -f "${C008_TMUX_CONFIG:?}" new-session -s c008 "$C008_LAUNCHER" ;;
 screen) : "${SCREENDIR:?owned isolated directory}"; exec "${C008_XTERM:?}" -geometry "${C008_GEOMETRY:-80x24}" -T 'C008 owned screen' -e "${C008_SCREEN:?}" -c "${C008_SCREEN_CONFIG:?}" -S "${C008_SCREEN_SESSION:?}" "$C008_LAUNCHER" ;;
 ssh) # -tt requests an SSH PTY; actual remote dimensions/window-change still require proof.
   [[ ${C008_SSH_HOST:?owned loopback endpoint} == 127.0.0.1 ]]
   [[ ${C008_REMOTE_LAUNCHER:?} =~ ^/[a-zA-Z0-9_./-]+$ ]]
   [[ ${C008_BINARY:?} =~ ^/[a-zA-Z0-9_./-]+$ && ${C008_OUT:?} =~ ^/[a-zA-Z0-9_./-]+$ && ${C008_GEOMETRY:-80x24} =~ ^[0-9]+x[0-9]+$ ]]
   exec "${C008_XTERM:?}" -geometry "${C008_GEOMETRY:-80x24}" -T 'C008 owned SSH' -e "${C008_SSH:?}" -F /dev/null -tt -p "${C008_SSH_PORT:?}" -i "${C008_SSH_OWNED_KEY:?}" -o IdentitiesOnly=yes -o StrictHostKeyChecking=yes -o UserKnownHostsFile="${C008_SSH_OWNED_KNOWN_HOSTS:?}" "${C008_SSH_USER:?}@${C008_SSH_HOST}" "$C008_REMOTE_LAUNCHER ${C008_BINARY:?} ${C008_OUT:?} ${C008_GEOMETRY:-80x24}" ;;
 vt) : "${VT_RUN_DIR:?}" "${VT_INITRD:?owner-prepared final public app necessary runtime closure}" "${VT_SCENE:?owner-accepted guest scene}"; export VT_RUN_DIR VT_INITRD VT_SCENE; exec /workspace/work/linux-vt-product-probe/probes/start-vt.sh ;;
 *) exit 2 ;;
esac
