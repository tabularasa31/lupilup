# lupilup Project Docs

This folder is the working project hub for the Flutter migration and the product work around it.

## What lives here

- [status.md](/Users/tabularasa/Projects/lupilup/docs/project/status.md): current state of the project, what is done, what is in progress, and known blockers
- [backlog.md](/Users/tabularasa/Projects/lupilup/docs/project/backlog.md): prioritized next steps for product, engineering, and release readiness
- [decisions.md](/Users/tabularasa/Projects/lupilup/docs/project/decisions.md): important decisions and why we made them

## Working agreement

- Update `status.md` when a meaningful milestone lands or a blocker changes.
- Update `backlog.md` when priorities shift.
- Add a new entry to `decisions.md` when we make a non-obvious product or technical choice.
- Keep entries short and practical so this stays useful during active development.

## Current direction

- Flutter is now the active mobile client in [flutter_app](/Users/tabularasa/Projects/lupilup/flutter_app).
- The legacy Expo/React Native app remains in the repo only as migration reference until we fully cut over.
- Supabase remains the shared backend for auth, stash, projects, settings, and Ravelry integration.
