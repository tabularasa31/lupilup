import type { TextStyle } from 'react-native';

/** PostScript names after `expo-font` load (see `app/_layout.tsx`). */
export const fonts = {
  serif: 'PlayfairDisplay_600SemiBold',
  sansRegular: 'Montserrat_400Regular',
  sansMedium: 'Montserrat_500Medium',
} as const;

export type FontToken = keyof typeof fonts;

/** Use with `style` when not using NativeWind `fontFamily` utilities. */
export const fontStyles = {
  heading: { fontFamily: fonts.serif } satisfies TextStyle,
  body: { fontFamily: fonts.sansRegular } satisfies TextStyle,
  label: { fontFamily: fonts.sansMedium } satisfies TextStyle,
} as const;
