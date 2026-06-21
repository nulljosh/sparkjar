const store = new Map();

function getIp(req) {
  const fwd = req.headers['x-forwarded-for'];
  return (fwd ? fwd.split(',')[0].trim() : null) || req.socket?.remoteAddress || 'unknown';
}

function checkRateLimit(key, limit, windowMs) {
  const now = Date.now();
  const entry = store.get(key);
  if (!entry || now - entry.start > windowMs) {
    store.set(key, { start: now, count: 1 });
    return true;
  }
  if (entry.count >= limit) return false;
  entry.count++;
  return true;
}

module.exports = { getIp, checkRateLimit };
