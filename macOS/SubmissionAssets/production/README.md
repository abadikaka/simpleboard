# Simple Board hackathon video production

This folder contains the reproducible sources for the public Simple Board hackathon demo. The published video must remain below three minutes and include both a working product demonstration and a clear account of how Codex and GPT-5.6 were used.

## Requirements

- macOS with Homebrew FFmpeg
- `curl` and `jq`
- The 2:39 visual draft at `drafts/SimpleBoard-Hackathon-Final-Under-3-Minutes.mp4`

The API key is never written to disk. Generated narration, intermediate media, and final exports are ignored by Git.

## Build

```sh
./generate_macos_narration.sh
./build_demo_video.sh
./validate_demo_video.sh
```

The default narration uses the built-in macOS `Samantha` voice at a tuned product-demo pace and exports a 48 kHz WAV without a network request or API charge. Captions are reviewed and timed in the committed SRT. The final end card and YouTube description disclose that the narration is synthetic.

An optional `generate_narration.sh` path remains available for OpenAI `gpt-4o-mini-tts` with the `marin` voice. It requires an API key with only `Text-to-Speech (/v1/audio/speech)` Request permission exported as `OPENAI_API_KEY`; the key is never written to disk.

The build creates:

- `exports/SimpleBoard-Hackathon-Demo-Final.mp4`
- `exports/SimpleBoard-Hackathon-Thumbnail.png`
- `SimpleBoard-Hackathon-Final.srt`

No stock music or sampled effects are used. The understated ambient bed and confirmation tones are synthesized locally by FFmpeg.
