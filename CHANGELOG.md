# Changelog

Versions follow [Semantic Versioning](https://semver.org/) per skill. For `production-readiness`, a new gate item or a change to the verdict rule is a minor or major version; wording and documentation fixes are patches.

## 2026-10-19 — opus-plan-sonnet-build 1.0.0

- **Added `opus-plan-sonnet-build` 1.0.0:** model routing for Claude Code. The main session stays on Sonnet. Opus subagents plan, critique the plan, take hard pieces Sonnet couldn't do, and review high-risk diffs. The build step requires a TDD skill.
- Description tested for triggering against 14 prompts (3 runs each, Sonnet 5.5): 38/42 correct, no false fires on small edits; the first draft scored 18/30. Known gap: bugs that already survived a fix trigger it about one run in three. Trigger test shipped in `evals/`.
- Works with superpowers: when its skills are loaded too, the Opus subagent writes the one `writing-plans` plan (Sonnet only saves it), building runs through `executing-plans` on Sonnet, and there is one final Opus review. Tested with both loaded (5 runs each): without this rule the plan was written twice, by Opus and then rewritten by Sonnet, in 5/5 runs; with it, once by Opus in 5/5.
- Root README: new introduction (the problem, what the repository does about it, who it's for) and badges.

## 2026-10-14 — production-readiness 1.1.0

- **New check (area 2), only if the app receives webhooks:** signature verified on the raw body, and the handler is idempotent (each event ID recorded, repeats skipped), so a provider retry can't charge, credit, or email twice.
- **New check (area 6), only if the app has scheduled or background jobs:** failures reach error tracking/alerts, and a heartbeat monitor notices a job that never runs.
- **Conditional items:** `SKILL.md` now says how to score *Only if…* items. One grep; if the feature isn't there, the row is `N/A — no <feature>`. Apps aren't asked about features they don't have.
- **Static-site rule:** for a site with only static files (no server code, functions, database, logins, or stored form data), server/data/backup/restore checks are `N/A`, the host's one-click rollback passes the rollback gate, and uptime monitoring is a non-gate WARN. HTTPS, secrets, and the dependency audit stay gates. Anything with a backend still gets every check.
- Both new items are non-gate; the gate list stays at 14.
- README: corrected the count (59 checks, not "about 70"); added "It only checks what your app has" and "Static sites get a lighter audit", update/uninstall steps, and the 1.1.0 test round. Sample report shows the new rows.

## 2026-10-08 — repository restructure

Glad-Personal becomes the single home for my skills.

- **Added `production-readiness` 1.0.0** (moved from `Gladiarn/claude-skills`): eight-area production-readiness checklist, 14 gate items, hard verdict (NOT READY / READY WITH CONDITIONS / READY), evidence level on every line (VERIFIED / CLAIMED / UNKNOWN), read-only live platform reads, report template and sample report.
- **Added `glad-frontend` 1.0.0** (moved from `Gladiarn/Glad-Frontend`) with a README.
- **`glad-personal` 2.0.0:** the skill list moved out of `SKILL.md` into `references/stack.json`; now covers my own skills, 21 third-party skills (including the 7 that predate vetting, now with verified sources) and 2 plugins. Added a README.
- **New `install.sh`:** install my skills, the third-party stack, or single skills; dry-run; tool installers opt-in; prints plugin commands.
- **New `catalog/README.md`**, generated from `stack.json` by `scripts/build-catalog.js`.

## Earlier

- 2026-09-30 — vercel plugin entry; `synced/` documented as host infrastructure.
- 2026-09-18 — ui-ux-pro-max added.
- 2026-09-16 — bundled global `CLAUDE.md` with provisioning steps.
- 2026-09-15 — first manifest.
