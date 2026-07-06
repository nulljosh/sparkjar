# Spark Technical Whitepaper

**v2.2.0** | July 2026

Spark is an idea-sharing platform: post an idea, vote it up, argue in the
comments, and let an LLM turn the good ones into build plans. Live at
[spark.heyitsmejosh.com](https://spark.heyitsmejosh.com), with native iOS,
macOS, and watchOS companions.

## Core Mechanic: Ideas as First-Class Objects

An idea is a post with a category, tags, votes, and comment threads — plus two
AI-generated attachments:

- **Enrichment (SPEC + PLAN)** — a Claude daemon
  (`daemon/spark-daemon.js`) picks up new ideas and writes a product spec and
  an implementation plan for each, turning a one-liner into something
  buildable.
- **Idea Bases** — AI-generated idea clusters seeded from a topic, so an empty
  feed can bootstrap itself.

Ranking is Hot/New with optimistic-UI upvotes; category and tag filters
(tech, design, business, random) slice the feed. New users see curated seed
ideas, and the frontend falls back to seed data if Supabase is unreachable.

## Architecture

- **Frontend**: one `index.html` — all HTML, CSS, and JS, no build step.
  Responsive CSS grid feed (auto-fill, 320px min columns), PWA with offline
  support, dark/light toggle.
- **API**: Vercel serverless functions. The Hobby plan caps a project at 12
  functions, so auth is consolidated into shared handlers — 10/12 used, and
  new endpoints must fit that budget.
- **Auth**: JWT with sign up/login, GitHub OAuth, ToS gate on register, and
  Face ID / Touch ID on iOS.
- **Database**: Supabase PostgreSQL with RLS enabled. This project is the
  shared free-tier database — lexly and other apps ride on it, so migrations
  here are effectively multi-tenant changes.
- **Daemon**: `spark-daemon.js` runs on demand (`--once`) rather than as a
  resident process, per the no-background-automation house rule.

## Platforms

| Platform | Version | Status |
|---|---|---|
| Web (PWA) | v2.1.0 | Live |
| iOS | v2.1.0 | App Store submission in progress |
| macOS | v1.0.0 | Uploaded to ASC, processing |
| watchOS | v1.0.0 | Bundled with iOS |

## Security

- RLS on every table; JWT secret rotated 2026-05-09.
- Known debt: an old `.env` lives in three historical commits (no longer
  tracked) — purge via `git filter-repo` is on the roadmap.
