import os
import sys
import html
import json
import requests
import time
from datetime import datetime, timedelta

# Ensure UTF-8 output on Windows consoles
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')

def load_env_file(filepath='.env'):
    """Load environment variables from a local .env file if it exists."""
    if os.path.exists(filepath):
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith('#') and '=' in line:
                        key, val = line.split('=', 1)
                        key = key.strip()
                        val = val.strip().strip('"').strip("'")
                        if key and key not in os.environ:
                            os.environ[key] = val
        except Exception as e:
            print(f"Warning: Could not read .env file: {e}")

# Load local .env file
load_env_file()

# Configuration - Supports environment variables or default values
TELEGRAM_TOKEN = os.getenv('TELEGRAM_TOKEN', 'your_bot_token_here')
TELEGRAM_CHAT_ID = os.getenv('TELEGRAM_CHAT_ID', 'your_chat_id_here')
EMBY_SERVER = os.getenv('EMBY_SERVER', 'http://your-emby-server:8096').rstrip('/')
EMBY_API_KEY = os.getenv('EMBY_API_KEY', 'your_emby_api_key_here')

# Time between checks (in seconds)
CHECK_INTERVAL = int(os.getenv('CHECK_INTERVAL', '1800'))  # 30 Min
MESSAGE_DELAY = int(os.getenv('MESSAGE_DELAY', '10'))     # 10 seconds between messages
LAST_CHECKED_FILE = 'emby_last_checked.txt'
NOTIFIED_ITEMS_FILE = 'emby_notified.txt'

def format_runtime(ticks):
    """Convert Emby runtime ticks (1 tick = 100ns) to a human-readable duration."""
    if not ticks:
        return None
    minutes = int(ticks / (10000000 * 60))
    hours = minutes // 60
    rem_min = minutes % 60
    if hours > 0:
        return f"{hours}h {rem_min}m" if rem_min else f"{hours}h"
    return f"{minutes}m"

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
    try:
        with open(LAST_CHECKED_FILE, 'r') as f:
            return datetime.strptime(f.read().strip(), '%m/%d/%Y %I:%M:%S %p')
    except (FileNotFoundError, ValueError):
        return datetime.now() - timedelta(hours=24)

def save_last_checked_time(check_time):
    with open(LAST_CHECKED_FILE, 'w') as f:
        f.write(check_time.strftime('%m/%d/%Y %I:%M:%S %p'))

def get_notified_items():
    try:
        with open(NOTIFIED_ITEMS_FILE, 'r') as f:
            return [line.strip() for line in f if line.strip()]
    except FileNotFoundError:
        return []

def save_notified_items(item_ids):
    with open(NOTIFIED_ITEMS_FILE, 'w') as f:
        for item_id in item_ids:
            f.write(f"{item_id}\n")

def parse_emby_date(date_str):
    formats = [
        '%m/%d/%Y %I:%M:%S %p',    # 05/08/2025 06:48:43 AM
        '%Y-%m-%dT%H:%M:%S.%fZ',  # ISO format with milliseconds
        '%Y-%m-%dT%H:%M:%SZ',      # ISO format without milliseconds
        '%Y-%m-%d %H:%M:%S'        # Alternative format
    ]
    for fmt in formats:
        try:
            return datetime.strptime(date_str, fmt)
        except ValueError:
            continue
    return datetime.now()

def get_recently_added_media():
    last_checked = get_last_checked_time()
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
        # Get movies
        response = requests.get(movies_url, params=movies_params, timeout=30)
        response.raise_for_status()
        movies = response.json().get('Items', [])

        for movie in movies:
            if 'DateCreated' in movie:
                date_added = parse_emby_date(movie['DateCreated'])
                if date_added > last_checked:
                    new_items.append(movie)

        # Get TV shows
        response = requests.get(series_url, params=series_params, timeout=30)
        response.raise_for_status()
        series = response.json().get('Items', [])

        for show in series:
            if 'DateCreated' in show:
                date_added = parse_emby_date(show['DateCreated'])
                if date_added > last_checked:
                    new_items.append(show)

        # Sort all items by date added descending
        new_items.sort(key=lambda x: parse_emby_date(x['DateCreated']), reverse=True)
        return new_items

    except Exception as e:
        print(f"Error fetching media from Emby: {e}")
        return []

def get_emby_item_url(item):
    """Generate the direct Emby web interface playback/detail URL."""
    item_id = item['Id']
    server_id = item.get('ServerId', '')
    return f"{EMBY_SERVER}/web/index.html#!/item?id={item_id}&serverId={server_id}"

def build_message(item):
    """Create a beautifully formatted, compact HTML message with media details."""
    item_type = "Movie" if item.get('Type') == 'Movie' else "TV Series"
    raw_title = item.get('Name', 'Unknown Title')
    title = html.escape(raw_title)
    year = item.get('ProductionYear', '')
    title_line = f"{title} ({year})" if year else title

    lines = [
        f"🎬 <b>New {item_type} Added to SN FTP SERVER</b>\n",
        f"📌 <b>Title:</b> {title_line}"
    ]

    # Community and Critic Ratings
    ratings = []
    if item.get('CommunityRating'):
        ratings.append(f"⭐ {item['CommunityRating']:.1f}/10")
    if item.get('CriticRating'):
        ratings.append(f"🍅 {item['CriticRating']}%")
    if ratings:
        lines.append(f"<b>Rating:</b> {' | '.join(ratings)}")

    # Genres
    genres = item.get('Genres')
    if genres:
        lines.append(f"🎭 <b>Genres:</b> {html.escape(', '.join(genres))}")

    # Runtime
    runtime = format_runtime(item.get('RunTimeTicks'))
    if runtime:
        lines.append(f"⏱️ <b>Runtime:</b> {runtime}")

    # Official / Age Content Rating
    if item.get('OfficialRating'):
        lines.append(f"🔞 <b>Rated:</b> {html.escape(str(item['OfficialRating']))}")

    # Series Status (Continuing / Ended)
    if item.get('Type') == 'Series' and item.get('Status'):
        lines.append(f"📺 <b>Status:</b> {html.escape(str(item['Status']))}")

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
        lines.append(f"🎞️ <b>Quality:</b> {html.escape(' | '.join(media_info))}")

    return "\n".join(lines)

def build_keyboard(item, emby_url):
    """Generate interactive Telegram Inline Keyboard button with styling & colors."""
    return {
        "inline_keyboard": [
            [
                {
                    "text": "Watch on SN FTP SERVER",
                    "url": emby_url,
                    "style": "success"
                }
            ]
        ]
    }

def send_telegram_message(item, notified_ids):
    item_id = item['Id']
    if item_id in notified_ids:
        print(f"Notification already sent for item ID: {item_id} ({item.get('Name', 'Unknown')})")
        return False

    try:
        title = item.get('Name', 'Unknown Title')
        emby_url = get_emby_item_url(item)
        message = build_message(item)
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
                print(f"Warning: Failed to download poster for {title}: {img_err}")

        # Send Photo with Caption and Inline Button
        if photo_bytes:
            url = f"https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendPhoto"
            data = {
                'chat_id': TELEGRAM_CHAT_ID,
                'caption': message,
                'parse_mode': 'HTML',
                'reply_markup': json.dumps(reply_markup)
            }
            files = {'photo': photo_bytes}
            response = requests.post(url, data=data, files=files, timeout=30)
        else:
            # Fallback to Text message with Inline Button
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
        print(f"Sent notification for {title} (ID: {item_id})")
        return True

    except Exception as e:
        print(f"Error sending Telegram message for item ID {item_id}: {e}")
        return False

def main():
    print("Starting Emby to Telegram notifier...")
    while True:
        try:
            print("Checking for new content...")

            new_items = get_recently_added_media()
            notified_ids = get_notified_items()
            newly_notified_ids = list(notified_ids)

            if new_items:
                print(f"Found {len(new_items)} potentially new items")

                for item in new_items:
                    if item['Id'] not in notified_ids:
                        success = send_telegram_message(item, notified_ids)
                        if success:
                            newly_notified_ids.append(item['Id'])
                            notified_ids.append(item['Id'])
                            save_notified_items(newly_notified_ids)
                        if success and item != new_items[-1]:
                            print(f"Waiting {MESSAGE_DELAY} seconds before next message...")
                            time.sleep(MESSAGE_DELAY)

            save_last_checked_time(datetime.now())
            print(f"Check complete. Waiting {CHECK_INTERVAL} seconds until next check...")
            time.sleep(CHECK_INTERVAL)

        except Exception as e:
            print(f"Error in main loop: {e}")
            time.sleep(60)

if __name__ == "__main__":
    main()
