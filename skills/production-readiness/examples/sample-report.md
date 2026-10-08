# Production Readiness Report — TableTop Bookings (2026-10-08)

> Example output. TableTop Bookings is a fictional restaurant-booking app used to show the report shape; it is not a real system.

**Verdict: NOT READY**
3 gate items fail: CI does not run before production deploys, there is no error tracking, and a database restore has never been tested.

**Stack:** Next.js frontend → Vercel (CDN) · Express API → Railway (2 replicas, sin) · Postgres → Neon (Launch plan) · CI: GitHub Actions (lint only) · Monitoring: Better Stack uptime
**Access used:** repo, `gh`, Railway MCP, `vercel` CLI, `neonctl`, `npm audit`, `tsc --noEmit`, `curl -sI` · **Not available:** none

## Gate items

| ⛔ Item | Status | Evidence | Level |
|---|---|---|---|
| Password hashing | PASS | `api/src/auth/hash.ts`: argon2id, memory 64 MB | VERIFIED |
| Session/token security | PASS | `api/src/auth/session.ts`: httpOnly, SameSite=Lax; refresh tokens hashed and rotated | VERIFIED |
| HTTPS + secure cookies | PASS | `curl -sI http://api.tabletop.example` → 301; HSTS `max-age=31536000`; live `Set-Cookie … Secure` | VERIFIED |
| Production secret check | PASS | `api/src/env.ts`: refuses `SESSION_SECRET` < 32 chars in production | VERIFIED |
| Every route guarded | PASS | 18 routers; all but `health`, `auth` use `requireUser`; writes use `requireRole` | VERIFIED |
| Secrets not in git | PASS | `git ls-files` → only `.env.example`; no key material in history | VERIFIED |
| Dependency audit | PASS | `npm audit`: 0 high/critical | VERIFIED |
| CI runs tests | FAIL | `.github/workflows/ci.yml` runs `eslint` only — no typecheck, no tests | VERIFIED |
| Deploys can't skip CI | FAIL | Railway `checkSuites: false`; `main` protection has no required checks | VERIFIED |
| Written rollback path | PASS | `docs/runbooks/rollback.md`: Railway redeploy + Vercel instant rollback; expand-only migrations | VERIFIED |
| Error tracking with alerts | FAIL | no Sentry/Bugsnag/Rollbar in either `package.json`; 5xx only in logs | VERIFIED |
| Uptime monitoring with alerts | PASS | Better Stack monitors on `/health` and the site, alerting on-call by SMS (dashboard shown) | VERIFIED |
| Backups with known retention | PASS | `neonctl projects get`: `history_retention_seconds: 604800` (7 days) | VERIFIED |
| Tested restore | FAIL | no restore test in runbooks, docs, or notes | VERIFIED |

## By area

### 1. Authentication
| Item | Status | Evidence | Level |
|---|---|---|---|
| ⛔ Password hashing | PASS | see gate table | VERIFIED |
| ⛔ Session/token security | PASS | see gate table | VERIFIED |
| ⛔ HTTPS + secure cookies | PASS | see gate table | VERIFIED |
| ⛔ Production secret check | PASS | see gate table | VERIFIED |
| Revocation on logout/disable | PASS | session row checked on every request (`requireUser`) | VERIFIED |
| Login brute-force protection | — | scored in area 3 | — |
| Admin MFA | WARN | no MFA and no recorded decision | VERIFIED |
| Password reset | PASS | single-use hashed tokens, 30 min expiry, same reply for unknown emails | VERIFIED |

### 3. Rate limiting & abuse
| Item | Status | Evidence | Level |
|---|---|---|---|
| Login/reset throttling + proxy IP | PASS | `express-rate-limit` on `/auth/*`; `trust proxy` = 1 matches Railway | VERIFIED |
| General API rate limit | PASS | 300 req/min per user (`api/src/app.ts`) | VERIFIED |
| Size limits + pagination caps | PASS | 200 kb body limit; `limit` max 100 | VERIFIED |
| Unbounded table cleanup | FAIL | `audit_events` grows forever; no retention job | VERIFIED |

### 5. Caching, CDN, load balancing & scaling
| Item | Status | Evidence | Level |
|---|---|---|---|
| Static frontend on CDN | PASS | `x-vercel-cache: HIT` | VERIFIED |
| Private API responses not cached | PASS | global `Cache-Control: private, no-store` | VERIFIED |
| Connection pooling | PASS | DB host is the Neon pooler endpoint | VERIFIED |
| ≥2 replicas | PASS | Railway `numReplicas: 2` | VERIFIED |
| Load test at peak | WARN | team says 200 concurrent users were tested; no results file | CLAIMED |

<!-- Areas 2, 4, 6, 7 and 8 follow the same shape in a real report. -->

## What to do next

**Before launch (gates):**
1. CI — add typecheck and tests (with a Postgres service) to `ci.yml`; make it a required check on `main`; set Railway `checkSuites: true`.
2. Error tracking — add Sentry to the API error handler and Next.js (`instrumentation.ts`, `global-error.tsx`); alert the on-call channel.
3. Restore test — restore the production branch to a Neon branch from yesterday, point a local API at it, verify bookings, record the date in `docs/runbooks/restore.md`.

**Conditions (soon after):**
1. Retention job for `audit_events` (keep 1 year).
2. Save the load-test script and results in the repo.

**Later / by choice:**
- MFA for admin accounts.

## Could not check
- none
