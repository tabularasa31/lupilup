# lupilup Flutter client

This directory contains the new Flutter client that replaces the Expo/React Native app over time.

## Setup

1. Install Flutter 3.22+ locally.
2. Copy `flutter_app/.env.example` to `flutter_app/.env`.
3. Run `flutter pub get`.
4. Run `flutter run`.

## Environment variables

```env
SUPABASE_URL=
SUPABASE_ANON_KEY=
RAVELRY_CLIENT_ID=
RAVELRY_AUTHORIZE_URL=https://www.ravelry.com/oauth/authorize
RAVELRY_REDIRECT_URI_SCHEME=lupilup://oauth/ravelry
SUPABASE_RAVELRY_EXCHANGE_FUNCTION=ravelry-exchange-token
```

## Notes

- Deep links expected by the app:
  - `lupilup://auth/callback`
  - `lupilup://oauth/ravelry`
- The Supabase schema and the `ravelry-exchange-token` edge function are reused from the existing project.
- The current React Native app remains in the repo as migration reference until the Flutter client fully replaces it.

