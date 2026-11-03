#!/usr/bin/env bash
if [ "$EUID" -ne 0 ]; then
    echo "⚠️ Please run as root: sudo bash uninstall.sh"
    exit 1
fi
echo "🛑 Uninstalling Emby to Telegram Service..."
systemctl stop emby-to-telegram.service 2>/dev/null || true
systemctl disable emby-to-telegram.service 2>/dev/null || true
rm -f /etc/systemd/system/emby-to-telegram.service
systemctl daemon-reload
echo "✅ Service successfully uninstalled."
