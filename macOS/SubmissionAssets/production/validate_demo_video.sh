#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FINAL="$SCRIPT_DIR/exports/SimpleBoard-Hackathon-Demo-Final.mp4"

[[ -f "$FINAL" ]] || { echo "Missing final video: $FINAL" >&2; exit 1; }

DURATION="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$FINAL")"
if ! awk -v duration="$DURATION" 'BEGIN { exit !(duration < 170.0) }'; then
  echo "Video must remain under 170 seconds; found $DURATION" >&2
  exit 1
fi

VIDEO_CODEC="$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of csv=p=0 "$FINAL")"
AUDIO_CODEC="$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of csv=p=0 "$FINAL")"
PIXEL_FORMAT="$(ffprobe -v error -select_streams v:0 -show_entries stream=pix_fmt -of csv=p=0 "$FINAL")"
SAMPLE_RATE="$(ffprobe -v error -select_streams a:0 -show_entries stream=sample_rate -of csv=p=0 "$FINAL")"
CHANNELS="$(ffprobe -v error -select_streams a:0 -show_entries stream=channels -of csv=p=0 "$FINAL")"

[[ "$VIDEO_CODEC" == "h264" ]] || { echo "Expected H.264, found $VIDEO_CODEC" >&2; exit 1; }
[[ "$AUDIO_CODEC" == "aac" ]] || { echo "Expected AAC, found $AUDIO_CODEC" >&2; exit 1; }
[[ "$PIXEL_FORMAT" == "yuv420p" ]] || { echo "Expected yuv420p, found $PIXEL_FORMAT" >&2; exit 1; }
[[ "$SAMPLE_RATE" == "48000" ]] || { echo "Expected 48 kHz audio, found $SAMPLE_RATE" >&2; exit 1; }
[[ "$CHANNELS" == "2" ]] || { echo "Expected stereo audio, found $CHANNELS channels" >&2; exit 1; }

ffmpeg -hide_banner -nostats -i "$FINAL" -filter_complex ebur128=peak=true -f null - 2>&1 | tail -n 18
ffmpeg -v error -i "$FINAL" -f null -

echo "Validated duration=${DURATION}s video=${VIDEO_CODEC}/${PIXEL_FORMAT} audio=${AUDIO_CODEC}/${SAMPLE_RATE}Hz/${CHANNELS}ch"
