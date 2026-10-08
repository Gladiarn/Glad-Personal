# Glad Personal

My agent skills in one place — the skills I wrote, plus a catalog of every third-party skill and plugin I use, so any machine can be set up the same way in one command.

- **My skills** live in this repo, each in its own folder with its own README.
- **Third-party skills and plugins** are **referenced, not copied**: the catalog points to each original repository and installs from there, so authors keep their licenses and you always get their latest version.

Works with Claude Code and other agents that load [`SKILL.md` skills](https://agentskills.io/specification).

## My skills

| Skill | What it does | Auto-triggers? |
|---|---|---|
| [**production-readiness**](skills/production-readiness/) | Audits whether an app is ready for production — auth & security, rate limiting, CI/CD, scaling, monitoring, backups & recovery — and returns an evidence-backed report with a hard verdict: **NOT READY / READY WITH CONDITIONS / READY**. | Yes |
| [**glad-frontend**](skills/glad-frontend/) | Makes frontend UI backend-ready by construction: repository pattern, swappable mock/real data, real loading/error/empty states. Data architecture only — pair with a design skill. | Yes |
| [**glad-personal**](skills/glad-personal/) | Provisions a new machine: installs everything below and sets up the global `CLAUDE.md`. | No (manual) |

## Third-party skills and plugins

21 skills and 2 Claude Code plugins, grouped by purpose (design, frontend, backend, workflow, dev tools), each with source, license, vetting status, install command and notes.

**→ [See the full catalog](catalog/README.md)**

## Install

### One skill

```bash
npx skills add https://github.com/Gladiarn/Glad-Personal --skill production-readiness
```

Swap the name for any skill above. For a third-party skill, use the command in its [catalog](catalog/README.md) row.

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
for s in production-readiness glad-frontend glad-personal; do
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
