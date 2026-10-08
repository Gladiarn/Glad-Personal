# Catalog — every skill and plugin in this setup

<!-- Generated from skills/glad-personal/references/stack.json by scripts/build-catalog.js. Edit stack.json, not this file. -->

Last updated: **2026-10-08**. Third-party entries are **references** to their original authors' repositories — install them from there; nothing is copied into this repo. Licenses are as each repository declares them ("see repo" = the repo has no standard license file; check before redistributing).

**Install everything:** `./install.sh --all` (add `--with-tools` for the tool installers) · **One item:** `./install.sh --skill <name>` or the command in its row.

Status: ✅ vetted = reviewed with the checklist below before installing · ⚪ not vetted = carried over from before the vetting process.

## My skills

| Skill | What it does | Install |
|---|---|---|
| [**glad-frontend**](../skills/glad-frontend/) | Backend-ready frontend data architecture: repository pattern, swappable mock/real data, real loading/error/empty states. | `npx skills add https://github.com/Gladiarn/Glad-Personal --skill glad-frontend` |
| [**production-readiness**](../skills/production-readiness/) | Evidence-backed production readiness audit with a hard verdict (NOT READY / READY WITH CONDITIONS / READY). | `npx skills add https://github.com/Gladiarn/Glad-Personal --skill production-readiness` |
| [**glad-personal**](../skills/glad-personal/) | This manifest as a skill: provisions a new machine with the skills and plugins below and sets up the global CLAUDE.md. | `npx skills add https://github.com/Gladiarn/Glad-Personal --skill glad-personal` |

## Third-party skills

### Design

| Skill | What it does | Source · License | Status | Install | Notes |
|---|---|---|---|---|---|
| **impeccable** | Full design workflow: shape, critique, audit, polish and harden interfaces. | [pbakaus/impeccable](https://github.com/pbakaus/impeccable) · Apache-2.0 | ✅ vetted | `npx skills add https://github.com/pbakaus/impeccable --skill impeccable` | Runs a bundled binary launcher (`impeccable context`) once per session. |
| **frontend-design** | Official Anthropic design principles that avoid the generic AI look. | [anthropics/skills](https://github.com/anthropics/skills) · see repo | ✅ vetted | `npx skills add https://github.com/anthropics/skills --skill frontend-design` |  |
| **web-design-guidelines** | Official Vercel accessibility and UX compliance review. | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) · see repo | ✅ vetted | `npx skills add https://github.com/vercel-labs/agent-skills --skill web-design-guidelines` | Fetches the live rules document when it runs. |
| **ui-ux-pro-max** | Local searchable design database (palettes, font pairings, icons, GSAP presets, charts) covering 22 stacks. | [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) · MIT | ✅ vetted | `npx skills add https://github.com/nextlevelbuilder/ui-ux-pro-max-skill --skill ui-ux-pro-max` | Queried through a bundled Python script; no network calls. Trust caveat: the author account was created the same day as the repo (2025-11-30) — installed after a clean content review. |
| **redesign-existing-projects** | Audits and upgrades an existing site without breaking functionality. | [leonxlnx/taste-skill](https://github.com/leonxlnx/taste-skill) · MIT | ✅ vetted | `npx skills add https://github.com/leonxlnx/taste-skill --skill redesign-existing-projects` | Only 3 of the 13 skills in this repo are used; install with --skill, never the bare repo. |
| **image-to-code** | Image-generation-first website build workflow. | [leonxlnx/taste-skill](https://github.com/leonxlnx/taste-skill) · MIT | ✅ vetted | `npx skills add https://github.com/leonxlnx/taste-skill --skill image-to-code` | Mostly inert unless an image-generation tool is available in the session. |

### Frontend

| Skill | What it does | Source · License | Status | Install | Notes |
|---|---|---|---|---|---|
| **vercel-react-best-practices** | About 70 React and Next.js performance rules from Vercel. | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) · see repo | ✅ vetted | `npx skills add https://github.com/vercel-labs/agent-skills --skill vercel-react-best-practices` |  |

### Backend

| Skill | What it does | Source · License | Status | Install | Notes |
|---|---|---|---|---|---|
| **backend-patterns** | API, repository, caching and auth patterns for Node, Express and Next.js. | [affaan-m/ECC](https://github.com/affaan-m/ECC) · MIT | ✅ vetted | `npx skills add https://github.com/affaan-m/ECC --skill backend-patterns` |  |
| **use-railway** | Official Railway skill: deploys, services, variables, logs, metrics, recovery. | [railwayapp/railway-skills](https://github.com/railwayapp/railway-skills) · MIT | ⚪ not vetted | `npx skills add https://github.com/railwayapp/railway-skills --skill use-railway` | Predates the vetting process. |

### Workflow

| Skill | What it does | Source · License | Status | Install | Notes |
|---|---|---|---|---|---|
| **tdd** | Red-green-refactor test-driven development. | [mattpocock/skills](https://github.com/mattpocock/skills) · MIT | ✅ vetted | `npx skills add https://github.com/mattpocock/skills --skill tdd` | Overlaps with superpowers' test-driven-development; both kept on purpose. |
| **grilling** | Stress-tests a plan or decision by grilling you about it. | [mattpocock/skills](https://github.com/mattpocock/skills) · MIT | ✅ vetted | `npx skills add https://github.com/mattpocock/skills --skill grilling` | Triggers on 'grill' language. |
| **grill-me** | Manual alias that forwards to grilling. | [mattpocock/skills](https://github.com/mattpocock/skills) · MIT | ✅ vetted | `npx skills add https://github.com/mattpocock/skills --skill grill-me` | Needs grilling installed too. |
| **full-output-enforcement** | Stops truncated or placeholder code in answers. | [leonxlnx/taste-skill](https://github.com/leonxlnx/taste-skill) · MIT | ✅ vetted | `npx skills add https://github.com/leonxlnx/taste-skill --skill full-output-enforcement` |  |
| **caveman** | Ultra-brief answer mode to save tokens. | [juliusbrussee/caveman](https://github.com/juliusbrussee/caveman) · Apache-2.0 | ✅ vetted | `npx skills add https://github.com/juliusbrussee/caveman --skill caveman` | Install only the caveman skill — not its sibling skills or the @caveman-ai/cli proxy. |
| **find-skills** | Searches the skills directory for skills that fit a task. | [vercel-labs/skills](https://github.com/vercel-labs/skills) · MIT | ⚪ not vetted | `npx skills add https://github.com/vercel-labs/skills --skill find-skills` | Installed with the skills CLI itself; predates the vetting process. |

### Dev tools

| Skill | What it does | Source · License | Status | Install | Notes |
|---|---|---|---|---|---|
| **dsr** | Fallback release infrastructure when GitHub Actions is throttled. | [Dicklesworthstone/doodlestein_self_releaser](https://github.com/Dicklesworthstone/doodlestein_self_releaser) · see repo | ⚪ not vetted | `npx skills add https://github.com/Dicklesworthstone/doodlestein_self_releaser --skill dsr` | Drives the dsr command-line tool; install the tool from the repo for it to do anything. |
| **rch** | Offloads cargo/gcc/bun builds to remote workers. | [Dicklesworthstone/remote_compilation_helper](https://github.com/Dicklesworthstone/remote_compilation_helper) · see repo | ⚪ not vetted | `npx skills add https://github.com/Dicklesworthstone/remote_compilation_helper --skill rch` | Drives the rch command-line tool; install the tool from the repo for it to do anything. |
| **sbh** | Disk-pressure defense: ballast files, cleanup, emergency mode. | [Dicklesworthstone/storage_ballast_helper](https://github.com/Dicklesworthstone/storage_ballast_helper) · see repo | ⚪ not vetted | `npx skills add https://github.com/Dicklesworthstone/storage_ballast_helper --skill sbh` | Drives the sbh command-line tool; install the tool from the repo for it to do anything. |
| **casr** *(tool installer)* | Converts and resumes sessions across Claude Code, Codex, Gemini and other agents. | [Dicklesworthstone/cross_agent_session_resumer](https://github.com/Dicklesworthstone/cross_agent_session_resumer) · see repo | ⚪ not vetted | `curl -fsSL https://raw.githubusercontent.com/Dicklesworthstone/cross_agent_session_resumer/main/install.sh \| bash` | Not in the skills directory: its own installer downloads a compiled binary and writes the skill. Read the installer first. |
| **process-triage** *(tool installer)* | Finds runaway processes and suggests safe fixes (the pt command). | [Dicklesworthstone/process_triage](https://github.com/Dicklesworthstone/process_triage) · see repo | ⚪ not vetted | `curl -fsSL https://raw.githubusercontent.com/Dicklesworthstone/process_triage/main/install.sh \| bash` | Not in the skills directory: its own installer downloads a compiled binary and writes the skill. Read the installer first. |
| **graphify** *(tool installer)* | Turns code, docs, papers and media into a queryable knowledge graph (/graphify). | [safishamsi/graphify](https://github.com/safishamsi/graphify) · Apache-2.0 | ⚪ not vetted | `uv tool install graphifyy && graphify install` | Python package; `graphify install` registers the skill. Use `pipx install graphifyy` if uv isn't available. |

## Plugins (Claude Code `/plugin install`)

Plugins are a different mechanism from `npx skills add`: they live in `~/.claude/plugins/`, their skills are namespaced (`superpowers:brainstorming`), they **auto-update**, and only you can install them — run the command inside Claude Code.

| Plugin | What it does | Source · License | Status | Install | Notes |
|---|---|---|---|---|---|
| **superpowers** | Process skills: brainstorming, writing and executing plans, TDD, systematic debugging, code review, verification, writing skills. | [obra/superpowers](https://github.com/obra/superpowers) · MIT | ✅ vetted | `/plugin install superpowers@claude-plugins-official` | Includes using-superpowers, which makes the agent check skills before every response — an accepted behaviour change. Auto-updates. |
| **vercel** | Vercel platform skills: deploys, env vars, Next.js, AI SDK, functions, storage, firewall. | [Claude Code official plugin marketplace](https://docs.anthropic.com/en/docs/claude-code/plugins) · see marketplace | ⚪ not vetted | `/plugin install vercel@claude-plugins-official` | Predates the vetting process. Auto-updates. |

## Declined — evaluated and rejected on purpose

| Skill | Source | Reason |
|---|---|---|
| browser-use | browser-use/browser-use | Real browser control (clicks, forms, cookies/sessions); flagged Med Risk by the installer's own Snyk scan; removed after installing. |
| playwright-cli | microsoft/playwright | Same real-browser-control risk category; declined before installing, including its native installer path. |

## Never provision

- `~/.claude/skills/synced/` — Claude Code's own cache of the built-in Anthropic skills (anthropic-skills:*). Host-managed — never copy it.

## How new skills get vetted

Before anything is added to this catalog:

1. **Check the author**, not just the stars — account age, other work, independent references.
2. **Read the actual `SKILL.md`** (and any scripts), not just the description.
3. **Flag risk:** anything that runs a compiled binary, needs new system dependencies, or can act in the real world (especially browser automation) needs an explicit yes.
4. **Python dependencies** go in a virtual environment, never system-wide.

To add one: add an entry to `skills/glad-personal/references/stack.json`, run `node scripts/build-catalog.js`, and commit both files.
