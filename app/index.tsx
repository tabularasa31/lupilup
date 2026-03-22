import { View } from 'react-native';

import { colors } from '@/constants/colors';

/** Router root placeholder — no product screens yet. */
export default function Index() {
  return (
    <View
      className="flex-1 bg-background"
      style={{ flex: 1, backgroundColor: colors.background }}
    />
  );
}
