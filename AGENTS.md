# Buda Marketplace

This repository powers the official [Buda.im](https://buda.im) Marketplace — the source of truth for official Skills and Agents available in Buda.

Buda reads this repository to populate its Marketplace, where users can discover and install pre-built Skills and Agents.

## Repository Structure

```
skills/                        # Skill definitions
└── skill-name/
    ├── SKILL.md               # Required: metadata + instructions
    ├── scripts/               # Optional: executable code
    ├── references/            # Optional: documentation
    └── assets/                # Optional: templates, resources

agents/                        # Agent definitions
└── agent-name/
    ├── AGENTS.md              # Agent description and instructions
    └── skills.json            # Skills this agent uses
```

## skills/

Skills follow the [Agent Skills specification](https://agentskills.io/specification). Each subdirectory is a self-contained skill.

### SKILL.md Frontmatter Fields

| Field           | Required | Notes                                                        |
|-----------------|----------|--------------------------------------------------------------|
| `name`          | Yes      | Lowercase, hyphens only, max 64 chars, matches directory name |
| `description`   | Yes      | What the skill does and when to use it, max 1024 chars       |
| `license`       | No       | License name or reference to bundled license file            |
| `compatibility` | No       | Environment requirements, max 500 chars                      |
| `metadata`      | No       | Arbitrary key-value pairs                                    |
| `allowed-tools` | No       | Space-delimited pre-approved tools (experimental)            |

### Minimal SKILL.md Example

```yaml
---
name: skill-name
description: A description of what this skill does and when to use it.
---
```

### Guidelines

- Keep `SKILL.md` under 500 lines; move detailed content to `references/`
- The `name` field must match the parent directory name exactly
- Write descriptions that include keywords agents can use to identify relevant tasks
- Scripts in `scripts/` should be self-contained with clear error messages

## agents/

Agents are pre-configured Buda agents. When a user installs an agent from the Marketplace, Buda provisions it with the defined `AGENTS.md` and installs all listed skills automatically.

Each agent directory contains:

- **`AGENTS.md`** — The agent's system prompt and behavioral instructions, loaded when the agent starts in Buda.
- **`skills.json`** — The list of skills to install for this agent. Each entry references a GitHub repository and an optional skill name.

### skills.json Format

```json
[
  {
    "url": "https://github.com/org/repo",
    "skillname": "skill-name"
  }
]
```

- `url`: GitHub repository containing the skill
- `skillname`: (optional) specific skill directory within the repo to install

### Example: agents/agent-seo

```
agents/agent-seo/
├── AGENTS.md       # SEO agent instructions
└── skills.json     # Skills to install: seo-audit, keyword-research, etc.
```
