import { router } from 'expo-router';
import * as WebBrowser from 'expo-web-browser';
import { useState } from 'react';
import { Platform } from 'react-native';
import {
  ActivityIndicator,
  Alert,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';

import { colors } from '@/constants/colors';
import { fonts } from '@/constants/fonts';
import { supabase } from '@/lib/supabase';

WebBrowser.maybeCompleteAuthSession();

export default function LoginScreen() {
  const [googleLoading, setGoogleLoading] = useState(false);

  async function handleGoogleLogin() {
    setGoogleLoading(true);
    try {
      const redirectTo = Platform.OS === 'web'
        ? `${window.location.origin}/auth/callback`
        : 'lupilup://auth/callback';

      const { data, error } = await supabase.auth.signInWithOAuth({
        provider: 'google',
        options: {
          redirectTo,
          skipBrowserRedirect: Platform.OS !== 'web',
        },
      });

      if (error) throw error;

      if (data.url && Platform.OS !== 'web') {
        const result = await WebBrowser.openAuthSessionAsync(
          data.url,
          'lupilup://auth/callback'
        );

        if (result.type === 'success' && result.url) {
          await supabase.auth.exchangeCodeForSession(result.url);
        }
      }
    } catch {
      Alert.alert('Ошибка входа', 'Не удалось войти через Google. Попробуйте ещё раз.');
    } finally {
      setGoogleLoading(false);
    }
  }

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.logo}>lupilup</Text>
        <Text style={styles.subtitle}>your yarn, beautifully organised</Text>
      </View>

      <View style={styles.buttons}>
        <TouchableOpacity
          style={styles.primaryButton}
          onPress={handleGoogleLogin}
          disabled={googleLoading}
          activeOpacity={0.75}
          accessibilityRole="button"
          accessibilityLabel="Continue with Google"
        >
          {googleLoading ? (
            <ActivityIndicator color="#FFFFFF" />
          ) : (
            <Text style={styles.primaryButtonText}>Continue with Google</Text>
          )}
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.secondaryButton}
          onPress={() => router.push('/(auth)/magic-link')}
          activeOpacity={0.75}
          accessibilityRole="button"
          accessibilityLabel="Continue with Email"
        >
          <Text style={styles.secondaryButtonText}>Continue with Email</Text>
        </TouchableOpacity>
      </View>

      <Text style={styles.legal}>
        By continuing you agree to our Terms of Service and Privacy Policy.
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
    paddingHorizontal: 24,
    justifyContent: 'space-between',
    paddingTop: 100,
    paddingBottom: 48,
  },
  header: {
    alignItems: 'center',
  },
  logo: {
    fontFamily: fonts.serif,
    fontSize: 36,
    color: colors.textPrimary,
    letterSpacing: 0.5,
  },
  subtitle: {
    fontFamily: fonts.sansRegular,
    fontSize: 13,
    color: colors.textSecondary,
    marginTop: 8,
    letterSpacing: 0.3,
  },
  buttons: {
    gap: 12,
  },
  primaryButton: {
    backgroundColor: colors.accent,
    borderRadius: 14,
    height: 52,
    alignItems: 'center',
    justifyContent: 'center',
  },
  primaryButtonText: {
    fontFamily: fonts.sansMedium,
    fontSize: 15,
    color: '#FFFFFF',
    letterSpacing: 0.2,
  },
  secondaryButton: {
    backgroundColor: colors.surface,
    borderRadius: 14,
    height: 52,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1,
    borderColor: colors.borderStrong,
  },
  secondaryButtonText: {
    fontFamily: fonts.sansMedium,
    fontSize: 15,
    color: colors.textPrimary,
    letterSpacing: 0.2,
  },
  legal: {
    fontFamily: fonts.sansRegular,
    fontSize: 11,
    color: colors.textTertiary,
    textAlign: 'center',
    lineHeight: 16,
  },
});
