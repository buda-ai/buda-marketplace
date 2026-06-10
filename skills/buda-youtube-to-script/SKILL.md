---
name: buda-youtube-to-script
description: Use this skill whenever the user provides a YouTube or other video URL and asks to create, generate, rewrite, repurpose, summarize into, or get a new talking script / voiceover script / short-form video script / 口播稿 / 小红书口播稿 / 抖音口播稿. Trigger strongly on phrases like "get new talking script", "生成口播稿", "根据这个视频写脚本", "把这个 YouTube 视频变成口播", or when the user gives a video URL plus an angle/prompt. This skill is fully self-contained: it downloads the source audio (and optionally video) with the bundled yt-dlp helper, transcribes the audio with Whisper, reads the bundled `assets/talking-script-template.md`, then produces a new template-based talking script. No other skill needs to be installed.
---

# YouTube to Talking Script

Turn a video URL into a new talking script by downloading the source audio, transcribing it, and rewriting the content into the user's requested angle.

This skill is self-contained. It does NOT depend on any separate downloader skill. The yt-dlp download logic ships with this skill at `scripts/download-audio.sh`, and the output template ships at `assets/talking-script-template.md`.

Important default: for script-generation tasks, prefer downloading audio only. Do not download the full MP4 unless the user explicitly asks to keep the video, wants video analysis, or audio extraction fails and a video fallback is necessary.

## Default behavior

Unless the user says otherwise:

- Output language: Chinese
- Script style: short-form talking script suitable for 小红书 / 抖音 / YouTube Shorts
- Target length: 60–90 seconds
- Rewrite mode: creative repurposing, not a literal translation or transcript summary
- Preserve the source video's core idea, but make the final script natural for a human to speak
- Include a strong 0–3 second hook
- Save all artifacts under `/agent/outputs/talking-scripts/<safe-title-or-id>-<YYYYMMDD-HHMMSS>/`
- By default keep the downloaded audio, transcript, and final script
- Download and keep the video only if the user explicitly asks for it or a later step truly needs it

## Inputs to extract from the user

Required:

- Video URL

Optional:

- Angle / prompt, for example: `get new talking script`, `面向创业者`, `做成 60 秒`, `小红书风格`, `重点讲 AI 工具如何提升效率`
- Target platform
- Target audience
- Target duration
- Output language
- Whether to include timestamps, subtitles, or title ideas

If the user gives only a URL and a vague phrase like `get new talking script`, proceed with the defaults. Do not ask unnecessary clarification questions.

## Workflow

### 1. Prepare a task folder

Create a durable output directory, not scratch files in `/agent` root.

```bash
mkdir -p /agent/outputs/talking-scripts
WORKDIR="/agent/outputs/talking-scripts/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$WORKDIR"
```

If possible, use `yt-dlp --print title` or `yt-dlp --print id` to create a more descriptive folder name. Sanitize names so they are safe as file paths.

### 2. Verify dependencies

```bash
which ffmpeg || echo "ffmpeg missing — install with: brew install ffmpeg"
```

You normally do NOT need to install yt-dlp manually. The bundled download script resolves `yt-dlp` in this order:

1. `yt-dlp` on PATH
2. `/agent/.local/bin/yt-dlp`
3. If still missing, it auto-installs into a dedicated venv at `/agent/.local/venvs/yt-dlp` and symlinks `/agent/.local/bin/yt-dlp` — this persists across sandbox restarts.

Auto-install needs `python3` (or `python`) available, which the Buda sandbox provides by default. `ffmpeg` is required for MP3 extraction and is also preinstalled.

### 3. Download audio (default) with the bundled helper

Audio is the default artifact because transcription is the main goal. Use the bundled script. Resolve its path against this skill directory:

```text
/space/.agents/skills/buda-youtube-to-script/scripts/download-audio.sh
```

```bash
bash /space/.agents/skills/buda-youtube-to-script/scripts/download-audio.sh \
  -o "$WORKDIR" \
  "VIDEO_URL"
```

The helper:

- Saves the MP3 to `$WORKDIR/audio/`
- For YouTube, tries `--cookies-from-browser chrome` first, then automatically retries without cookies
- For non-YouTube sites, tries without cookies first, then retries with cookies

If you prefer to run yt-dlp directly instead of the helper, the equivalent command is:

```bash
yt-dlp \
  --cookies-from-browser chrome \
  -P "$WORKDIR/audio" \
  -o "%(title).180B [%(id)s].%(ext)s" \
  -x --audio-format mp3 \
  "VIDEO_URL"
```

Retry without `--cookies-from-browser chrome` if the browser profile is unavailable.

### 4. Optional video download

Only if the user explicitly wants the MP4, wants frames/visual analysis, or audio download fails, also pull the full video:

```bash
bash /space/.agents/skills/buda-youtube-to-script/scripts/download-audio.sh \
  -o "$WORKDIR" --video \
  "VIDEO_URL"
```

This saves the video to `$WORKDIR/video/`. If audio download failed but video exists, extract audio with `ffmpeg`.

### 5. Transcribe with Whisper

Use the Whisper tool on the downloaded MP3 (or other audio file).

- Use `response_format: text` for a clean transcript, or `verbose_json` if timestamps are useful.
- Use `language` only when obvious or requested. For English videos, `en`; for Chinese videos, `zh`.
- Add a short `prompt` if the video has known jargon, creator names, products, or acronyms.

Save the transcript to:

```text
$WORKDIR/transcript.txt
```

If the tool returns JSON, also save `$WORKDIR/transcript.json`.

### 6. Read the talking script template

Always read the bundled template, resolving the relative path against this skill directory:

```text
/space/.agents/skills/buda-youtube-to-script/assets/talking-script-template.md
```

If this file is missing, recreate this structure in the final answer:

```markdown
# Talking Script: [Short title based on the video]

Source: [YouTube URL]
Estimated length: [Estimated speaking time based on the final script]
Angle: [The specific idea this script will focus on]
Audience: [Who this is for]

## Core Idea

[One sentence that captures the point of the video.]

## Timeline

| Time | Visual / Action | Voiceover | On-screen Text | Notes |
|---|---|---|---|---|

## Full Read-Through

[The complete voiceover script without table formatting.]

## Optional Titles

- [Title option 1]
- [Title option 2]
- [Title option 3]
```

### 7. Generate the new talking script

Use the transcript as source material, but do not simply compress it. Create a new script that fits the user's angle and target audience.

Quality bar:

- Start with a punchy hook in the first timeline row
- Make the voiceover conversational and speakable
- Avoid academic summary language like “本文主要讲述了”
- Prefer concrete examples over vague claims
- Keep sentences short enough for spoken delivery
- Keep the timeline realistic for the target duration
- Include concise on-screen text that works as captions
- Include delivery notes such as pause, emphasis, speed, or facial/action cues
- Include 3 title options with different angles
- Mention the source URL in the `Source` field

Respect the template headings exactly unless the user asks for another format.

### 8. Save outputs

Save at least:

```text
$WORKDIR/talking-script.md
$WORKDIR/transcript.txt
$WORKDIR/audio/<downloaded-file>.mp3
```

The MP3 is a required output unless the source platform truly prevents audio download. Treat the MP3 as a user-facing artifact that should be previewed in the UI.

### 9. Report back to the user

Keep the final response concise:

- Say the script is generated
- Provide the saved path
- Mention that the MP3 and transcript were also saved
- Mention video only if it was downloaded
- If `talking-script.md` should be previewed, first verify it with the Buda send-file script, then include the returned `[send:...]` marker in the reply
- Verify the downloaded MP3 with the Buda send-file script and include the returned `[send:...]` marker in the reply so the frontend UI shows a file card for the audio

Do not write `[send:...]` manually without verifying the file exists first. Do not paste the entire transcript unless the user asks.

## Failure handling

### Audio download fails

Try in this order:

1. Bundled helper (handles cookies + no-cookies retry automatically)
2. Direct YouTube with `--cookies-from-browser chrome`
3. Direct YouTube without cookies
4. List formats with `yt-dlp -F URL` (or `download-audio.sh --list URL`)
5. Download best audio fallback or, only if needed, a video fallback and extract audio with ffmpeg

### Video download fails

If video was optional for the task, skip it and continue as long as audio/transcript generation succeeded.

If the video is private, members-only, age-restricted, geo-restricted, or unavailable, explain clearly and ask the user for access/cookies or another URL.

### Whisper fails

Check:

- Audio file exists
- File is not zero bytes
- Audio format is supported

If needed, convert audio to a clean MP3:

```bash
ffmpeg -y -i "$AUDIO_FILE" -ac 1 -ar 16000 "$WORKDIR/audio/whisper-ready.mp3"
```

Then retry Whisper.

### Template missing

Use the fallback template shown above and tell the user the original template file was missing.

## Example prompts this skill should handle

- `get new talking script https://www.youtube.com/watch?v=abc123`
- `根据这个 YouTube 视频生成口播稿 https://youtu.be/abc123，角度是给 AI 创业者看的`
- `下载这个视频和音频，转文字，然后用模板写一个小红书口播稿：https://youtube.com/watch?v=abc123`
- `把这个视频改成 60 秒中文短视频脚本，风格犀利一点：https://youtu.be/abc123`
