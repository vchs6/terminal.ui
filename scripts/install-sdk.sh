#!/usr/bin/env bash
set -euo pipefail
root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
install_dir="${1:?Usage: install-sdk.sh INSTALL_DIRECTORY}"
sdk_url="$(node -p "require('$root_dir/docs/development/tools.lock.json').sdk.url")"
sdk_hash="$(node -p "require('$root_dir/docs/development/tools.lock.json').sdk.sha256")"
# A trusted mirror must serve exactly the pinned official bytes.
sdk_url="${CANGJIE_SDK_URL:-$sdk_url}"
mkdir -p "$install_dir"
curl --fail --location --retry 2 --connect-timeout 20 --max-time 300 "$sdk_url" -o "$install_dir/sdk.tar.gz"
printf '%s  %s\n' "$sdk_hash" "$install_dir/sdk.tar.gz" | sha256sum --check --status
tar -xzf "$install_dir/sdk.tar.gz" -C "$install_dir"
test -f "$install_dir/cangjie/envsetup.sh"
set +u
source "$install_dir/cangjie/envsetup.sh"
set -u
cjc --version
cjpm --version
