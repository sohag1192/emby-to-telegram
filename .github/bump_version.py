#!/usr/bin/env python3
"""
Version Helper & Bumper for Emby to Telegram Notifier.
Supports version detection, calculating next version, and updating
__version__ in both emby_to_telegram.py and emby_to_telegram_bn.py.
"""

import sys
import re
import subprocess
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
PY_FILES = [
    REPO_ROOT / 'emby_to_telegram.py',
    REPO_ROOT / 'emby_to_telegram_bn.py'
]

def get_latest_tag() -> str:
    """Retrieve the latest v* tag from git or fallback to 3.0."""
    try:
        out = subprocess.check_output(
            ['git', 'tag', '-l', 'v*', '--sort=-v:refname'],
            cwd=str(REPO_ROOT),
            text=True,
            stderr=subprocess.DEVNULL
        ).strip()
        tags = [t.strip() for t in out.splitlines() if t.strip()]
        if tags:
            return tags[0]
    except Exception:
        pass
    
    # Fallback to reading __version__ from emby_to_telegram.py
    main_py = REPO_ROOT / 'emby_to_telegram.py'
    if main_py.exists():
        content = main_py.read_text(encoding='utf-8')
        m = re.search(r"__version__\s*=\s*['\"]([^'\"]+)['\"]", content)
        if m:
            ver = m.group(1).lstrip('v')
            return f"v{ver}"
    return "v3.0"

def suggest_next_tag(current_tag: str) -> str:
    """Calculate the next minor version tag (e.g. v3.0 -> v3.1, v3.1 -> v3.2)."""
    clean = current_tag.lstrip('v').lstrip('V')
    parts = clean.split('.')
    try:
        if len(parts) == 1:
            return f"v{int(parts[0]) + 1}.0"
        elif len(parts) == 2:
            return f"v{parts[0]}.{int(parts[1]) + 1}"
        elif len(parts) >= 3:
            return f"v{parts[0]}.{parts[1]}.{int(parts[2]) + 1}"
    except ValueError:
        pass
    return "v3.1"

def update_version_in_files(new_tag: str):
    """Update __version__ = 'X.Y' in python files."""
    clean_ver = new_tag.lstrip('v').lstrip('V')
    pattern = re.compile(r"(__version__\s*=\s*)['\"][^'\"]+['\"]")
    replacement = rf"\g<1>'{clean_ver}'"

    updated = 0
    for file_path in PY_FILES:
        if file_path.exists():
            original = file_path.read_text(encoding='utf-8')
            new_content = pattern.sub(replacement, original)
            if new_content != original:
                file_path.write_text(new_content, encoding='utf-8')
                print(f"✅ Updated version to {clean_ver} in {file_path.name}")
                updated += 1
            else:
                print(f"ℹ️ {file_path.name} already has version {clean_ver}")
        else:
            print(f"⚠️ File not found: {file_path}")
    return updated

def main():
    if len(sys.argv) > 1:
        arg = sys.argv[1].strip()
        if arg in ('--suggest', '-s', 'suggest'):
            current = get_latest_tag()
            suggested = suggest_next_tag(current)
            print(f"CURRENT={current}")
            print(f"SUGGESTED={suggested}")
            return
        elif arg in ('--current', '-c', 'current'):
            print(get_latest_tag())
            return
        elif arg.startswith('v') or arg[0].isdigit():
            tag = arg if arg.startswith('v') else f"v{arg}"
            print(f"Updating files to release tag: {tag}...")
            update_version_in_files(tag)
            return

    current = get_latest_tag()
    suggested = suggest_next_tag(current)
    print(f"Current version tag:   {current}")
    print(f"Suggested next tag:    {suggested}")

if __name__ == '__main__':
    main()
