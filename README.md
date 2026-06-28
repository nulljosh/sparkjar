<img src="icon.svg" width="80">

# Spark

![version](https://img.shields.io/badge/version-v2.1.0-blue) ![license](https://img.shields.io/badge/license-MIT-green) [![GitHub](https://img.shields.io/badge/GitHub-nulljosh%2Fspark-black?logo=github)](https://github.com/nulljosh/spark)

Idea-sharing platform with upvoting, comments, JWT auth, and AI enrichment. Native companions for iOS, macOS, and watchOS.

[Live](https://spark.heyitsmejosh.com)

## Platforms

| Platform | Version | Status |
|---|---|---|
| Web (PWA) | v2.1.0 | Live |
| iOS | v2.1.0 | App Store submission in progress |
| macOS | v1.0.0 | App Store submission in progress |
| watchOS | v1.0.0 | Bundled with iOS |

<img src="screenshots/ios/01-feed.jpg" width="280">

## Features

- Vanilla JS -- single `index.html`, no build step
- JWT auth with sign up, login, biometric (Face ID / Touch ID on iOS)
- Category filters and Hot/New sorting
- Upvoting and trending with optimistic UI
- LLM enrichment (SPEC + PLAN) via Claude daemon
- Idea Bases: AI-generated idea clusters from a topic
- Comment threads on posts, markdown export
- Dark/light theme toggle
- PWA with offline support
- Vercel serverless + Supabase PostgreSQL (RLS enabled)
- Responsive grid layout (2-col desktop, 1-col mobile)
- Post tags (tech, design, business, random) with filter bar
- Curated seed ideas for new users

## Run

```bash
npx serve .
npm test
```

Deploy (manual, monorepo): `npx vercel --prod` from this directory.

## Database Setup (one-time)

Run this in the [Supabase SQL editor](https://supabase.com/dashboard/project/tjsxsqlxjmanwvmywwvw/sql/new) to enable pixel avatar support:

```sql
alter table users add column if not exists avatar_url text;
```

## Known Issues


## Security Roadmap

- [ ] Purge old `.env` from git history (was committed in 3 old commits, no longer tracked): `brew install git-filter-repo && git filter-repo --path spark/.env --invert-paths` then force-push

## Roadmap

- [ ] AI idea building — when a post is created, daemon auto-generates an implementation plan/code scaffold and attaches it (daemon exists at `daemon/spark-daemon.js`, needs enrichment prompt for builds)
- [x] Seed more custom ideas — populate Supabase with 20+ quality ideas across all categories
- [ ] iOS app testing — run through custom idea creation, voting, comments end-to-end
- [ ] SMTP email delivery for password reset
- [ ] Real-time updates via Supabase Realtime
- [ ] User profiles with post history
- [ ] Moderation tools

## Changelog

- v2.0.0: JWT_SECRET rotated, Supabase RLS hardened
- v1.3.0: Better seed ideas, RLS enabled on all Supabase tables, comment threads, iOS v2.0 (comments, profiles, sort, badges, 60+ tests), macOS + watchOS companions, WidgetKit widgets
- v1.2.0

## License

MIT 2026 Joshua Trommel
