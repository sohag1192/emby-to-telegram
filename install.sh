#!/usr/bin/env bash
# ==========================================================
# 🎬 Emby to Telegram Notifier - 1-Click Ubuntu/Linux Installer
# ==========================================================

set -e

# Detect script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================================="
echo "🎬 Installing Emby to Telegram Notifier"
echo "📂 Directory: $SCRIPT_DIR"
echo "=========================================================="

# Check for root/sudo
if [ "$EUID" -ne 0 ]; then
    echo "⚠️ This script requires administrative privileges."
    echo "➡️ Please run: sudo bash install.sh"
    exit 1
fi

# Step 1: Install system dependencies
echo "📦 [1/5] Updating package lists and installing dependencies..."
apt-get update -y
apt-get install -y python3 python3-pip python3-venv git curl

# Step 2: Create Python virtual environment
echo "🐍 [2/5] Setting up Python virtual environment..."
if [ ! -d "$SCRIPT_DIR/venv" ]; then
    python3 -m venv "$SCRIPT_DIR/venv"
fi

# Step 3: Install Python requirements
echo "📥 [3/5] Installing Python requirements..."
"$SCRIPT_DIR/venv/bin/pip" install --upgrade pip
"$SCRIPT_DIR/venv/bin/pip" install -r "$SCRIPT_DIR/requirements.txt"

# Step 4: Configure systemd background service
echo "⚙️ [4/5] Configuring systemd background service..."
SERVICE_FILE="/etc/systemd/system/emby-to-telegram.service"

cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=Emby to Telegram Notifier
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$SCRIPT_DIR
ExecStart=$SCRIPT_DIR/venv/bin/python $SCRIPT_DIR/emby_to_telegram.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Step 5: Enable and start service
echo "🚀 [5/5] Enabling and starting background service..."
systemctl daemon-reload
systemctl enable emby-to-telegram.service
systemctl restart emby-to-telegram.service

echo ""
echo "=========================================================="
echo "✅ Installation Complete! Service is running in background."
echo "=========================================================="
echo ""
echo "📋 Useful Service Commands:"
echo "  • Check Status:   sudo systemctl status emby-to-telegram"
echo "  • View Live Logs: sudo journalctl -u emby-to-telegram -f"
echo "  • Restart:        sudo systemctl restart emby-to-telegram"
echo "  • Stop:           sudo systemctl stop emby-to-telegram"
echo ""
