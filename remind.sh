#!/bin/bash
# French Drills daily reminder — fires at 8 PM via cron
# Checks if today's date appears in PROGRESS.json sessions
# If no session today, sends a desktop notification

PROGRESS="$HOME/Projects/french-drills-v3/PROGRESS.json"
TODAY=$(date +%Y-%m-%d)

export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

if [ ! -f "$PROGRESS" ]; then
  notify-send -u normal -i applications-education "French Drills" "No progress file found. Open syedalimoiz.com/french-drills-v3/ to start."
  exit 0
fi

if grep -q "\"date\":\"$TODAY\"" "$PROGRESS" 2>/dev/null; then
  exit 0
fi

notify-send -u normal -i applications-education "French Drills" "You haven't practiced today. 5 minutes keeps the streak alive. syedalimoiz.com/french-drills-v3/"
