# YouTube to Talking Script

Turn any YouTube (or other) video URL into a ready-to-record short-form talking script — fully automated, fully self-contained.

## What it does

Give it a video URL, and the skill:

1. Downloads the source video and MP3 audio with a bundled yt-dlp helper (auto-installs yt-dlp if missing)
2. Transcribes the audio with Whisper
3. Rewrites the content into a new talking script using a structured template (hook, timeline, full read-through, title options)
4. Saves the source video, script, transcript, and MP3 as durable artifacts and previews them in the UI

## Why self-contained

This skill bundles its own download logic at `scripts/download-audio.sh` — no separate downloader skill required. If `yt-dlp` is not found, the helper installs it into a persistent venv under `/agent` (survives sandbox restarts). `ffmpeg` and `python3` are preinstalled in the Buda sandbox.

## Defaults

- Output language: English
- Style: short-form for Red Note / TikTok / YouTube Shorts
- Length: 60–90 seconds, with a strong 0–3s hook
- Keeps source video, MP3 audio, transcript, and final script by default

## Example prompts

- `https://www.youtube.com/watch?v=abc123`
- `get new talking script https://www.youtube.com/watch?v=abc123`
- `generate a talking script from this YouTube video, angled for AI entrepreneurs: https://youtu.be/abc123`
- `turn this video into a 60-second short-form script, make it punchy: https://youtu.be/abc123`
