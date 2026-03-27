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
- Stash list and manual add/edit flow working
- Projects list and create flow working
- Settings screen and unit toggle working
- Shared data now persists across iOS and Android through Supabase
- Visual polish pass completed for `Stash`, `Projects`, and `Settings`
- Custom app icon and brand wordmark added to Flutter app
- Supabase migration applied to the live project

## In Progress

- Scanner is in temporary safe-mode without ML Kit OCR on iOS simulator
- Flutter design parity with the original RN direction is still being improved screen by screen

## Known Constraints

- iOS simulator cannot use the current ML Kit setup cleanly on Apple Silicon, so scanner is temporarily stubbed there
- Some temporary product gaps remain in scanner and detail flows
- The PR title/body on GitHub is outdated and should be refreshed to match the Flutter migration scope

## Next Milestones

- Polish `Scanner` UX and visual design
- Improve form polish for add/edit flows
- Decide when the RN reference app can stop being kept in the repo
- Prepare a cleaner beta-ready QA pass across both platforms
