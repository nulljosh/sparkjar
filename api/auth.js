// ponytail: one function for all auth routes — Vercel Hobby caps deployments at 12 fns
const handlers = {
  apple: require('./_lib/auth/apple'),
  github: require('./_lib/auth/github'),
  'github-callback': require('./_lib/auth/github-callback'),
  login: require('./_lib/auth/login'),
  'password-reset': require('./_lib/auth/password-reset'),
  register: require('./_lib/auth/register')
};

module.exports = async function handler(req, res) {
  const action = (req.query || {}).action || (req.url.match(/^\/api\/auth\/([\w-]+)/) || [])[1];
  const fn = handlers[action];
  if (!fn) return res.status(404).json({ error: 'Not found' });
  return fn(req, res);
};
