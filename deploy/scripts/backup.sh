#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
deploy_dir="$(cd -- "$script_dir/.." && pwd)"
compose_file="$deploy_dir/compose.yaml"
env_file="$deploy_dir/.env"
backup_dir="${1:-$deploy_dir/backups}"

if [[ ! -f "$env_file" ]]; then
  printf 'Missing %s; run init.sh first.\n' "$env_file" >&2
  exit 1
fi
if grep -Eq '^DB_(PASSWORD|ROOT_PASSWORD)=replace-with-' "$env_file"; then
  printf 'Replace the placeholder database passwords in %s before backing up.\n' "$env_file" >&2
  exit 1
fi

compose=(docker compose --env-file "$env_file" -f "$compose_file")
"${compose[@]}" config --quiet
umask 077
mkdir -p "$backup_dir"
backup_file="$backup_dir/mysql-$(date -u +%Y%m%dT%H%M%SZ).sql.gz"
tmp_file="$(mktemp "$backup_file.tmp.XXXXXX")"
trap 'rm -f "$tmp_file"' EXIT

# The command is evaluated inside the container so its password stays out of argv.
# shellcheck disable=SC2016
"${compose[@]}" exec -T mysql sh -ec \
  'exec env MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysqldump --user=root --single-transaction --routines --triggers --add-drop-table "$MYSQL_DATABASE"' \
  | gzip -c > "$tmp_file"
mv "$tmp_file" "$backup_file"
trap - EXIT
printf '%s\n' "$backup_file"
