---
name: production-readiness
description: Use when asked whether an app, API, or service is production ready, launch ready, or safe to go live; before a first production launch or a major release; or when reviewing security, rate limiting, CI/CD, deployment, scaling, monitoring, error tracking, backups, or disaster recovery for a web application.
license: MIT
metadata:
  version: 1.0.0
  author: Gladiarn
  repository: https://github.com/Gladiarn/Glad-Personal
---

# Production Readiness

## Overview

A production-readiness audit is an **evidence-backed checklist with a hard verdict**, not an opinion. Every item gets a status and the command or file that proved it. Anything not proven is not a pass.

**Core principle:** "Couldn't check" is a finding, not a footnote. Code that looks solid is not enough when backups, alerts, or CI are unproven: the verdict follows the gate, not the overall impression.

## When to Use

- "Is this production ready?" / "Can we launch?" / "What's left before go-live?"
- Before a first production launch, a big release, or handing a system to a client
- Periodic re-audit (re-run the same checklist; compare with the last report)

Not for: a code-correctness review of one change (use a code review), or a deep security audit (this skill calls for one; it does not replace a pen test).

## Process

1. **Map the stack** — read the repo (package manifests, framework config, deploy config, docs) and list: runtime/framework, database, hosting for each service, CI, monitoring. Also read project notes for open risks (roadmap, decisions log, agent memory files, issue list). Note which platform CLIs/MCP tools are available.
2. **Check live config, read-only** — platform settings are not in the repo. Use the platform's CLI/MCP read commands (see `checklist.md` → "Live platform reads"). Never mutate, never print secret values. When a setting's *value* matters (e.g. `NODE_ENV`), prove it by behaviour (a `Secure` flag on a live `Set-Cookie`, production error format) or ask the owner — don't read the variable.
3. **Work every item in `checklist.md`** — all eight areas. Mark items that don't apply `N/A` with the reason (e.g. RLS when the database is reachable only through the API).
4. **Run the cheap commands** — `npm audit` (or equivalent), `npx tsc --noEmit`, `npx eslint` (no `--cache`). Avoid project scripts that write (codegen such as `prisma generate`, build output, caches). If `tsc` fails only because generated code is missing, record it in "Could not check" as "typecheck not run (needs codegen)" — not as a failure. These command results are evidence for the CI and dependency-audit rows, not rows of their own. Run the test suite only if it is fast or the user agrees.
5. **Write the report** in the exact shape of `report-template.md`.
6. **Apply the verdict rule** below. Then offer to turn the gaps into a plan; do not fix anything during the audit.

## Evidence Levels (REQUIRED on every line)

| Level | Meaning | Effect on status |
|---|---|---|
| `VERIFIED` | You checked it yourself: a command, file, config, or live response proves it is there — **or proves it is absent** after you searched everywhere it could be (also used for a justified `N/A`) | Status is what you found (PASS, FAIL, or N/A) |
| `CLAIMED` | Docs, comments, or the owner say so, but you could not confirm it | Never PASS: WARN for normal items, FAIL for gate items |
| `UNKNOWN` | You had no way to look (no access to where the answer lives) and nobody stated it | WARN for normal items, FAIL for gate items |

**Not found ≠ unknown.** Searched the repo, docs and notes and there is no workflow, no runbook, no recorded restore test → `FAIL`, `VERIFIED`. A control the current plan doesn't offer (e.g. GitHub branch protection on a free private repo) is `FAIL`, `VERIFIED` — the protection is absent — with the plan noted.

## Verdict Rule

**GATE items are exactly the ⛔ items in `checklist.md`** (that list wins): password hashing, session/token security, production secret check, every route guarded, secrets out of git, HTTPS + secure cookies, dependency audit, CI runs tests, deploys can't skip CI, written rollback path, error tracking with alerts, uptime monitoring with alerts, backups with known retention, a **tested** restore.

- Any gate item `FAIL` (including CLAIMED/UNKNOWN gates, which are FAIL) → **NOT READY**
- All gates pass, some non-gate `FAIL`/`WARN` → **READY WITH CONDITIONS** (list them, each with an owner/next step)
- Everything passes or is justified `N/A` → **READY**

No "mostly yes", "ready for a careful launch", or percentage scores. Small team or internal app changes the urgency of fixes, not the verdict.

## Report Rules

- Gate rows appear in full in the gate table; in the area tables write `see gate table` in Evidence.
- An item listed under two areas is scored once, in the area that owns it (the other says `see area N`).

## Common Mistakes

| Mistake | Fix |
|---|---|
| Trusting the README for platform settings | Read the live config (replicas, health check, plan, restore window) |
| "Couldn't check" listed at the end, verdict unaffected | A gate that is `UNKNOWN` or only `CLAIMED` is FAIL → NOT READY |
| Backups "exist" because the provider has PITR | Gate needs: retention known **and** a restore actually tested, with a date |
| Narrative report | Use `report-template.md`: table per area, one line per item |
| "Nothing in the docs" marked UNKNOWN | You looked and it isn't there → FAIL |
| Running `npm run typecheck`/`build` in a read-only audit | They may write codegen/caches; use `tsc --noEmit` |
| Fixing things mid-audit | Audit only; offer a plan afterwards |
| Flagging RLS / multi-region / Redis by default | Only when the architecture needs it — otherwise `N/A` with reason |

## Files

- `checklist.md` — every item, by area, with how to verify it (generic + stack-specific commands)
- `report-template.md` — the required output shape
