#!/bin/sh
# Same guest/config as public app; raw existing ncurses tools, no policy resolver.
set -eu
out=/evidence/guest-profile
mkdir -p "$out"
printf 'TERM=%s\nCOLORTERM=%s\nLANG=%s\nLC_ALL=%s\nTERMINFO=%s\n' "${TERM-}" "${COLORTERM-}" "${LANG-}" "${LC_ALL-}" "${TERMINFO-}" > "$out/environment.txt"
locale charmap > "$out/charmap.txt"
stty size > "$out/size.txt"
set +e
infocmp -1 -x "$TERM" > "$out/infocmp.stdout" 2> "$out/infocmp.stderr"
printf '%s\n' "$?" > "$out/infocmp.exit"
for cap in colors ncv RGB Tc bold dim sitm smul rev smxx; do
 tput -T "$TERM" "$cap" > "$out/$cap.stdout" 2> "$out/$cap.stderr"
 printf '%s\n' "$?" > "$out/$cap.exit"
done
exit 0
