#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  printf 'Usage: %s <server-binary> <environment-file>\n' "$0" >&2
  exit 2
fi

binary="$(realpath -- "$1")"
env_file="$(realpath -- "$2")"
if [[ ! -x "$binary" ]]; then
  printf 'Server binary is not executable: %s\n' "$binary" >&2
  exit 1
fi
if [[ ! -f "$env_file" ]]; then
  printf 'Environment file not found: %s\n' "$env_file" >&2
  exit 1
fi
for name in DB_HOST DB_NAME DB_USER DB_PASSWORD HTTP_ADDR; do
  if ! grep -Eq "^${name}=.+$" "$env_file" || grep -Eq "^${name}=replace-with-" "$env_file"; then
    printf 'Set a non-placeholder value for %s in %s before installing.\n' "$name" "$env_file" >&2
    exit 1
  fi
done
if [[ $EUID -ne 0 ]]; then
  printf 'Run this script as root (for example, with sudo).\n' >&2
  exit 1
fi
if ! command -v systemctl >/dev/null 2>&1; then
  printf 'systemctl is required.\n' >&2
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
Description=Huai'an Eighty Point server
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
printf 'Installed and enabled eighty-point.service. Apply migrations if needed, then run: systemctl start eighty-point\n'
