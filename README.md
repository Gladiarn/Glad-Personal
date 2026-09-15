# Glad Personal

A personal [Claude Code / agent skill](https://github.com/vercel-labs/skills) manifest — a portable, self-updating record of which global skills I've vetted and use, with exact install commands, so a new machine (or a fresh `~/.claude/skills/`) can be brought up to the same state in one pass.

This is not a coding-behavior skill. It's read manually or by an agent when setting up a new environment.

## Install

```bash
npx skills add https://github.com/Gladiarn/Glad-Personal --skill glad-personal
```

It's manual-only (`disable-model-invocation: true`) — it never triggers on its own; use it explicitly when provisioning a machine.

## What it contains

- A table of currently recommended skills, each with its source repo and exact `npx skills add` install command
- A table of skills evaluated and deliberately declined (with the reason), so they don't get silently re-considered later
- A short vetting checklist for anything new: check the real account behind a repo (not just star count), read the actual `SKILL.md` before installing, flag anything that runs a compiled binary or grants real-world action capability (especially browser automation), prefer an isolated Python venv over system-wide installs

See [`skills/glad-personal/SKILL.md`](skills/glad-personal/SKILL.md) for the current list.

## License

MIT — see [LICENSE](LICENSE).
