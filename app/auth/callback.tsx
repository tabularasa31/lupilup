import { useRouter } from 'expo-router';
import { useEffect } from 'react';
import { ActivityIndicator, StyleSheet, View } from 'react-native';

import { colors } from '@/constants/colors';
import { supabase } from '@/lib/supabase';

/**
 * Web-only callback page for OAuth and magic link redirects.
 * Supabase redirects here after Google OAuth on web.
 * On native the deep link (lupilup://auth/callback) is handled in _layout.tsx.
 */
export default function AuthCallback() {
  const router = useRouter();

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      if (data.session) {
        router.replace('/(tabs)/stash');
      } else {
        router.replace('/(auth)/login');
      }
    });
  }, [router]);

  return (
    <View style={styles.container}>
      <ActivityIndicator color={colors.accent} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
