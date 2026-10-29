#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  printf '请以 root 身份运行此脚本（例如使用 sudo）。\n' >&2
  exit 1
fi
if ! command -v systemctl >/dev/null 2>&1; then
  printf '此脚本需要 systemctl。\n' >&2
  exit 1
fi

systemctl disable --now eighty-point.service 2>/dev/null || true
rm -f /etc/systemd/system/eighty-point.service
systemctl daemon-reload
systemctl reset-failed eighty-point.service 2>/dev/null || true
rm -f /opt/eighty-point/server
rmdir /opt/eighty-point 2>/dev/null || true
printf '已移除服务和服务端程序。环境配置及数据库数据已保留。\n'
