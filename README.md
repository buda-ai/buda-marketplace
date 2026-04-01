# Buda Marketplace

The official source of Skills and Agents for the [Buda.im](https://buda.im) Marketplace.

Buda reads this repository to populate its Marketplace. Users can browse and install pre-built Skills and Agents directly into their Buda workspace.

## What's inside

**`skills/`** — Individual skills following the [Agent Skills specification](https://agentskills.io/specification). Each skill teaches an agent how to do one thing well.

**`agents/`** — Pre-configured Buda agents. Installing an agent provisions it with a system prompt and automatically installs all its required skills.

## Contributing

Add a skill under `skills/<skill-name>/` with a valid `SKILL.md`, or add an agent under `agents/<agent-name>/` with an `AGENTS.md` and `skills.json`. See [AGENTS.md](./AGENTS.md) for the full spec.
