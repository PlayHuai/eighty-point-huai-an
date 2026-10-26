#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
deploy_dir="$(cd -- "$script_dir/.." && pwd)"
compose_file="$deploy_dir/compose.yaml"
env_file="$deploy_dir/.env"

if [[ $# -ne 2 || "$2" != "--confirm" ]]; then
  printf 'Usage: %s <backup.sql.gz> --confirm\n' "$0" >&2
  exit 2
fi
backup_file="$1"
if [[ ! -f "$backup_file" ]]; then
  printf 'Backup file not found: %s\n' "$backup_file" >&2
  exit 1
fi
if [[ ! -f "$env_file" ]]; then
  printf 'Missing %s; run init.sh first.\n' "$env_file" >&2
  exit 1
fi
if grep -Eq '^DB_(PASSWORD|ROOT_PASSWORD)=replace-with-' "$env_file"; then
  printf 'Replace the placeholder database passwords in %s before restoring.\n' "$env_file" >&2
  exit 1
fi

compose=(docker compose --env-file "$env_file" -f "$compose_file")
"${compose[@]}" config --quiet
gzip -t "$backup_file"
printf 'Restoring %s will replace tables in the configured database.\n' "$backup_file" >&2
# The command is evaluated inside the container so its password stays out of argv.
# shellcheck disable=SC2016
gzip -cd "$backup_file" \
  | "${compose[@]}" exec -T mysql sh -ec \
      'exec env MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql --user=root "$MYSQL_DATABASE"'
