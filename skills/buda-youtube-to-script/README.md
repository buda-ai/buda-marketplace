# YouTube to Talking Script

Turn any YouTube (or other) video URL into a ready-to-record short-form talking script — fully automated, fully self-contained.

## What it does

Give it a video URL (plus an optional angle like "面向创业者" or "做成 60 秒"), and the skill:

1. Downloads the source audio with a bundled yt-dlp helper (auto-installs yt-dlp if missing)
2. Transcribes the audio with Whisper
3. Rewrites the content into a new talking script using a structured template (hook, timeline, full read-through, title options)
4. Saves the script, transcript, and MP3 as durable artifacts and previews them in the UI

## Why self-contained

This skill bundles its own download logic at `scripts/download-audio.sh` — no separate downloader skill required. If `yt-dlp` is not found, the helper installs it into a persistent venv under `/agent` (survives sandbox restarts). `ffmpeg` and `python3` are preinstalled in the Buda sandbox.

## Defaults

- Output language: Chinese
- Style: short-form for 小红书 / 抖音 / YouTube Shorts
- Length: 60–90 seconds, with a strong 0–3s hook
- Audio-only download by default; video only when explicitly requested

## Example prompts

- `get new talking script https://www.youtube.com/watch?v=abc123`
- `根据这个 YouTube 视频生成口播稿，角度是给 AI 创业者看的：https://youtu.be/abc123`
- `把这个视频改成 60 秒中文短视频脚本，风格犀利一点：https://youtu.be/abc123`
