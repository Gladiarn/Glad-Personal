# Changelog

Versions follow [Semantic Versioning](https://semver.org/) per skill. For `production-readiness`, a new gate item or a change to the verdict rule is a minor or major version; wording and documentation fixes are patches.

## 2026-10-23 — opus-plan-sonnet-build 2.0.0

- **Breaking: the main session is now Opus (medium effort), not Sonnet.** Opus plans inline. The Opus planner subagent and the plan-critique pass are removed.
- **Three routes.** A: small and medium tasks stay entirely on Opus. B: a long build from an approved spec or plan (about 5+ files or 4+ tasks) gets a short plan file (tests and intent, no full code) and goes to one Sonnet subagent at effort "high"; Opus reads the diff and runs the tests. C: visual or interactive work is built inline, and the skill suggests `/model sonnet` for that stretch.
- **Risk review.** Every change touching auth, payments, permissions, data migrations or public endpoints gets an inline attacker reread on Opus. A fresh-context Opus reviewer (effort "medium") is kept only for payments, login/session/token handling and data-rewriting migrations, once per phase.
- **Why:** under 1.x the Opus planner often never ran (2 of 4 real sessions, 1 headless run), and on a small task the skill cost more than Opus alone ($0.48 vs $0.44).
- **Tested:** new `evals/route-test.sh`. Intended route taken 12/12 on 2.0 (3 runs × 4 tasks), against 3/8 on 1.1.2, where every run asked to switch to `/model sonnet`. The description is unchanged, so the trigger results still apply. The cost saving on long builds is still unmeasured.

## 2026-10-23 — opus-plan-sonnet-build 1.1.2

- **First cost measurement (README only, skill behavior unchanged).** One small permissions task, run three ways: Sonnet alone $0.15, Opus alone $0.44, this skill $0.48. No saving on a small task, and the skill did not load unprompted in a headless run (it had to be named). With it, the run ended with the fewest security gaps because the Opus review caught one. The README and the root README now say the saving is unproven instead of "not measured" / "lower cost everywhere else".
- **No hard-coded model versions in `SKILL.md`.** It said "Sonnet 5.5" and "Opus 5.5" in the opening paragraph and two headings; it now says the newest Sonnet and Opus, which is what the `opus` and `sonnet` aliases already resolved to. Meaning unchanged. The README keeps version numbers only where they are accurate records (the pinning example, and which model the trigger tests ran on).

## 2026-10-23 — repository tooling

- **Added `scripts/validate-skills.mjs`** and a GitHub Actions workflow that runs it on every push and pull request. It checks each skill's frontmatter (name matches the folder, description under 1024 characters, license, semver version), that each README states the same version as its `SKILL.md`, that relative links resolve, and that the plugin manifest matches. It caught `opus-plan-sonnet-build`'s README still saying 1.1.0 after the skill moved to 1.1.1; fixed.
- **Added `.claude-plugin/marketplace.json`:** each of the three product skills can now be installed as a Claude Code plugin (`/plugin marketplace add Gladiarn/Glad-Personal`). The existing `npx skills add` and symlink installs are unchanged.
- Added `CONTRIBUTING.md` and `SECURITY.md`.
- **`glad-frontend` (still 1.0.0, `SKILL.md` unchanged):** added a "How it was tested" and a "Limitations" section to its README, a trigger test (`evals/trigger-test.sh`, 14 prompts) and its results. Output test: with the skill, 6 of 6 builds had a repository interface with two implementations, a slow mock that can fail, and loading, error and empty states; without it, 0 of 3 had the interface or the simulated latency and failures, and only 1 of 3 had a loading state and 1 of 3 an error state for loading the data. Trigger test: 42/42 correct, and a shorter description scored the same, so the original was kept. The first no-skill baseline was discarded because the agents loaded the globally installed skill on their own.
- Root README: the claim that every README says how its skill was tested now names the three skills that change agent behavior, which is accurate.

## 2026-10-22 — opus-plan-sonnet-build 1.1.1

- Opus subagents (planner, plan critique, escalations) are spawned at effort "medium", replacing "high" from 1.0.1. Reviewer subagents follow the model decision: Opus reviewer at "medium", Sonnet reviewer at "high".

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
