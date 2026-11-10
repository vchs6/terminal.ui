#!/bin/bash
/workspace/work/session-extension-execution/source/tests/session_extensions/host-consumer.sh /workspace/work/session-extension-execution/source/tests/session_extensions/target/release/bin/main /workspace/work/session-extension-execution/raw/lifecycle-hosts/ledger-close/consumer Direct declared
status=$?
printf "%s\n" "$status" > /workspace/work/session-extension-execution/raw/lifecycle-hosts/ledger-close/child-exit
while [[ ! -f /workspace/work/session-extension-execution/raw/lifecycle-hosts/ledger-close/release-window ]]; do sleep 0.02; done
exit "$status"
