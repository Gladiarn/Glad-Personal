---
name: opus-plan-sonnet-build
description: "Use whenever a coding task needs a plan or is hard or risky: new features, changes across several files, refactors, auth, payments or data migrations, or a bug that a fix has already failed to solve (load it together with systematic-debugging). Load it alongside planning, brainstorming or TDD skills, never instead of them; it only decides which model does each part. Not for typos, renames, single-file tweaks, config edits or questions about code."
license: MIT
metadata:
  version: 2.1.0
  author: Gladiarn
  repository: https://github.com/Gladiarn/Glad-Personal
---

# Model routing: Opus thinks, Sonnet types the long builds

The main session runs on the newest Opus at medium effort (`/model opus`).
It plans, decides, reviews and does most of the work itself. Sonnet runs only
as a subagent (model "sonnet", effort "high") that executes a long plan Opus
already wrote. Nothing else gets a subagent by default: no planner, no
plan critique and no routine reviewer.

**If the main session is on Sonnet:** tell the user once that this skill
expects `/model opus` for planning and review, then carry on doing everything
in this session.

**Model names:** "opus" and "sonnet" are aliases for the newest models. Keep
passing the aliases; users pin versions with `ANTHROPIC_DEFAULT_OPUS_MODEL` /
`ANTHROPIC_DEFAULT_SONNET_MODEL`.

## Pick the route

| The task | Route |
|---|---|
| Small or medium: a few files, a bug fix, a contained feature | **A. Inline.** This session plans (in its head or a few lines), builds test-first and checks its own work. |
| Long build from an approved spec or agreed plan: about 5+ files or 4+ plan tasks, and mostly mechanical once planned | **B. Plan here, Sonnet builds.** See below. |
| Interactive or visual work the user watches step by step: layout, animation, styling, tuning in the browser | **C. Inline, no plan file.** Suggest once that the user runs `/model sonnet` for the stretch and `/model opus` after. |

Any route that touches auth, payments, permissions, data migrations or public
endpoints also gets the **risk review** below.

## Route B: plan here, Sonnet builds
1. **Write a short plan file** in this session (where writing-plans says, or
   `docs/plans/`). For each task: files, what changes, the tests to write
   first (with edge cases), and acceptance criteria. No full code. Sonnet
   writes the code. About one screen per 5 tasks.
2. **Spawn ONE subagent**, model "sonnet", effort "high". Its brief contains:
   - the plan file path, and that it follows the plan in order without re-planning
   - that it builds test-first with the test-driven-development skill
   - that it must not commit
   - that it stops and reports if a task fails twice or the plan looks wrong
   - its report: files changed, test command and result, deviations from the
     plan, open questions
3. **Check it here:** read the full diff, run the quick tests yourself (heavy
   suites go to the test runner below), and compare against the plan's
   acceptance criteria. Fix small gaps inline. For a large
   miss, continue the same subagent with SendMessage and a precise list.

If the subagent reports it is stuck, take that piece over in this session.

## Heavy test runs: Sonnet runs them, Opus reads the result
On every route, a test run is **heavy** if it needs a browser (Playwright,
WebKit, Cypress, screenshots), a running server or database (API and
integration suites), or produces long logs. Unit tests that finish in
seconds are not heavy: run them here.

Spawn ONE test-runner subagent, model "sonnet", effort "medium", the first
time a heavy run is needed. Its brief contains:
- the exact commands, and how to start the server and the database
- the specs or test files to run
- that it must not edit source or tests; if setup breaks, it reports how
- its report: pass/fail counts, and for each failure the test name, the first
  error lines, and the trace or screenshot path

Write and fix the tests and code here. For every rerun, continue the same
subagent with SendMessage, since its server and context are already warm.

## Risk review
1. **Always, inline:** reread the diff as an attacker and as a hostile input.
   Check every path for authorization: the owner/id checks, missing or null
   ids, and another user's ids. Also check replayed or duplicate requests,
   secrets in code or logs, and partial failure and rollback. Fix what breaks
   the requirement or security. List any other ideas for the user and don't
   build them.
2. **Plus one fresh-context reviewer**, model "opus", effort "medium", only for
   payments, login/session/token handling, or migrations that rewrite existing
   data. Run it once, when the phase ends, on the whole diff.

## With superpowers skills loaded
- **brainstorming:** this session.
- **writing-plans:** this session writes the plan in that skill's format,
  but uses route B's short form: tests and intent, not full code.
- **executing-plans / subagent-driven-development:** for route B, the Sonnet
  subagent above replaces them. Use one subagent for the whole plan, not
  one per task. This session does the checking.
- **Final review:** route B's check plus the risk review replace the
  "most capable model" reviewer, since this session already is that model.

## Bugs a fix already failed to solve
Stay in this session with systematic-debugging. Don't hand them to a subagent.
