#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/generated"
OUTPUT_FILE="$OUTPUT_DIR/narration.wav"

if [[ -z "${OPENAI_API_KEY:-}" ]]; then
  echo "OPENAI_API_KEY is required. Export it for this command only; do not save it in the repository." >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

REQUEST_JSON="$(jq -n \
  --rawfile input "$SCRIPT_DIR/narration.txt" \
  '{
    model: "gpt-4o-mini-tts",
    voice: "marin",
    response_format: "wav",
    input: $input,
    instructions: "Speak in a warm, confident, natural English product-demo voice. Use an engaging but calm pace of roughly 150 to 160 words per minute. Add brief natural pauses between paragraphs. Pronounce Codex as co-dex, GPT-5.6 as G P T five point six, SwiftUI as Swift U I, and Budi as boo-dee. Avoid exaggerated sales energy."
  }')"

curl --fail --silent --show-error \
  https://api.openai.com/v1/audio/speech \
  -H "Authorization: Bearer ${OPENAI_API_KEY}" \
  -H "Content-Type: application/json" \
  --data "$REQUEST_JSON" \
  --output "$OUTPUT_FILE"

ffprobe -v error -show_entries format=duration:stream=codec_name,sample_rate,channels \
  -of default=noprint_wrappers=1 "$OUTPUT_FILE"

echo "Generated $OUTPUT_FILE"
echo "Use the reviewed captions at $SCRIPT_DIR/SimpleBoard-Hackathon-Final.srt"
