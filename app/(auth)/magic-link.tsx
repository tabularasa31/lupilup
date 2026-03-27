import { router } from 'expo-router';
import { useState } from 'react';
import {
  ActivityIndicator,
  Alert,
  KeyboardAvoidingView,
  Platform,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from 'react-native';

import { colors } from '@/constants/colors';
import { fonts } from '@/constants/fonts';
import { supabase } from '@/lib/supabase';

type Step = 'input' | 'sent';

export default function MagicLinkScreen() {
  const [email, setEmail] = useState('');
  const [loading, setLoading] = useState(false);
  const [step, setStep] = useState<Step>('input');

  async function handleSend() {
    const trimmed = email.trim().toLowerCase();

    if (!trimmed || !trimmed.includes('@')) {
      Alert.alert('Check your email', 'Please enter a valid email address.');
      return;
    }

    setLoading(true);
    try {
      const { error } = await supabase.auth.signInWithOtp({
        email: trimmed,
        options: {
          emailRedirectTo: 'lupilup://auth/callback',
        },
      });

      if (error) throw error;

      setStep('sent');
    } catch {
      Alert.alert('Something went wrong', 'We couldn\'t send a magic link. Try again.');
    } finally {
      setLoading(false);
    }
  }

  if (step === 'sent') {
    return (
      <View style={styles.container}>
        <View style={styles.sentContent}>
          <Text style={styles.sentEmoji}>✉️</Text>
          <Text style={styles.sentTitle}>Check your inbox</Text>
          <Text style={styles.sentBody}>
            We sent a magic link to{'\n'}
            <Text style={styles.sentEmail}>{email.trim().toLowerCase()}</Text>
          </Text>
          <Text style={styles.sentHint}>
            Tap the link in the email to sign in. It expires in 1 hour.
          </Text>
        </View>

        <TouchableOpacity
          style={styles.secondaryButton}
          onPress={() => setStep('input')}
          activeOpacity={0.75}
          accessibilityRole="button"
        >
          <Text style={styles.secondaryButtonText}>Use a different email</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
    >
      <View style={styles.topRow}>
        <TouchableOpacity
          onPress={() => router.back()}
          hitSlop={{ top: 12, bottom: 12, left: 12, right: 12 }}
          activeOpacity={0.6}
          accessibilityRole="button"
          accessibilityLabel="Go back"
        >
          <Text style={styles.backText}>← Back</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.content}>
        <Text style={styles.title}>Sign in with email</Text>
        <Text style={styles.description}>
          Enter your email and we'll send you a magic link — no password needed.
        </Text>

        <TextInput
          style={styles.input}
          value={email}
          onChangeText={setEmail}
          placeholder="you@example.com"
          placeholderTextColor={colors.textTertiary}
          keyboardType="email-address"
          autoCapitalize="none"
          autoCorrect={false}
          autoComplete="email"
          returnKeyType="send"
          onSubmitEditing={handleSend}
        />

        <TouchableOpacity
          style={[
            styles.primaryButton,
            (!email.trim() || loading) && styles.buttonDisabled,
          ]}
          onPress={handleSend}
          disabled={!email.trim() || loading}
          activeOpacity={0.75}
          accessibilityRole="button"
          accessibilityLabel="Send magic link"
        >
          {loading ? (
            <ActivityIndicator color="#FFFFFF" />
          ) : (
            <Text style={styles.primaryButtonText}>Send magic link</Text>
          )}
        </TouchableOpacity>
      </View>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
    paddingHorizontal: 24,
    paddingBottom: 48,
  },
  topRow: {
    paddingTop: 60,
    marginBottom: 40,
  },
  backText: {
    fontFamily: fonts.sansRegular,
    fontSize: 14,
    color: colors.textSecondary,
  },
  content: {
    flex: 1,
  },
  title: {
    fontFamily: fonts.serif,
    fontSize: 28,
    color: colors.textPrimary,
    marginBottom: 12,
  },
  description: {
    fontFamily: fonts.sansRegular,
    fontSize: 14,
    color: colors.textSecondary,
    lineHeight: 20,
    marginBottom: 32,
  },
  input: {
    height: 52,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: colors.borderStrong,
    backgroundColor: colors.surface,
    paddingHorizontal: 16,
    fontFamily: fonts.sansRegular,
    fontSize: 15,
    color: colors.textPrimary,
    marginBottom: 16,
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
  buttonDisabled: {
    opacity: 0.45,
  },
  // Sent state
  sentContent: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 8,
  },
  sentEmoji: {
    fontSize: 48,
    marginBottom: 24,
  },
  sentTitle: {
    fontFamily: fonts.serif,
    fontSize: 28,
    color: colors.textPrimary,
    marginBottom: 12,
    textAlign: 'center',
  },
  sentBody: {
    fontFamily: fonts.sansRegular,
    fontSize: 15,
    color: colors.textSecondary,
    textAlign: 'center',
    lineHeight: 22,
    marginBottom: 16,
  },
  sentEmail: {
    fontFamily: fonts.sansMedium,
    color: colors.textPrimary,
  },
  sentHint: {
    fontFamily: fonts.sansRegular,
    fontSize: 12,
    color: colors.textTertiary,
    textAlign: 'center',
    lineHeight: 18,
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
  },
});
