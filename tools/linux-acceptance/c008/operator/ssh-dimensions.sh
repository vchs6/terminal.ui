#!/usr/bin/env bash
# Read-only remote kernel geometry; this NEVER changes the remote size.
set -euo pipefail
[[ ${C008_ROOT_ACTUAL_GO:-} == 1 && ${C008_SSH_HOST:?} == 127.0.0.1 ]]
[[ $# == 1 && $1 =~ ^/dev/pts/[0-9]+$ ]]
exec "${C008_SSH:?}" -F /dev/null -T -p "${C008_SSH_PORT:?}" -i "${C008_SSH_OWNED_KEY:?}" -o IdentitiesOnly=yes -o StrictHostKeyChecking=yes -o UserKnownHostsFile="${C008_SSH_OWNED_KNOWN_HOSTS:?}" "${C008_SSH_USER:?}@${C008_SSH_HOST}" "stty -F $1 size"
