---
name: opus-plan-sonnet-build
description: "Use whenever a coding task needs a plan or is hard or risky: new features, changes across several files, refactors, auth, payments or data migrations, or a bug that a fix has already failed to solve (load it together with systematic-debugging). Load it alongside planning, brainstorming or TDD skills, never instead of them; it only decides which model does each part. Not for typos, renames, single-file tweaks, config edits or questions about code."
license: MIT
metadata:
  version: 1.0.1
  author: Gladiarn
  repository: https://github.com/Gladiarn/Glad-Personal
---

# Model routing: Sonnet by default, Opus where judgment matters

This skill assumes the main session runs on Sonnet 5.5 (`/model sonnet`).
The main session never switches models. Opus 5.5 is used only through subagents
(model "opus"), and only for the jobs listed below. Spawn every Opus subagent
with effort "high".

**If the main session is not on Sonnet:** you cannot switch it yourself. Tell
the user once to run `/model sonnet`, then carry on. On Opus the steps still
work, they just save nothing.

**Model names:** "opus" and "sonnet" are aliases for the newest Opus and Sonnet
(5.5 when this was written). Users who need a fixed version pin the aliases
with `ANTHROPIC_DEFAULT_OPUS_MODEL` / `ANTHROPIC_DEFAULT_SONNET_MODEL`; keep
passing the aliases.

## Sonnet 5.5 handles (stay in this session)
- Well-scoped everyday coding: fixing bugs, iterating on features, verifying
  against requirements
- High-volume development and the TDD loop
- Well-defined repeated tasks: investigation, review, drafting
- Polished documents, slides, spreadsheets, diagrams, and document edits

## Opus 5.5 handles (via subagent)
1. **Planning** for non-trivial work
2. **Enhancing the plan**: a second pass that checks the plan against the
   requirements, finds gaps and risks, and tightens it before building
3. **Hard or complex features** that need careful judgment, including
   long-horizon work and the hardest problems, when Sonnet cannot handle them
4. **Review of high-risk changes**: auth, payments, permissions, schema
   migrations, large refactors

## With superpowers skills loaded
Each job runs once, on the model this skill assigns:
- **brainstorming:** in this session, on Sonnet. It is a conversation with the user.
- **writing-plans:** the Opus planning subagent writes this plan, in that
  skill's format, instead of the Step 1 plan, and returns it; this session
  saves it where writing-plans says. Never write a second plan on Sonnet.
  Step 2 critiques it.
- **Execution:** recommend executing-plans (build in this session). If the
  user picks subagent-driven-development, its implementers and task reviewers
  use model "sonnet", except task reviewers for the high-risk categories above,
  which use "opus".
- **Review:** one final review, on model "opus". It replaces Step 5; never run both.

## When to skip this skill
Typos, renames, small single-file edits, config tweaks, or anything where the
approach is already obvious. Just do it directly on Sonnet.

## Step 1: Plan (Opus subagent)
Spawn ONE subagent with model "opus". It is read-only and must not edit files.

Brief it with:
- the goal and constraints
- file paths already known to be relevant
- that the work will be done test-first (TDD)

Ask it to return a plan of roughly 400 words or less:
1. files to change, and why
2. ordered implementation steps
3. tests to write first, including edge cases
4. risks and ambiguities
5. acceptance criteria

Tell it to read only what it needs and not to explore the codebase broadly.
One planning subagent per task. Never one per step.

## Step 2: Enhance the plan (same Opus subagent)
Before building, send the plan back to the SAME subagent (continue it with
SendMessage, do not spawn a new one) and ask it to critique and tighten it:
missing edge cases, wrong assumptions, steps that are too large, untested
risks. Use the improved plan. Skip this step for small or low-risk tasks.

## Step 3: Build (this session, Sonnet)
- **REQUIRED SUB-SKILL:** implement the plan with your test-driven-development
  skill (for example `superpowers:test-driven-development` or `tdd`).
- Do not re-plan. Follow the plan as written. If the plan turns out to be
  wrong, escalate (Step 4).

## Step 4: Escalate to Opus when Sonnet is not enough
Escalate when any of these is true:
- the same problem fails twice
- the change needs careful judgment across many files or a long horizon
- tests fail for reasons that stay unclear after one honest investigation
- the plan turns out to be wrong

How:
- For a contained piece of work, give it to an Opus subagent with a thorough
  brief (goal, relevant files, what was tried, what failed). It does not see
  this conversation, so include everything it needs.
- For a long stretch of hard work, tell the user it is worth running
  `/model opus` for that stretch. This resets the cache once.
Do not escalate casually. Opus is for what Sonnet could not do.

## Step 5: Review
- Default: self-check on Sonnet. Tests failed for the right reason first, no
  tests were weakened, skipped, or deleted, and the diff stays within the plan.
- For the high-risk categories above: spawn ONE fresh-context subagent with
  model "opus" to review the diff.
