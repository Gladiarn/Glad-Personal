# opus-plan-sonnet-build

An agent skill for Claude Code that **decides which model does which part of a coding task**. Your session runs on Opus, which plans, decides and reviews. When a task is a long build from an agreed plan, Opus hands the typing to one Sonnet subagent and checks the result itself.

Running everything on Opus is expensive on long builds, where most tokens go into reading files, writing code and fixing tests. Running everything on Sonnet is cheaper, but the plan and the risky calls suffer. 2.0 keeps Opus in charge and uses Sonnet only where the work is mostly mechanical.

```
You (on Opus):  "The CSV import spec is approved, build it."   (about 9 files)
  → Opus writes a short plan: tasks, tests to write first, acceptance criteria
  → one Sonnet subagent (high effort) builds the whole plan test-first
  → Opus reads the diff, runs the tests, fixes small gaps
  → new endpoints, so Opus rereads the diff as an attacker
```

- **Version:** 2.1.0 · **License:** MIT · **Works with:** Claude Code (it relies on subagents with a per-spawn model and effort)

---

## What goes where

| Task | Route |
|---|---|
| Small or medium: a few files, a bug fix, a contained feature | **A.** Opus does everything in your session, test-first. |
| Long build from an approved spec or plan (about 5+ files or 4+ tasks, mostly mechanical) | **B.** Opus writes a short plan; one Sonnet subagent (effort high) builds it; Opus checks the diff and runs the tests. |
| Visual or interactive work you watch step by step | **C.** Built in your session with no plan file. It suggests `/model sonnet` for that stretch. |
| Heavy test runs on any route: browser (Playwright, WebKit, Cypress), API or integration suites that need a server or database, long logs | One Sonnet test-runner subagent (effort medium) runs them and reports failures; Opus fixes. Reruns reuse the same runner. Quick unit tests stay in your session. |
| Anything touching auth, payments, permissions, data migrations or public endpoints | Also a **risk review**: Opus rereads the diff as an attacker. Payments, login/session/token code and data-rewriting migrations also get one fresh Opus reviewer at the end of the phase. |

### What changed from 1.x

1.x put your session on Sonnet and called Opus through subagents to plan, critique the plan, take over hard pieces and review. In practice:

- **The Opus planner often never ran.** In 2 of 4 real sessions and one headless run, the skill loaded but no Opus subagent was spawned, so everything ran on Sonnet anyway.
- **There was no saving on small tasks.** The planner and reviewer each paid for their own context (see the measurements below).
- **Plans could get expensive.** Planner subagents writing full code made the plan cost close to the build.

2.0 makes the main session Opus. It plans inline with no planner subagent and no critique pass. Sonnet gets only the part it's good at: executing a long, clear plan.

## Requirements

- **Claude Code** with access to both Opus and Sonnet.
- **A test-driven-development skill.** The Sonnet builder uses one. Either works:
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

## Setup: put your session on Opus

Run this once in Claude Code. It's remembered for later sessions:

```
/model opus
```

Medium effort is the intended setting. **If your session is on Sonnet,** the skill reminds you once that planning and review are meant for Opus, then does everything in your session.

## Use

Nothing to type. It loads by itself when a task needs a plan or is hard or risky, and it runs alongside your planning, brainstorming, TDD or debugging skills, not instead of them:

> The CSV import spec is approved, build it.
> Add role-based permissions to the API and hide actions the user's role can't do.
> Split the orders table with a Prisma migration without losing data.

To force it: `/opus-plan-sonnet-build`.

### When it skips

Typos, renames, single-file tweaks, config edits, questions about code. Opus just does them.

### With the superpowers plugin

[superpowers](https://github.com/obra/superpowers) has its own chain (brainstorming → writing-plans → executing-plans or subagent-driven-development → review). This skill decides who runs each step:

| Job | Who |
|---|---|
| Brainstorming | Opus, your session |
| The `writing-plans` plan | Opus, your session, in short form: tests and intent, not full code |
| Building a long plan | one Sonnet subagent (effort high) for the whole plan, not one per task |
| Checking the build | Opus, your session: full diff, tests run, acceptance criteria |
| Final review | the check above plus the risk review; a fresh Opus reviewer only for payments, login/session/token or data-rewriting migrations |

## How it was tested

### Routing (2.0)

`evals/route-test.sh` gives a fresh, tool-less Opus session (medium effort) the skill and one of four tasks, and asks what it will do next. It scores whether each run takes the intended route:

| Task | Intended route | 1.1.2 (2 runs each) | 2.0 (3 runs each) |
|---|---|---|---|
| S1: CSV import from an approved spec, about 9 files | B: short plan, one Sonnet builder, Opus checks | 0/2 (Opus planner, then a critique pass, then the build in your session) | **3/3** |
| S2: max-length check in one handler | A: inline, no subagents | 2/2 | **3/3** |
| S3: Stripe billing, plan agreed | B + risk review + one Opus reviewer | 0/2 (reviewer yes, no attacker reread, building in your session) | **3/3** |
| S4: landing-page hero and scroll sections, watched live | C: inline, no plan file | 1/2 (one run spawned an Opus planner) | **3/3** |

2.1 adds two test-heavy tasks (2.0 as the baseline, 3 runs; 2.1, 2 runs), and S1–S4 were re-run on 2.1 (2 runs each, all on route):

| Task | Intended | 2.0 | 2.1 |
|---|---|---|---|
| S5: Safari bug, verified by the Playwright WebKit suite and API tests | Opus fixes; one Sonnet test runner runs both suites | 0/3 (Opus ran the server, database and both suites itself) | **2/2** |
| S6: one-function fix with a unit test that runs in a second | Run inline, no runner | 3/3 | **2/2** |

All 8 runs on 1.1.2 asked you to switch to `/model sonnet`; no 2.0 run did. On a one-handler public endpoint (S2), 2.0 runs a short hostile-input check, which is cheap and intended. **Limits:** these runs describe the plan, they don't execute it, so they test the routing decision, not the cost or the build quality.

### Triggering (description unchanged since 1.1)

The description decides whether the skill loads, so it was tested on its own. Each run was a fresh, tool-less Sonnet 5.5 session. It saw this skill's description plus seven realistic neighbours (tdd, systematic-debugging, writing-plans, brainstorming and others) and one prompt, then named the skills it would load. There were 14 prompts with 3 runs each: 7 that should load it and 7 that shouldn't.

| Description | Correct | Should-fire prompts that fired | Small edits that wrongly fired |
|---|---|---|---|
| First draft | 18/30 (on the first 10 prompts) | 3/15 | 0/15 |
| Current | **38/42** | 17/21 | **0/21** |

**Known gap:** for bugs that already survived a fix, it fires about one run in three, because the agent picks only systematic-debugging. In 2.0 that matters less, since those bugs stay in your Opus session either way.

Re-run both tests yourself (needs the Claude Code CLI, signed in):

```bash
bash evals/trigger-test.sh         # 3 runs per prompt, Sonnet
bash evals/route-test.sh           # 3 runs per task, Opus (SCEN="S5 S6" for a subset)
SKILL=none bash evals/route-test.sh 3   # no-skill control
```

## Cost tradeoff

**The saving is not proven. It should appear only on long builds (route B), and that hasn't been measured yet.**

### Measured once (October 2026)

The same small task in an empty project, run headless with `claude -p`: "add role-based permissions (admin, editor, viewer) to a small todo API, test-first", with 3 existing tests. Costs come from the CLI's own report (list prices).

| Run | Cost | Security gaps left |
|---|---|---|
| Sonnet alone | $0.15 | an editor could rewrite `ownerId`; two users with no id counted as each other's owner |
| Opus alone | $0.44 | users with no id still counted as each other's owner; a missing role was treated as editor |
| 1.x skill (Opus planner and reviewer, Sonnet builder) | $0.48 | none found; the Opus review caught the id-less owner gap |
| Opus alone + inline attacker reread (what 2.0's risk review does) | $0.57 | none found; it also added validation nobody asked for, which is why 2.0 says to list extra ideas instead of building them |

What this shows: on a small task, nothing beats Opus alone on cost, and the attacker reread closes the same gaps as a separate reviewer. 2.0 routes small tasks to Opus alone for that reason.

What it doesn't show: route B on a long build. There, the estimate is that moving the build to Sonnet saves about 20–40% against all-Opus (at most about 45%), because Opus still pays for the plan, reading the diff and running the tests. That is an estimate, not a measurement.

What eats into it:

- **The builder's brief and report.** The subagent starts cold and reads the plan and the code it touches.
- **Opus checking the diff.** Reading a large diff costs Opus tokens; this is the price of keeping judgment on Opus.
- **A fresh Opus reviewer.** Only for payments, login/session/token code or data-rewriting migrations.
- **Switching to `/model sonnet` for route C** resets the prompt cache once. That's worth it for a long visual stretch, not for one tweak.

If you measure it on your own work, compare the token usage of the same kind of long build with and without the skill.

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

Or export the same variables in your shell. The skill keeps passing the aliases, so the pins apply everywhere.

## Compared with the built-in `opusplan`

Claude Code's `/model opusplan` uses Opus in plan mode and Sonnet otherwise, so Sonnet does all the building and all the reviewing. This skill keeps Opus as your session. Sonnet only executes long, already-planned builds in a subagent, and Opus checks every result. Small and risky work never leaves Opus.

## Troubleshooting

| Symptom | Cause |
|---|---|
| The builder runs on Opus, not Sonnet | `CLAUDE_CODE_SUBAGENT_MODEL_FORCE` is set; it overrides every subagent's model. Unset it. |
| It keeps telling you about `/model opus` | Your session is on Sonnet. Run `/model opus`, or ignore it: everything still runs in your session. |
| A long build ran in your session instead of a subagent | It judged the task as route A or C. Say "use route B" or name the plan file. |
| Everything still costs a lot | Expected on small and medium tasks: those run on Opus by design. The saving is only on long builds. |

## Files

| File | Purpose |
|---|---|
| `SKILL.md` | The instructions the agent follows |
| `evals/route-test.sh` | Routing test: which route Opus picks for six tasks |
| `evals/trigger-prompts.tsv` | Test prompts and whether each should load the skill |
| `evals/trigger-test.sh` | Runs the trigger test |
| `LICENSE` | MIT |

## Changelog

See [CHANGELOG.md](../../CHANGELOG.md) in the repository root.
