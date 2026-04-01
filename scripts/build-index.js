#!/usr/bin/env node
// Generates skills/index.json (local skills) and agents/index.json
// Usage: node scripts/build-index.js

const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");

// --- skills/index.json ---
const skillsDir = path.join(root, "skills");
const skillsIndexPath = path.join(skillsDir, "index.json");

const existing = JSON.parse(fs.readFileSync(skillsIndexPath, "utf8"));
const externalSkills = existing.skills.filter((s) => s.url !== "./");

const localSkills = fs
  .readdirSync(skillsDir)
  .filter(
    (name) =>
      fs.statSync(path.join(skillsDir, name)).isDirectory() &&
      fs.existsSync(path.join(skillsDir, name, "SKILL.md"))
  )
  .map((name) => ({ url: "./", skillname: name }));

existing.skills = [...localSkills, ...externalSkills];
fs.writeFileSync(skillsIndexPath, JSON.stringify(existing, null, 2) + "\n");
console.log(`skills/index.json: ${localSkills.length} local skill(s)`);

// --- agents/index.json ---
const agentsDir = path.join(root, "agents");
const agents = fs
  .readdirSync(agentsDir)
  .filter(
    (name) =>
      fs.statSync(path.join(agentsDir, name)).isDirectory() &&
      fs.existsSync(path.join(agentsDir, name, "AGENTS.md"))
  )
  .map((name) => ({ name }));

fs.writeFileSync(
  path.join(agentsDir, "index.json"),
  JSON.stringify(agents, null, 2) + "\n"
);
console.log(`agents/index.json: ${agents.length} agent(s)`);
