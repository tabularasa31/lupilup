import '../global.css';

import {
  Montserrat_400Regular,
  Montserrat_500Medium,
} from '@expo-google-fonts/montserrat';
import { PlayfairDisplay_600SemiBold } from '@expo-google-fonts/playfair-display';
import { useFonts } from 'expo-font';
import * as Linking from 'expo-linking';
import { Stack } from 'expo-router';
import * as SplashScreen from 'expo-splash-screen';
import * as WebBrowser from 'expo-web-browser';
import { useEffect } from 'react';
import { View } from 'react-native';

import { colors } from '@/constants/colors';
import { supabase } from '@/lib/supabase';

void SplashScreen.preventAutoHideAsync();

// Required for OAuth redirect on iOS to close the in-app browser
WebBrowser.maybeCompleteAuthSession();

export default function RootLayout() {
  const [fontsLoaded, fontError] = useFonts({
    PlayfairDisplay_600SemiBold,
    Montserrat_400Regular,
    Montserrat_500Medium,
  });

  useEffect(() => {
    if (fontsLoaded || fontError) {
      void SplashScreen.hideAsync();
    }
  }, [fontError, fontsLoaded]);

  // Handle deep links: magic-link and OAuth redirects
  useEffect(() => {
    const handleUrl = async (url: string) => {
      if (url.includes('access_token') || url.includes('code=')) {
        await supabase.auth.exchangeCodeForSession(url).catch(() => {
          // fallback: setSession via URL fragment handled by Supabase internally
        });
      }
    };

    Linking.getInitialURL().then((url) => {
      if (url) void handleUrl(url);
    });

    const sub = Linking.addEventListener('url', ({ url }) => {
      void handleUrl(url);
    });

    return () => sub.remove();
  }, []);

  if (!fontsLoaded && !fontError) {
    return (
      <View
        style={{ flex: 1, backgroundColor: colors.background }}
        accessibilityLabel="Loading fonts"
      />
    );
  }

  return (
    <Stack
      screenOptions={{
        headerShown: false,
        contentStyle: { backgroundColor: colors.background },
      }}
    />
  );
}
