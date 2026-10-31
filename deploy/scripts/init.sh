#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
deploy_dir="$(cd -- "$script_dir/.." && pwd)"
compose_file="$deploy_dir/compose.yaml"
env_file="$deploy_dir/.env"

if [[ ! -f "$env_file" ]]; then
  cp "$deploy_dir/.env.example" "$env_file"
  chmod 600 "$env_file"
  printf '已创建 %s；请替换其中的密码占位值后重新运行 init.sh。\n' "$env_file" >&2
  exit 1
fi
if grep -Eq '^DB_(PASSWORD|ROOT_PASSWORD)=replace-with-' "$env_file"; then
  printf '部署前请先替换 %s 中的数据库密码占位值。\n' "$env_file" >&2
  exit 1
fi

source "$script_dir/build-info.sh"
compose=(docker compose --env-file "$env_file" -f "$compose_file")
"${compose[@]}" config --quiet
"${compose[@]}" build server migrate
"${compose[@]}" up -d --wait mysql redis
"${compose[@]}" run --rm migrate
"${compose[@]}" up -d --wait server
