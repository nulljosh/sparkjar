
- [x] Spark Mac 1.0: build + metadata + submit — SUBMITTED 2026-07-21 night. `.asc/workflow.json`'s `MAC_APP_ID: 6786482755` was a stale/invalid placeholder (that app ID doesn't exist in ASC); the Mac build was actually already uploaded under the *same* app record as iOS, `6785162492` (`com.heyitsmejosh.spark`, minOS 14.0 builds present — Mac was already merged into the shared bundle ID, no separate Mac app record ever existed or was needed). No MAC_OS version existed yet though — created one (`asc versions create --app 6785162492 --version 1.0 --platform MAC_OS`), attached build `b0d5496b` (build "3", minOS 14.0), fixed 3 blocking validate errors (description copied from iOS localization, build encryption set via `asc builds update --uses-non-exempt-encryption=false`, screenshot uploaded via `asc screenshots upload --device-type APP_DESKTOP` using the already-on-disk `macos/screenshots/spark-mac-1.png`), then `asc review submit --platform MAC_OS --confirm`. Submission `90772f50`. Fix the stale `MAC_APP_ID` in `.asc/workflow.json` to `6785162492` so future `ship-mac` runs target the right app.

- Fn-cap headroom (2026-07-05): 10/12 used. When needed, merge api/posts/[id]/index.js + vote.js into api/posts.js dispatch (rewrite /api/posts/:id(/vote) in vercel.json) → frees 2 slots. Mechanical, ~30min. Deferred, no feature currently blocked.

## From Icons.pdf / Asc.pdf (imported 2026-07-12)
- [ ] Sparkjar iOS: 4 screenshots + archive/upload — verified 2026-07-20: archive/upload done (build 202607191845 VALID on ASC 2026-07-19), App Group entitlement fix already landed (per sparkjar/CLAUDE.md 2026-07-18). Only screenshots remain — `screenshots/ios/01-feed-6.7.png` exists but that's 1 of the needed set, not 4.
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
- [ ] Mac ASC: remove purple icon, replace with correct branding (same complaint as root roadmap purple-icon item, tracked here for Spark specifically) — reconfirmed still broken in TestFlight as of 2026-07-19 (dedup'd 2026-07-20, was tracked twice); needs visual on-device check, can't verify icon color from file bytes alone.

## From Sparkjar.pdf (imported 2026-07-19)
- [ ] Domain/bundle-ID rename not yet applied in code: `ios/`, `macos/`, `watchos/`, `widgets-*` all still hardcode `baseURL = "https://spark.heyitsmejosh.com"` and metadata's `supportUrl`/`marketingUrl` already say `sparkjar.heyitsmejosh.com` (mismatch). Verified 2026-07-20 — deliberately NOT changed here: bundle ID `com.heyitsmejosh.spark` → `sparkjar` rename is still pending per root roadmap, and this needs to land as one coordinated rename (code + bundle ID + DNS), not a partial edit.

## Stashed 2026-07-19
- [x] ship-ios workflow fixed: archive step needed --xcodebuild-flag=-skipPackagePluginValidation (SwiftLint plugin); archive+export now succeed
- [x] ship-ios publish step broken: ExportOptions.plist uses destination:upload so no local IPA exists — fixed 2026-07-20, `ios/ExportOptions.plist` destination changed to `export`; next `ship-ios` run should produce a local IPA for `asc builds upload` to attach. Not re-run/verified this pass (heavy archive step, out of scope for this fork).
- [ ] iOS 1.0 is WAITING_FOR_REVIEW (since 06-27) while 2.2.0 builds (4,5 + today) sit unattached — decide: let 1.0 review land, or cancel and submit 2.2.0. Not auto-decided.

## Account deletion audit 2026-07-20
- [x] Added delete-account parity (Guideline 5.1.1(v)) — sparkjar has its own JWT auth (not Supabase Auth), so added a new `delete-account` action to the existing consolidated api/auth.js handler (no new Vercel fn slot used). Wired deleteAccount() through SparkAPI/AppState + ProfileView on both iOS and macOS. Both build-verified.
