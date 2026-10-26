#!/usr/bin/env bash
# Real-harness routing test: a headless Opus session with your real Claude Code setup (system prompt,
# installed skills and plugins, CLAUDE.md) gets a long build in a scratch repo. A PreToolUse hook
# (guard.mjs) records the first decisive action and blocks it, so nothing is built. Unlike
# route-test.sh, this shows whether the skill loads at all and whether Opus really spawns the builder.
#   R1: spec approved, "plan it and build it"      expect: skill loads, plan file, Sonnet spawn (or asks to approve the plan)
#   R2: plan approved, "execute it"                expect: skill loads, Sonnet spawn, no inline build
# usage: bash evals/real-route-test.sh [reps] [outdir]   (defaults: 3 reps, a temp dir; SCEN="R2" for a subset)
# needs: Claude Code CLI signed in, node, git. Costs about $0.30 (R2) to $0.60 (R1) per run.
# The skill under test is whatever ~/.claude/skills/opus-plan-sonnet-build points at.
set -euo pipefail
dir="$(cd "$(dirname "$0")" && pwd)"
reps="${1:-3}" out="${2:-$(mktemp -d)}"
mkdir -p "$out"; out="$(cd "$out" && pwd)"
printf '{"hooks":{"PreToolUse":[{"matcher":".*","hooks":[{"type":"command","command":"node %s/guard.mjs"}]}]}}' \
  "$dir" > "$out/settings.json"

fixture() { # $1 = repo dir, $2 = scenario
  mkdir -p "$1/docs/specs" "$1/api/src" "$1/admin/src"
  cat > "$1/docs/specs/csv-import.md" <<'EOF'
# CSV import (approved)
Admins upload a CSV of customers, see validation errors per row, preview valid rows, commit them to Postgres, and download an error report.
- API (Express): POST /imports (multipart upload, parse, validate rows: email required+valid, name required, phone optional E.164), GET /imports/:id/preview, POST /imports/:id/commit (insert valid rows in one transaction), GET /imports/:id/errors.csv
- Admin (React): upload page, preview table with per-row errors, commit button, error report download link
- Files: api/src/routes/imports.ts, api/src/services/csvParse.ts, api/src/services/validateRow.ts, api/src/db/imports.ts, api/migrations/003_imports.sql, admin/src/pages/ImportPage.tsx, admin/src/components/PreviewTable.tsx, admin/src/api/imports.ts, api/test/imports.test.ts
- Tests: vitest (npm test in api/ and admin/)
EOF
  echo '{"name":"api","scripts":{"test":"vitest run"}}' > "$1/api/package.json"
  echo '{"name":"admin","scripts":{"test":"vitest run"}}' > "$1/admin/package.json"
  echo 'import express from "express"; export const app = express();' > "$1/api/src/app.ts"
  echo 'export default function App(){ return null }' > "$1/admin/src/App.tsx"
  if [ "$2" = R2 ]; then mkdir -p "$1/docs/plans"; cat > "$1/docs/plans/csv-import.md" <<'EOF'
# CSV import plan (approved)
Spec: docs/specs/csv-import.md. Tests first with vitest in each task.
1. validateRow (api/src/services/validateRow.ts): email required+valid, name required, phone optional E.164. Tests: missing email, bad email, blank name, bad phone, valid row.
2. csvParse (api/src/services/csvParse.ts): header row, quoted commas, BOM, empty lines skipped. Tests for each.
3. Migration + db (api/migrations/003_imports.sql, api/src/db/imports.ts): imports, import_rows tables; commit inserts valid rows in one transaction, rolls back on failure. Tests: rollback on mid-batch failure.
4. Routes (api/src/routes/imports.ts): POST /imports, GET /imports/:id/preview, POST /imports/:id/commit (idempotent: second commit is 409), GET /imports/:id/errors.csv. Tests in api/test/imports.test.ts.
5. Admin client (admin/src/api/imports.ts) + ImportPage + PreviewTable: upload, per-row errors, commit button disabled while committing, error report link. Tests: renders errors, disables button.
Acceptance: all vitest suites pass; commit is all-or-nothing; second commit returns 409.
EOF
  fi
  (cd "$1" && git init -q && git add -A && git -c user.email=t@t -c user.name=t commit -qm init)
}

one() { # $1 = scenario, $2 = rep
  local w="$out/work-$1-$2" p
  rm -rf "$w"; fixture "$w" "$1"
  case $1 in
    R1) p="The spec for CSV import is approved: docs/specs/csv-import.md. It touches about 9 files across the Express API and the React admin. Plan it and build it.";;
    R2) p="The plan in docs/plans/csv-import.md is approved. Execute it.";;
  esac
  export GUARD_LOG="$out/$1-$2.tools.jsonl"; : > "$GUARD_LOG"
  (cd "$w" && timeout 1500 claude -p --model opus --effort medium --permission-mode default \
    --allowedTools "Read" "Glob" "Grep" "Skill" "Agent" "ToolSearch" "Write(docs/**)" "Edit(docs/**)" \
      "Bash(git *)" "Bash(ls *)" "Bash(cat *)" "Bash(head *)" "Bash(tail *)" "Bash(find *)" "Bash(grep *)" \
      "Bash(node -v*)" "Bash(npm -v*)" "Bash(which *)" "Bash(mkdir -p docs*)" "Bash(echo *)" "Bash(for *)" \
    --settings "$out/settings.json" --max-budget-usd 3 --no-session-persistence \
    --output-format stream-json --verbose "$p" < /dev/null > "$out/$1-$2.stream.jsonl" 2> "$out/$1-$2.err") || true
}
export -f one fixture; export out dir

for s in ${SCEN:-R1 R2}; do for r in $(seq "$reps"); do echo "$s $r"; done; done | xargs -P 3 -L 1 bash -c 'one "$0" "$1"'

node - "$out" <<'EOF'
const { readFileSync, readdirSync } = require("node:fs");
const dir = process.argv[2], tally = {};
for (const f of readdirSync(dir).filter((f) => f.endsWith(".tools.jsonl")).sort()) {
  const id = f.replace(".tools.jsonl", ""), sc = id.split("-")[0];
  const tools = readFileSync(`${dir}/${f}`, "utf8").split("\n").filter(Boolean).map(JSON.parse);
  const loaded = tools.some((t) => t.tool === "Skill" && t.input.skill === "opus-plan-sonnet-build");
  const first = tools.find((t) => t.tool === "Agent" || t.tool === "Task" ||
    (["Write", "Edit"].includes(t.tool) && !String(t.input.file_path).includes("/docs/")) ||
    (t.tool === "Bash" && /\b(npm|pnpm|npx|yarn) (i|install|add|test|run)\b/.test(t.input.command)));
  const spawn = first && (first.tool === "Agent" || first.tool === "Task");
  const verdict = !first ? "stopped to ask" : spawn
    ? `spawn model=${first.input.model ?? "inherit"} effort=${first.input.effort ?? "-"}` : `INLINE ${first.tool}`;
  const t = (tally[sc] ??= { n: 0, loaded: 0, sonnet: 0 });
  t.n++; if (loaded) t.loaded++; if (spawn && first.input.model === "sonnet") t.sonnet++;
  console.log(`${id}  skill loaded: ${loaded ? "yes" : "NO "}  first action: ${verdict}`);
}
for (const [sc, t] of Object.entries(tally)) console.log(`${sc}: skill loaded ${t.loaded}/${t.n}, Sonnet builder spawned ${t.sonnet}/${t.n}`);
EOF
echo "transcripts: $out"
