# production-readiness

An agent skill that answers **"Is this app ready for production?"** with an evidence-backed audit and a hard verdict, instead of a vague "looks good".

It checks the things that actually take production systems down — not only the code, but the live platform settings, CI, monitoring, and backups — and tells you exactly what is missing before you launch.

```
Verdict: NOT READY
3 gate items fail: no CI before production deploys, no error tracking, restore never tested.
```

- **Version:** 1.0.0 · **License:** MIT · **Works with:** Claude Code and any agent that loads `SKILL.md` skills ([Agent Skills spec](https://agentskills.io/specification))

---

## What it checks

Eight areas, about 70 checks, each with how to verify it:

| Area | Examples |
|---|---|
| 1. Authentication | password hashing, cookie/JWT security, secret validation at boot, session revocation, reset flow |
| 2. Authorization & app security | every route guarded, tenant scoping (IDOR), validation, CSRF/CORS, security headers, secrets in git, dependency audit |
| 3. Rate limiting & abuse | login/reset throttling, general API rate limit, proxy IP handling, unbounded tables |
| 4. Hosting, deploys, CI/CD | protected branches, CI before deploy, migrations, reproducible builds, rollback runbook, graceful shutdown |
| 5. Caching, CDN, scaling | CDN, no caching of private data, connection pooling, replicas, stateless servers, load testing |
| 6. Error tracking & logs | error tracking with alerts, uptime monitoring, health checks, structured/redacted logs, error boundaries |
| 7. Availability & recovery | backup retention, **tested** restore, DB plan limits, file storage backup, recovery runbook |
| 8. Product & release hygiene | no mock data on live screens, open bugs triaged, privacy basics, on-call owner |

Full list: [`checklist.md`](checklist.md).

### Gate items decide the verdict

14 items are **gates** (⛔ in the checklist): auth basics, every route guarded, secrets out of git, HTTPS + secure cookies, dependency audit, CI runs tests, deploys can't skip CI, written rollback path, error tracking, uptime monitoring, backup retention, and a tested restore.

| Result | Verdict |
|---|---|
| Any gate fails or can't be proven | **NOT READY** |
| All gates pass, some other items fail or warn | **READY WITH CONDITIONS** (each with a next step) |
| Everything passes or is justified N/A | **READY** |

No percentages, no "mostly ready".

### Evidence on every line

| Level | Meaning |
|---|---|
| `VERIFIED` | The agent proved it — by a command, a file, a live response — or proved it is absent |
| `CLAIMED` | Docs or the owner say so, but it couldn't be confirmed (never a pass) |
| `UNKNOWN` | The agent had no way to look (never a pass) |

"Could not check" is a finding, not a footnote.

## Install

**Into a project or your user skills, with the skills CLI:**

```bash
npx skills add https://github.com/Gladiarn/Glad-Personal --skill production-readiness
```

**Globally for Claude Code, from a clone** (updates with `git pull`):

```bash
git clone https://github.com/Gladiarn/Glad-Personal ~/Glad-Personal
mkdir -p ~/.claude/skills
ln -s ~/Glad-Personal/skills/production-readiness ~/.claude/skills/production-readiness
```

**Per project only:** copy this folder to `<project>/.claude/skills/production-readiness/` and commit it.

**Other agents:** copy the folder into the agent's skills directory (for example `~/.agents/skills/`), or paste `SKILL.md` plus the two companion files into the agent's instructions.

## Use

Ask in plain words — the skill triggers on its own:

> Is this production ready?
> What's left before we go live?
> Audit our deployment, monitoring and backups.

Or call it directly in Claude Code: `/production-readiness`.

The agent will map your stack, read the live platform settings it has access to, work through the checklist, and write the report in the shape of [`report-template.md`](report-template.md). See a full example in [`examples/sample-report.md`](examples/sample-report.md).

### Give it access for a better audit

The repo alone can't show replicas, backup retention, or branch protection. The more read access the agent has, the fewer `UNKNOWN` lines:

| Platform | What helps |
|---|---|
| GitHub | `gh` CLI signed in (branch protection, workflows, runs) |
| Railway | Railway MCP server or CLI |
| Vercel | `vercel` CLI signed in |
| Neon / Supabase / RDS | `neonctl`, provider CLI, or console screenshots |
| Others (AWS, GCP, Docker, Kubernetes) | the provider's describe/get commands |

## Safety

The audit is **read-only by design**:

- It never edits code, changes settings, deploys, or restarts anything.
- It never prints secret values — variable *names* only; settings whose value matters are proven by behaviour (for example a `Secure` flag on a live cookie).
- It avoids project scripts that write files (codegen, builds, caches) and runs `tsc --noEmit` / `eslint` directly.
- It does not run your test suite unless it is fast or you agree.

Fixing is a separate step: at the end it offers to turn the gaps into a plan.

## Customizing

- **Your own gates:** mark extra checklist items with ⛔ — the verdict rule treats every ⛔ item as a gate.
- **Your stack:** add rows to "Live platform reads" in `checklist.md` with your provider's read commands.
- **Not applicable:** items such as row-level security, multi-region, or Redis are only required when your architecture needs them; otherwise the report marks them `N/A` with the reason.

## Limitations

- It is an audit, not a penetration test or a line-by-line security review — it will tell you when you need one.
- Platform checks depend on the access you give it; without access, gate items become `UNKNOWN` and the verdict is NOT READY until someone confirms them.
- The checklist leans toward web apps and APIs (Node/TypeScript examples, with generic equivalents); mobile apps and data pipelines need extra items.

## How it was tested

Built test-first, following the [writing-skills](https://github.com/obra/superpowers) method:

1. **Baseline (no skill):** an agent auditing a real production CRM said "mostly yes, ready for a careful launch", relied on docs instead of live settings, and mixed verified findings with guesses.
2. **With the skill:** the same audit read the live hosting, CI and GitHub settings, tagged every line, and returned **NOT READY** with the six deciding gaps.
3. **Rule tests:** fresh agents applied the rules to ten edge cases (missing CI, owner claims without proof, free-plan limits, missing codegen, N/A items). Two rounds of wording fixes later, every case produced the intended status and verdict.

## Files

| File | Purpose |
|---|---|
| `SKILL.md` | The instructions the agent follows |
| `checklist.md` | Every check, by area, with how to verify it |
| `report-template.md` | The required report shape |
| `examples/sample-report.md` | A complete example report (fictional app) |
| `LICENSE` | MIT |

## Changelog

See [CHANGELOG.md](../../CHANGELOG.md) in the repository root.
