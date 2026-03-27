import { Redirect } from 'expo-router';
import { useEffect, useRef } from 'react';
import { Animated, StyleSheet, Text, View } from 'react-native';

import { colors } from '@/constants/colors';
import { fonts } from '@/constants/fonts';
import { useAuth } from '@/hooks/useAuth';

export default function Index() {
  const { session, isFirstTime, loading } = useAuth();
  const opacity = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.timing(opacity, {
      toValue: 1,
      duration: 600,
      useNativeDriver: true,
    }).start();
  }, [opacity]);

  if (!loading && session) {
    return <Redirect href={isFirstTime ? '/(onboarding)/ravelry-import' : '/(tabs)/stash'} />;
  }

  if (!loading && !session) {
    return <Redirect href="/(auth)/login" />;
  }

  return (
    <View style={styles.container}>
      <Animated.View style={{ opacity }}>
        <Text style={styles.logo}>lupilup</Text>
        <Text style={styles.tagline}>your yarn, beautifully organised</Text>
      </Animated.View>
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
  logo: {
    fontFamily: fonts.serif,
    fontSize: 36,
    color: colors.textPrimary,
    textAlign: 'center',
    letterSpacing: 0.5,
  },
  tagline: {
    fontFamily: fonts.sansRegular,
    fontSize: 13,
    color: colors.textSecondary,
    textAlign: 'center',
    marginTop: 8,
    letterSpacing: 0.3,
  },
});
