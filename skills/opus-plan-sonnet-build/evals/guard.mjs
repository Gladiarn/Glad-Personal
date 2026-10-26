// PreToolUse hook for real-route-test.sh: logs every tool call to $GUARD_LOG and blocks the first
// decisive action (a subagent spawn, a code write, an install or test run) so nothing gets built.
import { appendFileSync, readFileSync } from "node:fs";

const { tool_name: tool, tool_input: input = {} } = JSON.parse(readFileSync(0, "utf8"));
const slim = { ...input };
delete slim.content; delete slim.new_string; delete slim.old_string;
appendFileSync(process.env.GUARD_LOG, JSON.stringify({ tool, input: slim }) + "\n");

const stop = (what) => {
  process.stderr.write(`TEST HARNESS: ${what} recorded; stop here and end your turn.`);
  process.exit(2);
};
if (tool === "Agent" || tool === "Task") stop("spawn");
if (["Write", "Edit", "MultiEdit", "NotebookEdit"].includes(tool) && !String(input.file_path || "").includes("/docs/"))
  stop("code write (inline build)");
if (tool === "Bash" && /\b(npm|pnpm|npx|yarn) (i|install|add|test|run)\b/.test(input.command || ""))
  stop("build/test command");
