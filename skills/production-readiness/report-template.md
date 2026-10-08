# Production Readiness Report — <project> (<date>)

**Verdict: NOT READY | READY WITH CONDITIONS | READY**
<One sentence: the deciding reason (e.g. "2 gate items fail: no error tracking, restore never tested").>

**Stack:** <frontend → host>, <API → host, replicas>, <DB → provider/plan>, <CI>, <monitoring>
**Access used:** <repo, gh, railway MCP, vercel CLI, neonctl …> · **Not available:** <…>

## Gate items

| ⛔ Item | Status | Evidence | Level |
|---|---|---|---|
| Password hashing | PASS | `backend/src/auth/passwords.ts`: bcrypt cost 12 | VERIFIED |
| CI runs tests | FAIL | no `.github/workflows` (listed the repo root) | VERIFIED |
| Deploys can't skip CI | FAIL | Railway prod `checkSuites: false`; GitHub branch protection 403 "upgrade" (free plan) | VERIFIED |
| Backups with known retention | FAIL | provider console/CLI not available | UNKNOWN |
| Tested restore | FAIL | no restore test in repo, docs, or notes | VERIFIED |
| … one row per ⛔ item in checklist.md (14 rows) … | | | |

## By area

One table per area (1–8 from `checklist.md`), same columns, one row per checklist item. Gate rows say `see gate table`; items owned by another area say `see area N`. Use `N/A — <reason>` for items that don't apply. Level is VERIFIED, CLAIMED, or UNKNOWN.

### 1. Authentication
| Item | Status | Evidence | Level |
|---|---|---|---|

<!-- repeat for areas 2–8 -->

## What to do next

**Before launch (gates):**
1. <item> — <concrete fix> — <owner/where>

**Conditions (soon after):**
1. <item> — <fix>

**Later / by choice:**
- <item>

## Could not check
- <item> — <what access or person would settle it>
