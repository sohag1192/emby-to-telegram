<div align="center">

# 🎬 Emby to Telegram Notifier

An automated, lightweight background service for **Ubuntu / Linux** and **Windows** that monitors your **Emby Media Server** and broadcasts sleek, media-rich notifications with interactive action buttons directly to your **Telegram** channel, group, or private chat.

[![Visitors](https://hits.sh/github.com/sohag1192/emby-to-telegram.svg?style=for-the-badge&label=Total%20Visitors&color=007ec6)](https://hits.sh/github.com/sohag1192/emby-to-telegram/)
[![GitHub Stars](https://img.shields.io/github/stars/sohag1192/emby-to-telegram?style=for-the-badge&color=f5c518)](https://github.com/sohag1192/emby-to-telegram/stargazers)
[![Python](https://img.shields.io/badge/Python-3.8+-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%20%7C%2022.04%20%7C%2024.04-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011%20%7C%20Server-0078D6?style=for-the-badge&logo=windows&logoColor=white)](https://www.microsoft.com/windows)
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

- 🔄 **Autonomous 24/7 Background Service**:
  - **Ubuntu / Linux**: Runs silently as a native `systemd` daemon with auto-restart on boot or crash.
  - **Windows**: Silent background service with zero popup console windows and automatic launch on Windows boot.
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
- ⚡ **Lightweight & Fast**: Minimal CPU and memory usage.

---

## 🔗 Related Emby Projects

Check out these other open-source projects for Emby Media Server by [@sohag1192](https://github.com/sohag1192):

- 🎨 [**Emby Home Swiper UI**](https://github.com/sohag1192/Emby-Home-Swiper-UI) – A sleek, modern touch-enabled swiper carousel for the Emby web client home screen.
- 🔍 [**Emby Duplicate Finder**](https://github.com/sohag1192/emby-duplicate-finder) – Find, filter, and organize duplicate movies and media files across all your Emby libraries.

---

## 📦 Requirements

* **Operating System**: Ubuntu / Debian Linux or Windows 10/11/Server
* **Python 3.8+**
* An active **Emby Media Server** with an API key
* A **Telegram Bot Token** (from [@BotFather](https://t.me/BotFather))
* A destination **Telegram Chat ID** (Channel, Group, or User ID)

---

## ⚡ 1-Click Quick Installers

We provide automated 1-click installer scripts for both **Ubuntu / Linux** and **Windows**:

### 🐧 Option A: Ubuntu / Linux (1-Click Installer)

1. Clone the repository:
   ```bash
   sudo git clone https://github.com/sohag1192/emby-to-telegram.git /opt/emby-to-telegram
   cd /opt/emby-to-telegram
   ```

2. Configure your credentials at the top of `emby_to_telegram.py`:
   ```bash
   nano emby_to_telegram.py
   ```

3. Run the installer script:
   ```bash
   sudo bash install.sh
   ```

> **What it does automatically:**
> - Installs Python, venv, and system packages.
> - Builds the virtual environment and installs dependencies.
> - Configures and registers the `emby-to-telegram.service` in systemd.
> - Enables auto-start on boot and starts the service in the background immediately!

---

### 🪟 Option B: Windows (1-Click Background Auto-Runner)

1. Download or clone this repository to a folder on your computer (e.g. `D:\emby_notifier`).
2. Edit `emby_to_telegram.py` with Notepad to add your Telegram Token, Chat ID, and Emby API key.
3. **Double-click `install_windows.bat`**.

> **What it does automatically:**
> - Checks Python installation.
> - Sets up the virtual environment (`venv`) and installs requirements.
> - Configures a silent background auto-start shortcut in your Windows Startup folder.
> - Launches the notifier immediately in the background using `pythonw.exe` (no black terminal window).

#### Managing on Windows:
| Action | File to Run |
| :--- | :--- |
| **Start in Background** | Double-click `start_windows.bat` |
| **Stop Background Process** | Double-click `stop_windows.bat` |

---

## 📖 Manual Installation (Ubuntu Linux)

If you prefer to configure everything manually on Ubuntu:

### Step 1: Install System Dependencies
```bash
sudo apt update && sudo apt install -y python3 python3-pip python3-venv git
```

### Step 2: Clone and Setup Virtual Environment
```bash
sudo git clone https://github.com/sohag1192/emby-to-telegram.git /opt/emby-to-telegram
cd /opt/emby-to-telegram

python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
deactivate
```

### Step 3: Run as a Background Systemd Service
```bash
# Copy service unit
sudo cp /opt/emby-to-telegram/emby_to_telegram.service /etc/systemd/system/

# Reload systemd and start service
sudo systemctl daemon-reload
sudo systemctl enable --now emby_to_telegram.service

# Check status
sudo systemctl status emby_to_telegram.service

# View live real-time logs
journalctl -u emby_to_telegram.service -f
```

#### Handy Linux Service Commands:
| Action | Command |
| :--- | :--- |
| **Check Status** | `sudo systemctl status emby_to_telegram` |
| **Start Service** | `sudo systemctl start emby_to_telegram` |
| **Stop Service** | `sudo systemctl stop emby_to_telegram` |
| **Restart Service** | `sudo systemctl restart emby_to_telegram` |
| **View Live Logs** | `journalctl -u emby_to_telegram -f` |

---

## 🛠️ Configuration Reference

Inside `emby_to_telegram.py` (or via system environment variables):

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

```bash
# On Linux
cd /opt/emby-to-telegram
sudo systemctl stop emby_to_telegram.service
git pull
sudo systemctl start emby_to_telegram.service

# On Windows
git pull
call start_windows.bat
```

---

## ❓ Troubleshooting

#### 1. `Telegram API Error: Bad Request: chat not found`
* Ensure your bot is added as an **Administrator** in your Telegram channel or group.
* If sending to a public channel, you can use `@YourChannelUsername`. For private channels, use the negative numeric ID (e.g., `-100xxxxxxxxxx`).

#### 2. `Error fetching media from Emby: HTTPConnectionPool...`
* Check if your Emby server URL is reachable from the machine:
  ```bash
  curl -I http://YOUR_EMBY_IP:8096/emby/System/Info/Public
  ```
* Verify your Emby API key is valid in the Emby Admin Dashboard.

#### 3. Linux Service fails to start (`Exit code 1`)
* View recent error logs:
  ```bash
  journalctl -u emby_to_telegram.service -n 50 --no-pager
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
