#!/usr/bin/env bash
# Trigger test: does the description make an agent load this skill when it should, and not otherwise?
# Each run is a fresh, tool-less Claude Code session that sees a list of skill descriptions
# (this one plus realistic neighbours) and one user prompt, and names the skills it would load.
#
# usage: bash evals/trigger-test.sh [reps] [model]     (defaults: 3 reps, sonnet)
# needs: Claude Code CLI, signed in. Costs one short call per prompt per rep.
set -euo pipefail
dir="$(cd "$(dirname "$0")" && pwd)"
reps="${1:-3}" model="${2:-sonnet}"
desc="$(sed -n 's/^description: //p' "$dir/../SKILL.md" | head -1 | sed 's/^"//; s/"$//')"

export model sys="You are a coding agent. These skills are installed. Before acting on the user's message you decide which skills, if any, to load, based only on their descriptions.

- tdd: Test-driven development. Use when the user wants to build features or fix bugs test-first, mentions red-green-refactor, or wants integration tests.
- systematic-debugging: Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes.
- writing-plans: Use when you have a spec or requirements for a multi-step task, before touching code.
- brainstorming: Use before any creative work - creating features, building components, adding functionality, or modifying behavior.
- frontend-design: Guidance for distinctive, intentional visual design when building new UI or reshaping an existing one.
- production-readiness: Use when asked whether an app is production ready, launch ready, or safe to go live.
- caveman: Terse caveman voice. Use for /caveman or 'be brief'.
- opus-plan-sonnet-build: ${desc}

Reply with ONLY the comma-separated names of the skills you would load, or NONE. No other text."

one() {
  out=$(claude -p --setting-sources project --model "$model" --tools "" --no-session-persistence \
        --system-prompt "$sys" "$3" 2>&1 | tr '\n' ' ')
  hit=$(grep -q 'opus-plan-sonnet-build' <<<"$out" && echo yes || echo no)
  printf '%s\t%s\t%s\t%s\n' "$1" "$2" "$hit" "$out"
}
export -f one

# prompts file: id <TAB> should-fire (yes/no) <TAB> prompt
results="$(
  while IFS=$'\t' read -r id expect text; do
    for _ in $(seq "$reps"); do printf '%s\0%s\0%s\0' "$id" "$expect" "$text"; done
  done < "$dir/trigger-prompts.tsv" | xargs -0 -n 3 -P 8 bash -c 'one "$@"' _ | sort
)"

awk -F'\t' '{n[$1]++; if ($3 == "yes") h[$1]++; e[$1] = $2}
  END {for (k in n) printf "%-4s should fire: %-3s  fired %d/%d\n", k, e[k], h[k], n[k]}' <<<"$results" | sort
awk -F'\t' '$2 == $3 {ok++} END {print "correct: " ok "/" NR}' <<<"$results"
