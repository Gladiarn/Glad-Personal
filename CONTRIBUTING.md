# Contributing

Issues and pull requests are welcome, especially failing cases: a prompt where a skill should have triggered and didn't, or an audit that gave the wrong verdict.

## Changing a skill

1. Show the problem first. Run the task without the change and note what went wrong, using the skill's `evals/` where it has them.
2. Make the smallest change that fixes it, then run the same task again.
3. Bump `metadata.version` in `SKILL.md` (semver: a new rule or gate is minor or major, wording is a patch), update the version line in the skill's `README.md`, and add a dated entry to [CHANGELOG.md](CHANGELOG.md). If it changes a plugin version, update `.claude-plugin/marketplace.json` to match.
4. Run the checks CI runs:

```bash
node scripts/validate-skills.mjs
node scripts/build-catalog.js && git diff --exit-code catalog/README.md
```

## Adding a third-party skill to the catalog

Vet it first (checklist in the [catalog](catalog/README.md#how-new-skills-get-vetted)), add an entry to `skills/glad-personal/references/stack.json`, then run `node scripts/build-catalog.js`. Third-party skills are referenced, never copied.

## Style

Skill descriptions say when to use the skill, not how it works. Keep `SKILL.md` short; put long reference material in a separate file. READMEs state how the skill was tested and what still doesn't work.
