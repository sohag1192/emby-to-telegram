#!/usr/bin/env bash
if [ "$EUID" -ne 0 ]; then
    echo "⚠️ Please run as root: sudo bash restart.sh"
    exit 1
fi
systemctl restart emby-to-telegram.service
echo "✅ Emby to Telegram Notifier service restarted."
