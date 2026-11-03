#!/usr/bin/env bash
# ==========================================================
# 🎬 Emby to Telegram Notifier - 1-Click Ubuntu/Linux Installer
# ==========================================================

set -e

# Detect script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Check for root/sudo
if [ "$EUID" -ne 0 ]; then
    echo "⚠️ This script requires administrative privileges."
    echo "➡️ Please run: sudo bash $0"
    exit 1
fi

echo "=========================================================="
echo "🎬 Emby to Telegram Notifier - Linux Installer"
echo "📂 Project Root: $ROOT_DIR"
echo "=========================================================="

# Step 0: Language / Script selection
TARGET_SCRIPT=""

# Check if passed as command-line argument (e.g. sudo bash install.sh 1 / 2 / en / bn)
if [ -n "$1" ]; then
    case "$1" in
        1|en|EN|english|English|emby_to_telegram.py)
            TARGET_SCRIPT="emby_to_telegram.py"
            ;;
        2|bn|BN|bangla|Bangla|bengali|Bengali|emby_to_telegram_bn.py)
            TARGET_SCRIPT="emby_to_telegram_bn.py"
            ;;
        *)
            if [ -f "$ROOT_DIR/$1" ]; then
                TARGET_SCRIPT="$1"
            else
                echo "⚠️ Unknown argument: $1"
            fi
            ;;
    esac
fi

# Interactive menu if not specified via argument
if [ -z "$TARGET_SCRIPT" ]; then
    echo ""
    echo "=========================================================="
    echo "🌐 Choose Notification Language / সংস্করণ নির্বাচন করুন:"
    echo "=========================================================="
    echo "  [1] English Notification   (emby_to_telegram.py)"
    echo "  [2] বাংলা / Bengali সংস্করণ (emby_to_telegram_bn.py)"
    echo "=========================================================="
    read -rp "Select option [1 or 2] (Default: 1): " LANG_CHOICE

    case "$LANG_CHOICE" in
        2|bn|BN|bangla|Bangla|bengali|Bengali)
            TARGET_SCRIPT="emby_to_telegram_bn.py"
            ;;
        *)
            TARGET_SCRIPT="emby_to_telegram.py"
            ;;
    esac
fi

# Verify selected script exists in project root
if [ ! -f "$ROOT_DIR/$TARGET_SCRIPT" ]; then
    echo "❌ Error: $TARGET_SCRIPT was not found in $ROOT_DIR!"
    exit 1
fi

echo ""
echo "✅ Selected Version: $TARGET_SCRIPT"
echo "=========================================================="
echo ""

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
Description=Emby to Telegram Notifier ($TARGET_SCRIPT)
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

# Update local service template as well
if [ -f "$SCRIPT_DIR/emby_to_telegram.service" ]; then
    cp "$SERVICE_FILE" "$SCRIPT_DIR/emby_to_telegram.service"
fi

# Step 5: Enable and start service
echo "🚀 [5/5] Enabling and starting background service..."
systemctl daemon-reload
systemctl enable emby-to-telegram.service
systemctl restart emby-to-telegram.service

echo ""
echo "=========================================================="
echo "✅ Installation Complete! Service is running in background."
echo "📜 Active Script: $TARGET_SCRIPT"
echo "=========================================================="
echo ""
echo "📋 Useful Service Commands:"
echo "  • Check Status:   sudo bash $SCRIPT_DIR/status.sh"
echo "  • View Live Logs: sudo bash $SCRIPT_DIR/logs.sh"
echo "  • Restart:        sudo bash $SCRIPT_DIR/restart.sh"
echo "  • Stop:           sudo bash $SCRIPT_DIR/stop.sh"
echo ""
