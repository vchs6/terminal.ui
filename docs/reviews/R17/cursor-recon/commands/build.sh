#!/bin/sh
set -eu
BASE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cc -O2 -Wall -Wextra -Werror "$BASE/source/cursor-probe.c" -o "$BASE/packages/cursor-probe"
cc -static -O2 -Wall -Wextra -Werror "$BASE/source/cursor-probe.c" -o "$BASE/guest-root/cursor-probe"
python3 "$BASE/commands/pack-guest.py"
