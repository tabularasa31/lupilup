/**
 * Design tokens — same hex values as `tailwind.config.js` (NativeWind).
 * `accent`: FAB and primary CTAs only (per SRS).
 */
export const colors = {
  background: '#F5F5F0',
  surface: '#FFFFFF',
  border: '#F0EDE8',
  textPrimary: '#333333',
  textSecondary: '#999999',
  accent: '#D4A5A5',
  progressBar: '#C8C4BE',
} as const;

export type ColorToken = keyof typeof colors;
