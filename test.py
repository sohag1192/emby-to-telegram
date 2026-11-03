import os
import requests

# কনফিগারেশন ভ্যালু
TELEGRAM_TOKEN = os.getenv('TELEGRAM_TOKEN', '123456789:AAF2RWn_4MIf3LJ04RZLTOGPXsUh_B1oIE')
TELEGRAM_CHAT_ID = os.getenv('TELEGRAM_CHAT_ID', '10652325429')
EMBY_SERVER = os.getenv('EMBY_SERVER', 'http://192.168.1.100:8096').rstrip('/')
EMBY_API_KEY = os.getenv('EMBY_API_KEY', 'API_Keys')

print("--- [১] টেলিগ্রাম বট ও চ্যাট আইডি টেস্ট ---")
tg_url = f"https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendMessage"
tg_payload = {
    "chat_id": TELEGRAM_CHAT_ID,
    "text": "Hello! Emby to Telegram test message."
}

try:
    tg_resp = requests.post(tg_url, json=tg_payload, timeout=10)
    print(f"Telegram HTTP Status: {tg_resp.status_code}")
    print(f"Telegram Response: {tg_resp.text}")
    
    if tg_resp.status_code == 200:
        print(">> টেলিগ্রাম মেসেজ সফলভাবে গেছে!\n")
    else:
        print(">> টেলিগ্রাম মেসেজ ফেইল্ড! রেসপন্সের 'description' অংশটি দেখুন।\n")
except Exception as e:
    print(f">> টেলিগ্রাম কানেকশন এরর: {e}\n")


print("--- [২] এম্বি (Emby) সার্ভার কানেকশন টেস্ট ---")
emby_url = f"{EMBY_SERVER}/System/Info"
headers = {
    "X-Emby-Token": EMBY_API_KEY
}

try:
    emby_resp = requests.get(emby_url, headers=headers, timeout=10)
    print(f"Emby HTTP Status: {emby_resp.status_code}")
    
    if emby_resp.status_code == 200:
        server_info = emby_resp.json()
        print(f">> Emby সার্ভার কানেক্টেড! সার্ভার নাম: {server_info.get('ServerName', 'Unknown')}\n")
    elif emby_resp.status_code == 401:
        print(">> এরর: Emby API Key ভুল বা ইনভ্যালিড।\n")
    else:
        print(f">> Emby রেসপন্স: {emby_resp.text}\n")
except Exception as e:
    print(f">> Emby কানেকশন ফেইল্ড (IP/Port বা নেটওয়ার্ক চেক করুন): {e}\n")