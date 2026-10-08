#!/usr/bin/env bash
# Glad-Personal installer — sets up my skills and my third-party skill stack on a machine.
# Reads skills/glad-personal/references/stack.json. Third-party skills install from their
# original authors' repositories; nothing third-party is copied into this repo.
set -euo pipefail

REPO_URL="https://github.com/Gladiarn/Glad-Personal"
RAW_STACK="https://raw.githubusercontent.com/Gladiarn/Glad-Personal/main/skills/glad-personal/references/stack.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo "")"

usage() {
  cat <<'EOF'
Usage: install.sh [options]

What to install (pick at least one):
  --own            My own skills (glad-frontend, production-readiness, glad-personal)
  --stack          Third-party skills from the catalog (from their original repos)
  --all            Both of the above
  --skill <name>   One skill by name (own or third-party); repeatable

Options:
  --with-tools     Also run installers for "tool" entries (casr, process-triage, graphify).
                   These download compiled binaries or Python packages — read them first.
  --agent <ids>    Agents to install for, passed to `npx skills add -a` (default: claude-code)
  --dry-run        Print the commands without running them
  --list           Show everything in the catalog and exit
  -h, --help       Show this help

Plugins (superpowers, vercel) can't be installed by a script: the installer prints the
/plugin install commands for you to run inside Claude Code.

Examples:
  ./install.sh --all --dry-run
  ./install.sh --own
  ./install.sh --skill production-readiness --skill impeccable
  curl -fsSL https://raw.githubusercontent.com/Gladiarn/Glad-Personal/main/install.sh | bash -s -- --all
EOF
}

OWN=0 STACK=0 TOOLS=0 DRY=0 LIST=0 AGENTS="claude-code"
PICK=()
[ $# -eq 0 ] && { usage; exit 0; }
while [ $# -gt 0 ]; do
  case "$1" in
    --own) OWN=1 ;;
    --stack) STACK=1 ;;
    --all) OWN=1; STACK=1 ;;
    --skill) shift; [ $# -gt 0 ] || { echo "--skill needs a name" >&2; exit 2; }; PICK+=("$1") ;;
    --with-tools) TOOLS=1 ;;
    --agent) shift; [ $# -gt 0 ] || { echo "--agent needs a value" >&2; exit 2; }; AGENTS="$1" ;;
    --dry-run) DRY=1 ;;
    --list) LIST=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1 (see --help)" >&2; exit 2 ;;
  esac
  shift
done

command -v node >/dev/null 2>&1 || { echo "Node.js is required (it also provides npx). Install Node 18+ and re-run." >&2; exit 1; }

# Use the local stack.json when run from a clone; otherwise download it.
STACK_FILE="$SCRIPT_DIR/skills/glad-personal/references/stack.json"
if [ -z "$SCRIPT_DIR" ] || [ ! -f "$STACK_FILE" ]; then
  STACK_FILE="$(mktemp)"
  trap 'rm -f "$STACK_FILE"' EXIT
  curl -fsSL "$RAW_STACK" -o "$STACK_FILE"
fi

# Emit one tab-separated line per entry: kind, name, type, install command
entries() {
  node -e '
    const s = require(process.argv[1]);
    const out = (k, e, t) => console.log([k, e.name, t, e.install].join("\t"));
    s.own.forEach(e => out("own", e, "skill"));
    s.skills.forEach(e => out("stack", e, e.type));
    s.plugins.forEach(e => out("plugin", e, "plugin"));
  ' "$STACK_FILE"
}

if [ "$LIST" -eq 1 ]; then
  node -e '
    const s = require(process.argv[1]);
    console.log("My skills:"); s.own.forEach(e => console.log(`  ${e.name.padEnd(28)} ${e.summary}`));
    console.log("\nThird-party skills:"); s.skills.forEach(e => console.log(`  ${e.name.padEnd(28)} [${e.category}${e.type === "tool" ? ", tool" : ""}] ${e.summary}`));
    console.log("\nPlugins:"); s.plugins.forEach(e => console.log(`  ${e.name.padEnd(28)} ${e.install}`));
  ' "$STACK_FILE"
  exit 0
fi

[ "$OWN" -eq 1 ] || [ "$STACK" -eq 1 ] || [ ${#PICK[@]} -gt 0 ] || { echo "Nothing selected. Use --own, --stack, --all or --skill <name> (see --help)." >&2; exit 2; }

run() {
  if [ "$DRY" -eq 1 ]; then echo "  [dry-run] $*"; else echo "  → $*"; bash -c "$*"; fi
}

wanted() {
  local kind="$1" name="$2"
  for p in "${PICK[@]:-}"; do [ "$p" = "$name" ] && return 0; done
  [ "$kind" = own ] && [ "$OWN" -eq 1 ] && return 0
  [ "$kind" = stack ] && [ "$STACK" -eq 1 ] && return 0
  return 1
}

installed=() skipped_tools=() plugins=() failed=() found=()
while IFS=$'\t' read -r kind name type cmd; do
  if [ "$kind" = plugin ]; then
    { [ "$STACK" -eq 1 ] || [ "$OWN" -eq 1 ]; } && plugins+=("$cmd")
    continue
  fi
  wanted "$kind" "$name" || continue
  found+=("$name")
  echo "• $name"
  if [ "$type" = tool ]; then
    if [ "$TOOLS" -eq 1 ]; then
      run "$cmd" && installed+=("$name") || failed+=("$name")
    else
      echo "  skipped (tool installer — re-run with --with-tools, or run it yourself): $cmd"
      skipped_tools+=("$name")
    fi
  else
    run "$cmd -g -y -a $AGENTS" && installed+=("$name") || failed+=("$name")
  fi
done < <(entries)

for p in "${PICK[@]:-}"; do
  [ -z "$p" ] && continue
  printf '%s\n' "${found[@]:-}" | grep -qx "$p" || { echo "Not in the catalog: $p (see --list)" >&2; failed+=("$p"); }
done

echo
echo "Done$([ "$DRY" -eq 1 ] && echo ' (dry run — nothing was installed)')."
[ ${#installed[@]} -gt 0 ] && echo "  $([ "$DRY" -eq 1 ] && echo "Would install" || echo "Installed"): ${installed[*]}"
[ ${#skipped_tools[@]} -gt 0 ] && echo "  Skipped tool installers: ${skipped_tools[*]} (use --with-tools)"
[ ${#failed[@]} -gt 0 ] && echo "  Failed: ${failed[*]}"
if [ ${#plugins[@]} -gt 0 ]; then
  echo
  echo "Run these inside Claude Code to add the plugins:"
  for c in "${plugins[@]}"; do echo "  $c"; done
fi
echo
echo "Global CLAUDE.md: ask your agent to run the glad-personal skill to set it up or merge it (see $REPO_URL)."
[ ${#failed[@]} -eq 0 ]
