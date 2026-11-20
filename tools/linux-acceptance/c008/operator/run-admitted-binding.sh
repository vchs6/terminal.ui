#!/usr/bin/env bash
# Sole new command wrapper: exact independent loader/runner, no local expectations.
set -euo pipefail
[[ ${C008_ROOT_ACTUAL_GO:-} == 1 ]]
: "${C008_SOURCE:?}" "${C008_EXPECTED_PROFILE:?}" "${C008_147_ADMISSION:?}" "${C008_PROVENANCE:?}"
[[ -f $C008_147_ADMISSION && -f $C008_PROVENANCE ]]
cd "$C008_SOURCE"
export C008_TEST_INPUT_ROOT=/workspace/work/linux-final-host-test-contract/inputs
exec "${C008_NODE:?}" --loader /workspace/work/linux-final-host-test-contract/frozen-loader.mjs /workspace/work/linux-final-host-test-contract/run-frozen.mjs "$@"
