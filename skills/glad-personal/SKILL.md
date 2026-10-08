---
name: glad-personal
description: Personal skill manifest and provisioning guide for this user — lists their own skills plus the third-party global skills and plugins they've vetted and want on every machine, with exact install sources, and bundles a copy of their global CLAUDE.md to set up/merge on a new machine too. Use only when explicitly asked to set up skills on a new machine, check what skills are installed vs. missing, or "provision"/"redownload my skills."
disable-model-invocation: true
license: MIT
metadata:
  version: 2.0.0
  author: Gladiarn
  repository: https://github.com/Gladiarn/Glad-Personal
---

# Glad Personal — Skill Manifest

This is not a coding-behavior skill. It's a portable record of which skills this user wants installed — their own, plus third-party skills and plugins referenced from their original sources — so a new machine (or a fresh `~/.claude/skills/`) can be brought up to the same state in one pass.

**The list lives in [`references/stack.json`](references/stack.json)** (single source of truth): `own`, `skills` (third-party; `type: "skill"` installs with `npx skills add`, `type: "tool"` has its own installer), `plugins`, `declined`, `notProvisioned`. A human-readable version is in the repository's `catalog/README.md`.

## Known failure mode: never check skill availability from one source only

Confirmed to actually happen (2026-09-16): an agent ran `ls ~/.claude/skills/`, concluded no skill fit, and proceeded without one — when a plugin skill (`superpowers:writing-plans`) matched perfectly. Plugin skills live under `~/.claude/plugins/cache/<marketplace>/<plugin>/` and never appear in `~/.claude/skills/`.

**The fix**: the "available skills" list Claude Code injects into context already merges both sources — trust it. If re-checking manually, always check **both**:
- `~/.claude/skills/` (`npx skills add`-installed and tool-installed skills)
- `~/.claude/plugins/installed_plugins.json` (Claude Code plugins, e.g. `superpowers`, `vercel`)

## How to use this on a new machine

1. Read `references/stack.json`. List what's in `~/.claude/skills/` and `~/.claude/plugins/installed_plugins.json`.
2. Compare. For anything missing:
   - **`own` and `skills` with `type: "skill"`**: run the entry's `install` command with `-g -y -a claude-code` appended. If the repository is cloned, `./install.sh --all` does these in one go — run `./install.sh --all --dry-run` first and show the user.
   - **`type: "tool"`** (compiled binary or Python package installers): show the user the command and get an explicit yes before running it — never run these silently.
   - **`plugins`**: an agent cannot run `/plugin install`. Tell the user the exact command to run themselves.
3. Skip everything under `declined` (rejected on purpose) and `notProvisioned` (host-managed, e.g. `~/.claude/skills/synced/`).
4. **Set up global `CLAUDE.md`**: check whether `~/.claude/CLAUDE.md` exists.
   - **Missing**: copy [`references/CLAUDE.md`](references/CLAUDE.md) to `~/.claude/CLAUDE.md`.
   - **Exists**: read it, then merge in only the sections from the bundled copy that are missing (matched by `# heading`) — never overwrite. Report which sections were added.
   - If the bundled file isn't on disk, say so rather than inventing its content.
5. Report what was installed vs. already present vs. skipped vs. needs the user (plugins, tool installers) vs. what was merged into `CLAUDE.md`. Don't install or write anything without saying so.

**Staleness**: `references/CLAUDE.md` is a point-in-time copy (last synced 2026-10-08). Before relying on it, ask whether the user's live `CLAUDE.md` has newer content worth re-syncing first.

## Plugins differ from skills

Stored in `~/.claude/plugins/cache/…`, namespaced (`superpowers:systematic-debugging`), installed only by the user via `/plugin install`, and **auto-updated** (activated on `/reload-plugins` or the next session). A plugin can change after it was vetted — if its behavior seems off, check whether it updated before assuming the original review was wrong.

## How this user likes new skills vetted (apply before adding anything to stack.json)

- Check the source repo's real account (age, other work, independent references), not just the star count.
- Read the actual `SKILL.md` (and scripts) before installing.
- Flag anything that runs a compiled binary, needs new system dependencies, or can act in the real world (especially browser automation) — confirm before installing.
- Prefer a Python venv over system-wide installs for any Python dependency.

To add a skill: add it to `references/stack.json` (with `vetted`, `notes`, license as the repo declares it), then regenerate the catalog with `node scripts/build-catalog.js` from the repository root.
