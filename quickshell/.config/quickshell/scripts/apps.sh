#!/bin/sh
# Enumerate installed applications as one JSON array.
#
# This exists because Quickshell's DesktopEntries API returns nothing on this
# system — not "no match", but an empty database, with XDG_DATA_DIRS
# correctly set and /usr/share/applications full of .desktop files. Whatever
# the cause, the launcher cannot use it, so the desktop entry spec gets
# parsed here instead.
#
# Runs once when the shell starts. The results are cached in QML, so this is
# not on the path of opening the launcher.

python3 - <<'PYTHON'
import json
import os
import re

# Search path per the desktop entry spec: XDG_DATA_HOME first so a user
# override shadows the system copy of the same id.
home = os.environ.get("XDG_DATA_HOME") or os.path.expanduser("~/.local/share")
dirs = [home] + (os.environ.get("XDG_DATA_DIRS") or "/usr/local/share:/usr/share").split(":")

apps = {}

for base in dirs:
    appdir = os.path.join(base.strip(), "applications")
    if not os.path.isdir(appdir):
        continue

    for root, _, files in os.walk(appdir):
        for name in files:
            if not name.endswith(".desktop"):
                continue

            # The id is the path below applications/ with slashes as dashes.
            entry_id = os.path.relpath(os.path.join(root, name), appdir).replace("/", "-")
            if entry_id in apps:
                continue  # earlier directory wins

            try:
                with open(os.path.join(root, name), encoding="utf-8", errors="replace") as fh:
                    text = fh.read()
            except OSError:
                continue

            # Only the [Desktop Entry] group. Actions like [Desktop Action
            # new-window] carry their own Name and Exec and would otherwise
            # be picked up as if they were separate applications.
            head = text.split("[Desktop Entry]", 1)
            if len(head) < 2:
                continue
            body = re.split(r"\n\[", head[1], maxsplit=1)[0]

            def field(key):
                m = re.search(r"^%s\s*=\s*(.+)$" % key, body, re.M)
                return m.group(1).strip() if m else ""

            if field("Type") not in ("", "Application"):
                continue
            # NoDisplay marks entries that exist to own a MIME association or
            # a protocol handler and are not meant to be launched directly.
            if field("NoDisplay").lower() == "true":
                continue
            if field("Hidden").lower() == "true":
                continue

            name_str = field("Name")
            exec_str = field("Exec")
            if not name_str or not exec_str:
                continue

            # Strip the field codes (%u %f %U %F %i %c %k). Passing them
            # through would hand a literal "%u" to the program as an
            # argument.
            exec_str = re.sub(r"%[a-zA-Z]", "", exec_str).strip()

            apps[entry_id] = {
                "id": entry_id,
                "name": name_str,
                "comment": field("Comment"),
                "exec": exec_str,
                "icon": field("Icon"),
                "terminal": field("Terminal").lower() == "true",
            }

print(json.dumps(sorted(apps.values(), key=lambda a: a["name"].lower())))
PYTHON
