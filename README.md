# Buda Marketplace

The official source of Skills, Agents, and Teams for the [Buda.im](https://buda.im) Marketplace.

Buda reads this repository to populate its Marketplace. Users can browse and install pre-built Skills, Agents, and Teams directly into their Buda workspace.

## What is Buda?

Buda is a multi-agent AI platform that lets you run a team of AI agents as your workforce. Each agent has its own persistent cloud workspace (Drive), and can operate a browser, terminal, and Git — all visible in one UI. Agents can be deployed to Discord, Slack, Telegram, and more. Skills extend what agents can do without writing code.

## Repository Structure

This repository follows the [Buda Marketplace specification](https://buda.im/docs/create-skill-repo).

```
skills/                    # Skill definitions (Agent Skills spec)
└── skill-name/
    ├── SKILL.md           # Required
    └── README.md          # Optional: marketplace listing page

.buda/
├── agents/                # Pre-configured agents
│   └── agent-name/
│       ├── agent.json     # Required: name, description, skills
│       └── AGENTS.md      # Optional: instructions
└── teams/                 # Agent teams
    └── team-name/
        └── team.json      # Required: name, description, agents
```

## What's inside

**Skills** — Reusable capabilities following the [Agent Skills specification](https://agentskills.io/specification). Each skill teaches an agent how to do one thing well.

**Agents** — Pre-configured Buda agents bundled with a set of skills. Installing an agent provisions it with a system prompt and auto-installs all its required skills.

**Teams** — Groups of agents that collaborate on complex workflows.

## Contributing

See [AGENTS.md](./AGENTS.md) for the full spec on how to add skills, agents, and teams.
