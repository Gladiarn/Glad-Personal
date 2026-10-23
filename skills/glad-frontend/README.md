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

## How it was tested

Two things were tested: whether the skill changes what gets built, and whether its description makes an agent load it at the right time. Both ran on Sonnet 5.5 in October 2026.

**Does it change the output?** The three prompts in `evals/evals.json` were built in an empty Next.js (App Router, TypeScript) project, once without the skill and once with it. The no-skill runs used a session with no skills installed. A first attempt at the baseline was thrown away because the agents loaded this skill on their own from the global install.

| Check | Without the skill (3 runs) | With the skill (6 runs) |
|---|---|---|
| Repository interface with a mock and a real implementation | 0 of 3 (one function with an env switch inside it) | 6 of 6 |
| Simulated latency and injectable failures in the mock | 0 of 3 | 6 of 6 |
| Loading state | 1 of 3 (a `loading.tsx` over a mock that never delays, so it is never seen) | 6 of 6 |
| Error state for loading the data | 1 of 3 (the product grid has none; the team list only handles remove errors) | 6 of 6 |
| Empty state | 3 of 3 | 6 of 6 |
| A component imports the mock data directly | 0 of 3 | 0 of 6 |

In the six with-skill runs, three were told to read the skill and three loaded it by themselves.

**Does the description trigger?** 14 prompts, 3 runs each, in a fresh tool-less session that sees this description next to eight neighbouring skills: 6 prompts that should load it (the three eval prompts and three new ones) and 8 that should not (a typo, a style tweak, rate limiting, a Prisma migration, a production crash, a finished-copy landing page and others). Result: **42/42 correct**. A shorter, trigger-only version of the description scored the same, so the original was kept.

Re-run it yourself (needs the Claude Code CLI, signed in):

```bash
bash evals/trigger-test.sh                  # 3 runs per prompt, Sonnet
bash evals/trigger-test.sh 5 opus           # 5 runs, Opus
bash evals/trigger-test.sh 3 sonnet my-description.txt   # try another description
```

## Limitations

- **Small test.** Three prompts, one run each for the output comparison, graded by one person with searches and by reading the files, not blind. Treat the table as direction, not proof.
- **The baseline is not weak.** Without the skill, one run already put the data behind a single function. The skill's difference is the contract (an interface both implementations satisfy), a mock that is slow and can fail so the loading and error states are really seen, and those states being built every time.
- **Client-side React examples.** The pattern in `SKILL.md` uses a hook with `useState` and `useEffect`. A Next.js App Router page that fetches in a server component (with `loading.tsx` and `error.tsx`) is a valid way to be backend-ready that the skill does not describe yet.
- **React and TypeScript only.** Vue, Svelte and Angular would need the same pattern translated.
- **Not a design skill.** It decides where data comes from and never what the page looks like.

## Files

| File | Purpose |
|---|---|
| `SKILL.md` | Instructions the agent follows |
| `evals/evals.json` | Three build prompts with expected outcomes |
| `evals/trigger-prompts.tsv` | 14 prompts and whether each should load the skill |
| `evals/trigger-test.sh` | Runs the trigger test |
| `LICENSE` | MIT |

## History

Originally shipped with design-interview content as well, which overlapped with design skills. Narrowed to data architecture only on 2026-09-15 so it stays useful whichever design skill you pair it with.
