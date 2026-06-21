'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');

const NOTES_DIR = path.join(os.homedir(), '.spark', 'notes');

function ensureNotesDir() {
  fs.mkdirSync(NOTES_DIR, { recursive: true });
}

function exportPost(post) {
  ensureNotesDir();
  const lines = [
    '---',
    `id: ${post.id}`,
    `title: ${post.title}`,
    `category: ${post.category || 'tech'}`,
    `score: ${post.score || 0}`,
    post.linked_repo ? `repo: ${post.linked_repo}` : null,
    `created_at: ${post.created_at || new Date().toISOString()}`,
    '---',
    '',
    `# ${post.title}`,
    '',
    post.content || '',
  ];

  if (post.enrichment_spec) {
    lines.push('', '## Spec', '', post.enrichment_spec);
  }
  if (post.enrichment_plan) {
    lines.push('', '## Plan', '', post.enrichment_plan);
  }

  const content = lines.filter(l => l !== null).join('\n');
  const filepath = path.join(NOTES_DIR, `${post.id}.md`);
  fs.writeFileSync(filepath, content, 'utf-8');
  return filepath;
}

function parseImport(filepath) {
  const raw = fs.readFileSync(filepath, 'utf-8');
  const fmMatch = raw.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
  if (!fmMatch) throw new Error('Invalid note format: missing frontmatter');

  const fm = {};
  for (const line of fmMatch[1].split('\n')) {
    const idx = line.indexOf(':');
    if (idx < 0) continue;
    fm[line.slice(0, idx).trim()] = line.slice(idx + 1).trim();
  }

  // Strip markdown heading and extract content
  let body = fmMatch[2].trim();
  body = body.replace(/^#[^\n]*\n/, '').trim();
  // Remove enrichment sections if present
  const specIdx = body.indexOf('\n## Spec');
  const planIdx = body.indexOf('\n## Plan');
  const cutAt = Math.min(
    specIdx >= 0 ? specIdx : Infinity,
    planIdx >= 0 ? planIdx : Infinity
  );
  const content = cutAt < Infinity ? body.slice(0, cutAt).trim() : body;

  return {
    title: fm.title || path.basename(filepath, '.md'),
    content,
    category: fm.category || 'tech',
    linked_repo: fm.repo || null
  };
}

module.exports = { exportPost, parseImport, NOTES_DIR };
