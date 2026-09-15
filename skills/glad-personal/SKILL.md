---
name: glad-personal
description: Personal skill manifest and provisioning guide for this user — lists the global skills they've vetted and want on every machine, with exact install commands. Use only when explicitly asked to set up skills on a new machine, check what skills are installed vs. missing, or "provision"/"redownload my skills."
disable-model-invocation: true
---

# Glad Personal — Skill Manifest

This is not a coding-behavior skill. It's a portable record of which global skills this user has already vetted and wants installed, so a new machine (or a fresh `~/.claude/skills/`) can be brought up to the same state in one pass.

## How to use this on a new machine

1. List what's currently in `~/.claude/skills/`.
2. Compare against the "Install" table below.
3. For anything missing, run its exact install command (each is `npx skills add <repo> --skill <name>`).
4. Skip anything listed under "Declined" — those were evaluated and rejected on purpose, not overlooked.
5. Report what was installed vs. already present vs. skipped; don't silently install without saying so.

## How this user likes new skills vetted (apply this before adding anything not already on this list)

- Check the source repo: real GitHub account (age, followers, other work), not just a high star count — star counts in this ecosystem can be very high very fast even when legitimate, so corroborate independently (press coverage, other devs referencing it, a known maintainer) rather than trusting stars alone.
- Actually read the `SKILL.md` content before installing, not just the description.
- Flag anything that installs/runs a compiled binary, requires new system dependencies, or grants real-world action capability (especially browser automation — clicking, form submission, cookie/session access). Treat that category as materially riskier than a plain-text guidance skill, and confirm before installing.
- Prefer a Python venv (not system pip, not `--break-system-packages`) for any Python dependency a skill needs.

## Install — currently recommended

| Skill | Source | Install command | Notes |
|---|---|---|---|
| impeccable | pbakaus/impeccable | `npx skills add https://github.com/pbakaus/impeccable --skill impeccable` | Full design workflow; runs a bundled binary launcher (`impeccable context`) once per session |
| frontend-design | anthropics/skills | `npx skills add https://github.com/anthropics/skills --skill frontend-design` | Official Anthropic; anti-generic-AI-look design principles |
| web-design-guidelines | vercel-labs/agent-skills | `npx skills add https://github.com/vercel-labs/agent-skills --skill web-design-guidelines` | Official Vercel; a11y/UX compliance checklist, fetches live rules doc |
| vercel-react-best-practices | vercel-labs/agent-skills | `npx skills add https://github.com/vercel-labs/agent-skills --skill vercel-react-best-practices` | 70 React/Next.js perf rules |
| tdd | mattpocock/skills | `npx skills add https://github.com/mattpocock/skills --skill tdd` | Red-green-refactor |
| test-driven-development | obra/superpowers | `npx skills add https://github.com/obra/superpowers --skill test-driven-development` | Overlaps with `tdd`, kept both intentionally |
| systematic-debugging | obra/superpowers | `npx skills add https://github.com/obra/superpowers --skill systematic-debugging` | Root-cause-before-fixes methodology |
| verification-before-completion | obra/superpowers | `npx skills add https://github.com/obra/superpowers --skill verification-before-completion` | No success claims without running verification |
| backend-patterns | affaan-m/ECC | `npx skills add https://github.com/affaan-m/ECC --skill backend-patterns` | API/repository/caching/auth patterns, Node/Next-focused |
| grilling | mattpocock/skills | `npx skills add https://github.com/mattpocock/skills --skill grilling` | Auto-triggers on stress-testing/"grill" language |
| grill-me | mattpocock/skills | `npx skills add https://github.com/mattpocock/skills --skill grill-me` | Manual-only alias that forwards to `grilling`; needs `grilling` installed too or it's a dead pointer |
| skill-creator | anthropics/skills | `npx skills add https://github.com/anthropics/skills --skill skill-creator` | Official Anthropic; for building/evaluating new skills |
| caveman | juliusbrussee/caveman | `npx skills add https://github.com/juliusbrussee/caveman --skill caveman` | Auto-triggers on "be brief"/"less tokens"/"caveman mode". Only install the `caveman` skill from that repo, not its sibling skills or the separate `@caveman-ai/cli` proxy — neither was requested or vetted |

## Experimental — not currently recommended

| Skill | Source | Status |
|---|---|---|
| glad-frontend (formerly frontend-ready) | github.com/Gladiarn/Glad-Frontend, skill `glad-frontend` | Paused as of 2026-09-15 — user feedback was "not good enough." Left installed on the original machine but do not auto-reinstall on a new one without asking first. |

## Declined — evaluated and deliberately rejected

| Skill | Source | Reason |
|---|---|---|
| browser-use | browser-use/browser-use | Real CDP browser control (clicks, forms, cookies/sessions) — flagged Med Risk by the installer's own Snyk scan; removed after installing |
| playwright-cli | microsoft/playwright | Same real-browser-control risk category as browser-use, declined before installing despite being an official Microsoft source |

## Also present but not part of this manifest

`casr`, `dsr`, `graphify`, `process-triage`, `rch`, `sbh`, `use-railway` predate this manifest (already on the original machine before this vetting process started) — carry them over too if setting up a new machine to match, but they weren't vetted through the process above.
