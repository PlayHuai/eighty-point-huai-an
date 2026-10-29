#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  printf '用法：%s <服务端程序路径> <环境配置文件路径>\n' "$0" >&2
  exit 2
fi

binary="$(realpath -- "$1")"
env_file="$(realpath -- "$2")"
if [[ ! -x "$binary" ]]; then
  printf '服务端程序不存在或不可执行：%s\n' "$binary" >&2
  exit 1
fi
if [[ ! -f "$env_file" ]]; then
  printf '找不到环境配置文件：%s\n' "$env_file" >&2
  exit 1
fi
for name in DB_HOST DB_NAME DB_USER DB_PASSWORD HTTP_ADDR; do
  if ! grep -Eq "^${name}=.+$" "$env_file" || grep -Eq "^${name}=replace-with-" "$env_file"; then
    printf '安装前请在配置文件 %s 中为 %s 设置有效值，不能留空或使用占位值。\n' "$env_file" "$name" >&2
    exit 1
  fi
done
if [[ $EUID -ne 0 ]]; then
  printf '请以 root 身份运行此脚本（例如使用 sudo）。\n' >&2
  exit 1
fi
if ! command -v systemctl >/dev/null 2>&1; then
  printf '此脚本需要 systemctl。\n' >&2
  exit 1
fi

if ! getent passwd eighty-point >/dev/null; then
  useradd --system --no-create-home --shell /usr/sbin/nologin eighty-point
fi

install -d -o root -g root -m 0755 /opt/eighty-point /etc/eighty-point
install -o root -g root -m 0755 "$binary" /opt/eighty-point/server
install -o root -g root -m 0600 "$env_file" /etc/eighty-point/server.env

cat > /etc/systemd/system/eighty-point.service <<'EOF'
[Unit]
Description=淮安80分服务端
After=network.target mysql.service

[Service]
Type=simple
User=eighty-point
Group=eighty-point
EnvironmentFile=/etc/eighty-point/server.env
ExecStartPre=/opt/eighty-point/server migrate
ExecStart=/opt/eighty-point/server serve
Restart=on-failure
RestartSec=5
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable eighty-point.service
printf '已安装并启用 eighty-point.service。启动服务并执行数据库迁移：systemctl start eighty-point\n'
