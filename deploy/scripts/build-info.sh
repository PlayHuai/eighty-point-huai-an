#!/usr/bin/env bash
set -euo pipefail

build_info_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(cd -- "$build_info_dir/../.." && pwd)"
SERVER_COMMIT="$(git -C "$repo_dir" rev-parse --verify HEAD)"
SERVER_VERSION="$(tr -d '\r\n' < "$repo_dir/VERSION")"
if [[ ! "$SERVER_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+([+-][A-Za-z0-9.-]+)?$ ]]; then
  printf 'VERSION must contain a version such as 1.0.0 or 1.0.0-beta.1.\n' >&2
  exit 1
fi
if [[ ! -s "$repo_dir/CHANGELOG.md" ]]; then
  printf 'CHANGELOG.md must not be empty.\n' >&2
  exit 1
fi
SERVER_CHANGELIST="$(base64 < "$repo_dir/CHANGELOG.md" | tr -d '\r\n')"
export SERVER_COMMIT SERVER_VERSION SERVER_CHANGELIST
