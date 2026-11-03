import os
import sys
import html
import json
import requests
import time
from datetime import datetime, timedelta, timezone

# Ensure UTF-8 output on Windows consoles
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')

__version__ = '3.0'

# Configuration - Supports environment variables or default values
TELEGRAM_TOKEN = os.getenv('TELEGRAM_TOKEN', 'ADD YOUR TELEGRAM_TOKEN')
TELEGRAM_CHAT_ID = os.getenv('TELEGRAM_CHAT_ID', 'ADD YOUR TELEGRAM_CHAT_ID')
EMBY_SERVER = os.getenv('EMBY_SERVER', ' ADD YOUR EMBY_SERVER  http://192.168.1.100:8096 OR https://emby.yourdomain.com').rstrip('/')
EMBY_API_KEY = os.getenv('EMBY_API_KEY', 'ADD YOUR EMBY_API_KEY')


# Button text (can be customized via environment variable)
BUTTON_TEXT = os.getenv('BUTTON_TEXT', 'Watch on SN FTP SERVER')

# Time between checks (in seconds)
CHECK_INTERVAL = int(os.getenv('CHECK_INTERVAL', '1800'))  # 30 Min
MESSAGE_DELAY = int(os.getenv('MESSAGE_DELAY', '10'))     # 10 seconds between messages
LAST_CHECKED_FILE = 'emby_last_checked.txt'
NOTIFIED_ITEMS_FILE = 'emby_notified.txt'

def format_runtime_bn(ticks):
    """Convert Emby runtime ticks (1 tick = 100ns) to a Bengali readable duration."""
    if not ticks:
        return None
    minutes = int(ticks / (10000000 * 60))
    hours = minutes // 60
    rem_min = minutes % 60
    if hours > 0:
        return f"{hours} ঘণ্টা {rem_min} মিনিট" if rem_min else f"{hours} ঘণ্টা"
    return f"{minutes} মিনিট"

def format_size(bytes_val):
    """Format file size in bytes to a human-readable string (MB, GB, etc.)."""
    if not bytes_val:
        return None
    val = float(bytes_val)
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if val < 1024:
            return f"{val:.2f} {unit}"
        val /= 1024
    return f"{val:.2f} PB"

def get_last_checked_time():
    """Retrieve last check timestamp in UTC (matching Emby's DateCreated timezone)."""
    try:
        with open(LAST_CHECKED_FILE, 'r') as f:
            content = f.read().strip()
            if content:
                return datetime.strptime(content, '%m/%d/%Y %I:%M:%S %p')
    except (FileNotFoundError, ValueError):
        pass
    # Fallback to 24 hours ago in UTC
    return datetime.now(timezone.utc).replace(tzinfo=None) - timedelta(hours=24)

def save_last_checked_time(check_time):
    with open(LAST_CHECKED_FILE, 'w') as f:
        f.write(check_time.strftime('%m/%d/%Y %I:%M:%S %p'))

def get_notified_items():
    """Read all notified IDs and keys as a set for O(1) instant duplicate detection."""
    try:
        with open(NOTIFIED_ITEMS_FILE, 'r', encoding='utf-8') as f:
            return set(line.strip() for line in f if line.strip())
    except FileNotFoundError:
        return set()

def append_notified_item(item_key):
    """Atomically append a single notified key to file so it is never lost or wiped."""
    with open(NOTIFIED_ITEMS_FILE, 'a', encoding='utf-8') as f:
        f.write(f"{item_key}\n")

def is_already_notified(item, notified_ids):
    """Bulletproof check: Verify by both Emby Item ID and Title+Year key."""
    item_id = str(item.get('Id', '')).strip()
    if item_id and item_id in notified_ids:
        return True

    # Also check normalized title+year key (prevents duplicates if item is re-scanned or re-indexed)
    name = str(item.get('Name', '')).strip().lower()
    year = str(item.get('ProductionYear', '')).strip()
    item_type = str(item.get('Type', '')).strip().lower()
    if name:
        clean_name = "".join(c for c in name if c.isalnum() or c.isspace()).replace(" ", "_")
        title_key = f"title:{item_type}_{clean_name}_{year}"
        if title_key in notified_ids:
            return True

    return False

def mark_as_notified(item, notified_ids):
    """Record both Emby ID and Title+Year key to permanently block duplicate alerts."""
    item_id = str(item.get('Id', '')).strip()
    if item_id and item_id not in notified_ids:
        notified_ids.add(item_id)
        append_notified_item(item_id)

    name = str(item.get('Name', '')).strip().lower()
    year = str(item.get('ProductionYear', '')).strip()
    item_type = str(item.get('Type', '')).strip().lower()
    if name:
        clean_name = "".join(c for c in name if c.isalnum() or c.isspace()).replace(" ", "_")
        title_key = f"title:{item_type}_{clean_name}_{year}"
        if title_key not in notified_ids:
            notified_ids.add(title_key)
            append_notified_item(title_key)

def parse_emby_date(date_str):
    """
    Parse Emby ISO 8601 date strings robustly.
    Handles 7-digit fractional seconds (e.g. 2026-11-02T13:11:22.0000000Z).
    Returns datetime.min on error (NEVER datetime.now) so errors cannot cause duplicate alerts.
    """
    if not date_str:
        return datetime.min

    clean_str = date_str.rstrip('Z')
    if '.' in clean_str:
        base, frac = clean_str.split('.', 1)
        clean_str = f"{base}.{frac[:6]}"

    try:
        return datetime.fromisoformat(clean_str)
    except Exception:
        pass

    formats = [
        '%m/%d/%Y %I:%M:%S %p',
        '%Y-%m-%d %H:%M:%S',
        '%Y-%m-%dT%H:%M:%S'
    ]
    for fmt in formats:
        try:
            return datetime.strptime(clean_str, fmt)
        except ValueError:
            continue

    return datetime.min

def get_recently_added_media():
    """Retrieve new movies and series that have not yet been notified."""
    notified_ids = get_notified_items()
    fields = 'Genres,CommunityRating,CriticRating,OfficialRating,RunTimeTicks,MediaSources,Path,DateCreated,PremiereDate,ServerId,ProductionYear,Status'

    # Get movies
    movies_url = f"{EMBY_SERVER}/emby/Items"
    movies_params = {
        'Recursive': 'true',
        'IncludeItemTypes': 'Movie',
        'SortBy': 'DateCreated',
        'SortOrder': 'Descending',
        'Limit': 20,
        'Fields': fields,
        'X-Emby-Token': EMBY_API_KEY
    }

    # Get TV shows (series level, not individual episodes)
    series_url = f"{EMBY_SERVER}/emby/Items"
    series_params = {
        'Recursive': 'true',
        'IncludeItemTypes': 'Series',
        'SortBy': 'DateCreated',
        'SortOrder': 'Descending',
        'Limit': 20,
        'Fields': fields,
        'X-Emby-Token': EMBY_API_KEY
    }

    new_items = []

    try:
        # Fetch movies
        response = requests.get(movies_url, params=movies_params, timeout=30)
        response.raise_for_status()
        movies = response.json().get('Items', [])

        for movie in movies:
            if not is_already_notified(movie, notified_ids):
                new_items.append(movie)

        # Fetch TV shows
        response = requests.get(series_url, params=series_params, timeout=30)
        response.raise_for_status()
        series = response.json().get('Items', [])

        for show in series:
            if not is_already_notified(show, notified_ids):
                new_items.append(show)

        # Deduplicate items by ID within the current batch
        seen_batch = set()
        unique_items = []
        for item in new_items:
            iid = str(item.get('Id', '')).strip()
            if iid and iid not in seen_batch:
                seen_batch.add(iid)
                unique_items.append(item)

        # Sort all items by date added descending (newest first)
        unique_items.sort(key=lambda x: parse_emby_date(x.get('DateCreated', '')), reverse=True)
        return unique_items

    except Exception as e:
        print(f"Emby সার্ভার থেকে মিডিয়া ফেচ করতে সমস্যা হয়েছে: {e}")
        return []

def get_emby_item_url(item):
    """Generate the direct Emby web interface playback/detail URL."""
    item_id = item['Id']
    server_id = item.get('ServerId', '')
    return f"{EMBY_SERVER}/web/index.html#!/item?id={item_id}&serverId={server_id}"

def build_message_bn(item):
    """Create a beautifully formatted Bengali HTML message with media details."""
    item_type = "মুভি" if item.get('Type') == 'Movie' else "টিভি সিরিজ"
    raw_title = item.get('Name', 'অজানা শিরোনাম')
    title = html.escape(raw_title)
    year = item.get('ProductionYear', '')
    title_line = f"{title} ({year})" if year else title

    lines = [
        f"🎬 <b>SN FTP সার্ভারে নতুন {item_type} যুক্ত হয়েছে</b>\n",
        f"📌 <b>শিরোনাম:</b> {title_line}"
    ]

    # Community and Critic Ratings
    ratings = []
    if item.get('CommunityRating'):
        ratings.append(f"⭐ {item['CommunityRating']:.1f}/10")
    if item.get('CriticRating'):
        ratings.append(f"🍅 {item['CriticRating']}%")
    if ratings:
        lines.append(f"<b>রেটিং:</b> {' | '.join(ratings)}")

    # Genres
    genres = item.get('Genres')
    if genres:
        lines.append(f"🎭 <b>ধরন:</b> {html.escape(', '.join(genres))}")

    # Runtime in Bengali
    runtime = format_runtime_bn(item.get('RunTimeTicks'))
    if runtime:
        lines.append(f"⏱️ <b>সময়সীমা:</b> {runtime}")

    # Official / Age Content Rating
    if item.get('OfficialRating'):
        lines.append(f"🔞 <b>বয়সসীমা:</b> {html.escape(str(item['OfficialRating']))}")

    # Series Status (Continuing / Ended)
    if item.get('Type') == 'Series' and item.get('Status'):
        status_val = str(item['Status'])
        if status_val.lower() == 'continuing':
            status_bn = "চলমান (Continuing)"
        elif status_val.lower() == 'ended':
            status_bn = "সমাপ্ত (Ended)"
        else:
            status_bn = status_val
        lines.append(f"📺 <b>স্ট্যাটাস:</b> {html.escape(status_bn)}")

    # Quality and File Size
    media_info = []
    if item.get('MediaSources'):
        ms = item['MediaSources'][0]
        v_streams = [s for s in ms.get('MediaStreams', []) if s.get('Type') == 'Video']
        if v_streams:
            disp = v_streams[0].get('DisplayTitle')
            h = v_streams[0].get('Height')
            if disp:
                media_info.append(disp)
            elif h:
                media_info.append(f"{h}p")
        sz = format_size(ms.get('Size'))
        if sz:
            media_info.append(sz)
    if media_info:
        lines.append(f"🎞️ <b>কোয়ালিটি:</b> {html.escape(' | '.join(media_info))}")

    return "\n".join(lines)

def build_keyboard(item, emby_url):
    """Generate interactive Telegram Inline Keyboard button with styling & colors."""
    return {
        "inline_keyboard": [
            [
                {
                    "text": BUTTON_TEXT,
                    "url": emby_url,
                    "style": "success"
                }
            ]
        ]
    }

def send_telegram_message(item, notified_ids):
    item_id = str(item.get('Id', '')).strip()
    if is_already_notified(item, notified_ids):
        print(f"ইতিমধ্যে নোটিফিকেশন পাঠানো হয়েছে: {item.get('Name', 'Unknown')} (ID: {item_id})")
        return False

    try:
        title = item.get('Name', 'অজানা শিরোনাম')
        emby_url = get_emby_item_url(item)
        message = build_message_bn(item)
        reply_markup = build_keyboard(item, emby_url)

        # Get poster image URL
        image_url = None
        if 'ImageTags' in item and 'Primary' in item['ImageTags']:
            image_tag = item['ImageTags']['Primary']
            image_url = f"{EMBY_SERVER}/emby/Items/{item_id}/Images/Primary?maxHeight=600&tag={image_tag}&quality=90"

        # Try downloading poster image safely
        photo_bytes = None
        if image_url:
            try:
                img_res = requests.get(image_url, timeout=15)
                if img_res.status_code == 200:
                    photo_bytes = img_res.content
            except Exception as img_err:
                print(f"পোস্টার ডাউনলোড করা যায়নি ({title}): {img_err}")

        # Try sending Photo with Caption and Inline Button
        sent = False
        if photo_bytes:
            try:
                url = f"https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendPhoto"
                data = {
                    'chat_id': TELEGRAM_CHAT_ID,
                    'caption': message,
                    'parse_mode': 'HTML',
                    'reply_markup': json.dumps(reply_markup)
                }
                files = {'photo': photo_bytes}
                response = requests.post(url, data=data, files=files, timeout=30)
                response.raise_for_status()
                sent = True
            except Exception as photo_err:
                print(f"পোস্টারসহ ফটো পাঠানো যায়নি ({photo_err})। টেক্সট মেসেজ পাঠানো হচ্ছে...")

        # Fallback to Text message if photo was not sent
        if not sent:
            url = f"https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendMessage"
            data = {
                'chat_id': TELEGRAM_CHAT_ID,
                'text': message,
                'parse_mode': 'HTML',
                'reply_markup': json.dumps(reply_markup),
                'disable_web_page_preview': False
            }
            response = requests.post(url, data=data, timeout=30)
            response.raise_for_status()

        print(f"নোটিফিকেশন সফলভাবে পাঠানো হয়েছে: {title} (ID: {item_id})")
        return True

    except Exception as e:
        print(f"টেলিগ্রাম মেসেজ পাঠাতে ত্রুটি হয়েছে (ID {item_id}): {e}")
        return False

def main():
    print(f"Emby to Telegram (বাংলা সংস্করণ v{__version__}) নোটিফায়ার শুরু হচ্ছে...")
    while True:
        try:
            print("নতুন কন্টেন্টের জন্য চেক করা হচ্ছে...")

            new_items = get_recently_added_media()
            notified_ids = get_notified_items()

            if new_items:
                print(f"{len(new_items)} টি নতুন আইটেম পাওয়া গেছে")

                for item in new_items:
                    if not is_already_notified(item, notified_ids):
                        success = send_telegram_message(item, notified_ids)
                        if success:
                            mark_as_notified(item, notified_ids)
                        if success and item != new_items[-1]:
                            print(f"পরবর্তী নোটিফিকেশনের জন্য {MESSAGE_DELAY} সেকেন্ড অপেক্ষা করা হচ্ছে...")
                            time.sleep(MESSAGE_DELAY)
                    else:
                        print(f"ইতিমধ্যে নোটিফাইড: {item.get('Name')} (ID: {item.get('Id')})")

            # Save check time in UTC
            save_last_checked_time(datetime.now(timezone.utc).replace(tzinfo=None))
            print(f"চেক সম্পন্ন হয়েছে। পরবর্তী চেকের জন্য {CHECK_INTERVAL} সেকেন্ড অপেক্ষা করা হচ্ছে...")
            time.sleep(CHECK_INTERVAL)

        except Exception as e:
            print(f"প্রধান লুপে ত্রুটি: {e}")
            time.sleep(60)

if __name__ == "__main__":
    main()
