
- Spark Mac: build VALID + metadata staged (version 1.0, id 2ecadabc). Remaining: verify metadata applied, upload screenshot (metadata/../spark-mac-1.png), submit via `asc release submit`. Screenshot saved at macos/screenshots/spark-mac-1.png

- Fn-cap headroom (2026-07-05): 10/12 used. When needed, merge api/posts/[id]/index.js + vote.js into api/posts.js dispatch (rewrite /api/posts/:id(/vote) in vercel.json) → frees 2 slots. Mechanical, ~30min. Deferred, no feature currently blocked.

## From Icons.pdf / Asc.pdf (imported 2026-07-12)
- [ ] Sparkjar iOS: 4 screenshots + archive/upload; App Group entitlement still empty on regenerated profiles
- [ ] Spark Mac 1.0: build + metadata + submit

## 2026-07-14 dump
- [ ] Hook up AI (Gemini preferred — check existing integration; Qwen fallback) for idea generation
- [ ] After AI works: infinite scroll + pagination on Ideas page
- [ ] Landing page + registration/onboarding flow
- [ ] Fix broken Create view
- [ ] Replace purple app icon with correct branding; bump version

## App Store submission (parked 2026-07-14, wrap-up)
- [ ] 4 screenshots (fastlane snapshot, iPhone 11 Pro Max / 14 Plus sims)
- [ ] archive + upload build (asc workflow run ship-ios)
- [ ] submit

## From Spark.pdf (imported 2026-07-14)
- [ ] Mac ASC: remove purple icon, replace with correct branding (same complaint as root roadmap purple-icon item, tracked here for Spark specifically)

## From Sparkjar.pdf (imported 2026-07-19)
- [ ] Duplicate of existing item above (Mac ASC purple icon) but reconfirmed still broken in TestFlight as of 2026-07-19 — icon still showing purple placeholder instead of correct branding.
- [ ] URL needs fixing — stale domain/name reference somewhere in-app or in metadata (repo/app renamed spark→sparkjar 2026-07-18, bundle ID com.heyitsmejosh.spark→sparkjar rename still pending per root roadmap). Likely the same underlying rename-in-progress issue, not a separate bug — check support URL / in-app links against `sparkjar.heyitsmejosh.com` once bundle ID rename lands.
