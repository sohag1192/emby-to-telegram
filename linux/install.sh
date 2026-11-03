#!/usr/bin/env bash
# ==========================================================
# 🎬 Emby to Telegram Notifier - 1-Click Ubuntu/Linux Installer
# ==========================================================

set -e

# Detect script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

TARGET_SCRIPT="${1:-emby_to_telegram_bn.py}"
if [ ! -f "$ROOT_DIR/$TARGET_SCRIPT" ]; then
    TARGET_SCRIPT="emby_to_telegram.py"
fi

echo "=========================================================="
echo "🎬 Installing Emby to Telegram Notifier ($TARGET_SCRIPT)"
echo "📂 Project Root: $ROOT_DIR"
echo "=========================================================="

# Check for root/sudo
if [ "$EUID" -ne 0 ]; then
    echo "⚠️ This script requires administrative privileges."
    echo "➡️ Please run: sudo bash $0"
    exit 1
fi

# Step 1: Install system dependencies
echo "📦 [1/5] Updating package lists and installing dependencies..."
apt-get update -y
apt-get install -y python3 python3-pip python3-venv git curl

# Step 2: Create Python virtual environment
echo "🐍 [2/5] Setting up Python virtual environment..."
if [ ! -d "$ROOT_DIR/venv" ]; then
    python3 -m venv "$ROOT_DIR/venv"
fi

# Step 3: Install Python requirements
echo "📥 [3/5] Installing Python requirements..."
"$ROOT_DIR/venv/bin/pip" install --upgrade pip
"$ROOT_DIR/venv/bin/pip" install -r "$ROOT_DIR/requirements.txt"

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
WorkingDirectory=$ROOT_DIR
ExecStart=$ROOT_DIR/venv/bin/python $ROOT_DIR/$TARGET_SCRIPT
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
echo "  • Check Status:   sudo bash $SCRIPT_DIR/status.sh"
echo "  • View Live Logs: sudo bash $SCRIPT_DIR/logs.sh"
echo "  • Restart:        sudo bash $SCRIPT_DIR/restart.sh"
echo "  • Stop:           sudo bash $SCRIPT_DIR/stop.sh"
echo ""
