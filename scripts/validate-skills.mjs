#!/usr/bin/env node
// Validates every skill in skills/ and the plugin marketplace manifest.
// Run from the repository root: node scripts/validate-skills.mjs
// Exits 1 when any check fails. No dependencies.
import { readFileSync, readdirSync, existsSync, statSync } from 'node:fs';
import { join, dirname, resolve } from 'node:path';

const root = resolve(new URL('..', import.meta.url).pathname);
const problems = [];
const fail = (where, msg) => problems.push(`${where}: ${msg}`);

function frontmatter(file) {
  const text = readFileSync(file, 'utf8');
  const m = text.match(/^---\n([\s\S]*?)\n---\n/);
  if (!m) return null;
  const out = { metadata: {} };
  let inMeta = false;
  for (const line of m[1].split('\n')) {
    if (/^metadata:\s*$/.test(line)) { inMeta = true; continue; }
    const kv = line.match(/^(\s*)([\w-]+):\s*(.*)$/);
    if (!kv) continue;
    const val = kv[3].replace(/^"(.*)"$/, '$1');
    if (inMeta && kv[1]) out.metadata[kv[2]] = val;
    else { inMeta = false; out[kv[2]] = val; }
  }
  return out;
}

const skillsDir = join(root, 'skills');
const skills = readdirSync(skillsDir).filter((d) => statSync(join(skillsDir, d)).isDirectory());
const versions = {};

for (const dir of skills) {
  const base = join(skillsDir, dir);
  const where = `skills/${dir}`;
  for (const f of ['SKILL.md', 'README.md', 'LICENSE']) {
    if (!existsSync(join(base, f))) fail(where, `missing ${f}`);
  }
  if (!existsSync(join(base, 'SKILL.md'))) continue;

  const fm = frontmatter(join(base, 'SKILL.md'));
  if (!fm) { fail(where, 'SKILL.md has no frontmatter'); continue; }
  if (fm.name !== dir) fail(where, `frontmatter name "${fm.name}" does not match folder`);
  if (!/^[a-z0-9-]+$/.test(fm.name || '')) fail(where, 'name must be lowercase letters, numbers and hyphens');
  if (!fm.description) fail(where, 'missing description');
  else if (fm.description.length > 1024) fail(where, `description is ${fm.description.length} chars (max 1024)`);
  if (!fm.license) fail(where, 'missing license');
  const v = fm.metadata.version;
  if (!/^\d+\.\d+\.\d+$/.test(v || '')) fail(where, 'metadata.version must be x.y.z');
  versions[dir] = v;

  // README must state the same version as SKILL.md
  if (existsSync(join(base, 'README.md'))) {
    const readme = readFileSync(join(base, 'README.md'), 'utf8');
    const rv = readme.match(/\*\*Version:\*\*\s*(\d+\.\d+\.\d+)/);
    if (rv && v && rv[1] !== v) fail(where, `README says version ${rv[1]} but SKILL.md says ${v}`);
  }
}

// Relative markdown links in every README and the changelog must resolve.
const mdFiles = ['README.md', 'CHANGELOG.md', 'CONTRIBUTING.md', 'catalog/README.md',
  ...skills.map((d) => `skills/${d}/README.md`)].filter((f) => existsSync(join(root, f)));
for (const f of mdFiles) {
  const text = readFileSync(join(root, f), 'utf8').replace(/```[\s\S]*?```/g, '');
  for (const m of text.matchAll(/\]\((?!https?:|mailto:|#)([^)\s#]+)(?:#[^)]*)?\)/g)) {
    const target = resolve(dirname(join(root, f)), m[1]);
    if (!existsSync(target)) fail(f, `broken link ${m[1]}`);
  }
}

// Plugin marketplace manifest.
const mp = join(root, '.claude-plugin/marketplace.json');
if (existsSync(mp)) {
  let data;
  try { data = JSON.parse(readFileSync(mp, 'utf8')); } catch (e) { fail('.claude-plugin/marketplace.json', `invalid JSON: ${e.message}`); }
  for (const p of data?.plugins ?? []) {
    for (const s of p.skills ?? []) {
      const name = s.replace(/^\.\/skills\//, '');
      if (!existsSync(join(root, s, 'SKILL.md'))) fail('.claude-plugin/marketplace.json', `plugin ${p.name} points to missing ${s}`);
      else if (versions[name] && p.version !== versions[name]) fail('.claude-plugin/marketplace.json', `plugin ${p.name} is ${p.version} but SKILL.md is ${versions[name]}`);
    }
  }
}

if (problems.length) {
  console.error(`${problems.length} problem(s):\n- ${problems.join('\n- ')}`);
  process.exit(1);
}
console.log(`ok: ${skills.length} skills validated (${Object.entries(versions).map(([k, v]) => `${k}@${v}`).join(', ')})`);
