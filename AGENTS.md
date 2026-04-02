# Buda Marketplace

This repository powers the official [Buda.im](https://buda.im) Marketplace — the source of truth for official Skills, Agents, and Teams available in Buda.

## What is Buda?

Buda is a multi-agent AI platform that lets you run a team of AI agents as your workforce. Each agent has its own persistent cloud workspace (Drive), and can operate a browser, terminal, and Git — all visible in one UI. Agents can be deployed to Discord, Slack, Telegram, and more. Skills extend what agents can do without writing code.

Buda reads this repository to populate its Marketplace, where users can discover and install pre-built Skills, Agents, and Teams.

## Repository Structure

```
skills/                              # Skill definitions (any layout)
└── skill-name/
    ├── SKILL.md                     # Required: metadata + instructions
    ├── README.md                    # Optional: marketplace listing page
    ├── scripts/                     # Optional: executable code
    ├── references/                  # Optional: documentation
    └── assets/                      # Optional: templates, resources

.buda/                               # Agents and Teams
├── agents/
│   └── agent-name/
│       ├── agent.json               # Required: agent manifest
│       ├── AGENTS.md                # Optional: instructions
│       └── README.md                # Optional: listing page (takes priority)
└── teams/
    └── team-name/
        ├── team.json                # Required: team manifest
        └── README.md                # Optional: listing page
```

## skills/

Skills follow the [Agent Skills specification](https://agentskills.io/specification). Each subdirectory containing a `SKILL.md` is a self-contained skill.

If a `README.md` exists alongside `SKILL.md`, Buda uses it as the marketplace listing page instead.

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

## .buda/agents/

Agents are pre-configured Buda agents. When a user installs an agent from the Marketplace, Buda provisions it with the defined `AGENTS.md` and installs all listed skills automatically.

### agent.json Format

```json
{
  "name": "My Agent",
  "description": "One-line description shown on the marketplace card.",
  "skills": [
    {
      "repo": "https://github.com/org/repo",
      "skillName": "skill-name"
    }
  ]
}
```

| Field              | Required | Notes                                          |
|--------------------|----------|------------------------------------------------|
| `name`             | Yes      | Display name in the marketplace                |
| `description`      | Yes      | One-line description on the listing card       |
| `skills`           | Yes      | List of skill dependencies                     |
| `skills[].repo`    | Yes      | GitHub URL of the repository containing the skill |
| `skills[].skillName` | Yes    | Directory name containing the `SKILL.md`       |

`AGENTS.md` is optional — defines the agent's role and behavioral instructions. If `README.md` exists, it takes priority as the listing page.

## .buda/teams/

Teams are groups of agents that collaborate on complex workflows.

### team.json Format

```json
{
  "name": "My Team",
  "description": "One-line description shown on the marketplace card.",
  "agents": [
    {
      "repo": "https://github.com/org/repo",
      "agentName": "agent-name"
    }
  ]
}
```

| Field               | Required | Notes                                           |
|---------------------|----------|-------------------------------------------------|
| `name`              | Yes      | Display name in the marketplace                 |
| `description`       | Yes      | One-line description on the listing card        |
| `agents`            | Yes      | List of member agents                           |
| `agents[].repo`     | Yes      | GitHub URL of the repository containing the agent |
| `agents[].agentName`| Yes      | Directory name under `.buda/agents/`            |

`README.md` is optional — if present, used as the team's listing page.
