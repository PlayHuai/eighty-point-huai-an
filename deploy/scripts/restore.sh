#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
deploy_dir="$(cd -- "$script_dir/.." && pwd)"
compose_file="$deploy_dir/compose.yaml"
env_file="$deploy_dir/.env"

if [[ $# -ne 2 || "$2" != "--confirm" ]]; then
  printf '用法：%s <备份文件.sql.gz> --confirm\n' "$0" >&2
  exit 2
fi
backup_file="$1"
if [[ ! -f "$backup_file" ]]; then
  printf '找不到备份文件：%s\n' "$backup_file" >&2
  exit 1
fi
if [[ ! -f "$env_file" ]]; then
  printf '找不到 %s；请先运行 init.sh。\n' "$env_file" >&2
  exit 1
fi
if grep -Eq '^DB_(PASSWORD|ROOT_PASSWORD)=replace-with-' "$env_file"; then
  printf '恢复前请先替换 %s 中的数据库密码占位值。\n' "$env_file" >&2
  exit 1
fi

compose=(docker compose --env-file "$env_file" -f "$compose_file")
"${compose[@]}" config --quiet
gzip -t "$backup_file"
printf '警告：恢复 %s 将替换目标数据库中的表和数据。\n' "$backup_file" >&2
# 在容器内执行命令，避免密码出现在进程参数中。
# shellcheck disable=SC2016
gzip -cd "$backup_file" \
  | "${compose[@]}" exec -T mysql sh -ec \
      'exec env MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql --user=root "$MYSQL_DATABASE"'
