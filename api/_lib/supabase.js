function stripEnvPrefix(val) {
  // Handle env vars that arrive as KEY_NAME=value (Vercel quirk).
  // Only strip the prefix if the value starts with an uppercase identifier followed by '='.
  // This avoids mangling base64 keys that legitimately contain '=' padding.
  const m = val.match(/^[A-Z_]+=(.+)$/);
  return m ? m[1].trim() : val;
}

function getSupabaseConfig() {
  let url = stripEnvPrefix((process.env.SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL || '').trim());
  let anonKey = stripEnvPrefix((process.env.SUPABASE_ANON_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || '').trim());
  let serviceRoleKey = stripEnvPrefix((process.env.SUPABASE_SERVICE_ROLE_KEY || '').trim());

  return { url, anonKey, serviceRoleKey };
}

async function supabaseRequest(path, { method = 'GET', body, useServiceRole = false } = {}) {
  const { url, anonKey, serviceRoleKey } = getSupabaseConfig();
  const key = (useServiceRole && serviceRoleKey) ? serviceRoleKey : anonKey;
  if (!url || !key) throw new Error('supabase_not_configured');

  const res = await fetch(`${url}/rest/v1/${path}`, {
    method,
    headers: {
      apikey: key,
      Authorization: `Bearer ${key}`,
      'Content-Type': 'application/json',
      Prefer: 'return=representation'
    },
    body: body ? JSON.stringify(body) : undefined
  });

  let data = null;
  try { data = await res.json(); } catch { data = null; }

  if (!res.ok) {
    const message = (data && (data.message || data.error || JSON.stringify(data))) || `supabase_http_${res.status}`;
    const err = new Error(message);
    err.status = res.status;
    throw err;
  }

  return data;
}

async function supabaseRpc(fnName, params = {}, { useServiceRole = false } = {}) {
  const { url, anonKey, serviceRoleKey } = getSupabaseConfig();
  const key = (useServiceRole && serviceRoleKey) ? serviceRoleKey : anonKey;
  if (!url || !key) throw new Error('supabase_not_configured');

  const res = await fetch(`${url}/rest/v1/rpc/${fnName}`, {
    method: 'POST',
    headers: {
      apikey: key,
      Authorization: `Bearer ${key}`,
      'Content-Type': 'application/json',
      Prefer: 'return=representation'
    },
    body: JSON.stringify(params)
  });

  let data = null;
  try { data = await res.json(); } catch { data = null; }

  if (!res.ok) {
    const message = (data && (data.message || data.error || JSON.stringify(data))) || `supabase_http_${res.status}`;
    const err = new Error(message);
    err.status = res.status;
    throw err;
  }

  return data;
}

module.exports = {
  getSupabaseConfig,
  supabaseRequest,
  supabaseRpc
};
