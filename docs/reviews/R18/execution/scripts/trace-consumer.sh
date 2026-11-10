#!/bin/bash
exec /usr/bin/strace -ff -e trace=process -o /workspace/work/session-extension-execution/raw/no-product-process/trace /workspace/work/session-extension-execution/source/tests/session_extensions/target/release/bin/main
