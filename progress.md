# lupilup — Progress Log

## Status legend
- ✅ Done
- 🚧 In progress
- ⬜ Not started

---

## Milestones

### Auth flow
- ✅ Supabase client setup (`lib/supabase.ts`)
- ✅ Database schema + RLS policies (`supabase/migrations/20260323000000_initial_schema.sql`)
- ✅ `hooks/useAuth.ts` — session listener, first-time user detection
- ✅ `app/index.tsx` — splash screen with fade-in logo, auth-based redirect
- ✅ `app/(auth)/login.tsx` — Google OAuth + magic link entry point
- ✅ `app/(auth)/magic-link.tsx` — email input, send link, confirmation screen
- ✅ `app/auth/callback.tsx` — web OAuth redirect handler
- ✅ Google OAuth configured in Supabase + Google Cloud Console
- ✅ Design tokens updated (`colors.ts` — borderStrong, textTertiary, success, warning, danger)

### Onboarding
- ⬜ `app/(onboarding)/ravelry-import.tsx` — connect Ravelry or skip

### Stash (core feature)
- ⬜ `app/(tabs)/stash.tsx` — stash list screen
- ⬜ `components/stash/YarnCard.tsx`
- ⬜ `components/stash/StashList.tsx`
- ⬜ `components/stash/FilterPills.tsx`
- ⬜ `hooks/useStash.ts`

### Scanner
- ⬜ `app/(tabs)/scan.tsx`
- ⬜ ML Kit OCR integration
- ⬜ Gemini label parsing
- ⬜ Ravelry yarn enrichment
- ⬜ Duplicate detection

### Projects
- ⬜ `app/(tabs)/projects.tsx`
- ⬜ Finish project flow (leftover weight input)

### Account & Settings
- ⬜ Unit system toggle (metric / imperial)
- ⬜ Ravelry disconnect
- ⬜ Premium upgrade flow

---

## Last updated
2026-03-23 — Auth flow complete, pushed to `feature/auth-flow`
