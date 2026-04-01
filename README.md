# Buda Marketplace

The official source of Skills and Agents for the [Buda.im](https://buda.im) Marketplace.

## What is Buda?

Buda is a multi-agent AI platform that lets you run a team of AI agents as your workforce. Each agent has its own persistent cloud workspace (Drive), and can operate a browser, terminal, and Git — all visible in one UI. Agents can be deployed to Discord, Slack, Telegram, and more. Skills extend what agents can do without writing code.

Buda reads this repository to populate its Marketplace. Users can browse and install pre-built Skills and Agents directly into their Buda workspace.

## What's inside

**`skills/`** — Individual skills following the [Agent Skills specification](https://agentskills.io/specification). Each skill teaches an agent how to do one thing well.

**`agents/`** — Pre-configured Buda agents. Installing an agent provisions it with a system prompt and automatically installs all its required skills.

## Contributing

Add a skill under `skills/<skill-name>/` with a valid `SKILL.md`, or add an agent under `agents/<agent-name>/` with an `AGENTS.md` and `skills.json`. See [AGENTS.md](./AGENTS.md) for the full spec.
