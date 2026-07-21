#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/generated"
AIFF_FILE="$OUTPUT_DIR/narration-macos.aiff"
OUTPUT_FILE="$OUTPUT_DIR/narration.wav"
VOICE="${SIMPLE_BOARD_VOICE:-Samantha}"
RATE="${SIMPLE_BOARD_VOICE_RATE:-155}"

command -v say >/dev/null || { echo "macOS say is required" >&2; exit 1; }
command -v ffmpeg >/dev/null || { echo "FFmpeg is required" >&2; exit 1; }

if ! say -v '?' | awk '{print $1}' | grep -Fxq "${VOICE%% *}"; then
  echo "The requested macOS voice is not installed: $VOICE" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

perl -0pe '
  s/\bCodex\b/co-dex/g;
  s/GPT-5\.6/G P T five point six/g;
  s/SwiftUI/Swift U I/g;
  s/\bBudi\b/boo-dee/g;
  s/\n\n/ [[slnc 420]] /g;
' "$SCRIPT_DIR/narration.txt" | \
  say -v "$VOICE" -r "$RATE" -o "$AIFF_FILE" -f -

ffmpeg -hide_banner -loglevel error -y \
  -i "$AIFF_FILE" -ar 48000 -ac 1 -c:a pcm_s24le "$OUTPUT_FILE"

DURATION="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUTPUT_FILE")"
if ! awk -v duration="$DURATION" 'BEGIN { exit !(duration >= 120 && duration <= 180) }'; then
  echo "Narration render is empty or outside the expected duration: $DURATION" >&2
  exit 1
fi

ffprobe -v error -show_entries format=duration:stream=codec_name,sample_rate,channels \
  -of default=noprint_wrappers=1 "$OUTPUT_FILE"

echo "Generated local macOS narration with $VOICE at $OUTPUT_FILE"
echo "Use the reviewed captions at $SCRIPT_DIR/SimpleBoard-Hackathon-Final.srt"
