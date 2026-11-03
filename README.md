<div align="center">

# 🎬 Emby to Telegram Notifier

An automated, lightweight background service for **Windows & Ubuntu / Linux** that monitors your **Emby Media Server** and broadcasts sleek, media-rich notifications with interactive action buttons directly to your **Telegram** channel, group, or private chat.

[![Release](https://img.shields.io/badge/Release-v3.0-blueviolet?style=for-the-badge&logo=github)](https://github.com/sohag1192/emby-to-telegram/releases)
[![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011%20%7C%20Server-0078D6?style=for-the-badge&logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%20%7C%2022.04%20%7C%2024.04-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![Python](https://img.shields.io/badge/Python-3.8+-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![Telegram](https://img.shields.io/badge/Telegram-Bot%20API-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://core.telegram.org/bots)
[![License](https://img.shields.io/badge/License-MIT-success?style=for-the-badge)](LICENSE)
[![Daily & Total Hits](https://hits.sh/github.com/sohag1192/emby-to-telegram.svg?view=today-total&style=for-the-badge&label=Daily%20%2F%20Total%20Hits&color=007ec6)](https://hits.sh/github.com/sohag1192/emby-to-telegram/)
[![GitHub Stars](https://img.shields.io/github/stars/sohag1192/emby-to-telegram?style=for-the-badge&color=f5c518)](https://github.com/sohag1192/emby-to-telegram/stargazers)

<br/>

**Language / ভাষা:**
[![English](https://img.shields.io/badge/Language-English-blue?style=for-the-badge)](README.md)
[![বাংলা](https://img.shields.io/badge/Language-%E0%A6%AC%E0%A6%BE%E0%A6%82%E0%A6%B2%E0%A6%BE-green?style=for-the-badge)](README_bn.md)

<p align="center">
  <a href="README.md">🇬🇧 <b>English</b></a> • 
  <a href="README_bn.md">🇧🇩 <b>বাংলা (Bengali)</b></a>
</p>

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

- 🔄 **Autonomous 24/7 Background Service**: Runs seamlessly as a native `systemd` daemon on Ubuntu/Linux with automatic restarts on crash or system boot.
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

## 🚀 What's New in Version 3.0 (v3.0)

- 🪟 **Dedicated Windows Package (`windows/`)**:
  - `install.bat`: 1-Click installer and automatic Windows Startup boot integration.
  - `run.bat`: Always-Run console launcher with continuous auto-restart loop on crashes.
  - `run_background.bat` & `run_hidden.vbs`: Windowless background runner for silent 24/7 service.
  - `status.bat` & `stop.bat`: Instant process state inspection and 1-click process shutdown.
- 🐧 **Dedicated Linux Package (`linux/`)**:
  - `install.sh`: 1-Click Ubuntu / Debian installer with native `systemd` service setup.
  - Management scripts: `status.sh`, `logs.sh`, `restart.sh`, `stop.sh`, `uninstall.sh`.
- 🇧🇩 **Dedicated Bengali Edition (`emby_to_telegram_bn.py`)**:
  - Full native Bengali card formatting, runtimes, ratings, and statuses.
- 🛡️ **Double-Lock Protection & Text Fallback**:
  - Complete duplicate filtering and automatic text fallback when poster images are unavailable.
- 🧹 **Clean Repository Architecture**:
  - Modular directory organization (`windows/`, `linux/`) and runtime files properly ignored in `.gitignore`.
- 🚀 **Updated GitHub Deployment Tool (`upload_to_github.BAT`)**:
  - Version-tagged git synchronization tool supporting release v3.0 tags and rebase workflows.

---

## 🔗 Related Emby Projects

Check out these other open-source projects for Emby Media Server by [@sohag1192](https://github.com/sohag1192):

- 🎨 [**Emby Home Swiper UI**](https://github.com/sohag1192/Emby-Home-Swiper-UI) – A sleek, modern touch-enabled swiper carousel for the Emby web client home screen.
- 🔍 [**Emby Duplicate Finder**](https://github.com/sohag1192/emby-duplicate-finder) – Find, filter, and organize duplicate movies and media files across all your Emby libraries.

---

## 📦 Requirements

* **Ubuntu / Debian Linux** or **Windows (10 / 11 / Server)**
* **Python 3.8+**
* An active **Emby Media Server** with an API key
* A **Telegram Bot Token** (from [@BotFather](https://t.me/BotFather))
* A destination **Telegram Chat ID** (Channel, Group, or User ID)

---

## 🪟 1-Click Windows Setup & 24/7 Running

All Windows scripts are organized inside the **`windows/`** directory:

| Script File | Path | Purpose & Features |
| :--- | :--- | :--- |
| **`install.bat`** | `windows/install.bat` | 🎬 **1-Click Installer**: Creates Python venv, installs requirements, and sets up Windows boot auto-start. |
| **`run.bat`** | `windows/run.bat` | 🔄 **Always-Run Console**: Displays live logs and automatically restarts after 10s if disconnected or crashed. |
| **`run_background.bat`** | `windows/run_background.bat` | 🚀 **Background Runner**: Runs silently 24/7 without keeping any open command prompt window. |
| **`status.bat`** | `windows/status.bat` | 📊 **Status Check**: Instantly verifies if the notifier is running and displays its Process ID (PID). |
| **`stop.bat`** | `windows/stop.bat` | 🛑 **Stop Service**: Terminates all running foreground and background notifier processes. |

### How to use on Windows:
1. Double-click **`windows/install.bat`** to set up the virtual environment and dependencies.
2. When prompted, choose `Y` to enable automatic startup whenever Windows boots.
3. Launch **`windows/run.bat`** for live console monitoring, or **`windows/run_background.bat`** to run silently 24/7 in the background.

---

## ⚡ 1-Click Quick Installation (Ubuntu / Linux)

All Linux scripts and service configurations are located in the **`linux/`** directory:

1. **Clone the repository:**
   ```bash
   sudo git clone https://github.com/sohag1192/emby-to-telegram.git /opt/emby-to-telegram
   cd /opt/emby-to-telegram
   ```

2. **Configure your credentials in `emby_to_telegram.py`:**
   ```bash
   nano emby_to_telegram.py
   ```
   Set your `TELEGRAM_TOKEN`, `TELEGRAM_CHAT_ID`, `EMBY_SERVER`, and `EMBY_API_KEY`.

3. **Run the 1-click installer script:**
   ```bash
   # For Bengali (বাংলা) notifications:
   sudo bash linux/install.sh emby_to_telegram_bn.py

   # Or for English notifications:
   sudo bash linux/install.sh emby_to_telegram.py
   ```

> 💡 **Linux Service Management Scripts (`linux/` directory):**
> - **Check Status:** `sudo bash linux/status.sh`
> - **View Live Logs:** `sudo bash linux/logs.sh`
> - **Restart Service:** `sudo bash linux/restart.sh`
> - **Stop Service:** `sudo bash linux/stop.sh`
> - **Uninstall Service:** `sudo bash linux/uninstall.sh`

> **What `install.sh` does automatically:**
> - Installs Python, venv, and required system tools.
> - Creates isolated virtual environment and installs dependencies.
> - Configures and registers `emby-to-telegram.service` in systemd.
> - Enables automatic startup on boot and starts the service immediately.
> - Supports both English (`emby_to_telegram.py`) and Bengali (`emby_to_telegram_bn.py`)!

---

## 📖 Manual Installation (Ubuntu Linux)

If you prefer to configure everything step-by-step manually:

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

### 👀 Daily & Total Hits
[![Daily & Total Hits](https://hits.sh/github.com/sohag1192/emby-to-telegram.svg?view=today-total&style=for-the-badge&label=Daily%20%2F%20Total%20Hits&color=007ec6)](https://hits.sh/github.com/sohag1192/emby-to-telegram/)

### ⭐ Star History
[![Star History Chart](https://api.star-history.com/svg?repos=sohag1192/emby-to-telegram&type=Date)](https://www.star-history.com/#sohag1192/emby-to-telegram&Date)

---

## 🤝 Contributing & Contact

Contributions, bug reports, feature suggestions, and pull requests are welcome!  
If you find a bug or have an idea to improve the UI, feel free to open an [Issue](https://github.com/sohag1192/emby-to-telegram/issues) or submit a [Pull Request](https://github.com/sohag1192/emby-to-telegram/pulls).

<p align="center">
  📫 <b>Email:</b> <a href="mailto:sohag1192@gmail.com">sohag1192@gmail.com</a><br/>
  💬 <b>Telegram:</b> <a href="https://t.me/Md_Sohag_Rana">@Md_Sohag_Rana</a>
</p>

---

## 📜 License

This project is licensed under the MIT License.
