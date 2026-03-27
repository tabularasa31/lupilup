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

## 2026-03-27 — `+` opens Scan, with manual add inside the scanner flow

The centered FAB now opens `Scan` by default, and the `Scan` screen provides a clear `Add manually` fallback into stash editor.

Why:

- Scan remains the primary product entrypoint for adding yarn
- Manual entry still stays easy to reach when scan is not the right path
- This keeps the bottom navigation minimal without losing either workflow

## 2026-03-27 — Stash and project UI now follow one compact card system

The `Stash` and `Projects` lists now use closely related compact card patterns instead of separate visual languages.

Why:

- The product feels more coherent when stash and project lists behave like one system
- Shared spacing, hierarchy, and right-side metrics make scanning easier
- This better matches the current Flutter direction than the earlier mixed card styles

## 2026-03-27 — Use a stash polling fallback in addition to realtime

The stash repository now listens to Supabase realtime updates and also periodically refetches stash data as a reconciliation fallback.

Why:

- Realtime behaviour was not consistently updating both devices during cross-device testing
- A lightweight polling fallback improves trust in shared stash state
- This is safer for now than depending entirely on perfect websocket delivery

## 2026-03-27 — `finished_at` is optional until the live schema catches up

The app now supports a `finished_at` timestamp for projects, but save operations gracefully fall back when the live Supabase schema does not yet contain that column.

Why:

- We wanted to ship the product behaviour now without blocking on immediate DB rollout
- Completed projects should still save correctly even before the migration is applied
- This keeps the UI and data model moving forward while protecting the live app
