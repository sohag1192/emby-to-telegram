import requests
import time
from datetime import datetime, timedelta

# Configuration - MOVE THESE TO ENVIRONMENT VARIABLES!
TELEGRAM_TOKEN="your_token_here"
TELEGRAM_CHAT_ID="your_chat_id_here"
EMBY_SERVER="http://your-emby-server:8096"
EMBY_API_KEY="your_api_key_here"

# Time between checks (in seconds)
CHECK_INTERVAL = 1800 # 30 Min
MESSAGE_DELAY = 10    # 10 seconds between messages
LAST_CHECKED_FILE = 'emby_last_checked.txt'
NOTIFIED_ITEMS_FILE = 'emby_notified.txt'

def get_last_checked_time():
    try:
        with open(LAST_CHECKED_FILE, 'r') as f:
            return datetime.strptime(f.read().strip(), '%m/%d/%Y %I:%M:%S %p')
    except (FileNotFoundError, ValueError):
        return datetime.now() - timedelta(hours=24)

def save_last_checked_time(time):
    with open(LAST_CHECKED_FILE, 'w') as f:
        f.write(time.strftime('%m/%d/%Y %I:%M:%S %p'))

def get_notified_items():
    try:
        with open(NOTIFIED_ITEMS_FILE, 'r') as f:
            return [line.strip() for line in f]
    except FileNotFoundError:
        return []

def save_notified_items(item_ids):
    with open(NOTIFIED_ITEMS_FILE, 'w') as f:
        for item_id in item_ids:
            f.write(f"{item_id}\n")

def parse_emby_date(date_str):
    formats = [
        '%m/%d/%Y %I:%M:%S %p',  # 05/08/2025 06:48:43 AM
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

    # Get movies
    movies_url = f"{EMBY_SERVER}/emby/Items"
    movies_params = {
        'Recursive': 'true',
        'IncludeItemTypes': 'Movie',
        'SortBy': 'DateCreated',
        'SortOrder': 'Descending',
        'Limit': 20,  # Increase limit to catch items added since last check
        'Fields': 'Overview,PrimaryImageAspectRatio,MediaSources,Path,DateCreated,PremiereDate,ServerId',
        'X-Emby-Token': EMBY_API_KEY
    }

    # Get TV shows (series, not episodes)
    series_url = f"{EMBY_SERVER}/emby/Items"
    series_params = {
        'Recursive': 'true',
        'IncludeItemTypes': 'Series',
        'SortBy': 'DateCreated',
        'SortOrder': 'Descending',
        'Limit': 20,  # Increase limit
        'Fields': 'Overview,PrimaryImageAspectRatio,MediaSources,Path,DateCreated,PremiereDate,ServerId',
        'X-Emby-Token': EMBY_API_KEY
    }

    new_items = []

    try:
        # Get movies
        response = requests.get(movies_url, params=movies_params)
        response.raise_for_status()
        movies = response.json()['Items']

        for movie in movies:
            if 'DateCreated' in movie:
                date_added = parse_emby_date(movie['DateCreated'])
                if date_added > last_checked:
                    new_items.append(movie)

        # Get TV shows
        response = requests.get(series_url, params=series_params)
        response.raise_for_status()
        series = response.json()['Items']

        for show in series:
            if 'DateCreated' in show:
                date_added = parse_emby_date(show['DateCreated'])
                if date_added > last_checked:
                    new_items.append(show)

        # Sort all items by date added
        new_items.sort(key=lambda x: parse_emby_date(x['DateCreated']), reverse=True)

        return new_items
    except Exception as e:
        print(f"Error fetching media: {e}")
        return []

def get_emby_item_url(item):
    """Generate the correct Emby web interface URL"""
    item_id = item['Id']
    server_id = item.get('ServerId', '')
    return f"{EMBY_SERVER}/web/index.html#!/item?id={item_id}&serverId={server_id}"

def send_telegram_message(item, notified_ids):
    item_id = item['Id']
    if item_id in notified_ids:
        print(f"Notification already sent for item ID: {item_id} ({item.get('Name', 'Unknown')})")
        return False

    try:
        item_type = "Movie" if item['Type'] == 'Movie' else "TV Series"
        title = item.get('Name', 'Unknown Title')
        year = item.get('ProductionYear', '')
        overview = item.get('Overview', 'No description available.')
        emby_url = get_emby_item_url(item)

        if year:
            title = f"{title} ({year})"

        message = f"🎬 *New {item_type} Added to SN FTP SERVER*\n\n"
        message += f"*Title:* {title}\n"

        if item['Type'] == 'Series':
            status = item.get('Status', '')
            if status:
                message += f"*Status:* {status}\n"

        message += f"\n{overview}\n\n"
        message += f"[▶️ Play in SN FTP SERVER]({emby_url})"

        # Get image URL
        image_url = None
        if 'ImageTags' in item and 'Primary' in item['ImageTags']:
            image_tag = item['ImageTags']['Primary']
            image_url = f"{EMBY_SERVER}/emby/Items/{item_id}/Images/Primary?maxHeight=500&tag={image_tag}&quality=90"

        # Send to Telegram
        if image_url:
            url = f"https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendPhoto"
            data = {
                'chat_id': TELEGRAM_CHAT_ID,
                'caption': message,
                'parse_mode': 'Markdown',
                'disable_web_page_preview': False
            }
            files = {'photo': requests.get(image_url).content}
            response = requests.post(url, data=data, files=files)
        else:
            url = f"https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendMessage"
            data = {
                'chat_id': TELEGRAM_CHAT_ID,
                'text': message,
                'parse_mode': 'Markdown',
                'disable_web_page_preview': False
            }
            response = requests.post(url, data=data)

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