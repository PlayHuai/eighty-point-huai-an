#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  printf 'Run this script as root (for example, with sudo).\n' >&2
  exit 1
fi
if ! command -v systemctl >/dev/null 2>&1; then
  printf 'systemctl is required.\n' >&2
  exit 1
fi

systemctl disable --now eighty-point.service 2>/dev/null || true
rm -f /etc/systemd/system/eighty-point.service
systemctl daemon-reload
systemctl reset-failed eighty-point.service 2>/dev/null || true
rm -f /opt/eighty-point/server
rmdir /opt/eighty-point 2>/dev/null || true
printf 'Removed the service and server binary. Configuration and database data were kept.\n'
