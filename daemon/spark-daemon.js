#!/usr/bin/env node
'use strict';

/**
 * Spark background daemon
 * Polls API for enrichment requests and idea base generation tasks.
 * Runs Claude CLI locally — no API key needed (uses Claude Max subscription).
 *
 * Usage: node spark-daemon.js [--once]
 * Env:   SPARK_DAEMON_SECRET, SPARK_API_URL
 */

const { execFile } = require('child_process');
const https = require('https');
const http = require('http');
const { enrichmentPrompt, ideaBasePrompt } = require('./prompts');

const API_URL = process.env.SPARK_API_URL || 'https://spark.heyitsmejosh.com';
const SECRET = process.env.SPARK_DAEMON_SECRET;
const POLL_INTERVAL_MS = 5 * 60 * 1000;
const RUN_ONCE = process.argv.includes('--once');

if (!SECRET) {
  console.error('[daemon] SPARK_DAEMON_SECRET not set');
  process.exit(1);
}

function log(msg) {
  console.log(`[${new Date().toISOString()}] ${msg}`);
}

function apiRequest(path, { method = 'GET', body } = {}) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, API_URL);
    const lib = url.protocol === 'https:' ? https : http;
    const data = body ? JSON.stringify(body) : undefined;

    const req = lib.request(url, {
      method,
      headers: {
        'Content-Type': 'application/json',
        'x-daemon-secret': SECRET,
        ...(data ? { 'Content-Length': Buffer.byteLength(data) } : {})
      }
    }, (res) => {
      let raw = '';
      res.on('data', chunk => raw += chunk);
      res.on('end', () => {
        try { resolve(JSON.parse(raw)); }
        catch { resolve(raw); }
      });
    });

    req.on('error', reject);
    if (data) req.write(data);
    req.end();
  });
}

function runClaude(prompt) {
  return new Promise((resolve, reject) => {
    execFile('claude', ['--print', prompt], {
      encoding: 'utf-8',
      timeout: 120000,
      env: { ...process.env, CLAUDECODE: '' }
    }, (err, stdout) => {
      if (err) reject(err);
      else resolve(stdout.trim());
    });
  });
}

function parseEnrichment(raw) {
  const specMatch = raw.match(/SPEC:\s*([\s\S]*?)(?=PLAN:|$)/i);
  const planMatch = raw.match(/PLAN:\s*([\s\S]*?)$/i);
  return {
    spec: specMatch ? specMatch[1].trim() : null,
    plan: planMatch ? planMatch[1].trim() : null
  };
}

function parseIdeaBase(raw) {
  const clean = raw.replace(/^```(?:json)?\n?/, '').replace(/\n?```$/, '').trim();
  try {
    return JSON.parse(clean);
  } catch {
    const match = clean.match(/\[[\s\S]*\]/);
    if (match) return JSON.parse(match[0]);
    throw new Error('Failed to parse idea base JSON');
  }
}

async function processEnrichments() {
  const { posts } = await apiRequest('/api/ai?type=enrich&needs=true');
  if (!posts || posts.length === 0) return;

  log(`Processing ${posts.length} enrichment(s) in parallel`);

  await Promise.all(posts.map(async (post) => {
    try {
      log(`Enriching: ${post.id} — ${post.title}`);
      const raw = await runClaude(enrichmentPrompt(post));
      const { spec, plan } = parseEnrichment(raw);
      await apiRequest('/api/ai?type=enrich', {
        method: 'PATCH',
        body: { id: post.id, spec, plan }
      });
      log(`Enriched: ${post.id}`);
    } catch (err) {
      log(`Error enriching ${post.id}: ${err.message}`);
    }
  }));
}

async function processIdeaBases() {
  const { ideaBases } = await apiRequest('/api/ai?type=idea-base&pending=true');
  if (!ideaBases || ideaBases.length === 0) return;

  log(`Processing ${ideaBases.length} idea base(s)`);

  for (const ib of ideaBases) {
    try {
      log(`Generating ideas for: ${ib.topic}`);
      const raw = runClaude(ideaBasePrompt(ib.topic, ib.description));
      const ideas = parseIdeaBase(raw);

      if (!Array.isArray(ideas) || ideas.length === 0) throw new Error('No ideas returned');

      const settled = await Promise.all(ideas.slice(0, 10).map(async (idea) => {
        try {
          const result = await apiRequest('/api/posts', {
            method: 'POST',
            body: { title: idea.title, content: idea.content, category: idea.category || 'tech' }
          });
          if (result.post && result.post.id) {
            await apiRequest('/api/ai?type=enrich', { method: 'POST', body: { id: result.post.id } });
            return result.post.id;
          }
        } catch (err) {
          log(`Failed to post idea "${idea.title}": ${err.message}`);
        }
        return null;
      }));
      const postIds = settled.filter(Boolean);

      await apiRequest('/api/ai?type=idea-base', {
        method: 'PATCH',
        body: { id: ib.id, post_ids: postIds }
      });

      log(`Idea base complete: ${ib.id} — ${postIds.length} ideas posted`);
    } catch (err) {
      log(`Error processing idea base ${ib.id}: ${err.message}`);
    }
  }
}

async function tick() {
  log('Daemon tick start');
  try {
    await processEnrichments();
    await processIdeaBases();
  } catch (err) {
    log(`Tick error: ${err.message}`);
  }
  log('Daemon tick done');
}

async function main() {
  log(`Spark daemon starting — API: ${API_URL}`);
  await tick();
  if (RUN_ONCE) process.exit(0);
  setInterval(tick, POLL_INTERVAL_MS);
}

main().catch(err => {
  console.error('[daemon] Fatal:', err.message);
  process.exit(1);
});
