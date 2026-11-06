#!/usr/bin/env bash
# Stops the background fluidsynth (and its keep-alive tail) started by
# start-fluidsynth.sh.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PID_FILE="$PROJECT_DIR/.fluidsynth.pid"
FIFO="$PROJECT_DIR/.fluidsynth.fifo"

if [[ ! -f "$PID_FILE" ]] || ! kill -0 "$(head -n1 "$PID_FILE")" 2>/dev/null; then
  echo "fluidsynth is not running"
  rm -f "$PID_FILE" "$FIFO"
  exit 0
fi

while read -r pid; do
  kill "$pid" 2>/dev/null || true
done < "$PID_FILE"

rm -f "$PID_FILE" "$FIFO"
echo "fluidsynth stopped"
