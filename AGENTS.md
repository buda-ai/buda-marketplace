# Agent Skills

This repository follows the [Agent Skills specification](https://agentskills.io/specification).

## What are Agent Skills?

Agent Skills are structured, reusable instruction sets that agents load on demand. Each skill lives in its own directory and contains a `SKILL.md` file with YAML frontmatter (name, description, and optional fields) followed by Markdown instructions.

## Directory Structure

```
skill-name/
├── SKILL.md          # Required: metadata + instructions
├── scripts/          # Optional: executable code
├── references/       # Optional: documentation
└── assets/           # Optional: templates, resources
```

## SKILL.md Frontmatter Fields

| Field           | Required | Notes                                                        |
|-----------------|----------|--------------------------------------------------------------|
| `name`          | Yes      | Lowercase, hyphens only, max 64 chars, matches directory name |
| `description`   | Yes      | What the skill does and when to use it, max 1024 chars       |
| `license`       | No       | License name or reference to bundled license file            |
| `compatibility` | No       | Environment requirements, max 500 chars                      |
| `metadata`      | No       | Arbitrary key-value pairs                                    |
| `allowed-tools` | No       | Space-delimited pre-approved tools (experimental)            |

## Minimal Example

```yaml
---
name: skill-name
description: A description of what this skill does and when to use it.
---
```

## Guidelines

- Keep `SKILL.md` under 500 lines; move detailed content to `references/`
- The `name` field must match the parent directory name exactly
- Write descriptions that include keywords agents can use to identify relevant tasks
- Scripts in `scripts/` should be self-contained with clear error messages
