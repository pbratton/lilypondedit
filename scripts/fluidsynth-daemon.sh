#!/usr/bin/env bash
# Runs fluidsynth in the foreground, meant to be launched by launchd (see
# com.frescobaldi.fluidsynth.plist) rather than run directly.
#
# fluidsynth's interactive shell reads commands from stdin and quits the
# instant it hits EOF. launchd gives jobs a /dev/null stdin by default,
# which would make fluidsynth exit right after starting. A FIFO held open
# by a never-ending `tail -f /dev/null` never delivers EOF, which keeps
# fluidsynth's shell loop blocked and the process alive. On SIGTERM
# (launchd stopping the job), the trap below cleans up both processes.
set -euo pipefail

# launchd runs jobs with a minimal PATH (/usr/bin:/bin:/usr/sbin:/sbin)
# that doesn't include Homebrew, so fluidsynth must be locatable without
# relying on the login shell's PATH.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOUNDFONT="$PROJECT_DIR/assets/Sonatina_Symphonic_Orchestra.sf2"
FIFO="$PROJECT_DIR/.fluidsynth.fifo"
FLUIDSYNTH_BIN="$(command -v fluidsynth)"

TAIL_PID=""
FS_PID=""

cleanup() {
  [[ -n "$FS_PID" ]] && kill "$FS_PID" 2>/dev/null || true
  [[ -n "$TAIL_PID" ]] && kill "$TAIL_PID" 2>/dev/null || true
  rm -f "$FIFO"
}
trap cleanup EXIT TERM INT

rm -f "$FIFO"
mkfifo "$FIFO"

tail -f /dev/null > "$FIFO" &
TAIL_PID=$!

"$FLUIDSYNTH_BIN" \
  -o midi.driver=coremidi \
  -o audio.driver=coreaudio \
  -o audio.coreaudio.device=default \
  -o audio.period-size=256 \
  "$SOUNDFONT" \
  < "$FIFO" &
FS_PID=$!

wait "$FS_PID"
