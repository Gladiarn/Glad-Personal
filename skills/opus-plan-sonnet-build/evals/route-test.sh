#!/usr/bin/env bash
# Routing test: given this SKILL.md, what does a main session on Opus decide to do for four tasks?
# S1 long build from an approved spec (expect route B), S2 one-handler change (A),
# S3 Stripe billing (B + risk review + one Opus reviewer), S4 visual page the user watches (C),
# S5 Safari bug verified by Playwright WebKit + API tests, S6 small fix with one quick unit test.
# usage: bash evals/route-test.sh [reps] [outdir]     (defaults: 3 reps, a temp dir)
# Pass SCEN="S5 S6" to run only some scenarios.
# Pass SKILL=none to run the no-skill control. Costs one short Opus call per scenario per rep.
set -euo pipefail
dir="$(cd "$(dirname "$0")" && pwd)"
skill="${SKILL:-$dir/../SKILL.md}" reps="${1:-3}" out="${2:-$(mktemp -d)}"
mkdir -p "$out"
if [ "$skill" = none ]; then body="(no routing skill loaded)"; else body="$(cat "$skill")"; fi

export sys="You are Claude Code, main session running on Opus 5.5 at medium effort. You can spawn subagents with Agent(model: opus|sonnet|haiku, effort: low|medium|high, prompt) and continue them with SendMessage. You can read/edit files and run tests. superpowers skills (brainstorming, writing-plans, test-driven-development) are installed.

This skill is loaded:
<skill>
${body}
</skill>

Do NOT do the task. Reply with a numbered list (max 8 lines) of exactly what you will do next: who does each part (this session or a subagent), the model and effort of every subagent you would spawn, what plan you write and where, and how the result is reviewed. If you would ask the user to change models, say so."

S1="The spec for the CSV import feature is approved (docs/specs/csv-import.md): upload, row validation, preview table, commit to Postgres, error report download. It touches about 9 files across the Express API and the React admin. Go ahead and build it."
S2="Add a max length of 280 to the comment body in the POST /comments handler and return 400 with a message when it's longer. There's an existing test file for that route."
S3="Add Stripe subscription billing to our Express API: checkout session, webhook handler that updates the user's plan, and a customer portal link. Plan is agreed, build it."
S4="Build the hero and first three scroll sections of the kasumi-an landing page from the approved design. It's mostly layout, scroll animation and visual tuning; I'll be looking at it in the browser as you go."
S5="Checkout's Pay button does nothing on Safari. Fix it, then verify with the Playwright WebKit e2e suite and the API integration tests (they need the dev server and a test database running)."
S6="formatPrice(0) returns an empty string instead of \"\$0.00\". Fix it; there's a unit test file for it that runs in about a second."
export S1 S2 S3 S4 S5 S6

one() { claude -p --setting-sources project --model opus --effort medium --tools "" --no-session-persistence \
          --system-prompt "$sys" "${!1}" > "$2/$1-$3.txt" 2>&1; }
export -f one
for s in ${SCEN:-S1 S2 S3 S4 S5 S6}; do for r in $(seq "$reps"); do printf '%s\0%s\0%s\0' "$s" "$out" "$r"; done; done \
  | xargs -0 -n 3 -P 8 bash -c 'one "$@"' _
for f in "$out"/*.txt; do echo "=== $(basename "$f")"; cat "$f"; echo; done
