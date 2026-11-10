#!/usr/bin/env bash
# Regenerates raw evidence.  Failures are recorded and do not stop later cases.
set -u
root=/workspace/work/auto-capability-recon
bin="$root/terminfo_probe"
mkdir -p "$root/raw" "$root/generated-terminfo"

run_case() {
  local name=$1
  shift
  printf 'command:' > "$root/raw/$name.log"
  printf ' %q' "$@" >> "$root/raw/$name.log"
  printf '\n' >> "$root/raw/$name.log"
  "$@" >> "$root/raw/$name.log" 2>&1
  local status=$?
  printf 'exit=%d\n' "$status" >> "$root/raw/$name.log"
  return "$status"
}

run_case compile cc -Wall -Wextra -Werror -std=c11 -o "$bin" "$root/source/terminfo_probe.c" -ldl || :
run_case host_environment bash -c "env | rg '^(TERM|COLORTERM|TERM_PROGRAM|VTE_VERSION|TMUX|STY|WT_SESSION|KITTY_|WEZTERM|LC_TERMINAL)=' || true" || :
run_case cangjie_sdk bash -c 'source /workspace/work/validation/sdk/cangjie/envsetup.sh && cjc -v' || :
run_case stdio_tty bash -c 'test -t 0; printf "stdin_isatty=%s\n" "$?"; test -t 1; printf "stdout_isatty=%s\n" "$?"; tty; printf "tty_exit=%s\n" "$?"' || :
run_case ncv_local_entry bash -c "infocmp -L -1 linux | rg 'no_color_video|enter_(bold|dim|italics|underline|reverse)_mode'" || :
run_case ncv_decode python3 "$root/source/ncv_probe.py" || :
run_case libtinfo_symbols "$bin" xterm-256color || :
run_case basic_mono "$bin" dumb || :
run_case basic_8 "$bin" linux || :
run_case indexed_256 "$bin" xterm-256color || :
run_case xterm_style_entry bash -c "infocmp -1 -x xterm-256color | rg '^\\s*(bold|dim|sitm|smul|rev|smxx)='" || :
run_case linux_style_entry bash -c "infocmp -1 -x linux | rg '^\\s*(bold|dim|sitm|smul|rev|smxx)='" || :
run_case restore_existing "$bin" xterm-256color libtinfo.so.6 dumb || :
run_case missing_entry "$bin" no-such-terminal-entry || :
run_case missing_library "$bin" xterm-256color /definitely/missing/libtinfo.so || :
run_case restricted_env_fallback env -i PATH=/usr/bin:/bin TERM=xterm-256color TERMINFO=/definitely/missing TERMINFO_DIRS=/definitely/missing "$bin" xterm-256color || :
run_case synthetic_compile tic -x -o "$root/generated-terminfo" "$root/source/extended-terminfo.src" || :
run_case rgb_extension env TERMINFO="$root/generated-terminfo" "$bin" probe-rgb || :
run_case tc_extension env TERMINFO="$root/generated-terminfo" "$bin" probe-tc || :
run_case indexed_16 env TERMINFO="$root/generated-terminfo" "$bin" probe-16 || :
run_case dlmopen_compile cc -Wall -Wextra -Werror -std=c11 -o "$root/dlmopen_probe" "$root/source/dlmopen_probe.c" -ldl -pthread || :
run_case dlmopen_isolation "$root/dlmopen_probe" || :
run_case cangjie_overloads bash -c "source /workspace/work/validation/sdk/cangjie/envsetup.sh && cjc '$root/source/application_overload_probe.cj' -o '$root/application_overload_probe' && '$root/application_overload_probe'" || :
run_case cangjie_dlmopen_c_compile bash -c "cd '$root/cangjie_dlmopen_probe' && cc -Wall -Wextra -Werror -std=c11 -fPIC -c native/cangjie_dlmopen_probe.c -o native/cangjie_dlmopen_probe.o && ar rcs native/libcangjie_dlmopen_probe.a native/cangjie_dlmopen_probe.o" || :
run_case cangjie_dlmopen_cjpm_build bash -c "source /workspace/work/validation/sdk/cangjie/envsetup.sh && cd '$root/cangjie_dlmopen_probe' && cjpm build" || :
run_case cangjie_dlmopen_directbin bash -c "source /workspace/work/validation/sdk/cangjie/envsetup.sh && cd '$root/cangjie_dlmopen_probe' && ./target/release/bin/main" || :
