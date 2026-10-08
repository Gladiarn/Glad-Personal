# glad-frontend

A frontend **data-architecture** skill: it makes every page, table, list, dashboard or form **backend-ready by construction**, so swapping mock data for the real API later changes one file — never the UI.

- **Version:** 1.0.0 · **License:** MIT · **Works with:** Claude Code and any agent that loads `SKILL.md` skills
- **Scope:** data flow only. It has no opinion on visual design — pair it with a design skill such as `frontend-design`, `impeccable` or `web-design-guidelines`.

## The problem it solves

By default, agents hardcode display data straight into JSX (`<td>Alice</td>`). That works today and costs a rebuild tomorrow: when the backend arrives, someone must find every literal and rewire the data flow without breaking the layout. glad-frontend prevents that from the first line.

## What it enforces

1. **Types first** — the data shape is defined before any UI.
2. **A repository interface** the UI always talks to (`findAll`, `findById`, …).
3. **Two implementations** with the same contract: a mock now, a real API client later — switching is a one-line binding change.
4. **Realistic mock behaviour** — simulated latency, realistic varied data (not "Item 1"), and the ability to trigger errors and empty results.
5. **Loading, error and empty states** that are genuinely exercised, not just written.
6. **No hardcoded display data** anywhere — a checklist runs before UI work is called finished.

It uses the same vocabulary as the Repository Pattern in `backend-patterns`, so frontend and backend stay consistent.

## When it triggers

Automatically, when you ask to build a page, component, table, list, dashboard or form **before the backend exists**, or say you want the UI "ready to plug in the backend later".

## Install

```bash
npx skills add https://github.com/Gladiarn/Glad-Personal --skill glad-frontend
```

Or install everything from this repository: see the [main README](../../README.md).

## Example

> I'm building a Next.js admin dashboard. Build a page with a table of customer orders (id, customer, total, status). We don't have the API yet, but I want it ready to plug in later without rewriting the page.

With glad-frontend, the result is an `Order` type, an `OrderRepository` interface, a `MockOrderRepository` with realistic data and latency, a hook the table reads from, and handled loading/error/empty states — with no rows written into the JSX.

## Pairs well with

| Skill | For |
|---|---|
| `frontend-design` / `impeccable` | how the UI should look |
| `web-design-guidelines` | accessibility and UX review |
| `backend-patterns` | the matching repository pattern on the server |

## Files

| File | Purpose |
|---|---|
| `SKILL.md` | Instructions the agent follows |
| `evals/evals.json` | Test prompts with expected outcomes, used to check the skill still behaves as intended |
| `LICENSE` | MIT |

## History

Originally shipped with design-interview content as well, which overlapped with design skills. Narrowed to data architecture only on 2026-09-15 so it stays useful whichever design skill you pair it with.
