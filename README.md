---

# 🎬 Emby to Telegram Notifier

This project automatically checks your **Emby Media Server** for newly added Movies and TV Series, and sends rich notifications to a **Telegram channel/group** using a bot.

---

## ✨ Features
- Polls Emby server at a configurable interval (default: every 30 minutes).
- Detects newly added Movies and TV Series.
- Sends Telegram notifications with:
  - Title, year, and description
  - Poster image (if available)
  - Direct link to play in Emby
- Avoids duplicate notifications by tracking already sent items.
- Runs continuously as a **systemd service** on Linux.

---

## 📸 Screenshots

| Example Notifications | |
|-----------------------|--|
| ![Screenshot 39](https://github.com/sohag1192/emby-to-telegram/blob/main/Screenshot_39.png) | ![Screenshot 40](https://github.com/sohag1192/emby-to-telegram/blob/main/Screenshot_40.png) |
| ![Screenshot 41](https://github.com/sohag1192/emby-to-telegram/blob/main/Screenshot_41.png) |  ![Screenshot 40](https://github.com/sohag1192/emby-to-telegram/blob/main/Screenshot_38.png) |

---

## 📦 Requirements
- Python 3.8+
- `requests` library
- A Telegram Bot Token (from [@BotFather](https://t.me/BotFather))
- A Telegram Chat ID (channel or group)
- Emby server API key

---

## ⚙️ Installation

### 1. Clone the repository
```bash
git clone https://github.com/sohag1192/emby-to-telegram.git
cd emby-to-telegram
```

### 2. Create a virtual environment
```bash
python3 -m venv venv
source venv/bin/activate
pip install requests
deactivate
```

### 3. Configure environment variables
Instead of hardcoding secrets, export them:

```bash
export TELEGRAM_TOKEN="your_bot_token"
export TELEGRAM_CHAT_ID="-1001234567890"
export EMBY_SERVER="http://your-emby-server:8096"
export EMBY_API_KEY="your_emby_api_key"
```

---

## 🛠️ Systemd Service Setup

Create a service file:

```bash
sudo nano /etc/systemd/system/emby-to-telegram.service
```

Paste:

```ini
[Unit]
Description=Emby to Telegram Notifier
After=network.target

[Service]
User=root
WorkingDirectory=/root/emby_notifier
ExecStart=/root/emby_notifier/venv/bin/python /root/emby_notifier/emby_notifier/emby_to_telegram.py
Restart=always
RestartSec=30
Environment=TELEGRAM_TOKEN=your_bot_token
Environment=TELEGRAM_CHAT_ID=-1001234567890
Environment=EMBY_SERVER=http://your-emby-server:8096
Environment=EMBY_API_KEY=your_emby_api_key

[Install]
WantedBy=multi-user.target
```

---

## ▶️ Usage

Enable and start the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable emby-to-telegram.service
sudo systemctl start emby-to-telegram.service
```

Check status:

```bash
sudo systemctl status emby-to-telegram.service
```

View logs:

```bash
journalctl -u emby-to-telegram.service -f
```

---

## 📊 Star History & Visitors

### ⭐ Star History
[![Star History Chart](https://api.star-history.com/svg?repos=sohag1192/emby-to-telegram&type=Date)](https://www.star-history.com/#sohag1192/emby-to-telegram&Date)

### 👀 Visitor Counter
![Visitor Count](https://hits.sh/github.com/sohag1192/emby-to-telegram.svg?style=for-the-badge&label=Visitors&color=blue)

---

## 🔄 Updating

To update the script:

```bash
cd /root/emby_notifier
git pull
sudo systemctl restart emby-to-telegram.service
```

---

## 📜 License
This project is for personal use. Ensure you comply with Emby and Telegram API terms of service.

---

