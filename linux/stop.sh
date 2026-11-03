#!/usr/bin/env bash
if [ "$EUID" -ne 0 ]; then
    echo "⚠️ Please run as root: sudo bash stop.sh"
    exit 1
fi
systemctl stop emby-to-telegram.service
echo "✅ Emby to Telegram Notifier service stopped."
