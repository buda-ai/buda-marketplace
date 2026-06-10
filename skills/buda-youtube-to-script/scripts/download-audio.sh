#!/bin/bash
# download-audio.sh — self-contained yt-dlp audio downloader for the
# buda-youtube-to-script skill. No other skill required.
#
# Usage:
#   ./download-audio.sh -o OUTDIR [--video] [--list] URL
#
# Options:
#   -o, --out DIR     Output directory (required). MP3 saved under DIR/audio,
#                     video (if --video) under DIR/video.
#   --video           Also download the full video (bestvideo+bestaudio).
#   --list            Just list available formats, then exit.
#   -h, --help        Show this help.
#
# Behavior:
#   - Resolves yt-dlp from PATH or /agent/.local/bin/yt-dlp; if missing,
#     auto-installs it into /agent/.local/venvs/yt-dlp (persistent).
#   - For YouTube, tries --cookies-from-browser chrome first, then retries
#     without cookies if that fails.
#   - Audio is extracted as MP3 by default (transcription is the goal).

set -euo pipefail

OUTDIR=""
WANT_VIDEO=false
LIST_ONLY=false
URL=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -o|--out) OUTDIR="$2"; shift 2 ;;
    --video) WANT_VIDEO=true; shift ;;
    --list) LIST_ONLY=true; shift ;;
    -h|--help) head -20 "$0" | tail -18; exit 0 ;;
    *) URL="$1"; shift ;;
  esac
done

if [[ -z "$URL" ]]; then
  echo "Error: no URL provided" >&2
  exit 1
fi

# Resolve yt-dlp, auto-installing into /agent if missing (persistent across restarts).
ensure_ytdlp() {
  # 1) Already on PATH?
  local found
  found="$(command -v yt-dlp || true)"
  if [[ -n "$found" ]]; then echo "$found"; return 0; fi
  # 2) Known persistent location?
  if [[ -x /agent/.local/bin/yt-dlp ]]; then echo "/agent/.local/bin/yt-dlp"; return 0; fi
  # 3) Not found — install into a dedicated venv under /agent (persistent).
  echo "yt-dlp not found, installing into /agent/.local/venvs/yt-dlp ..." >&2
  local venv="/agent/.local/venvs/yt-dlp"
  local py
  py="$(command -v python3 || command -v python || true)"
  if [[ -z "$py" ]]; then
    echo "Error: python not found, cannot auto-install yt-dlp." >&2
    return 1
  fi
  "$py" -m venv "$venv" >&2 || { echo "Error: failed to create venv." >&2; return 1; }
  "$venv/bin/pip" install --upgrade pip >&2 2>&1 || true
  "$venv/bin/pip" install yt-dlp >&2 || { echo "Error: pip install yt-dlp failed." >&2; return 1; }
  mkdir -p /agent/.local/bin
  ln -sf "$venv/bin/yt-dlp" /agent/.local/bin/yt-dlp
  echo "/agent/.local/bin/yt-dlp"
}

YTDLP="$(ensure_ytdlp)" || { echo "Error: yt-dlp unavailable and auto-install failed. Install manually: pip install yt-dlp" >&2; exit 1; }
if [[ -z "$YTDLP" ]]; then
  echo "Error: yt-dlp not found." >&2
  exit 1
fi

if ! command -v ffmpeg &>/dev/null; then
  echo "Warning: ffmpeg not found. Audio extraction may fail. Install: brew install ffmpeg" >&2
fi

# Is this a YouTube URL? (cookies help most for YouTube)
IS_YT=false
if [[ "$URL" == *"youtube.com"* || "$URL" == *"youtu.be"* ]]; then
  IS_YT=true
fi

if [[ "$LIST_ONLY" == true ]]; then
  "$YTDLP" -F "$URL"
  exit 0
fi

if [[ -z "$OUTDIR" ]]; then
  echo "Error: -o/--out OUTDIR is required" >&2
  exit 1
fi

NAME_TMPL='%(title).180B [%(id)s].%(ext)s'

run_audio() {
  local with_cookies="$1"
  mkdir -p "$OUTDIR/audio"
  if [[ "$with_cookies" == true ]]; then
    "$YTDLP" --cookies-from-browser chrome -P "$OUTDIR/audio" -o "$NAME_TMPL" -x --audio-format mp3 "$URL"
  else
    "$YTDLP" -P "$OUTDIR/audio" -o "$NAME_TMPL" -x --audio-format mp3 "$URL"
  fi
}

run_video() {
  local with_cookies="$1"
  mkdir -p "$OUTDIR/video"
  if [[ "$with_cookies" == true ]]; then
    "$YTDLP" --cookies-from-browser chrome -P "$OUTDIR/video" -o "$NAME_TMPL" -f "bestvideo+bestaudio/best" "$URL"
  else
    "$YTDLP" -P "$OUTDIR/video" -o "$NAME_TMPL" -f "bestvideo+bestaudio/best" "$URL"
  fi
}

echo "==> Downloading audio (MP3) to $OUTDIR/audio"
if [[ "$IS_YT" == true ]]; then
  run_audio true || { echo "Cookies attempt failed, retrying without cookies..."; run_audio false; }
else
  run_audio false || { echo "Retrying audio with cookies..."; run_audio true; }
fi

if [[ "$WANT_VIDEO" == true ]]; then
  echo "==> Downloading video to $OUTDIR/video"
  if [[ "$IS_YT" == true ]]; then
    run_video true || { echo "Cookies attempt failed, retrying without cookies..."; run_video false; }
  else
    run_video false || { echo "Retrying video with cookies..."; run_video true; }
  fi
fi

echo "==> Done. Files under: $OUTDIR"
