# opus-plan-sonnet-build

An agent skill for Claude Code that **decides which model does which part of a coding task**: Opus plans, Sonnet builds, and Opus is called back only when Sonnet gets stuck.

Running everything on Opus is expensive. Running everything on Sonnet is cheaper, but the planning and the hardest calls suffer. This skill splits the work the way Anthropic's own model guide does: Sonnet for well-scoped, high-volume work, Opus for careful judgment and the hardest problems.

```
You (on Sonnet):  "Add Stripe subscriptions with webhooks and a customer portal."
  → Opus subagent writes the plan, then critiques and tightens it
  → Sonnet builds it test-first, in your session
  → stuck twice? that piece goes to Opus
  → touches payments, so an Opus subagent reviews the diff
```

- **Version:** 1.0.1 · **License:** MIT · **Works with:** Claude Code (it relies on subagents with a per-spawn model and the `/model` command)

---

## What goes where

| Sonnet 5.5 — your main session | Opus 5.5 — subagents only |
|---|---|
| Well-scoped coding: bug fixes, feature iteration, checking against requirements | Planning non-trivial work |
| High-volume development and the TDD loop | A second pass that critiques and tightens the plan |
| Repeated tasks: investigation, review, drafting | Hard or long-horizon pieces Sonnet couldn't do |
| Documents, slides, spreadsheets, diagrams | Reviewing high-risk diffs: auth, payments, permissions, schema migrations, large refactors |

Your main session **never switches models** on its own. Opus only runs inside subagents, so your session's prompt cache stays warm.

## Requirements

- **Claude Code** with access to both Opus and Sonnet.
- **A test-driven-development skill.** The build step requires one. Either works:
  - `superpowers:test-driven-development`, from the [superpowers](https://github.com/obra/superpowers) plugin: `/plugin install superpowers@claude-plugins-official`
  - `tdd`, from [mattpocock/skills](https://github.com/mattpocock/skills): `npx skills add https://github.com/mattpocock/skills --skill tdd`

## Install

**Copy it into your Claude Code skills folder:**

```bash
git clone https://github.com/Gladiarn/Glad-Personal
mkdir -p ~/.claude/skills
cp -r Glad-Personal/skills/opus-plan-sonnet-build ~/.claude/skills/
```

**Or with the skills CLI:**

```bash
npx skills add https://github.com/Gladiarn/Glad-Personal --skill opus-plan-sonnet-build
```

**Or keep it linked to a clone** (updates with `git pull`):

```bash
git clone https://github.com/Gladiarn/Glad-Personal ~/Glad-Personal
ln -s ~/Glad-Personal/skills/opus-plan-sonnet-build ~/.claude/skills/opus-plan-sonnet-build
```

**Per project only:** copy the folder to `<project>/.claude/skills/opus-plan-sonnet-build/` and commit it.

**Uninstall:** `rm -r ~/.claude/skills/opus-plan-sonnet-build`

## Setup: put your session on Sonnet

Run this once in Claude Code. It's remembered for later sessions:

```
/model sonnet
```

**If your session is on another model:** the skill can't switch it for you. It reminds you once to run `/model sonnet`, then carries on. On Opus it still works (plan, critique, build, review), but it saves nothing, because the building is on Opus anyway.

## Use

Nothing to type. It loads by itself when a task needs a plan or is hard or risky, and it runs alongside your planning, brainstorming, TDD or debugging skills, not instead of them:

> Add role-based permissions to the API and hide actions the user's role can't do.
> Refactor our auth from sessions to JWTs across backend and frontend.
> Split the orders table with a Prisma migration without losing data.

To force it: `/opus-plan-sonnet-build`.

### When it skips

Typos, renames, single-file tweaks, config edits, questions about code, or anything where the approach is already obvious. Those run on Sonnet directly, with no planning subagent.

### With the superpowers plugin

[superpowers](https://github.com/obra/superpowers) has its own plan-and-build chain (brainstorming → writing-plans → executing-plans or subagent-driven-development → review), and it loads alongside this skill on most planned tasks. This skill tells the two how to split the work, so each job runs once:

| Job | Model | Runs |
|---|---|---|
| Brainstorming (a conversation with you) | Sonnet | once |
| The `writing-plans` plan | Opus subagent (Sonnet only saves the file) | **once** |
| Critique of the plan | the same Opus subagent | once |
| Building, test-first | Sonnet, in your session (`executing-plans`) | once |
| Final review | Opus | **once** |

Without that rule, an agent with both loaded wrote the plan **twice** in all 5 test runs: a short Opus draft, then a full Sonnet rewrite. So the detailed plan, where the decisions are made, came from Sonnet. With it, Opus wrote the only plan in 5/5 runs, and there was one Opus review each time.

## Cost tradeoff

**The savings are an estimate. They have not been measured.**

The idea: on a typical feature, most tokens go into building (reading files, writing code and tests, running and fixing them), not into planning. Sonnet costs well below Opus per token (see [Anthropic pricing](https://www.anthropic.com/pricing)). Moving the building to Sonnet should therefore cost noticeably less than an all-Opus session, while planning and the hardest calls still get Opus.

What eats into that:

- **The plan costs extra.** Each planned task adds an Opus subagent: its own context, the plan, then the critique pass. On a task that's small, this overhead can cost more than doing it on Sonnet directly, which is why small edits skip the skill.
- **Escalations cost Opus prices.** A task that keeps escalating ends up close to all-Opus.
- **`/model opus` for a long hard stretch resets the prompt cache once.** That's worth it for a long stretch, not for one question.
- **Briefs must be complete.** Subagents don't see your conversation, so each brief repeats the context they need.

If you measure it on your own work, compare the token usage of the same kind of task with and without the skill.

## Pinning model versions

`opus` and `sonnet` are **aliases for the newest model in each family** (Opus 5.5 and Sonnet 5.5 when this was written). When a newer model comes out, the skill uses it automatically.

To stay on a fixed version, pin what the aliases point to. Add this to `~/.claude/settings.json`:

```json
{
  "env": {
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "claude-opus-5-5",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "claude-sonnet-5-5"
  }
}
```

Or export the same variables in your shell. For the main session alone you can also run `/model claude-sonnet-5-5`. The skill keeps passing the aliases, so the pins apply everywhere.

## Compared with the built-in `opusplan`

Claude Code has a built-in `/model opusplan` alias: Opus while you're in plan mode, Sonnet otherwise. It's simpler and needs no skill. This skill differs in four ways:

- It decides **per task** whether planning is needed, so you don't have to enter plan mode.
- It adds a **critique pass** on the plan before building.
- It **escalates** hard pieces to Opus during the build, not only during planning.
- It adds an **Opus review** for high-risk diffs.

Your session stays on Sonnet the whole time, so the cache is never reset by a model switch.

## Troubleshooting

| Symptom | Cause |
|---|---|
| Subagents run on Sonnet, not Opus | `CLAUDE_CODE_SUBAGENT_MODEL_FORCE` is set; it overrides every subagent's model. Unset it. |
| Subagents run on an older Opus | Your organisation doesn't allow the newest Opus, or `ANTHROPIC_DEFAULT_OPUS_MODEL` pins an older one. |
| The skill didn't load for a bug | Expected sometimes; see the test results below. Type `/opus-plan-sonnet-build`. |
| Everything still costs a lot | Check `/model`: the main session is probably on Opus. |

## How it was tested

The description decides whether the skill loads, so it was tested on its own. Each run was a fresh, tool-less Sonnet 5.5 session. It saw this skill's description plus seven realistic neighbours (tdd, systematic-debugging, writing-plans, brainstorming and others) and one prompt, then named the skills it would load. There were 14 prompts with 3 runs each: 7 that should load it (features, refactors, permissions, a data migration, two bugs that a fix failed to solve) and 7 that shouldn't (typo, rename, port change, a `console.log`, a button colour, `.gitignore`, a question).

| Description | Correct | Should-fire prompts that fired | Small edits that wrongly fired |
|---|---|---|---|
| First draft | 18/30 (on the first 10 prompts) | 3/15 | 0/15 |
| This version | **38/42** | 17/21 | **0/21** |

The first draft lost to the planning and debugging skills: the agent picked *them* instead. This version says outright that it loads alongside them. It fires on every feature, refactor, permissions and migration prompt. **Known gap:** for bugs that already survived a fix, it fires about one run in three, because the agent picks only systematic-debugging. Invoke it by name there.

Re-run the test yourself (needs the Claude Code CLI, signed in):

```bash
bash evals/trigger-test.sh        # 3 runs per prompt, Sonnet
bash evals/trigger-test.sh 5 opus # 5 runs, Opus
```

## Files

| File | Purpose |
|---|---|
| `SKILL.md` | The instructions the agent follows |
| `evals/trigger-prompts.tsv` | Test prompts and whether each should load the skill |
| `evals/trigger-test.sh` | Runs the trigger test |
| `LICENSE` | MIT |

## Changelog

See [CHANGELOG.md](../../CHANGELOG.md) in the repository root.
