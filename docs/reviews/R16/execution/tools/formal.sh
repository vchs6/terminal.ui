#!/bin/bash
set -u
b=/workspace/work/glyph-execution
for mode in api public negative internal rich session; do
 python3 "$b/tools/run.py" "glyph-$mode" "$b/source" "tests/glyphs/run.sh $mode" || exit $?
done
python3 "$b/tools/run.py" native-session "$b/source" 'tests/native-session/run.sh' || exit $?
python3 "$b/tools/run.py" bundle "$b/source" 'cjpm bundle' || exit $?
python3 "$b/tools/run.py" host-consumer-build "$b/host-consumer" 'cjpm build' || exit $?
python3 "$b/tools/run.py" session-consumer-build "$b/source" 'tests/session_extensions/run.sh build' || exit $?
