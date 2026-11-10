#!/bin/sh
stty rows 8 cols 80
stty -g > '/workspace/work/auto-harness-repair/evidence/pty-fence/before'
tty > '/workspace/work/auto-harness-repair/evidence/pty-fence/tty'
'/workspace/work/auto-harness-repair-validation/tests/terminals/fixture/target/release/bin/main'
status=$?
stty -g > '/workspace/work/auto-harness-repair/evidence/pty-fence/after'
exit "$status"
