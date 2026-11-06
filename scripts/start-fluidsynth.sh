#!/usr/bin/env bash
# Starts fluidsynth in the background with a virtual CoreMIDI port so
# Frescobaldi can send it MIDI for playback on macOS.
# https://github.com/frescobaldi/frescobaldi/wiki/MIDI-playback-on-Mac-OS-X
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SOUNDFONT="$PROJECT_DIR/assets/Sonatina_Symphonic_Orchestra.sf2"
PID_FILE="$PROJECT_DIR/.fluidsynth.pid"
LOG_FILE="$PROJECT_DIR/.fluidsynth.log"
FIFO="$PROJECT_DIR/.fluidsynth.fifo"

if [[ ! -f "$SOUNDFONT" ]]; then
  echo "Soundfont not found: $SOUNDFONT" >&2
  exit 1
fi

if [[ -f "$PID_FILE" ]] && kill -0 "$(head -n1 "$PID_FILE")" 2>/dev/null; then
  echo "fluidsynth is already running (pid $(head -n1 "$PID_FILE"))"
  exit 0
fi

# fluidsynth's interactive shell reads commands from stdin and quits as
# soon as it hits EOF, so piping from /dev/null (or passing -i/--no-shell,
# which drops the command loop entirely) makes it exit within seconds in
# the background. A FIFO held open by a never-ending `tail -f /dev/null`
# never delivers EOF, which is what keeps fluidsynth's shell loop blocked
# and the process alive.
rm -f "$FIFO"
mkfifo "$FIFO"

tail -f /dev/null > "$FIFO" &
TAIL_PID=$!
disown

fluidsynth \
  -o midi.driver=coremidi \
  -o audio.driver=coreaudio \
  -o audio.coreaudio.device=default \
  -o audio.period-size=256 \
  "$SOUNDFONT" \
  < "$FIFO" > "$LOG_FILE" 2>&1 &
FLUIDSYNTH_PID=$!
disown

sleep 1

if ! kill -0 "$FLUIDSYNTH_PID" 2>/dev/null; then
  kill "$TAIL_PID" 2>/dev/null || true
  echo "fluidsynth failed to start, see $LOG_FILE" >&2
  cat "$LOG_FILE" >&2
  exit 1
fi

printf '%s\n%s\n' "$FLUIDSYNTH_PID" "$TAIL_PID" > "$PID_FILE"
echo "fluidsynth started (pid $FLUIDSYNTH_PID), logging to $LOG_FILE"
echo "In Frescobaldi: Edit > Preferences > MIDI settings, select the 'FluidSynth virtual port' output."
