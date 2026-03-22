/** Color tokens mirror `constants/colors.ts` — update both when changing palette. */
/** @type {import('tailwindcss').Config} */
module.exports = {
  // Required for NativeWind on web — avoids "dark mode is type 'media'" runtime error
  // when something toggles color scheme (e.g. Expo Router / RN Web). See nativewind#1489.
  darkMode: 'class',
  content: ['./app/**/*.{js,jsx,ts,tsx}', './components/**/*.{js,jsx,ts,tsx}'],
  presets: [require('nativewind/preset')],
  theme: {
    extend: {
      colors: {
        background: '#F5F5F0',
        surface: '#FFFFFF',
        border: '#F0EDE8',
        accent: '#D4A5A5',
        'progress-bar': '#C8C4BE',
        'text-primary': '#333333',
        'text-secondary': '#999999',
      },
      fontFamily: {
        serif: ['PlayfairDisplay_600SemiBold'],
        sans: ['Montserrat_400Regular'],
        'sans-medium': ['Montserrat_500Medium'],
      },
    },
  },
  plugins: [],
};
