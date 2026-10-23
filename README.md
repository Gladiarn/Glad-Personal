# Glad Personal

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Agent Skills](https://img.shields.io/badge/format-Agent%20Skills-8A2BE2.svg)](https://agentskills.io/specification)
[![Claude Code](https://img.shields.io/badge/built%20for-Claude%20Code-D97757.svg)](https://docs.anthropic.com/en/docs/claude-code)

**A ready-made, tested set of agent skills for Claude Code.** It has the skills I wrote and use every day, plus a vetted catalog of the best third-party skills and plugins, each linked to its original author. Clone it and you get a complete, working setup in one command.

## The problem

Agent skills make coding agents much better at specific jobs: auditing a launch, planning features, test-driven development, design. But using them well is harder than it looks:

- **They're scattered.** A good setup pulls from a dozen repositories. Rebuilding it on a new machine means remembering every install command.
- **Quality varies.** Anyone can publish a skill. Some run compiled binaries, some control a real browser, and many have never been tested to see whether they actually trigger.
- **Copying breaks things.** Pasting someone else's skill into your own repo drops their license and freezes it at an old version.
- **Defaults cost more than they need to.** Running every task on the most capable model is expensive when most of the work doesn't need it.

## What this repository does about it

- **Original skills, tested against a baseline.** Each skill here is compared with an agent *without* it, and its description is tested for triggering. The README of every skill that changes agent behavior (`production-readiness`, `opus-plan-sonnet-build`, `glad-frontend`) says how it was tested, with the numbers, and what still doesn't work.
- **A vetted catalog, not copies.** Third-party skills are **referenced, not copied**: the [catalog](catalog/README.md) points to each original repository and installs from there, so authors keep their licenses and you always get their latest version. Each entry was checked against a written [vetting checklist](catalog/README.md#how-new-skills-get-vetted); the ones that were declined are listed too, with the reason.
- **One-command setup.** `./install.sh --all` installs everything, on any machine, the same way.

**Who it's for:** developers using Claude Code (or any agent that loads [`SKILL.md` skills](https://agentskills.io/specification)) who want a solid, trustworthy starting set instead of assembling one skill by skill. Take the whole setup, or just the one skill you need.

## My skills

| Skill | What it does | Auto-triggers? |
|---|---|---|
| [**production-readiness**](skills/production-readiness/) | Audits whether an app is ready for production — auth & security, rate limiting, CI/CD, scaling, monitoring, backups & recovery — and returns an evidence-backed report with a hard verdict: **NOT READY / READY WITH CONDITIONS / READY**. | Yes |
| [**opus-plan-sonnet-build**](skills/opus-plan-sonnet-build/) | Decides which model does each part of a coding task: Opus runs your session, plans and reviews, and hands long, already-planned builds to one Sonnet subagent. Small and risky work never leaves Opus. The saving on long builds is not measured yet; see the skill's README. | Yes |
| [**glad-frontend**](skills/glad-frontend/) | Makes frontend UI backend-ready by construction: repository pattern, swappable mock/real data, real loading/error/empty states. Data architecture only — pair with a design skill. | Yes |
| [**glad-personal**](skills/glad-personal/) | Provisions a new machine: installs everything below and sets up the global `CLAUDE.md`. | No (manual) |

## Third-party skills and plugins

19 skills and 2 Claude Code plugins, grouped by purpose (design, frontend, backend, workflow, dev tools), each with source, license, vetting status, install command and notes.

**→ [See the full catalog](catalog/README.md)**

## Install

### One skill

```bash
npx skills add https://github.com/Gladiarn/Glad-Personal --skill production-readiness
```

Swap the name for any skill above. For a third-party skill, use the command in its [catalog](catalog/README.md) row.

### As a Claude Code plugin

Run inside Claude Code (needs 2.1.275 or later for the one-step form):

```
/plugin install production-readiness --marketplace Gladiarn/Glad-Personal
/plugin install opus-plan-sonnet-build --marketplace Gladiarn/Glad-Personal
/plugin install glad-frontend --marketplace Gladiarn/Glad-Personal
```

Plugins are namespaced (`production-readiness:production-readiness`) and update with `/plugin update`.

### All my skills

```bash
npx skills add https://github.com/Gladiarn/Glad-Personal --skill '*'
```

### My whole setup on a new machine

```bash
git clone https://github.com/Gladiarn/Glad-Personal ~/Glad-Personal
cd ~/Glad-Personal
./install.sh --all --dry-run   # preview
./install.sh --all             # my skills + every third-party skill, from their original repos
```

Or without cloning:

```bash
curl -fsSL https://raw.githubusercontent.com/Gladiarn/Glad-Personal/main/install.sh | bash -s -- --all
```

Then:

- **Plugins** — the installer prints the `/plugin install` commands; run them inside Claude Code (scripts can't install plugins).
- **Tool installers** (`casr`, `process-triage`, `graphify`) download compiled binaries or Python packages, so they're skipped by default. Read them, then add `--with-tools`.
- **Global `CLAUDE.md`** — in Claude Code, run `/glad-personal` to copy or merge it.

### Installer options

| Option | Does |
|---|---|
| `--own` | my skills only |
| `--stack` | third-party skills only |
| `--all` | both |
| `--skill <name>` | one skill (repeatable) |
| `--with-tools` | also run the tool installers |
| `--agent <ids>` | agents to install for (default `claude-code`) |
| `--dry-run` | print commands, install nothing |
| `--list` | show the catalog |

Needs Node.js 18+ (for `npx`).

### Keep a clone linked (always up to date)

```bash
git clone https://github.com/Gladiarn/Glad-Personal ~/Glad-Personal
mkdir -p ~/.claude/skills
for s in production-readiness opus-plan-sonnet-build glad-frontend glad-personal; do
  ln -s ~/Glad-Personal/skills/$s ~/.claude/skills/$s
done
# update later with: git -C ~/Glad-Personal pull
```

## Repository layout

```
Glad-Personal/
├── README.md                 this page
├── install.sh                one-command setup
├── catalog/README.md         every third-party skill & plugin (generated)
├── scripts/build-catalog.js  regenerates the catalog from stack.json
├── skills/
│   ├── production-readiness/ SKILL.md · README.md · checklist · template · example · LICENSE
│   ├── opus-plan-sonnet-build/ SKILL.md · README.md · evals · LICENSE
│   ├── glad-frontend/        SKILL.md · README.md · evals · LICENSE
│   └── glad-personal/        SKILL.md · README.md · references/stack.json · references/CLAUDE.md · LICENSE
├── CHANGELOG.md
└── LICENSE
```

`skills/glad-personal/references/stack.json` is the single source of truth for the catalog and the installer.

## Adding or changing a skill

1. **My skill:** add a folder under `skills/` with `SKILL.md` (frontmatter: `name`, `description`, `license`, `metadata.version`), a `README.md` and a `LICENSE`. Add it to `own` in `stack.json`.
2. **Third-party skill:** vet it (checklist in the [catalog](catalog/README.md#how-new-skills-get-vetted)), then add an entry to `skills` in `stack.json`.
3. Run `node scripts/build-catalog.js`, update the [changelog](CHANGELOG.md), and commit.

## License

My skills and the tooling in this repo are [MIT](LICENSE). Third-party skills and plugins listed in the catalog belong to their authors and are under their own licenses.
