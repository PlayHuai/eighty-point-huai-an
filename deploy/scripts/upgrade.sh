#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
deploy_dir="$(cd -- "$script_dir/.." && pwd)"
compose_file="$deploy_dir/compose.yaml"
env_file="$deploy_dir/.env"

if [[ ! -f "$env_file" ]]; then
  printf 'Missing %s; run init.sh first.\n' "$env_file" >&2
  exit 1
fi
if grep -Eq '^DB_(PASSWORD|ROOT_PASSWORD)=replace-with-' "$env_file"; then
  printf 'Replace the placeholder database passwords in %s before upgrading.\n' "$env_file" >&2
  exit 1
fi

compose=(docker compose --env-file "$env_file" -f "$compose_file")
"${compose[@]}" config --quiet
"${compose[@]}" up -d --wait mysql redis
"$script_dir/backup.sh"
"${compose[@]}" build server migrate
"${compose[@]}" stop server
"${compose[@]}" run --rm migrate
"${compose[@]}" up -d --wait server
