#!/usr/bin/env bash
# Trigger test: does the description make an agent load this skill when it should, and not otherwise?
# Each run is a fresh, tool-less Claude Code session that sees a list of skill descriptions
# (this one plus realistic neighbours) and one user prompt, and names the skills it would load.
#
# usage: bash evals/trigger-test.sh [reps] [model] [description-file]
#   reps              runs per prompt (default 3)
#   model             default sonnet
#   description-file  text file holding an alternative description to test (default: the one in SKILL.md)
# needs: Claude Code CLI, signed in. Costs one short call per prompt per rep.
set -euo pipefail
dir="$(cd "$(dirname "$0")" && pwd)"
reps="${1:-3}" model="${2:-sonnet}"
if [ -n "${3:-}" ]; then
  desc="$(cat "$3")"
else
  desc="$(sed -n 's/^description: //p' "$dir/../SKILL.md" | head -1 | sed 's/^"//; s/"$//')"
fi

export model sys="You are a coding agent. These skills are installed. Before acting on the user's message you decide which skills, if any, to load, based only on their descriptions.

- tdd: Test-driven development. Use when the user wants to build features or fix bugs test-first, mentions red-green-refactor, or wants integration tests.
- systematic-debugging: Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes.
- writing-plans: Use when you have a spec or requirements for a multi-step task, before touching code.
- brainstorming: Use before any creative work - creating features, building components, adding functionality, or modifying behavior.
- impeccable: Use when the user wants to design, redesign, critique, polish or otherwise improve a frontend interface: websites, landing pages, dashboards, components, typography, layout, color, motion.
- web-design-guidelines: Review UI code for accessibility and UX best practices. Use when asked to review my UI or audit design.
- backend-patterns: Backend architecture patterns, API design, database optimization and server-side best practices for Node.js, Express and Next.js API routes.
- production-readiness: Use when asked whether an app is production ready, launch ready, or safe to go live.
- glad-frontend: ${desc}

Reply with ONLY the comma-separated names of the skills you would load, or NONE. No other text."

one() {
  out=$(claude -p --setting-sources project --model "$model" --tools "" --no-session-persistence \
        --system-prompt "$sys" "$3" 2>&1 | tr '\n' ' ')
  hit=$(grep -q 'glad-frontend' <<<"$out" && echo yes || echo no)
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
