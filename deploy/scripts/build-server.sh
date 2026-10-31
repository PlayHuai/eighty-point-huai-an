#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/build-info.sh"
cd "$repo_dir/server"
package=github.com/Derek0120/eighty-point-huai-an/server/internal/buildinfo
go build -trimpath \
  -ldflags="-s -w -X $package.Commit=$SERVER_COMMIT -X $package.Version=$SERVER_VERSION -X $package.ChangelistBase64=$SERVER_CHANGELIST" \
  -o "${1:-$repo_dir/dist/server}" ./cmd/server
