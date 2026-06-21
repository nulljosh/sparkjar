import { describe, it, expect, beforeEach } from 'vitest';
import { createRequire } from 'module';
import fs from 'fs';

const require = createRequire(import.meta.url);

beforeEach(() => {
  try { fs.unlinkSync('/tmp/spark-users.json'); } catch {}
  try { fs.unlinkSync('/tmp/spark-sessions.json'); } catch {}
});

const { issueToken } = require('../api/_lib/store');

function createMockRes() {
  const headers = {};
  const res = {
    statusCode: null,
    body: null,
    status(code) { res.statusCode = code; return res; },
    json(data) { res.body = data; return res; },
    setHeader(key, val) { headers[key] = val; },
    getHeader(key) { return headers[key]; },
  };
  return res;
}

describe('Comments API handler', () => {
  it('should return 400 on GET without post_id', async () => {
    const handler = require('../api/comments');
    const res = createMockRes();
    await handler({ method: 'GET', query: {} }, res);
    expect(res.statusCode).toBe(400);
  });

  it('should return 401 on POST without auth', async () => {
    const handler = require('../api/comments');
    const res = createMockRes();
    await handler({
      method: 'POST',
      headers: {},
      body: { post_id: 'test-1', content: 'hello' }
    }, res);
    expect(res.statusCode).toBe(401);
  });

  it('should return 400 on POST without content', async () => {
    const user = { username: 'tester', userId: 'user-1' };
    const token = issueToken(user);
    const handler = require('../api/comments');
    const res = createMockRes();
    await handler({
      method: 'POST',
      headers: { authorization: `Bearer ${token}` },
      body: { post_id: 'test-1' }
    }, res);
    expect(res.statusCode).toBe(400);
  });

  it('should return 400 on POST with content too long', async () => {
    const user = { username: 'tester', userId: 'user-1' };
    const token = issueToken(user);
    const handler = require('../api/comments');
    const res = createMockRes();
    await handler({
      method: 'POST',
      headers: { authorization: `Bearer ${token}` },
      body: { post_id: 'test-1', content: 'x'.repeat(2001) }
    }, res);
    expect(res.statusCode).toBe(400);
  });

  it('should return 405 for unsupported methods', async () => {
    const handler = require('../api/comments');
    const res = createMockRes();
    await handler({ method: 'DELETE', query: {}, headers: {} }, res);
    expect(res.statusCode).toBe(405);
  });
});

