# Production Readiness Checklist

⛔ = GATE item (see SKILL.md verdict rule). Each item: **what to check** → **how to verify**. Stack-specific commands are examples; use the equivalent for the stack you mapped.

## Live platform reads (read-only)

| Platform | Read commands |
|---|---|
| GitHub | `gh api repos/{owner}/{repo}/branches/{branch}/protection`: 404 "Branch not protected" = unprotected (FAIL, VERIFIED); 403 whose message says upgrade/plan = feature not on this plan (FAIL, VERIFIED); 403 otherwise = no admin access (UNKNOWN). Also `gh api repos/{owner}/{repo}/rulesets`, `ls .github/workflows`, `gh run list --limit 5` |
| Railway | MCP `get-service-config` / `describe-service` (replicas, healthcheck, preDeploy, restart policy, `checkSuites`, variable **names**), `environment-status`. Avoid `list-variables` — it returns values |
| Vercel | `vercel project ls`, `vercel env ls`, `vercel firewall` (rules, attack mode), deployment protection in project settings |
| Neon | `neonctl projects list`, `neonctl projects get <id>` (plan, `history_retention_seconds`), branches list |
| AWS / GCP / Docker / K8s | the equivalent describe/get commands (ECS service desired count, RDS backup retention, `kubectl get deploy,hpa,pdb`) |

If a platform has no CLI/MCP access here, the items that depend on it are `UNKNOWN` — say what access would settle them. "→ ask" items: the owner's answer is `CLAIMED` unless they show proof (a screenshot, a monitor URL, a restore log).

## 1. Authentication

- ⛔ Passwords hashed with bcrypt/argon2/scrypt (cost set); no plaintext or fast hashes → grep the auth code
- ⛔ Session/token: httpOnly + SameSite cookies (the `Secure` flag is scored under the HTTPS gate), or short-lived bearer tokens; JWT verify pins algorithm (+ issuer/audience); refresh tokens hashed and rotated → read token + cookie code
- ⛔ HTTPS everywhere: HTTP redirects to HTTPS, HSTS set, auth cookies `Secure` in production (prove live: `curl -sI http://…` → 301; `curl -sI https://…` → `strict-transport-security`; a live `Set-Cookie` shows `Secure`) 
- ⛔ Production refuses to start without a strong secret (length check, no dev default) → read env/config validation
- Logout / disable / password change revoke access immediately (sessions re-checked) → read auth middleware
- Login brute-force protection → scored in area 3
- Admin accounts: MFA available or a recorded decision not to → read auth code / docs
- Password reset: single-use, expiring, hashed tokens; no user enumeration → read reset flow

## 2. Authorization & application security

- ⛔ Every non-public route requires auth; every write requires a permission → list routers, count routes vs auth/permission guards, read the exceptions
- Tenant/ownership scoping on every query (no IDOR) → grep the scoping helper; read 3–5 detail/update endpoints; tests that cross-tenant access returns 404/403
- Input validation on every route (schema, strict objects, body size limit) → read validation middleware + app setup
- CSRF protection for cookie auth (SameSite + origin check or tokens); CORS allow-list, not `*` with credentials → read app setup
- Security headers: API (helmet or equivalent), frontend CSP / X-Frame-Options / nosniff / Referrer-Policy → read headers config; note `unsafe-inline`
- Errors: no stack traces or internals to clients in production → read error handler
- Raw SQL only with parameters; no user input in `*Unsafe` calls → grep `queryRaw|executeRaw|Unsafe`
- File uploads: type/size checked server-side, signed short-lived URLs, private bucket → read upload code
- ⛔ Secrets not in git → `git ls-files | grep -iE '\.env|secret|key'`; `git log -p -S 'BEGIN PRIVATE KEY' --all | head` (count only)
- Secrets ever pasted/leaked have been rotated → ask / check project notes
- ⛔ Dependency audit: no unaccepted high/critical → `npm audit` (or `pip-audit`, `cargo audit`…); each accepted advisory has a written reason
- Row-level security: `N/A` when only the server talks to the DB; required when clients query the DB directly (Supabase, Firebase, PostgREST)

## 3. Rate limiting & abuse

- Login and password-reset throttled (per account + per IP), with correct client IP behind proxies (`trust proxy` hop count matches the platform) → read auth services + app setup
- General API rate limit (per IP and/or per user) → grep `rate-limit|rateLimit|throttle`; or edge/WAF rules (Vercel firewall, Cloudflare)
- Request size limits; expensive endpoints paginated (`limit` max enforced) → read validators
- Unbounded tables have cleanup (login attempts, sessions, logs) → grep `deleteMany`/cron for each append-only table

## 4. Hosting, deployment, CI/CD & version control

- Version control with protected production branch (no direct pushes, PR required) → `gh api …/protection`
- ⛔ CI runs typecheck, lint, tests (with a real DB if used) on PRs to production → `.github/workflows/*`, `gh run list`
- ⛔ Production deploy cannot skip CI (no CI at all = FAIL; otherwise a required status check, or the platform waits for checks, e.g. Railway `checkSuites: true`) → branch protection + platform config
- Staging environment mirrors production; changes go staging → production → docs + platform environments
- Migrations: run automatically before the new code starts; backwards-compatible (expand → deploy → contract); drift check → deploy config + migration files
- Build is reproducible (lockfile committed; production runs compiled output, not dev runners like `tsx`/`ts-node` unless chosen deliberately) → package.json `start`
- Infra config in code or documented (railway.json/vercel.json/IaC, or a written settings record) → repo files
- ⛔ Rollback path **written down**: the exact steps to restore the previous deploy on each platform, and how migrations affect it (expand-only = safe; after a contract migration = what to do). Platform rollback support alone = FAIL → runbook in repo/docs
- Graceful shutdown on SIGTERM (finish requests, close DB pool) → read server entry

## 5. Caching, CDN, load balancing & scaling

- Static frontend served from a CDN → hosting platform
- Private/authenticated API responses marked `no-store`/`private`; no shared caching of user data → response headers
- DB connections pooled (pooler URL / pool size suited to serverless or replicas) → DB URL host contains pooler / pool config
- Instance count: ≥2 replicas for anything customer-critical, or a recorded decision to accept single-instance downtime → live platform config
- Stateless servers (no in-memory sessions); in-memory caches safe with N instances (or short TTL noted) → grep caches
- Load test at expected peak done, with results → docs / ask
- Autoscaling or headroom plan for growth → platform config / docs

## 6. Error tracking, logs & monitoring

- ⛔ Error tracking on backend **and** frontend (Sentry/Bugsnag/Rollbar/Datadog…) with alerts to a person → grep deps + init code
- ⛔ Uptime monitoring on the health endpoint and the site, alerting a person → ask / check external monitor
- Health endpoint checks the database, not just the process → read health route
- Structured logs with request IDs; secrets/tokens/passwords redacted → read logger setup
- Log retention long enough to investigate incidents (platform plan) → platform docs/config
- Frontend error boundaries (e.g. Next.js `error.tsx` + `global-error.tsx`) → `find app -name 'error.tsx' -o -name 'global-error.tsx'`
- Audit log of user changes for business-critical data → grep audit writes

## 7. Availability & recovery

- ⛔ Database backups/PITR enabled; retention window known (e.g. Neon `history_retention_seconds`, RDS backup retention) → live platform read
- ⛔ A restore has been **tested** (restore to a branch/new instance, app connects, data verified) — record the date → runbook / notes / ask; no record anywhere = FAIL, VERIFIED; owner says yes without a record = CLAIMED (FAIL for this gate)
- Database on a plan that won't suspend/cap production (free tiers that pause compute) → live plan read
- File storage (uploads, invoices) versioned or backed up → bucket config
- Recovery runbook: who does what for "deploy broke prod", "DB corrupted", "provider outage"; RTO/RPO stated → docs
- Health checks + auto-restart configured → platform config
- Single region acceptable for the audience (multi-region only if required) → `N/A` with reason otherwise

## 8. Product & release hygiene

- Features in production are finished (no mock/sample data on live screens) → feature flags / live-area config
- Known open bugs triaged; none blocking money, data, or access → issue list / roadmap
- Legal/data basics where applicable: privacy policy, data retention, PII handling → ask
- Owner named for on-call / incidents → ask
