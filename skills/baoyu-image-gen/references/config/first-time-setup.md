---
name: first-time-setup
description: First-time setup and default model selection flow for baoyu-image-gen
---

# First-Time Setup

⛔ **BLOCKING**: Image generation is NOT allowed until this setup completes and EXTEND.md exists.

## When this triggers

| Condition | Flow |
|-----------|------|
| No EXTEND.md at `.baoyu-skills/baoyu-image-gen/EXTEND.md` (relative to CWD) | Flow 1: Full setup |
| EXTEND.md exists but `default_model.[provider]` is null | Flow 2: Model selection only |

## Flow 1: Full Setup Checklist

Complete every step in order. Do NOT skip any step. Check off each step as you go.

- [ ] Step 1: Ask provider
- [ ] Step 2: Check required environment variables for the chosen provider
- [ ] Step 3: Ask custom base URL (optional)
- [ ] Step 4: Ask model (based on provider from Step 1)
- [ ] Step 5: Ask quality
- [ ] Step 6: Write EXTEND.md
- [ ] Step 7: Verify EXTEND.md was written

**Language**: Match the user's input language.

### Step 1: Ask Default Provider

Ask the user to choose a provider. Present these options:

| Option | Description |
|--------|-------------|
| Google (Recommended) | Gemini multimodal — high quality, reference images, flexible sizes |
| OpenAI | GPT Image — consistent quality, reliable output |
| OpenRouter | Router for Gemini/FLUX/OpenAI-compatible image models |
| DashScope | Alibaba Cloud Qwen-Image — strong Chinese/English text rendering |
| Jimeng | 即梦 (Volcengine) — Chinese image generation |
| Seedream | 豆包 (Volcengine ARK) — Doubao Seedream models |
| Replicate | Community models — nano-banana-pro, flexible model selection |

⛔ Do NOT proceed to Step 2 until the user has answered.

### Step 2: Check Required Environment Variables

Based on the provider chosen in Step 1, check whether the required environment variable(s) exist:

| Provider | Required env var(s) | Check command |
|----------|---------------------|---------------|
| Google | `GOOGLE_API_KEY` | `test -n "$GOOGLE_API_KEY" && echo "ok"` |
| OpenAI | `OPENAI_API_KEY` | `test -n "$OPENAI_API_KEY" && echo "ok"` |
| OpenRouter | `OPENROUTER_API_KEY` | `test -n "$OPENROUTER_API_KEY" && echo "ok"` |
| DashScope | `DASHSCOPE_API_KEY` | `test -n "$DASHSCOPE_API_KEY" && echo "ok"` |
| Jimeng | `JIMENG_ACCESS_KEY_ID` and `JIMENG_SECRET_ACCESS_KEY` | `test -n "$JIMENG_ACCESS_KEY_ID" && test -n "$JIMENG_SECRET_ACCESS_KEY" && echo "ok"` |
| Seedream | `ARK_API_KEY` | `test -n "$ARK_API_KEY" && echo "ok"` |
| Replicate | `REPLICATE_API_TOKEN` | `test -n "$REPLICATE_API_TOKEN" && echo "ok"` |

- If the check prints "ok" → proceed to Step 3.
- If the check prints nothing (env var missing) → ⛔ **STOP.** Tell the user:
  "The environment variable `XXX` is required for [Provider]. Please open Buda's Agent Settings page and add it to the agent's environment variables. Once done, come back here and let me know so we can continue."
  Do NOT proceed until the user confirms the variable is set.

⛔ Do NOT proceed to Step 3 until the environment variable check passes.

### Step 3: Ask Custom Base URL (Optional)

Ask the user whether they want to use a custom API endpoint (base URL) for the chosen provider. This is useful for proxies, self-hosted instances, or region-specific endpoints.

Present this to the user:

> The default API endpoint for [Provider] is the official one. If you need to use a custom endpoint (e.g., a proxy or self-hosted instance), you can set it now. Otherwise, skip this step.

| Provider | Env var for custom base URL | Default |
|----------|----------------------------|---------|
| Google | `GOOGLE_BASE_URL` | Official Google API |
| OpenAI | `OPENAI_BASE_URL` | Official OpenAI API |
| OpenRouter | `OPENROUTER_BASE_URL` | `https://openrouter.ai/api/v1` |
| DashScope | `DASHSCOPE_BASE_URL` | Official DashScope API |
| Jimeng | `JIMENG_BASE_URL` | `https://visual.volcengineapi.com` |
| Seedream | `SEEDREAM_BASE_URL` | `https://ark.cn-beijing.volces.com/api/v3` |
| Replicate | `REPLICATE_BASE_URL` | Official Replicate API |

- If the user wants a custom URL → tell them the env var name for their provider (from the table above), e.g.: "You can customize the API endpoint by adding `OPENAI_BASE_URL` in Buda's Agent Settings page. Set it to your desired URL, then restart the conversation."
- If the user says skip / no / use default → proceed to Step 4.

### Step 4: Ask Default Model

Based on the provider chosen in Step 1, ask the user to pick a model from the matching table below. Only show ONE table — the one for the chosen provider.

**Google models:**

| Model | Description |
|-------|-------------|
| gemini-3-pro-image-preview (Recommended) | Highest quality, best for production |
| gemini-3.1-flash-image-preview | Fast, good quality, lower cost |
| gemini-3-flash-preview | Fast, balanced quality and speed |

**OpenAI models:**

| Model | Description |
|-------|-------------|
| gpt-image-1.5 (Recommended) | Latest GPT Image model |
| gpt-image-1 | Previous generation |

**OpenRouter models:**

| Model | Description |
|-------|-------------|
| google/gemini-3.1-flash-image-preview (Recommended) | Best for image output and reference-image edits |
| google/gemini-2.5-flash-image-preview | Fast preview-oriented generation |
| black-forest-labs/flux.2-pro | High-quality text-to-image |

**DashScope models:**

| Model | Description |
|-------|-------------|
| qwen-image-2.0-pro (Recommended) | Best for text rendering and custom sizes |
| qwen-image-2.0 | Faster 2.0 variant with flexible output size |
| qwen-image-max | Legacy, five fixed output sizes only |

DashScope note: Prefer `qwen-image-2.0-pro` for custom `--size`, uncommon ratios (21:9), or Chinese/English text rendering.

**Jimeng models:**

| Model | Description |
|-------|-------------|
| jimeng_t2i_v40 (Recommended) | Latest Jimeng text-to-image model |

**Seedream models:**

| Model | Description |
|-------|-------------|
| doubao-seedream-5-0-260128 (Recommended) | Latest Seedream 5.0, supports reference images |
| doubao-seedream-4-5-250115 | Seedream 4.5, supports reference images |
| doubao-seedream-4-0-250115 | Seedream 4.0, supports reference images |
| doubao-seedream-3-0-250110 | Seedream 3.0, no reference image support |

**Replicate models:**

| Model | Description |
|-------|-------------|
| google/nano-banana-pro (Recommended) | Google's fast image model on Replicate |
| google/nano-banana | Google's base image model |

⛔ Do NOT proceed to Step 5 until the user has answered.

### Step 5: Ask Default Quality

| Option | Description |
|--------|-------------|
| 2k (Recommended) | 2048px — covers, illustrations, infographics |
| normal | 1024px — quick previews, drafts |

⛔ Do NOT proceed to Step 6 until the user has answered.

### Step 6: Write EXTEND.md

Save location: `.baoyu-skills/baoyu-image-gen/EXTEND.md` (relative to current working directory)

1. Create the directory:
```bash
mkdir -p .baoyu-skills/baoyu-image-gen
```

2. Write the file using this template (fill in values from Steps 1, 4, and 5; leave unselected providers as null):

```yaml
---
version: 1
default_provider: [provider from Step 1, or null]
default_quality: [quality from Step 3]
default_aspect_ratio: null
default_image_size: null
default_model:
  google: [model if Google selected, else null]
  openai: [model if OpenAI selected, else null]
  openrouter: [model if OpenRouter selected, else null]
  dashscope: [model if DashScope selected, else null]
  jimeng: [model if Jimeng selected, else null]
  seedream: [model if Seedream selected, else null]
  replicate: [model if Replicate selected, else null]
---
```

### Step 7: Verify EXTEND.md

```bash
test -f .baoyu-skills/baoyu-image-gen/EXTEND.md && cat .baoyu-skills/baoyu-image-gen/EXTEND.md
```

- If the file exists and content is correct → confirm to user: "Preferences saved. Ready to generate images."
- If the file is missing or malformed → go back to Step 6 and retry.

⛔ Do NOT proceed to image generation until this verification passes.

---

## Flow 2: Model Selection Only

Triggered when EXTEND.md exists but `default_model.[current_provider]` is null.

- [ ] Step 1: Ask model for the current provider (use the matching model table from Flow 1 Step 4)
- [ ] Step 2: Update EXTEND.md — only change the relevant `default_model.[provider]` key, leave everything else unchanged
- [ ] Step 3: Verify the update

```bash
cat .baoyu-skills/baoyu-image-gen/EXTEND.md
```

Confirm the model value is set, then continue with image generation.
