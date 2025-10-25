Python script that polls your Emby server and posts new items into a Telegram channel. To actually **install and run** this script on your system, here’s a step‑by‑step guide:

---

## 🐍 1. Install Python
- On **Windows**: download from [python.org/downloads](https://www.python.org/downloads/), check “Add Python to PATH” during install.  
- On **Linux (Ubuntu/Debian)**:
  ```bash
  sudo apt update
  sudo apt install python3 python3-pip -y
  ```
- On **CentOS/RHEL**:
  ```bash
  sudo yum install python3 python3-pip -y
  ```

---

## 📦 2. Install required Python packages
Your script uses the `requests` library. Install it with:
```bash
pip install requests
```

---

## 🔑 3. Secure your configuration
Right now, your script has **hard‑coded secrets** (Telegram bot token, chat ID, Emby API key). That’s risky.  
Instead, store them in environment variables:

### Linux/macOS
```bash
export TELEGRAM_TOKEN="your_token_here"
export TELEGRAM_CHAT_ID="your_chat_id_here"
export EMBY_SERVER="http://your-emby-server:8096"
export EMBY_API_KEY="your_api_key_here"
```

### Windows (PowerShell)
```powershell
setx TELEGRAM_TOKEN "your_token_here"
setx TELEGRAM_CHAT_ID "your_chat_id_here"
setx EMBY_SERVER "http://your-emby-server:8096"
setx EMBY_API_KEY "your_api_key_here"
```

Then in your Python script, replace the hard‑coded values with:

```python
import os

TELEGRAM_TOKEN = os.getenv("TELEGRAM_TOKEN")
TELEGRAM_CHAT_ID = os.getenv("TELEGRAM_CHAT_ID")
EMBY_SERVER = os.getenv("EMBY_SERVER")
EMBY_API_KEY = os.getenv("EMBY_API_KEY")
```

---

## ▶️ 4. Run the script
Navigate to the folder where you saved it (say `emby_to_telegram.py`) and run:

```bash
python emby_to_telegram.py
```

It will:
- Poll your Emby server every 30 minutes (`CHECK_INTERVAL = 1800`)
- Send new items to your Telegram channel
- Track what’s already been notified in `emby_notified.txt`

---

## 🔄 5. Run it continuously
- On **Linux**, use `screen`, `tmux`, or set it up as a `systemd` service.  
- On **Windows**, you can run it in a background PowerShell window or use Task Scheduler.

---

✅ That’s it — you’ve got a working notifier.  


👉 Do you want me to also show you how to make this run as a **systemd service** on Linux (so it starts automatically at boot and keeps running in the background)?


Perfect — let’s turn your Python notifier into a **systemd service** so it runs in the background and starts automatically on boot. Here’s how you can set it up:

---

## 🛠 Step 1: Place your script
Save your Python script as, for example:

```
/opt/emby-to-telegram/emby_to_telegram.py
```

Make sure it’s executable:

```bash
chmod +x /opt/emby-to-telegram/emby_to_telegram.py
```

---

## 🛠 Step 2: Create a virtual environment (recommended)
This keeps dependencies isolated:

```bash
cd /opt/emby-to-telegram
python3 -m venv venv
source venv/bin/activate
pip install requests
deactivate
```

---

## 🛠 Step 3: Create a systemd service file
Create a new unit file:

```bash
sudo nano /etc/systemd/system/emby-to-telegram.service
```

Paste this content:

```ini
[Unit]
Description=Emby to Telegram Notifier
After=network.target

[Service]
Type=simple
ExecStart=/opt/emby-to-telegram/venv/bin/python /opt/emby-to-telegram/emby_to_telegram.py
WorkingDirectory=/opt/emby-to-telegram
Restart=always
RestartSec=10
User=yourusername
Environment="TELEGRAM_TOKEN=your_token_here"
Environment="TELEGRAM_CHAT_ID=your_chat_id_here"
Environment="EMBY_SERVER=http://your-emby-server:8096"
Environment="EMBY_API_KEY=your_api_key_here"

[Install]
WantedBy=multi-user.target
```

> 🔑 Replace `yourusername` with the Linux user that should run the script, and fill in your real environment variables.

---

## 🛠 Step 4: Reload systemd and enable service
```bash
sudo systemctl daemon-reload
sudo systemctl enable emby-to-telegram.service
sudo systemctl start emby-to-telegram.service
```

---

## 🛠 Step 5: Check status and logs
```bash
sudo systemctl status emby-to-telegram.service
```

To see logs:
```bash
journalctl -u emby-to-telegram.service -f
```

---

✅ Now your notifier will:
- Run in the background
- Restart automatically if it crashes
- Start on boot

---

Would you like me to also show you how to **rotate logs** (so your `journalctl` logs don’t grow endlessly), or is the default systemd logging enough for your use case?

