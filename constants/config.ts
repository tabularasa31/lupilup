/**
 * Supabase URL/key as in the Supabase dashboard.
 * Expo inlines only `EXPO_PUBLIC_*` into the client bundle.
 */
export const SUPABASE_URL = process.env.EXPO_PUBLIC_SUPABASE_URL ?? '';
export const SUPABASE_ANON_KEY = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY ?? '';
