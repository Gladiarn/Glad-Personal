# Changelog

Versions follow [Semantic Versioning](https://semver.org/) per skill. For `production-readiness`, a new gate item or a change to the verdict rule is a minor or major version; wording and documentation fixes are patches.

## 2026-10-21 — catalog: trimmed overlapping design skills; CLAUDE.md re-synced

- **Moved `frontend-design`, `redesign-existing-projects`, `image-to-code` and `ui-ux-pro-max` from the catalog to `declined`.** All four overlap `impeccable`, which already covers design, redesign, audit, polish and animation, and two of them pull in a different direction: `frontend-design` is a second "be bold" design lead, and `image-to-code` makes generating a mockup image mandatory first. `ui-ux-pro-max` also depends on `${CLAUDE_PLUGIN_ROOT}`, which is not set for skills installed in `~/.claude/skills`. The design set is now `impeccable`, `web-design-guidelines`, `scroll-craft` and `emil-design-eng`.
- **Re-synced `references/CLAUDE.md`** with the live file. New sections: git and GitHub authorship and style (no Claude credit anywhere, conventional commit messages, first-person comments), and "Scroll pages always get Emil", which loads `emil-design-eng` whenever `scroll-craft` is used.
- Third-party skill count is now 19.

## 2026-10-20 — catalog: emil-design-eng

- **Added `emil-design-eng`** ([emilkowalski/skills](https://github.com/emilkowalski/skills), MIT) to the Design catalog, vetted. Referenced, not copied. One plain-text `SKILL.md` (about 670 lines, no scripts or binaries); read in full before install. It covers when to animate, easing and duration by element, press and hover behaviour, springs and a review checklist, and adds nothing on scroll-driven pages (that stays with scroll-craft). Use it on demand for interactive UI. Its easing advice (springs only for gestures) differs from `ui-ux-pro-max`'s "prefer springs"; for ordinary UI follow `emil-design-eng`. Only this skill is installed from that repo, which also holds animate, review-animations and others.

## 2026-10-20 — opus-plan-sonnet-build 1.1.0

- **Final review with superpowers loaded** is now one fresh-context reviewer on Sonnet by default, and on Opus only for the high-risk categories (auth, payments, permissions, schema migrations, large refactors). Before, it always ran on Opus, which contradicted Step 5. Basis: CodeRabbit's review benchmark has Opus catching more hard bugs (about 8–10 of 13 against 6 for Sonnet 5.5), at roughly 60% higher cost per review, so Opus is kept where a missed bug is the expensive failure. Routing checked with 56 minimal-context runs (this skill plus executing-plans only, not the full set). Risky tasks went to Opus 22/22, including 10/10 on tasks the wording was never tuned on. Routine tasks went to Sonnet 6/10 at first, because executing-plans pulls toward the most capable model; after the rule was made explicit, 8/10 on the same tasks but only 5/10 on fresh ones (small UI tweaks such as a tooltip or a footer fix often still got Opus). Known gap: about half of routine reviews still pick Opus, the safe but costlier direction.

## 2026-10-20 — opus-plan-sonnet-build 1.0.1

- Every Opus subagent (planner, plan critique, escalations, high-risk review) is now spawned with effort "high", so the effort no longer depends on a default. Not yet verified in a live run: `/tasks` shows the model but not the effort.

## 2026-10-19 — catalog: scroll-craft

- **Added `scroll-craft`** ([nateherkai/scroll-craft](https://github.com/nateherkai/scroll-craft), MIT) to the Design catalog, vetted. Referenced, not copied; installs from the author's repo. Risk notes in its row: headless Chromium against localhost only (fresh profile, not your browser), ffmpeg and playwright-core needed for verification, optional paid kie.ai generation (reference photos go to kie's official temporary storage, deleted after 24 hours), and `--lan` serving is opt-in.

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
