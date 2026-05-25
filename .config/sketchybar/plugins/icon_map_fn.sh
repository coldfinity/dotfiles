#!/bin/bash
function icon_map() {
  case "$1" in
  # Terminals
  "WezTerm"|"Terminal"|"iTerm2"|"kitty"|"Alacritty"|"Hyper"|"Warp")
    icon_result=" "
    ;;
  # Browsers
  "Google Chrome"|"Chromium"|"Google Chrome Canary")
    icon_result=" "
    ;;
  "Firefox"|"Firefox Developer Edition"|"Firefox Nightly"|"LibreWolf"|"Tor Browser")
    icon_result=" "
    ;;
  "Safari"|"Safari Technology Preview")
    icon_result="󰀹 "
    ;;
  "Brave Browser")
    icon_result="󰖟 "
    ;;
  "Arc")
    icon_result="󰇮 "
    ;;
  "Microsoft Edge")
    icon_result="󰇩 "
    ;;
  "Vivaldi")
    icon_result="󰣺 "
    ;;
  "Orion"|"Orion RC")
    icon_result="󰀥 "
    ;;
  "Min"|"qutebrowser")
    icon_result="󰖟 "
    ;;
  # Code Editors / IDEs
  "Code"|"Code - Insiders"|"VSCodium")
    icon_result="󰨞 "
    ;;
  "Neovide"|"MacVim"|"Vim"|"VimR"|"Kakoune"|"Emacs")
    icon_result=" "
    ;;
  "Sublime Text")
    icon_result="󰒓 "
    ;;
  "Atom")
    icon_result="󰉋 "
    ;;
  "IntelliJ IDEA")
    icon_result="󰅴 "
    ;;
  "PyCharm")
    icon_result="󰌠 "
    ;;
  "WebStorm")
    icon_result="󰅳 "
    ;;
  "Rider"|"JetBrains Rider")
    icon_result="󰒓 "
    ;;
  "Xcode")
    icon_result="󰈙 "
    ;;
  "Zed")
    icon_result="󰢽 "
    ;;
  "Android Studio")
    icon_result="󰀴 "
    ;;
  # Communication
  "Discord"|"Discord Canary"|"Discord PTB")
    icon_result="󰙯 "
    ;;
  "Slack")
    icon_result="󰒱 "
    ;;
  "Telegram")
    icon_result=" "
    ;;
  "Signal")
    icon_result="󰭻 "
    ;;
  "WhatsApp")
    icon_result=" "
    ;;
  "Skype")
    icon_result="󰒿 "
    ;;
  "Microsoft Teams")
    icon_result="󰊻 "
    ;;
  "Messages"|"Nachrichten")
    icon_result="󰍡 "
    ;;
  "Mattermost")
    icon_result="󰓅 "
    ;;
  "Zulip")
    icon_result="󰓈 "
    ;;
  "Element")
    icon_result="󰇦 "
    ;;
  "TeamSpeak 3")
    icon_result="󰓥 "
    ;;
  "Caprine")
    icon_result="󰓣 "
    ;;
  # Music / Media
  "Spotify")
    icon_result="󰓇 "
    ;;
  "Music"|"TIDAL")
    icon_result="󰎈 "
    ;;
  "VLC")
    icon_result="󰕼 "
    ;;
  "mpv")
    icon_result="󰏃 "
    ;;
  "Podcasts")
    icon_result="󰦜 "
    ;;
  "Audacity")
    icon_result="󰐢 "
    ;;
  # Productivity
  "Finder")
    icon_result="󰀶 "
    ;;
  "Mail"|"Airmail"|"Canary Mail"|"HEY"|"Mailspring"|"MailMate"|"Spark Desktop"|"Thunderbird")
    icon_result="󰊁 "
    ;;
  "Calendar"|"Fantastical"|"Cron"|"Amie")
    icon_result="󰃭 "
    ;;
  "Notes")
    icon_result="󰎚 "
    ;;
  "Reminders")
    icon_result="󰁃 "
    ;;
  "Notion")
    icon_result="󰰅 "
    ;;
  "Todoist")
    icon_result=" "
    ;;
  "Things")
    icon_result="󱣽 "
    ;;
  "Trello")
    icon_result="󰚌 "
    ;;
  "TickTick")
    icon_result=" "
    ;;
  "Obsidian")
    icon_result="󱓟 "
    ;;
  "Joplin")
    icon_result="󰳃 "
    ;;
  "Logseq")
    icon_result="󰸍 "
    ;;
  "Bear")
    icon_result="󱞐 "
    ;;
  "Evernote Legacy")
    icon_result="󰅫 "
    ;;
  "Typora")
    icon_result="󰺾 "
    ;;
  "Drafts")
    icon_result="󰙴 "
    ;;
  # File Management
  "Preview"|"Skim"|"zathura")
    icon_result=" "
    ;;
  "Dropbox")
    icon_result="󰇣 "
    ;;
  "Transmit")
    icon_result="󰉴 "
    ;;
  # Design / Creative
  "Figma")
    icon_result="󰘧 "
    ;;
  "Sketch")
    icon_result="󰎼 "
    ;;
  "Blender")
    icon_result="󰂜 "
    ;;
  "Affinity Photo")
    icon_result="󰝣 "
    ;;
  "Affinity Designer")
    icon_result="󰛶 "
    ;;
  "Affinity Publisher")
    icon_result="󰛶 "
    ;;
  "Final Cut Pro")
    icon_result="󰗂 "
    ;;
  "Keynote")
    icon_result="󰢏 "
    ;;
  "Pages")
    icon_result="󰢐 "
    ;;
  "Numbers")
    icon_result="󰢑 "
    ;;
  "OBS")
    icon_result="󰑋 "
    ;;
  # Dev Tools
  "GitHub Desktop")
    icon_result="󰊤 "
    ;;
  "Docker"|"Docker Desktop")
    icon_result="󰡨 "
    ;;
  "Insomnia")
    icon_result="󰦻 "
    ;;
  "Postman"|"Cypress")
    icon_result="󰘨 "
    ;;
  "Godot")
    icon_result="󰫃 "
    ;;
  "Replit")
    icon_result="󰘫 "
    ;;
  # Utilities
  "System Settings"|"System Preferences")
    icon_result=" "
    ;;
  "Alfred"|"Spotlight"|"Raycast")
    icon_result="󰇧 "
    ;;
  "1Password"|"Bitwarden"|"KeePassXC")
    icon_result=" "
    ;;
  "App Store")
    icon_result="󰂚 "
    ;;
  "Color Picker")
    icon_result="󰃉 "
    ;;
  "Setapp")
    icon_result="󰸁 "
    ;;
  "CleanMyMac X")
    icon_result="󰔒 "
    ;;
  "Keyboard Maestro")
    icon_result="󰌌 "
    ;;
  "Grammarly Editor")
    icon_result="󰰴 "
    ;;
  "OmniFocus")
    icon_result="󰰮 "
    ;;
  # Other
  "zoom.us")
    icon_result="󰑉 "
    ;;
  "Notability")
    icon_result="󰩷 "
    ;;
  "DEVONthink 3")
    icon_result="󰻃 "
    ;;
  "Zotero")
    icon_result="󰑛 "
    ;;
  "Calibre")
    icon_result="󰂿 "
    ;;
  "MAMP"|"MAMP PRO")
    icon_result="󰊕 "
    ;;
  "Parallels Desktop")
    icon_result="󰨙 "
    ;;
  "VMware Fusion")
    icon_result="󰻅 "
    ;;
  "Pi-hole Remote")
    icon_result="󰎃 "
    ;;
  "League of Legends")
    icon_result="󰥭 "
    ;;
  "Linear")
    icon_result="󰆬 "
    ;;
  "ClickUp")
    icon_result="󰳺 "
    ;;
  "Spark Desktop")
    icon_result="󰒯 "
    ;;
  *)
    icon_result=" "
    ;;
  esac
}
icon_map "$1"
echo "$icon_result"
