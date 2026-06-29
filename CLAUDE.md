# Spark

Version: v2.2.0

## Recovery note (2026-06-21)
Local checkout and GitHub repo both went missing before this date (cause unconfirmed — no Time Machine/APFS snapshot/trash copy existed to check). Source was recovered from Vercel's deployment-files API (`GET /v8/deployments/{id}/files/{fileId}`, v6 of the same endpoint is disabled) against the latest deployment, plus the live-served frontend at spark.heyitsmejosh.com as a cross-check (the frontend is unbundled, so the served files are the actual source). Risk: any local edits made between the last deploy and the original deletion are not captured — this is the latest deployed snapshot, not necessarily the latest *written* code.

## Shipped (2026-06-28)
- [x] ToS checkbox required on register (blocks submit if unchecked) — `index.html`, `/tos.html`
- [x] GitHub Sign In/Up — `api/auth/github.js`, `api/auth/github-callback.js`
- [x] Supabase migration `006_github_oauth.sql` applied (github_id, avatar_url columns)
- [x] GITHUB_CLIENT_ID + GITHUB_CLIENT_SECRET set in Vercel production

## Rules

- No emojis
- No build step -- everything runs from index.html
- Mobile-first layout
- Respect the existing visual language; keep UI minimal and fast to scan
- Seed data fallback when Supabase is unreachable

## Run

```bash
npx serve .
npm test
node daemon/spark-daemon.js --once   # test daemon manually
```

## Layout

Feed uses CSS grid (`repeat(auto-fill, minmax(320px, 1fr))`), 3-line content clamp. No box-shadows anywhere.

## Key Files

- index.html (all frontend: HTML + CSS + JS)
- api/posts.js (GET/POST posts, seed data fallback)
- api/enrich.js (POST=user requests enrichment, GET=daemon poll, PATCH=daemon writes)
- api/idea-base.js (POST=create ideabase, GET=list, PATCH=daemon updates post_ids)
- api/notes.js (GET=export post as markdown download)
- api/_lib/supabase.js (Supabase REST wrapper)
- daemon/spark-daemon.js (local Mac daemon: polls, runs CLAUDECODE="" claude --print, patches back)
- daemon/prompts.js (Claude prompt templates for enrichment + ideabase)
- daemon/notes.js (markdown export/import helpers)
- sw.js

## Daemon

- Runs every 5 min via LaunchAgent: `~/Library/LaunchAgents/com.spark.daemon.plist`
- Invokes: `CLAUDECODE="" claude --print "..."` (no API key -- uses Claude Max)
- Secret: `SPARK_DAEMON_SECRET` env var (set in Vercel + `~/.spark/daemon.env`)
- Logs: `~/.spark/daemon.log`
- Symlink: `~/.local/bin/spark-daemon -> daemon/spark-daemon.js`

## Load LaunchAgent

```bash
launchctl load ~/Library/LaunchAgents/com.spark.daemon.plist
launchctl list | grep spark
tail -f ~/.spark/daemon.log
```

## Set Vercel Env

```bash
vercel env add SPARK_DAEMON_SECRET
# value: generate with `openssl rand -hex 32` -- never commit it.
# Must match the value in ~/.spark/daemon.env (used by the local daemon).
```

## Native Companions

| Platform | Dir | Bundle ID | Status |
|---|---|---|---|
| iOS | ios/ | com.heyitsmejosh.spark | Submission in progress, v2.1.0 build 2 |
| macOS | macos/ | com.heyitsmejosh.spark.mac | Submission in progress, v1.0.0 |
| watchOS | watchos/ | com.heyitsmejosh.spark.watchos | Bundled with iOS; no login UI (view-only without iOS pre-auth) |

Build with `xcodegen generate` in each platform dir. Screenshots in `screenshots/`.

## Migration

Run `supabase/migrations/20260410000006_llm_enrichment.sql` via Supabase SQL editor.
