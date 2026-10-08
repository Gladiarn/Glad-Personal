# glad-personal

A **provisioning skill**: it sets up a new machine with the same skills, plugins and global `CLAUDE.md` as my main machine, from one list.

It is manual-only (`disable-model-invocation: true`) — it never triggers on its own. You call it when you want it.

- **Version:** 2.0.0 · **License:** MIT · **Works with:** Claude Code (other agents can follow the same steps)

## What it does

When you run it, the agent:

1. Reads the list in [`references/stack.json`](references/stack.json) — my own skills, the third-party skills I use (each pointing to its original repository), the Claude Code plugins, plus what was declined and what must never be copied.
2. Compares it with what is installed — **both** `~/.claude/skills/` and `~/.claude/plugins/` (checking only one gives wrong answers).
3. Installs what's missing:
   - skills → `npx skills add <original repo> --skill <name>`
   - tool installers (compiled binaries, Python packages) → only after you say yes
   - plugins → tells you the `/plugin install` command to run yourself (agents can't)
4. Sets up `~/.claude/CLAUDE.md` from the bundled copy — copies it if missing, or merges in only the missing sections if you already have one. Never overwrites.
5. Reports exactly what was installed, already present, skipped, or left for you.

## Install

```bash
npx skills add https://github.com/Gladiarn/Glad-Personal --skill glad-personal
```

## Use

In Claude Code:

```
/glad-personal
```

or say: *"Use glad-personal to set up my skills on this machine."* / *"Which of my skills are missing here?"*

**Without an agent:** clone the repository and run the installer directly:

```bash
git clone https://github.com/Gladiarn/Glad-Personal ~/Glad-Personal
cd ~/Glad-Personal && ./install.sh --all --dry-run   # see what it would do
./install.sh --all                                   # do it
```

## Files

| File | Purpose |
|---|---|
| `SKILL.md` | Instructions the agent follows |
| `references/stack.json` | The list: own skills, third-party skills, plugins, declined, never-provision |
| `references/CLAUDE.md` | Copy of my global `CLAUDE.md` (last synced 2026-10-08) |
| `LICENSE` | MIT (covers this skill, not the third-party skills it references) |

## Updating the list

Edit `references/stack.json`, then from the repository root run `node scripts/build-catalog.js` to regenerate `catalog/README.md`, and commit both. New third-party skills go through the vetting checklist in `SKILL.md` first.
