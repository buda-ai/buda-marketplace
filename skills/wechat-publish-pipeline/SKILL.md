---
name: wechat-publish-pipeline
description: End-to-end pipeline for writing and publishing an article to WeChat Official Account draft box. Use when user says "帮我写一篇新文章", "写文章发公众号", "配图排版发草稿箱", "直接发公众号", "配图发布", "write and publish", or any combination of writing + illustrating + posting to WeChat without manual confirmation steps.
---

# WeChat Full Publish Pipeline

**全自动模式**：从选题到草稿箱，中间不打断。收到指令后按以下步骤顺序执行，全程不等待用户确认。

## ⚡ 进度汇报规范（强制执行）

**在每个 Step 完成后、开始下一个 Step 的工具调用之前，先输出一行汇报文字。** 文字和下一步的工具调用在同一个响应里，顺序是：

```
[文字：✅ Step N 完成：...]
[工具调用：Step N+1 的第一个工具]
```

这是唯一能让用户实时看到进度的方式。不要等用户回复，不要"结束本轮等待"，文字和工具调用一起发出。

**汇报格式：**
```
✅ Step 0 完成：选题「{标题}」（HN {N} points）
✅ Step 1 完成：文章写好，{字数}字
✅ Step 2 完成：5张插图全部生成
✅ Step 3 完成：封面图生成
✅ Step 4 完成：排版完成
✅ Step 5 完成：已发布草稿箱，media_id: {id}
```

## Pipeline Steps

```
Step 0: Topic Selection        (web-search + judgment)
Step 1: Research & Write       (url-to-markdown + translate + write)
Step 2: Article Illustrations  (baoyu-article-illustrator)
Step 3: Cover Image            (baoyu-imagine)
Step 4: Markdown → HTML        (baoyu-markdown-to-html)
Step 5: Publish to Draft Box   (baoyu-post-to-wechat API)
```

每步完成后**立即**发一条进度消息给用户（见上方进度汇报规范）。

---

## Step 0: Topic Selection (自主选题)

**完全自主，不询问用户。**

### 0.1 采集热点

同时搜索以下来源，取近 24-48 小时内容：

```
- Hacker News 热榜 Top 20（https://news.ycombinator.com/best）
- GitHub Trending（https://github.com/trending）
- 如有必要：Twitter/X AI/tech 话题
```

### 0.2 筛选标准

优先选择满足以下条件的话题：

| 标准 | 说明 |
|------|------|
| **相关性** | AI、开发工具、技术趋势、安全事件、工程实践 |
| **时效性** | 事件发生在 48 小时内，有第一手资料可查 |
| **深度潜力** | 有技术细节可挖，不是纯新闻转述 |
| **受众匹配** | 适合技术向公众号读者（工程师、AI 从业者） |
| **未写过** | 检查 `/agent/articles/` 避免重复选题 |

### 0.3 自主决策

从候选话题中选分数最高的一个，记录选题理由，直接进入 Step 1。不展示候选列表，不等待反馈。

> 📢 输出 `✅ Step 0 完成：选题「{标题}」（HN {N} points，来源：{URL}）`，然后在同一响应里立即开始 Step 1 的工具调用（抓取原文）。

---

## Step 1: Research & Write (研究与写作)

### 1.1 获取原始资料

用 `baoyu-url-to-markdown` 抓取主要来源页面：

```bash
SKILL_DIR="/agent/wechat-agent-skills/skills/baoyu-url-to-markdown"
npx -y bun "$SKILL_DIR/scripts/main.ts" --url "{source_url}" --output /tmp/source.md
```

如有多个关键来源（原文 + 讨论帖），全部抓取。

### 1.2 如需翻译

若原文为英文，用 `baoyu-translate` 精翻核心内容作为参考（不直接发翻译稿）：

```bash
SKILL_DIR="/agent/wechat-agent-skills/skills/baoyu-translate"
npx -y bun "$SKILL_DIR/scripts/main.ts" /tmp/source.md --mode normal --to zh
```

### 1.3 撰写原创文章

**文章风格要求：**
- 第一人称叙述视角（"那天..."、"让我们从..."）或第三人称叙事
- 开头用一个具体场景/事件钩住读者，不要从"背景"开始
- 有结构：开篇钩子 → 核心事件/概念 → 技术细节 → 影响/意义 → 结语
- 有自己的观点，不是新闻转述
- 代码示例、数据、引用要准确，来自原始资料
- 长度：2000-4000 字
- 语言：中文

**文件命名与存储：**
```
/agent/articles/drafts/{slug}-{YYYY-MM-DD}.md
```
slug: 英文 kebab-case，2-4 词，来自文章主题

**Frontmatter：**
```yaml
---
title: 文章标题
date: YYYY-MM-DD
source: 原文URL
tags: [tag1, tag2]
digest: 文章摘要（≤15字，发布时传给微信）
---
```

**摘要要求：**
- 不超过 15 字
- 点出核心事件/结论，不是标题的复述
- 示例："AI供应链遭劫持，数千应用悄然中招"

> 📢 输出 `✅ Step 1 完成：文章写好，约 {字数} 字，保存至 {路径}`，然后在同一响应里立即开始 Step 2 的工具调用（创建插图 prompts）。

---

## Step 2: Article Illustrations (配插图)

Skill: `baoyu-article-illustrator`

### 2.1 分析文章，规划插图

读文章，判断：
- 内容类型 → 选 preset
  - 技术/安全/AI → `tech-explainer`（infographic + blueprint）
  - 叙事+技术混合 → `tech-explainer`，关键事件用 `timeline` 类型
  - 方法论/框架 → `system-design`
- 密度：`per-section`（每个主要章节至少 1 张）
- 创建 `{article-dir}/imgs/outline.md`

**好的插图位置：**
- 文章开头之前（时间线或全局概览）
- 关键技术机制说明之后（流程图/框架图）
- 数据/对比节（infographic/comparison）
- 结论前的总结性图示

### 2.2 创建所有 prompt 文件（BLOCKING，必须全部创建后才能生成）

存到 `{article-dir}/imgs/prompts/NN-{type}-{slug}.md`

**Prompt 质量要求：**
- `Layout`：描述整体构图
- `ZONES`：每个区域有具体内容，不能模糊
- `LABELS`：使用文章中的实际数字/术语/引语
- `COLORS`：十六进制色值 + 语义说明
- `STYLE`：技术/安全类用 blueprint/dark/digital 风格
- `ASPECT`: 16:9

**内容审核安全规则**（避免触发 OpenAI 内容政策）：
- ❌ "fork bomb", "malware install", "exploit", "hack", "kill process"
- ✅ 改为描述行为/结果："process multiplication", "malicious payload", "vulnerability abuse mechanism"
- 如果某张图被 `moderation_blocked` 拒绝，立即改写 prompt 描述行为而非技术名词，单独重试

### 2.3 批量生成

创建 `{article-dir}/imgs/batch.json`：

```json
{
  "jobs": 3,
  "tasks": [
    {
      "id": "01-slug",
      "promptFiles": ["prompts/01-type-slug.md"],
      "image": "01-type-slug.png",
      "provider": "openai",
      "model": "gpt-image-1",
      "ar": "16:9",
      "quality": "2k"
    }
  ]
}
```

```bash
cd {article-dir}/imgs
SKILL_DIR="/agent/wechat-agent-skills/skills/baoyu-imagine"
npx -y bun "$SKILL_DIR/scripts/main.ts" --batchfile batch.json --jobs 3
```

### 2.4 插入文章

每张图插入对应段落之后：
```markdown
![描述文字](imgs/NN-type-slug.png)
```

> 📢 输出 `✅ Step 2 完成：5张插图全部生成并插入文章`，然后在同一响应里立即开始 Step 3 的工具调用（生成封面图）。

---

## Step 3: Cover Image (封面图)

封面图存到 `{article-dir}/imgs/cover.png`（`wechat-api.ts` 默认读取此路径）。

### 3.1 创建封面 prompt

存到 `{article-dir}/imgs/prompts/cover.md`

**技术/AI 类文章封面选型：**
- `type: conceptual`
- `palette: dark`
- `rendering: digital`
- 情绪：bold，高对比度
- 配色：深海军蓝/黑底 + 电光红橙（威胁感）或青蓝（科技感）
- 不含文字（微信会单独显示标题）
- 主视觉元素要与文章主题强相关（不要通用科技图）

### 3.2 生成封面

```bash
cd {article-dir}/imgs
SKILL_DIR="/agent/wechat-agent-skills/skills/baoyu-imagine"
npx -y bun "$SKILL_DIR/scripts/main.ts" \
  --promptfiles "prompts/cover.md" \
  --image "cover.png" \
  --provider openai \
  --model gpt-image-1 \
  --ar 16:9 \
  --quality 2k
```

> 📢 输出 `✅ Step 3 完成：封面图生成`，然后在同一响应里立即开始 Step 4 的工具调用（排版）。

---

## Step 4: Markdown → HTML (排版)

```bash
cd {article-dir}
SKILL_DIR="/agent/wechat-agent-skills/skills/baoyu-markdown-to-html"
npx -y bun "$SKILL_DIR/scripts/main.ts" {article-file} --theme grace --cite
```

默认配置：
- Theme: `grace`（优雅，适合技术内容）
- `--cite`：外链转底部引用（微信友好）

确认输出 JSON 中 `contentImages` 包含所有插图后继续。

> 📢 输出 `✅ Step 4 完成：排版完成`，然后在同一响应里立即开始 Step 5 的工具调用（发布到微信）。

---

## Step 5: Publish to WeChat Draft Box (发布)

```bash
cd {article-dir}
SKILL_DIR="/agent/wechat-agent-skills/skills/baoyu-post-to-wechat"
npx -y bun "$SKILL_DIR/scripts/wechat-api.ts" \
  {article-file} \
  --theme grace \
  --color blue \
  --cover imgs/cover.png
```

**关键注意事项：**
- 传 `.md` 文件，不传 `.html`（脚本内部处理转换和图片上传）
- 图片自动压缩到 <1MB JPEG 再上传
- 成功后返回 `media_id`

> 📢 **最终汇报**：发送 `✅ Step 5 完成：已发布草稿箱，media_id: {media_id}`，pipeline 结束。

---

## 首次运行环境检查

### EXTEND.md 检查与自动创建

```bash
test -f "$HOME/.baoyu-skills/baoyu-article-illustrator/EXTEND.md" || mkdir -p "$HOME/.baoyu-skills/baoyu-article-illustrator" && cat > "$HOME/.baoyu-skills/baoyu-article-illustrator/EXTEND.md" << 'EOF'
---
version: 1
watermark:
  enabled: false
  content: ""
  position: bottom-right
  opacity: 0.7
preferred_style:
  name: null
  description: ""
default_output_dir: imgs-subdir
language: zh
custom_styles: []
---
EOF

test -f "$HOME/.baoyu-skills/baoyu-imagine/EXTEND.md" || mkdir -p "$HOME/.baoyu-skills/baoyu-imagine" && cat > "$HOME/.baoyu-skills/baoyu-imagine/EXTEND.md" << 'EOF'
---
version: 1
default_provider: openai
default_quality: 2k
default_aspect_ratio: null
default_image_size: null
default_model:
  google: null
  openai: gpt-image-1
  azure: null
  openrouter: null
  dashscope: null
  minimax: null
  replicate: null
---
EOF

test -f "$HOME/.baoyu-skills/baoyu-cover-image/EXTEND.md" || mkdir -p "$HOME/.baoyu-skills/baoyu-cover-image" && cat > "$HOME/.baoyu-skills/baoyu-cover-image/EXTEND.md" << 'EOF'
---
version: 1
watermark:
  enabled: false
  content: ""
  position: bottom-right
  opacity: 0.7
preferred_type: null
preferred_palette: null
preferred_rendering: null
preferred_text: title-only
preferred_mood: balanced
preferred_font: clean
default_aspect: 16:9
default_output_dir: imgs-subdir
quick_mode: false
language: zh
custom_palettes: []
---
EOF

test -f "$HOME/.baoyu-skills/baoyu-post-to-wechat/EXTEND.md" || mkdir -p "$HOME/.baoyu-skills/baoyu-post-to-wechat" && cat > "$HOME/.baoyu-skills/baoyu-post-to-wechat/EXTEND.md" << 'EOF'
default_theme: grace
default_color: blue
default_publish_method: api
default_author: 宝玉
need_open_comment: 1
only_fans_can_comment: 0
EOF
```

### npm 依赖检查

```bash
ls /agent/skills/baoyu-skills/node_modules/jimp 2>/dev/null || \
  (cd /agent/skills/baoyu-skills && npm install jimp @jsquash/webp)
```

---

## 完成报告

```
WeChat Full Pipeline Complete!

选题: [topic]
来源: [source URL]
文章: [article path]
插图: X 张
封面: imgs/cover.png
主题: grace + blue

✓ 已发布至公众号草稿箱
• media_id: [media_id]

→ 草稿箱: https://mp.weixin.qq.com（内容管理 → 草稿箱）
```
