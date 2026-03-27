/**
 * Design tokens — same hex values as `tailwind.config.js` (NativeWind).
 * `accent`: FAB and primary CTAs only (per SRS).
 */
export const colors = {
  background: '#F5F5F0',
  surface: '#FFFFFF',
  border: '#F0EDE8',
  borderStrong: '#E8E4DE',
  textPrimary: '#333333',
  textSecondary: '#999999',
  textTertiary: '#CCCCCC',
  accent: '#D4A5A5',
  progressBar: '#C8C4BE',
  success: '#7DB87D',
  warning: '#E0A840',
  danger: '#E08080',
} as const;

export type ColorToken = keyof typeof colors;
