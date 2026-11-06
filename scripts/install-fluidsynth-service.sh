#!/usr/bin/env bash
# Installs fluidsynth as a per-user launchd agent: starts automatically at
# login, stops automatically at logout/shutdown, and restarts if it
# crashes. Run uninstall-fluidsynth-service.sh to remove it again.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DAEMON_SCRIPT="$SCRIPT_DIR/fluidsynth-daemon.sh"
TEMPLATE="$SCRIPT_DIR/com.frescobaldi.fluidsynth.plist.template"
LABEL="com.frescobaldi.fluidsynth"
PLIST_DEST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG_FILE="$PROJECT_DIR/.fluidsynth.log"
UID_NUM="$(id -u)"

if [[ ! -x "$DAEMON_SCRIPT" ]]; then
  echo "Missing or non-executable: $DAEMON_SCRIPT" >&2
  exit 1
fi

mkdir -p "$HOME/Library/LaunchAgents"

sed \
  -e "s|__SCRIPT_PATH__|$DAEMON_SCRIPT|g" \
  -e "s|__LOG_PATH__|$LOG_FILE|g" \
  "$TEMPLATE" > "$PLIST_DEST"

# bootout is a no-op (and would otherwise fail) if it isn't loaded yet.
launchctl bootout "gui/$UID_NUM/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$UID_NUM" "$PLIST_DEST"
launchctl enable "gui/$UID_NUM/$LABEL"

echo "Installed and started $LABEL"
echo "Plist: $PLIST_DEST"
echo "Logs:  $LOG_FILE"
echo "It will now start automatically at login and stop at logout/shutdown."
