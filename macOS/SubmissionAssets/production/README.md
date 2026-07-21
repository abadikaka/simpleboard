# Simple Board hackathon video production

This folder contains the reproducible sources for the public Simple Board hackathon demo. The published video must remain below three minutes and include both a working product demonstration and a clear account of how Codex and GPT-5.6 were used.

## Requirements

- macOS with Homebrew FFmpeg
- `curl` and `jq`
- An OpenAI API key exported as `OPENAI_API_KEY` only while generating narration
- The 2:39 visual draft at `drafts/SimpleBoard-Hackathon-Final-Under-3-Minutes.mp4`

The API key is never written to disk. Generated narration, intermediate media, and final exports are ignored by Git.

## Build

```sh
./generate_narration.sh
./build_demo_video.sh
./validate_demo_video.sh
```

The narration uses `gpt-4o-mini-tts`, the `marin` voice, and WAV output. OpenAI requires a clear disclosure that the voice is AI-generated; the final end card and YouTube description both contain that disclosure.

The build creates:

- `exports/SimpleBoard-Hackathon-Demo-Final.mp4`
- `exports/SimpleBoard-Hackathon-Thumbnail.png`
- `SimpleBoard-Hackathon-Final.srt`

No stock music or sampled effects are used. The understated ambient bed and confirmation tones are synthesized locally by FFmpeg.
