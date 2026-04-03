# Buda Marketplace

This repository powers the official [Buda.im](https://buda.im) Marketplace — the source of truth for official Skills, Agents, and Teams available in Buda.

## What is Buda?

Buda is a multi-agent AI platform that lets you run a team of AI agents as your workforce. Each agent has its own persistent cloud workspace (Drive), and can operate a browser, terminal, and Git — all visible in one UI. Agents can be deployed to Discord, Slack, Telegram, and more. Skills extend what agents can do without writing code.

Buda reads this repository to populate its Marketplace, where users can discover and install pre-built Skills, Agents, and Teams.

## Repository Structure

This repository follows the [Agent Companies specification](https://agentcompanies.io/specification), which extends the [Agent Skills specification](https://agentskills.io/specification).

```
COMPANY.md                           # Company root manifest
skills/                              # Skill definitions
└── skill-name/
    ├── SKILL.md                     # Required: metadata + instructions
    └── README.md                    # Optional: marketplace listing page
agents/                              # Agent definitions
└── agent-name/
    └── AGENTS.md                    # Role, instructions, and attached skills
teams/                               # Team definitions
└── team-name/
    └── TEAM.md                      # Team manifest
```

## skills/

Skills follow the [Agent Skills specification](https://agentskills.io/specification). Each subdirectory containing a `SKILL.md` is a self-contained skill.

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

## agents/

Each subdirectory defines one agent role. `AGENTS.md` contains YAML frontmatter and a markdown instruction body.

### AGENTS.md Frontmatter Fields

| Field       | Required    | Notes                                      |
|-------------|-------------|--------------------------------------------|
| `name`      | Yes         | Human-readable name                        |
| `description` | Yes       | Short discovery description                |
| `slug`      | Recommended | Stable portable identity                   |
| `schema`    | No          | `agentcompanies/v1`                        |
| `skills`    | No          | List of skill slugs or shortnames to attach |

### Minimal AGENTS.md Example

```yaml
---
schema: agentcompanies/v1
name: My Agent
description: What this agent does.
skills:
  - skill-name
---

Agent instructions go here.
```

## teams/

Each subdirectory defines one team. `TEAM.md` contains YAML frontmatter describing the team and its members.

### Minimal TEAM.md Example

```yaml
---
schema: agentcompanies/v1
name: My Team
description: What this team does.
includes:
  - ../agent-name/AGENTS.md
---
```

## External Skill References

To reference skills from external repositories, use `metadata.sources` in the frontmatter:

```yaml
skills:
  - keyword-research
metadata:
  sources:
    - kind: github-dir
      repo: aaron-he-zhu/seo-geo-claude-skills
      path: research/keyword-research
      commit: main
      url: https://github.com/aaron-he-zhu/seo-geo-claude-skills
```
