// Unified AI handler — enrich, idea-base, notes
// Routes by ?type= to stay under Vercel Hobby 12-function limit.
const { supabaseRequest } = require('./_lib/supabase');
const { parseToken } = require('./posts');
const { getIp, checkRateLimit } = require('./_lib/ratelimit');

// --- enrich ---

async function handleEnrich(req, res) {
  if (req.method === 'POST') {
    const user = parseToken(req.headers.authorization, req.headers.cookie);
    if (!user) return res.status(401).json({ error: 'Authentication required' });
    if (!checkRateLimit('enrich:' + getIp(req), 5, 60_000)) {
      return res.status(429).json({ error: 'Too many requests' });
    }

    const { id, spec, plan } = req.body || {};
    if (!id || !spec || !plan) return res.status(400).json({ error: 'id, spec, plan required' });

    await supabaseRequest(`posts?id=eq.${encodeURIComponent(id)}`, {
      method: 'PATCH',
      body: {
        enriched: true,
        enrichment_plan: plan,
        enrichment_spec: spec,
        enrichment_completed_at: new Date().toISOString()
      },
      useServiceRole: true
    });

    return res.status(200).json({ ok: true });
  }

  return res.status(405).json({ error: 'Method not allowed' });
}

// --- idea-base ---

async function handleIdeaBase(req, res) {
  if (req.method === 'GET') {
    const rows = await supabaseRequest('idea_bases?order=created_at.desc&limit=50');
    return res.status(200).json({ ideaBases: Array.isArray(rows) ? rows : [] });
  }

  if (req.method === 'POST') {
    const user = parseToken(req.headers.authorization, req.headers.cookie);
    if (!user) return res.status(401).json({ error: 'Authentication required' });
    if (!checkRateLimit('ideabase:' + getIp(req), 2, 60_000)) {
      return res.status(429).json({ error: 'Too many requests' });
    }

    const { topic, description, post_ids } = req.body || {};
    if (!topic || typeof topic !== 'string' || topic.length > 200) {
      return res.status(400).json({ error: 'topic required (max 200 chars)' });
    }
    if (!Array.isArray(post_ids)) {
      return res.status(400).json({ error: 'post_ids array required' });
    }

    const rows = await supabaseRequest('idea_bases', {
      method: 'POST',
      body: {
        topic,
        description: description || null,
        post_ids,
        created_by: user.userId,
        created_at: new Date().toISOString()
      },
      useServiceRole: true
    });

    const row = Array.isArray(rows) ? rows[0] : rows;
    return res.status(201).json({ ideaBase: row });
  }

  return res.status(405).json({ error: 'Method not allowed' });
}

// --- rfs (YC Requests for Startups, scraped + cached) ---

let rfsCache = { items: null, ts: 0 };
const RFS_TTL_MS = 12 * 60 * 60 * 1000;
const RFS_ENTRY_RE = /<div id="([\w-]+)"><div class="border[^"]*py-10[^"]*"><div class="w-full"><div class="mb-6"><h3[^>]*>([^<]+)<span.*?<\/h3><span[^>]*>By<!-- --> (.*?)<\/a><\/span><\/div>.*?whitespace-pre-wrap[^>]*>(.*?)<\/div><\/div><\/div><\/div><\/div><\/div>/gs;

function stripTags(s) {
  return s.replace(/<[^>]+>/g, '').replace(/&#x27;/g, "'").replace(/&amp;/g, '&').replace(/\s+/g, ' ').trim();
}

async function fetchRfs() {
  const res = await fetch('https://www.ycombinator.com/rfs', { headers: { 'User-Agent': 'Mozilla/5.0' } });
  if (!res.ok) throw new Error(`YC fetch failed: ${res.status}`);
  const html = await res.text();
  const items = [];
  let m;
  while ((m = RFS_ENTRY_RE.exec(html))) {
    items.push({
      slug: m[1],
      title: m[2].trim(),
      author: stripTags(m[3]),
      description: stripTags(m[4]),
      url: `https://www.ycombinator.com/rfs#${m[1]}`
    });
  }
  return items;
}

async function handleRfs(req, res) {
  if (req.method !== 'GET') return res.status(405).json({ error: 'Method not allowed' });

  const fresh = rfsCache.items && (Date.now() - rfsCache.ts) < RFS_TTL_MS;
  if (!fresh) {
    try {
      const items = await fetchRfs();
      if (items.length) rfsCache = { items, ts: Date.now() };
    } catch (err) {
      console.error('[AI] rfs fetch failed', err.message);
      // ponytail: serve stale cache on fetch failure, only 500 if we have nothing
      if (!rfsCache.items) return res.status(502).json({ error: 'Could not fetch YC RFS' });
    }
  }

  return res.status(200).json({ rfs: rfsCache.items || [], cachedAt: rfsCache.ts });
}

// --- notes ---

async function handleNotes(req, res) {
  if (req.method !== 'GET') return res.status(405).json({ error: 'Method not allowed' });

  const id = req.query && req.query.id;
  if (!id) return res.status(400).json({ error: 'id required' });

  const rows = await supabaseRequest(
    `posts?id=eq.${encodeURIComponent(id)}&select=id,title,content,category,score,linked_repo,enrichment_plan,enrichment_spec,created_at`
  );

  if (!Array.isArray(rows) || rows.length === 0) {
    return res.status(404).json({ error: 'Post not found' });
  }

  const p = rows[0];
  const lines = [
    `---`,
    `id: ${p.id}`,
    `title: ${p.title}`,
    `category: ${p.category || 'tech'}`,
    `score: ${p.score || 0}`,
    p.linked_repo ? `repo: ${p.linked_repo}` : null,
    `created_at: ${p.created_at}`,
    `---`,
    ``,
    `# ${p.title}`,
    ``,
    p.content,
  ];

  if (p.enrichment_spec) lines.push('', '## Spec', '', p.enrichment_spec);
  if (p.enrichment_plan) lines.push('', '## Plan', '', p.enrichment_plan);

  const markdown = lines.filter(l => l !== null).join('\n');
  res.setHeader('Content-Type', 'text/markdown; charset=utf-8');
  res.setHeader('Content-Disposition', `attachment; filename="spark-${p.id}.md"`);
  return res.status(200).send(markdown);
}

// --- router ---

module.exports = async function handler(req, res) {
  try {
    const type = req.query && req.query.type;
    if (type === 'enrich') return await handleEnrich(req, res);
    if (type === 'idea-base') return await handleIdeaBase(req, res);
    if (type === 'notes') return await handleNotes(req, res);
    if (type === 'rfs') return await handleRfs(req, res);
    return res.status(400).json({ error: 'type required: enrich | idea-base | notes | rfs' });
  } catch (err) {
    console.error('[AI]', err.message);
    return res.status(500).json({ error: 'Internal server error' });
  }
};
