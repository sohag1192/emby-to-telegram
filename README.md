<div align="center">

# 🎬 Emby to Telegram Notifier

An automated, lightweight background service for **Ubuntu / Linux** that monitors your **Emby Media Server** and broadcasts sleek, media-rich notifications with interactive action buttons directly to your **Telegram** channel, group, or private chat.

[![Visitors](https://hits.sh/github.com/sohag1192/emby-to-telegram.svg?style=for-the-badge&label=Total%20Visitors&color=007ec6)](https://hits.sh/github.com/sohag1192/emby-to-telegram/)
[![GitHub Stars](https://img.shields.io/github/stars/sohag1192/emby-to-telegram?style=for-the-badge&color=f5c518)](https://github.com/sohag1192/emby-to-telegram/stargazers)
[![Python](https://img.shields.io/badge/Python-3.8+-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%20%7C%2022.04%20%7C%2024.04-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![Telegram](https://img.shields.io/badge/Telegram-Bot%20API-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://core.telegram.org/bots)
[![License](https://img.shields.io/badge/License-MIT-success?style=for-the-badge)](LICENSE)

<br/>

<img src="Screenshot_29.png" alt="Emby to Telegram Overview" width="100%" />

</div>

---

## 📸 Telegram Notifications Preview

<div align="center">

| 🎬 Movie Notification Card | 📺 TV Series Notification Card |
| :---: | :---: |
| <img src="Screenshot_30.png" width="380" alt="Movie Card Preview" /> | <img src="Screenshot_31.png" width="380" alt="TV Series Card Preview" /> |

</div>

---

## ✨ Features

- 🔄 **Autonomous 24/7 Background Service**: Runs seamlessly as a native `systemd` service on Ubuntu with automatic restarts on crash or system boot.
- 🛡️ **Guaranteed Duplicate Prevention**: Double-locking protection tracks both Emby Item IDs and normalized Title keys with immediate atomic disk persistence (`emby_notified.txt`). Items will **never** be sent twice.
- 🎬 **Multi-Media Monitoring**: Automatically detects newly added **Movies** and **TV Series**.
- 📊 **Rich Metadata Cards**:
  - 📌 Title and release year
  - ⭐ Community Rating (`8.3/10`) & 🍅 Critic Rating (`73%`)
  - 🎭 Genres (e.g. *Action, Crime, Drama*)
  - ⏱️ Converted human-readable runtime (`1h 48m`)
  - 🔞 Age / content certification (`PG-13`, `R`, `TV-MA`)
  - 🎞️ Quality & file size (`1080p | 1.03 GB`)
  - 📺 TV Series status (*Continuing / Ended*)
- 🟢 **Styled Interactive Buttons**: One-click **`[Watch on SN FTP SERVER]`** inline button linking directly to the Emby web player with native Telegram Bot API styling.
- 🖼️ **High-Res Poster Art**: Downloads and attaches primary poster artwork with automatic fallback to text if an image is missing.
- ⚡ **Lightweight & Fast**: Uses standard Python libraries with low CPU and memory footprint.

---

## 🔗 Related Emby Projects

Check out these other open-source projects for Emby Media Server by [@sohag1192](https://github.com/sohag1192):

- 🎨 [**Emby Home Swiper UI**](https://github.com/sohag1192/Emby-Home-Swiper-UI) – A sleek, modern touch-enabled swiper carousel for the Emby web client home screen.
- 🔍 [**Emby Duplicate Finder**](https://github.com/sohag1192/emby-duplicate-finder) – Find, filter, and organize duplicate movies and media files across all your Emby libraries.

---

## 📦 Requirements

* **Ubuntu Linux** (20.04 LTS, 22.04 LTS, 24.04 LTS, or Debian-based distributions)
* **Python 3.8+**
* An active **Emby Media Server** with an API key
* A **Telegram Bot Token** (from [@BotFather](https://t.me/BotFather))
* A destination **Telegram Chat ID** (Channel, Group, or User ID)

---

## 🚀 Ubuntu Installation Guide

Follow these step-by-step instructions to install and configure the notifier on your Ubuntu server:

### Step 1: Install System Dependencies

Update package lists and install Python, `pip`, virtual environment tools, and `git`:

```bash
sudo apt update && sudo apt install -y python3 python3-pip python3-venv git
```

---

### Step 2: Clone the Repository

Clone the project to your preferred location (recommended path: `/opt/emby-to-telegram`):

```bash
sudo git clone https://github.com/sohag1192/emby-to-telegram.git /opt/emby-to-telegram
cd /opt/emby-to-telegram
```

---

### Step 3: Set Up Python Virtual Environment

Create an isolated virtual environment and install the required dependencies:

```bash
# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Deactivate venv
deactivate
```

---

### Step 4: Configure Credentials

Open `emby_to_telegram.py` using nano:

```bash
nano emby_to_telegram.py
```

Set your Telegram Bot Token, Chat ID, Emby Server URL, and API Key at the top of the file:

```python
TELEGRAM_TOKEN = os.getenv('TELEGRAM_TOKEN', 'YOUR_TELEGRAM_BOT_TOKEN')
TELEGRAM_CHAT_ID = os.getenv('TELEGRAM_CHAT_ID', 'YOUR_TELEGRAM_CHAT_ID')
EMBY_SERVER = os.getenv('EMBY_SERVER', 'http://YOUR_EMBY_IP:8096').rstrip('/')
EMBY_API_KEY = os.getenv('EMBY_API_KEY', 'YOUR_EMBY_API_KEY')
```

> **Tip:** Press `Ctrl + O`, then `Enter` to save in nano, and `Ctrl + X` to exit.

You can also override credentials anytime via system environment variables:
```bash
export TELEGRAM_TOKEN="YOUR_TELEGRAM_BOT_TOKEN"
export TELEGRAM_CHAT_ID="YOUR_TELEGRAM_CHAT_ID"
export EMBY_SERVER="http://YOUR_EMBY_IP:8096"
export EMBY_API_KEY="YOUR_EMBY_API_KEY"
```

---

### Step 5: Test Run (Optional)

Verify your configuration before starting background mode:

```bash
/opt/emby-to-telegram/venv/bin/python emby_to_telegram.py
```

If everything is configured properly, you will see:
```text
Starting Emby to Telegram notifier...
Checking for new content...
```
Press `Ctrl + C` to stop the test run.

---

## ⚙️ Running in the Background on Ubuntu

### Method 1: Systemd Service (Recommended & Production-Ready)

Running as a `systemd` service ensures the bot starts automatically on server boot, restarts automatically if it crashes, and lets you inspect logs easily.

1. **Copy the service file to the systemd directory:**

```bash
sudo cp /opt/emby-to-telegram/emby_to_telegram.service /etc/systemd/system/
```

2. **Reload systemd daemon:**

```bash
sudo systemctl daemon-reload
```

3. **Enable and start the service:**

```bash
# Enable to start automatically on system boot
sudo systemctl enable emby_to_telegram.service

# Start the service immediately
sudo systemctl start emby_to_telegram.service
```

4. **Check status:**

```bash
sudo systemctl status emby_to_telegram.service
```

5. **View live real-time logs:**

```bash
journalctl -u emby_to_telegram.service -f
```

#### Handy Service Management Commands:

| Action | Command |
| :--- | :--- |
| **Check Status** | `sudo systemctl status emby_to_telegram` |
| **Start Service** | `sudo systemctl start emby_to_telegram` |
| **Stop Service** | `sudo systemctl stop emby_to_telegram` |
| **Restart Service** | `sudo systemctl restart emby_to_telegram` |
| **Disable Boot Autostart** | `sudo systemctl disable emby_to_telegram` |
| **View Live Logs** | `journalctl -u emby_to_telegram -f` |

---

### Method 2: Running with `nohup` (Simple Background Run)

If you do not want to use `systemd`, you can run the bot using `nohup`:

```bash
cd /opt/emby-to-telegram
nohup /opt/emby-to-telegram/venv/bin/python emby_to_telegram.py > notifier.log 2>&1 &
```

* **Check the live log:**
  ```bash
  tail -f notifier.log
  ```

* **Stop the process:**
  ```bash
  pkill -f emby_to_telegram.py
  ```

---

## 🛠️ Configuration Reference

| Parameter | Description | Default |
| :--- | :--- | :--- |
| `TELEGRAM_TOKEN` | Bot API token from [@BotFather](https://t.me/BotFather) | *Required* |
| `TELEGRAM_CHAT_ID` | Telegram Channel/Group/User ID | *Required* |
| `EMBY_SERVER` | Base URL of your Emby server (e.g. `http://100.100.100.6:8096`) | *Required* |
| `EMBY_API_KEY` | Emby API Key (*Emby Dashboard > Advanced > API Keys*) | *Required* |
| `CHECK_INTERVAL` | Interval between library checks in seconds | `1800` (30 mins) |
| `MESSAGE_DELAY` | Delay between consecutive Telegram messages in seconds | `10` |

---

## 🔄 Updating to Latest Version

To update your installation to the latest version:

```bash
cd /opt/emby-to-telegram
sudo systemctl stop emby_to_telegram.service
git pull
sudo systemctl start emby_to_telegram.service
```

---

## ❓ Troubleshooting

#### 1. `Telegram API Error: Bad Request: chat not found`
* Ensure your bot is added as an **Administrator** in your Telegram channel or group.
* If sending to a public channel, you can use `@YourChannelUsername`. For private channels, use the negative numeric ID (e.g., `-100xxxxxxxxxx`).

#### 2. `Error fetching media from Emby: HTTPConnectionPool...`
* Check if your Emby server URL is reachable from the Ubuntu machine:
  ```bash
  curl -I http://YOUR_EMBY_IP:8096/emby/System/Info/Public
  ```
* Verify your Emby API key is valid in the Emby Admin Dashboard.

#### 3. Service fails to start (`Exit code 1`)
* Inspect recent error logs:
  ```bash
  journalctl -u emby_to_telegram.service -n 50 --no-pager
  ```
* Verify file permissions:
  ```bash
  sudo chown -R root:root /opt/emby-to-telegram
  ```

---

## 📊 Star History & Visitor Count

### 👀 Total Visitors
[![Visitor Counter](https://hits.sh/github.com/sohag1192/emby-to-telegram.svg?style=for-the-badge&label=Total%20Visitors&color=007ec6)](https://hits.sh/github.com/sohag1192/emby-to-telegram/)

### ⭐ Star History
[![Star History Chart](https://api.star-history.com/svg?repos=sohag1192/emby-to-telegram&type=Date)](https://www.star-history.com/#sohag1192/emby-to-telegram&Date)

---

## 📜 License

This project is licensed under the MIT License.
