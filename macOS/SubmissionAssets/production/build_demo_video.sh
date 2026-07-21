#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
DRAFT="$SCRIPT_DIR/drafts/SimpleBoard-Hackathon-Final-Under-3-Minutes.mp4"
NARRATION="$SCRIPT_DIR/generated/narration-marin.wav"
EXPORT_DIR="$SCRIPT_DIR/exports"
FINAL="$EXPORT_DIR/SimpleBoard-Hackathon-Demo-Final.mp4"
THUMBNAIL="$EXPORT_DIR/SimpleBoard-Hackathon-Thumbnail.png"
INTRO_CARD="$SCRIPT_DIR/generated/intro-card.png"
OUTRO_CARD="$SCRIPT_DIR/generated/outro-card.png"
ICON="$REPO_ROOT/macOS/SimpleBoard/Resources/Assets.xcassets/AppIcon.appiconset/SimpleBoardIcon.png"
DASHBOARD="$SCRIPT_DIR/source-scenes/01-owner-dashboard.jpg"
TARGET_VOICE_DURATION="156.4"
INTRO_DURATION="5"
MAIN_DURATION="159"
OUTRO_DURATION="4"
TOTAL_DURATION="168"

for required in ffmpeg ffprobe; do
  command -v "$required" >/dev/null || { echo "$required is required" >&2; exit 1; }
done

for required_file in "$DRAFT" "$NARRATION" "$ICON" "$DASHBOARD" "$SCRIPT_DIR/render_cards.swift"; do
  [[ -f "$required_file" ]] || { echo "Missing required file: $required_file" >&2; exit 1; }
done

mkdir -p "$EXPORT_DIR"

swift -module-cache-path "$EXPORT_DIR/swift-module-cache" \
  "$SCRIPT_DIR/render_cards.swift" \
  "$ICON" "$DASHBOARD" "$INTRO_CARD" "$OUTRO_CARD" "$THUMBNAIL"

VOICE_DURATION="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$NARRATION")"
VOICE_TEMPO="$(awk -v actual="$VOICE_DURATION" -v target="$TARGET_VOICE_DURATION" 'BEGIN { printf "%.8f", actual / target }')"

if ! awk -v tempo="$VOICE_TEMPO" 'BEGIN { exit !(tempo >= 0.85 && tempo <= 1.20) }'; then
  echo "Narration duration $VOICE_DURATION requires an unsafe tempo adjustment ($VOICE_TEMPO). Regenerate the narration." >&2
  exit 1
fi

ffmpeg -hide_banner -y \
  -loop 1 -framerate 30 -t "$INTRO_DURATION" -i "$INTRO_CARD" \
  -i "$DRAFT" \
  -loop 1 -framerate 30 -t "$OUTRO_DURATION" -i "$OUTRO_CARD" \
  -i "$NARRATION" \
  -f lavfi -i "aevalsrc=0.018*sin(2*PI*130.81*t)+0.010*sin(2*PI*196.00*t)+0.006*sin(2*PI*261.63*t):s=48000:d=${TOTAL_DURATION}" \
  -f lavfi -i "sine=f=659.25:sample_rate=48000:d=0.16" \
  -f lavfi -i "sine=f=783.99:sample_rate=48000:d=0.20" \
  -filter_complex "
    [0:v]scale=1920:1080:flags=lanczos,
      fade=t=in:st=0:d=0.45,fade=t=out:st=4.45:d=0.55,
      setpts=PTS-STARTPTS[intro];
    [1:v]trim=duration=${MAIN_DURATION},setpts=PTS-STARTPTS,
      scale=1920:1080:flags=lanczos,setsar=1[main];
    [2:v]scale=1920:1080:flags=lanczos,
      fade=t=in:st=0:d=0.35,fade=t=out:st=3.55:d=0.45,
      setpts=PTS-STARTPTS[outro];
    [intro][main][outro]concat=n=3:v=1:a=0,format=yuv420p[video];
    [3:a]atempo=${VOICE_TEMPO},aresample=48000,
      highpass=f=70,lowpass=f=15500,
      acompressor=threshold=0.12:ratio=2.5:attack=10:release=140:makeup=1.35,
      adelay=5000|5000,apad=whole_dur=${TOTAL_DURATION},atrim=duration=${TOTAL_DURATION},
      pan=stereo|c0=c0|c1=c0[voice];
    [4:a]lowpass=f=900,highpass=f=80,volume=0.085,
      afade=t=in:st=0:d=2.5,afade=t=out:st=164:d=4,
      pan=stereo|c0=c0|c1=c0[bed];
    [5:a]volume=0.10,adelay=950|950,pan=stereo|c0=c0|c1=c0[chime1];
    [6:a]volume=0.08,adelay=1110|1110,pan=stereo|c0=c0|c1=c0[chime2];
    [voice][bed][chime1][chime2]amix=inputs=4:duration=longest:dropout_transition=0,
      loudnorm=I=-14:TP=-1:LRA=7,aresample=48000[audio]
  " \
  -map "[video]" -map "[audio]" \
  -t "$TOTAL_DURATION" -r 30 \
  -c:v libx264 -preset slow -crf 17 -profile:v high -level:v 4.2 -pix_fmt yuv420p \
  -c:a aac -b:a 192k -ar 48000 -ac 2 \
  -movflags +faststart "$FINAL"

echo "Built $FINAL"
echo "Built $THUMBNAIL"
