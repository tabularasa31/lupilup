# Decision Log

## 2026-03-27 — Flutter becomes the active client

We are moving active mobile development from Expo/React Native to Flutter. The RN app stays in the repository only as a reference during migration, not as the primary implementation target.

Why:

- RN velocity had become too costly for this stage of the project
- Flutter gives us a more comfortable path for continuing the product
- The existing backend could be reused without a user migration

## 2026-03-27 — Keep Supabase as the shared backend

The Flutter app continues using the existing Supabase project for auth, stash, projects, settings, and Ravelry integration.

Why:

- It preserves existing backend work
- It keeps the migration focused on the client
- It avoids unnecessary data migration risk

## 2026-03-27 — Temporary scanner safe-mode on simulator

The scanner is temporarily running in a reduced mode without ML Kit OCR on iOS simulator.

Why:

- The current ML Kit dependency blocks clean iOS simulator runs on Apple Silicon
- We wanted the rest of the app to remain testable during migration
- This keeps real product work moving while scanner is revisited separately

## 2026-03-27 — Project docs live in `docs/project`

Project status, backlog, and decisions are now tracked under [docs/project](/Users/tabularasa/Projects/lupilup/docs/project/README.md).

Why:

- The old single `progress.md` had drifted away from the real project state
- The migration now spans product, engineering, and release work
- A small docs hub is easier to maintain than one long log file
