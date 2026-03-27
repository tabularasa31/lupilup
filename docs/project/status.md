# Current Status

Last updated: 2026-03-27

## Overall

The Flutter migration is live in the repository and is now the main app under active development. Core flows are working across iOS and Android against the shared Supabase project.

## Done

- Flutter client created in [flutter_app](/Users/tabularasa/Projects/lupilup/flutter_app)
- iOS and Android projects generated and configured
- Supabase connected from Flutter
- Deep links configured for:
  - `lupilup://auth/callback`
  - `lupilup://oauth/ravelry`
- Google auth flow working
- Bootstrap and onboarding flow working
- Ravelry onboarding flow wired to existing backend contract
- Stash list refreshed to the new compact `Yarn` layout
- Stash manual add/edit flow working
- Scanner entry now routes from the centered FAB, with manual add available from the `Scan` screen
- Projects list, create flow, and finish flow working
- Project cards restyled to match the stash card system
- Project finish flow now updates linked leftover yarn weights
- Stash and project state now refresh more reliably across iOS and Android
- Settings screen and unit toggle working
- Shared data now persists across iOS and Android through Supabase
- Visual polish pass completed for `Stash`, `Projects`, and `Settings`
- Custom app icon and brand wordmark added to Flutter app
- `finished_at` migration file added for projects

## In Progress

- Scanner is in temporary safe-mode without ML Kit OCR on iOS simulator
- Final Flutter polish is still being applied screen by screen
- `finished_at` still needs to be applied to the live Supabase project so completed projects can persist an explicit finish date everywhere

## Known Constraints

- iOS simulator cannot use the current ML Kit setup cleanly on Apple Silicon, so scanner is temporarily stubbed there
- Until the `finished_at` DB migration is applied, the app falls back gracefully and still saves project status without the finish timestamp
- Some temporary product gaps remain in scanner and detail flows

## Next Milestones

- Polish `Scanner` UX and visual design
- Apply the `finished_at` migration to the live Supabase project
- Improve form polish for add/edit flows
- Decide when the RN reference app can stop being kept in the repo
- Prepare a cleaner beta-ready QA pass across both platforms
