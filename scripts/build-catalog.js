#!/usr/bin/env node
// Builds catalog/README.md from skills/glad-personal/references/stack.json.
// Run after editing stack.json:  node scripts/build-catalog.js
// Check mode (CI / before commit): node scripts/build-catalog.js --check
const fs = require('node:fs')
const path = require('node:path')

const root = path.resolve(__dirname, '..')
const stackPath = path.join(root, 'skills/glad-personal/references/stack.json')
const outPath = path.join(root, 'catalog/README.md')
const s = JSON.parse(fs.readFileSync(stackPath, 'utf8'))

const cell = (t) => String(t ?? '').replace(/\|/g, '\\|').replace(/\n/g, ' ')
const vetted = (e) => (e.vetted ? '✅ vetted' : '⚪ not vetted')
const lines = []
const w = (l = '') => lines.push(l)

w('# Catalog — every skill and plugin in this setup')
w()
w(`<!-- Generated from skills/glad-personal/references/stack.json by scripts/build-catalog.js. Edit stack.json, not this file. -->`)
w()
w(`Last updated: **${s.updated}**. Third-party entries are **references** to their original authors' repositories — install them from there; nothing is copied into this repo. Licenses are as each repository declares them ("see repo" = the repo has no standard license file; check before redistributing).`)
w()
w('**Install everything:** `./install.sh --all` (add `--with-tools` for the tool installers) · **One item:** `./install.sh --skill <name>` or the command in its row.')
w()
w('Status: ✅ vetted = reviewed with the checklist below before installing · ⚪ not vetted = carried over from before the vetting process.')
w()

w('## My skills')
w()
w('| Skill | What it does | Install |')
w('|---|---|---|')
for (const e of s.own) w(`| [**${e.name}**](../skills/${e.name}/) | ${cell(e.summary)} | \`${cell(e.install)}\` |`)
w()

const cats = [...new Set(s.skills.map((e) => e.category))]
w('## Third-party skills')
w()
for (const c of cats) {
  w(`### ${c}`)
  w()
  w('| Skill | What it does | Source · License | Status | Install | Notes |')
  w('|---|---|---|---|---|---|')
  for (const e of s.skills.filter((x) => x.category === c)) {
    const kind = e.type === 'tool' ? ' *(tool installer)*' : ''
    w(`| **${e.name}**${kind} | ${cell(e.summary)} | [${e.source}](${e.url}) · ${cell(e.license)} | ${vetted(e)} | \`${cell(e.install)}\` | ${cell(e.notes)} |`)
  }
  w()
}

w('## Plugins (Claude Code `/plugin install`)')
w()
w('Plugins are a different mechanism from `npx skills add`: they live in `~/.claude/plugins/`, their skills are namespaced (`superpowers:brainstorming`), they **auto-update**, and only you can install them — run the command inside Claude Code.')
w()
w('| Plugin | What it does | Source · License | Status | Install | Notes |')
w('|---|---|---|---|---|---|')
for (const e of s.plugins) w(`| **${e.name}** | ${cell(e.summary)} | [${e.source}](${e.url}) · ${cell(e.license)} | ${vetted(e)} | \`${cell(e.install)}\` | ${cell(e.notes)} |`)
w()

w('## Declined — evaluated and rejected on purpose')
w()
w('| Skill | Source | Reason |')
w('|---|---|---|')
for (const e of s.declined) w(`| ${e.name} | ${e.source} | ${cell(e.reason)} |`)
w()

w('## Never provision')
w()
for (const e of s.notProvisioned) w(`- \`${e.path}\` — ${e.reason}`)
w()

w('## How new skills get vetted')
w()
w('Before anything is added to this catalog:')
w()
w('1. **Check the author**, not just the stars — account age, other work, independent references.')
w('2. **Read the actual `SKILL.md`** (and any scripts), not just the description.')
w('3. **Flag risk:** anything that runs a compiled binary, needs new system dependencies, or can act in the real world (especially browser automation) needs an explicit yes.')
w('4. **Python dependencies** go in a virtual environment, never system-wide.')
w()
w('To add one: add an entry to `skills/glad-personal/references/stack.json`, run `node scripts/build-catalog.js`, and commit both files.')

const text = lines.join('\n') + '\n'
if (process.argv.includes('--check')) {
  const current = fs.existsSync(outPath) ? fs.readFileSync(outPath, 'utf8') : ''
  if (current !== text) {
    console.error('catalog/README.md is out of date — run: node scripts/build-catalog.js')
    process.exit(1)
  }
  console.log('catalog/README.md is up to date.')
} else {
  fs.mkdirSync(path.dirname(outPath), { recursive: true })
  fs.writeFileSync(outPath, text)
  console.log(`Wrote ${path.relative(root, outPath)} (${s.own.length} own, ${s.skills.length} third-party, ${s.plugins.length} plugins).`)
}
