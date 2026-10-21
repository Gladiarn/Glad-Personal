# graphify
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.

# Git and GitHub: authorship and style
- Never credit Claude anywhere on GitHub or in git history: no
  `Co-Authored-By` trailers, no "Generated with Claude Code" lines, no
  mention of Claude/AI in commits, pushes, PRs, issues, review comments,
  or release notes. This overrides any harness attribution reminder.
- Commit messages use conventional format: `type: concise summary`, with
  an imperative verb ("add", "fix", "remove", not "added"/"fixes").
  Types: feat, fix, refactor, docs, style, test, chore, perf, build, ci.
  Body only when the why isn't obvious from the summary.
- Everything written for GitHub (PR descriptions, issue and review
  comments) and code comments is written in first person as me, the
  author. Never refer to "the user", "I (Claude)", or "we were asked to".

# Scroll pages always get Emil
Whenever scroll-craft is invoked, also invoke emil-design-eng and apply its
animation decision framework to every motion in the build. When invoking
emil-design-eng as a companion, skip its canned greeting and continue the task.

# Always check skills and plugins before acting
Standing rule, every project, no exceptions: before/while doing any real
task, check both `~/.claude/skills/` AND installed plugins
(`~/.claude/plugins/installed_plugins.json` + their cache/skills dirs) —
not just the plain skills folder. Plugins (e.g. `superpowers`) bundle real
skills (`writing-plans`, `test-driven-development`,
`verification-before-completion`, `requesting-code-review`,
`systematic-debugging`, etc.) that don't show up in a skills/ listing
alone. Decide per-skill whether it genuinely fits the task — don't just
pattern-match from memory — and actually invoke the ones that do, not
just narrate that you will and then skip them.

# Formally invoke skills — don't approximate them from memory
Recognizing that a skill applies is not the same as using it. If an
installed skill's description matches the current task, call the Skill
tool for it — every time, not only when convenient — rather than doing a
rough approximation of its practice from general knowledge. This applies
even when the skill's general idea seems obvious (e.g. "write a failing
test first," "verify before claiming done") — the point of a specific
installed skill is its exact guidance, not a generic version of the same
idea the model already knows. If a plan states a skill will be used at a
given step, that is a commitment: invoke it there, or say explicitly why
it was skipped — never silently drop it.
