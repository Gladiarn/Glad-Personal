# Changelog

Versions follow [Semantic Versioning](https://semver.org/) per skill. For `production-readiness`, a new gate item or a change to the verdict rule is a minor or major version; wording and documentation fixes are patches.

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
