---
name: glad-personal
description: Personal skill manifest and provisioning guide for this user — lists the global skills they've vetted and want on every machine, with exact install commands, and bundles a copy of their global CLAUDE.md to set up/merge on a new machine too. Use only when explicitly asked to set up skills on a new machine, check what skills are installed vs. missing, or "provision"/"redownload my skills."
disable-model-invocation: true
---

# Glad Personal — Skill Manifest

This is not a coding-behavior skill. It's a portable record of which global skills this user has already vetted and wants installed, so a new machine (or a fresh `~/.claude/skills/`) can be brought up to the same state in one pass.

## Known failure mode: never check skill availability from one source only

Confirmed to actually happen (2026-09-16, a different project's session): an agent reasoning about "does any installed skill apply to this task" ran `ls ~/.claude/skills/`, concluded no skill fit, and proceeded without one — when a plugin-provided skill (`superpowers:writing-plans`) actually matched perfectly. Plugin skills live at `~/.claude/plugins/cache/<marketplace>/<plugin>/`, a completely different path, and will never show up in an `~/.claude/skills/` listing. The agent later caught and corrected this itself, but the miss was real, not a hypothetical risk.

**The fix**: the "available skills" list that Claude Code injects into context (after installs, removals, or a Skill tool call) already merges both sources correctly and is the reliable source of truth — trust it over a manual re-derivation. If actively re-checking what's installed for any reason (not just provisioning a new machine), always check **both**:
- `~/.claude/skills/` (`npx skills add`-installed, plus a few pre-existing ones — see below)
- `~/.claude/plugins/installed_plugins.json` (Claude Code native plugins, e.g. `superpowers`, `vercel`)

A check of only one is a partial check and will produce wrong "no skill applies" conclusions, exactly like the incident above.

## How to use this on a new machine

1. List what's currently in `~/.claude/skills/`, and check installed plugins too (`~/.claude/plugins/installed_plugins.json`) — this user uses both `npx skills add` and Claude Code's native `/plugin install`, see the two tables below.
2. Compare against the "Install" table (npx skills) and "Plugins" table (native Claude Code plugins) below.
3. For anything missing: run the exact `npx skills add` command for entries in the Install table. Plugin entries can't be installed by an agent — tell the user the exact `/plugin install` command to run themselves.
4. Skip anything listed under "Declined" — those were evaluated and rejected on purpose, not overlooked.
5. **Set up global `CLAUDE.md`**: check whether `~/.claude/CLAUDE.md` exists on this machine.
   - **Missing entirely**: copy [`references/CLAUDE.md`](references/CLAUDE.md) (bundled in this skill) to `~/.claude/CLAUDE.md` directly.
   - **Already exists**: read it first, then merge in only the sections from the bundled copy that are missing (matched by `# heading`) — never blindly overwrite a file that might have other machine-specific content the user added since. Report exactly which sections were added.
   - This step needs `npx skills add`-installer to have actually written this reference file to disk for you to read (it will have, as part of installing this skill) — if for some reason it isn't at that path, say so rather than inventing the content from memory.
6. Report what was installed vs. already present vs. skipped vs. needs the user to run a `/plugin install` command themselves vs. what got merged into `CLAUDE.md`; don't silently install/write without saying so.

**Staleness note**: `references/CLAUDE.md` is a point-in-time copy, not a live link — it was last synced 2026-09-16. If the real `~/.claude/CLAUDE.md` on the machine this manifest was authored on has changed since, this bundled copy is behind. When in doubt, or before relying on it for a provisioning run, ask the user whether their live `CLAUDE.md` has newer content worth re-syncing here first.

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
| tdd | mattpocock/skills | `npx skills add https://github.com/mattpocock/skills --skill tdd` | Red-green-refactor. Overlaps with the `superpowers` plugin's `test-driven-development`, kept both intentionally |
| backend-patterns | affaan-m/ECC | `npx skills add https://github.com/affaan-m/ECC --skill backend-patterns` | API/repository/caching/auth patterns, Node/Next-focused |
| grilling | mattpocock/skills | `npx skills add https://github.com/mattpocock/skills --skill grilling` | Auto-triggers on stress-testing/"grill" language |
| grill-me | mattpocock/skills | `npx skills add https://github.com/mattpocock/skills --skill grill-me` | Manual-only alias that forwards to `grilling`; needs `grilling` installed too or it's a dead pointer |
| caveman | juliusbrussee/caveman | `npx skills add https://github.com/juliusbrussee/caveman --skill caveman` | Auto-triggers on "be brief"/"less tokens"/"caveman mode". Only install the `caveman` skill from that repo, not its sibling skills or the separate `@caveman-ai/cli` proxy — neither was requested or vetted |
| ui-ux-pro-max | nextlevelbuilder/ui-ux-pro-max-skill | `npx skills add https://github.com/nextlevelbuilder/ui-ux-pro-max-skill --skill ui-ux-pro-max` | Local searchable design database (palettes, font pairings, icons, GSAP presets, charts) queried via a bundled Python script — no network calls, no subprocess, clean on review. Covers 22 implementation stacks, most of which nothing else in this list touches (SwiftUI, Flutter, Jetpack Compose, WPF, JavaFX, Angular, Laravel, Svelte, Astro) — the rest of this list is essentially React/Next-only. Overlaps partially with `web-design-guidelines` (a11y/UX) and `vercel-react-best-practices` (React perf) but non-conflicting, since both cite the same standard practices. **Trust caveat**: author account (`nextlevelbuilder`) was created the same day as the repo (2025-11-30), under a year old at install time, no independent track record beyond the repo itself — thinner signal than the rest of this list, installed anyway after clean content review |
| glad-frontend | Gladiarn/Glad-Frontend | `npx skills add https://github.com/Gladiarn/Glad-Frontend --skill glad-frontend` | This user's own skill. Scoped narrowly and deliberately to backend-ready data architecture (repository pattern, mock/real swap, loading/error/empty states) — has no opinion on visual design by design; pair with a design skill (impeccable/frontend-design) for that. Originally shipped with design-interview content too, which caused it to overlap with impeccable/frontend-design; stripped down 2026-09-15 after user feedback that the combined version "wasn't good." |
| redesign-existing-projects | leonxlnx/taste-skill | `npx skills add https://github.com/leonxlnx/taste-skill --skill redesign-existing-projects` | Audits/upgrades an *existing* site without breaking functionality — distinct job from building new (that's impeccable/frontend-design's job) |
| full-output-enforcement | leonxlnx/taste-skill | `npx skills add https://github.com/leonxlnx/taste-skill --skill full-output-enforcement` | Stops truncated/placeholder code output. General behavior, not design-specific |
| image-to-code | leonxlnx/taste-skill | `npx skills add https://github.com/leonxlnx/taste-skill --skill image-to-code` | Image-generation-first build workflow. Mostly inert without an image-gen tool available in-session — install anyway for when one is, but don't expect it to do much without one |

Note on the `leonxlnx/taste-skill` repo: it bundles 13 skills total. The 3 above were the only ones judged genuinely non-redundant with what's already on this list — the other 10 (`brandkit`, `brutalist-skill`, `gpt-tasteskill`, `imagegen-frontend-mobile`, `imagegen-frontend-web`, `minimalist-skill`, `soft-skill`, `stitch-skill`, `taste-skill`, `taste-skill-v1`) either duplicate impeccable/frontend-design's anti-slop guidance, need image-gen not available here, or are single-locked-in-aesthetic skills. Don't install the bare repo URL without `--skill <name>` — that just lists all 13, doesn't install anything, but a future CLI version might behave differently.

## Plugins — installed via `/plugin install`, not `npx skills add`

These are Claude Code's own native plugin system — a materially different mechanism from everything in the table above, not just a different command:

- **Storage**: lives at `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/`, not in `~/.claude/skills/` at all. Check `~/.claude/plugins/installed_plugins.json` to see what's installed, not the skills folder.
- **Invocation name**: every skill inside a plugin is namespaced as `<plugin>:<skill-name>` (e.g. `superpowers:systematic-debugging`), never the bare name. It still auto-triggers on its own judgment exactly like an unprefixed global skill — the namespace only matters if invoking it explicitly.
- **An agent cannot run `/plugin install`** — it's an interactive slash command only the user can run themselves. If this manifest is being applied on a new machine, tell the user the exact command and stop there for that entry.
- **Updates are automatic by default**, unlike `npx skills add` skills (which stay frozen until someone explicitly runs `npx skills update`). Specifically: Claude Code auto-refreshes the marketplace catalog in the background after session startup (random delay up to ~10 min), and if auto-update is enabled it downloads/stages new plugin versions automatically — but activating a staged update still needs `/reload-plugins` or the next session start, it doesn't hot-swap mid-session. Manual refresh/update: `/plugin update` or `/plugin marketplace update`. Auto-update can be disabled via the `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` env var. Practical implication: a plugin's content can change without anyone re-reviewing it the way we vetted it at install time — if something in a plugin's behavior seems off, check whether it silently updated before assuming the original review was wrong.

| Plugin | Source | Install command | Notes |
|---|---|---|---|
| superpowers | obra/superpowers, via `claude-plugins-official` marketplace | `/plugin install superpowers@claude-plugins-official` | Supersedes 4 previously-individually-installed skills, removed 2026-09-16 when this plugin was adopted: `systematic-debugging`, `test-driven-development`, `verification-before-completion` (all from the same `obra/superpowers` source, now covered by the plugin), and `skill-creator` (anthropics/skills — replaced by the plugin's `writing-skills`, which does the same job). Also brings 9 new skills not previously installed: `brainstorming`, `dispatching-parallel-agents`, `executing-plans`, `finishing-a-development-branch`, `receiving-code-review`, `requesting-code-review`, `subagent-driven-development`, `using-git-worktrees`, `writing-plans`. **Important**: also includes `using-superpowers`, which forces a skill-check before every single response including clarifying questions — a standing behavior change the user explicitly accepted, not an incidental side effect. Installed 2026-09-15, version 6.3.0 at install time — check `~/.claude/plugins/installed_plugins.json` for the current version, since auto-update may have moved it past this. |
| vercel | `claude-plugins-official` marketplace | `/plugin install vercel@claude-plugins-official` | Predates this vetting process (installed 2026-06-22, before this manifest existed) — present on the original machine but never individually reviewed the way everything else on this page was. Carry it over for parity if it matters to your workflow, but don't treat its presence here as an endorsement the way the rest of this manifest is. |

## Not a skill — don't provision this

`~/.claude/skills/synced/` is **not** a user-installed skill and should never be copied to a new machine or added to this manifest. It's Claude Code's own internal cache for the built-in Anthropic skills bundle (shows up as `anthropic-skills:docs`, `anthropic-skills:docx`, `anthropic-skills:pdf`, `anthropic-skills:pptx`, `anthropic-skills:morning`, `anthropic-skills:import-memory`, `anthropic-skills:skill-creator`, `anthropic-skills:xlsx` in the available-skills list) — host-managed infrastructure that ships with the product itself, not something either of us chose to install. If it ever looks unfamiliar again: no `SKILL.md` at its top level, bucket/UUID-named subdirectories — that's the signature, and it's expected, not a red flag.

## Declined — evaluated and deliberately rejected

| Skill | Source | Reason |
|---|---|---|
| browser-use | browser-use/browser-use | Real CDP browser control (clicks, forms, cookies/sessions) — flagged Med Risk by the installer's own Snyk scan; removed after installing |
| playwright-cli | microsoft/playwright | Same real-browser-control risk category as browser-use, declined before installing despite being an official Microsoft source. Also declined its native installer path (`npm install -g @playwright/cli` then `playwright-cli install --skills -g`) — same skill, same risk, different door |

## Also present but not part of this manifest

`casr`, `dsr`, `graphify`, `process-triage`, `rch`, `sbh`, `use-railway` predate this manifest (already on the original machine before this vetting process started) — carry them over too if setting up a new machine to match, but they weren't vetted through the process above.
