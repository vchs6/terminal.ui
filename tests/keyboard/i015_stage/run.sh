#!/usr/bin/env bash
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/../../.." && pwd)
if [[ "${1:-}" == "--pure" ]]; then
    cd "$here/pure"
    cjpm build
    exec ./target/release/bin/main
fi
output=${CJTUI_KEYBOARD_I015_ARTIFACTS:-$(mktemp -d)}
mkdir -p "$output" "$here/.wrapped/src"
cc -std=c11 -Wall -Wextra -Werror -O2 -c "$root/tests/interaction_a/native/clock_wrap.c" -o "$output/clock-wrap.o"
cc -std=c11 -Wall -Wextra -Werror -O2 -fPIC -shared "$root/tests/interaction_a/native/input_hup.c" -ldl -o "$output/poll-observer.so"
cp "$here/src/"*.cj "$here/.wrapped/src/"
python3 - "$here" "$output" "$root" <<'PYCONFIG'
from pathlib import Path
import sys
here,output,root=map(Path,sys.argv[1:])
text=(here/'cjpm.toml').read_text().replace('path = "../../.."','path = "../../../.."').replace('link-option = ""','link-option = "'+str((output/'clock-wrap.o').resolve())+' --wrap=cjt_monotonic_ms"')
(here/'.wrapped/cjpm.toml').write_text(text)
if (root/'cangjie-repo.toml').exists():(here/'.wrapped/cangjie-repo.toml').write_bytes((root/'cangjie-repo.toml').read_bytes())
PYCONFIG
(cd "$here/.wrapped" && cjpm build)
exec python3 "$here/runner.py" --stage Keyboard --case csi-real-idle-Keyboard --binary "$here/.wrapped/target/release/bin/main" --output "$output/capture" --poll-library "$output/poll-observer.so"
