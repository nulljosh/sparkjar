module.exports = async function handler(req, res) {
  // ponytail: stub — add APPLE_CLIENT_ID + APPLE_TEAM_ID to Vercel env to implement
  return res.status(501).json({ error: 'Apple Sign In not yet configured — add APPLE_CLIENT_ID and APPLE_TEAM_ID to Vercel env' });
};
