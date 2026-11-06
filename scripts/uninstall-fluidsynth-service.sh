#!/usr/bin/env bash
# Stops and removes the fluidsynth launchd agent installed by
# install-fluidsynth-service.sh.
set -euo pipefail

LABEL="com.frescobaldi.fluidsynth"
PLIST_DEST="$HOME/Library/LaunchAgents/$LABEL.plist"
UID_NUM="$(id -u)"

launchctl bootout "gui/$UID_NUM/$LABEL" 2>/dev/null || true
rm -f "$PLIST_DEST"

echo "Uninstalled $LABEL"
