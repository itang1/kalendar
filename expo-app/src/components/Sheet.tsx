// A full-height modal with a title bar, used for every secondary screen
// (day detail, About, feast list, jump to date).

import type { ReactNode } from 'react';
import { Modal, Pressable, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useTheme } from '../theme';

interface Props {
  visible: boolean;
  title: string;
  onClose: () => void;
  /** Optional control on the left of the title bar (e.g. Share). */
  left?: ReactNode;
  closeLabel?: string;
  children: ReactNode;
}

export function Sheet({ visible, title, onClose, left, closeLabel = 'Done', children }: Props) {
  const t = useTheme();
  return (
    <Modal visible={visible} animationType="slide" onRequestClose={onClose} presentationStyle="pageSheet">
      <SafeAreaView style={[styles.root, { backgroundColor: t.surface }]} edges={['top', 'bottom']}>
        <View style={[styles.bar, { borderBottomColor: t.hairline }]}>
          <View style={styles.side}>{left}</View>
          <Text style={[styles.title, { color: t.text }]} numberOfLines={1} accessibilityRole="header">
            {title}
          </Text>
          <View style={[styles.side, styles.right]}>
            <Pressable onPress={onClose} hitSlop={10} accessibilityRole="button">
              <Text style={[styles.done, { color: t.text }]}>{closeLabel}</Text>
            </Pressable>
          </View>
        </View>
        <View style={styles.body}>{children}</View>
      </SafeAreaView>
    </Modal>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1 },
  bar: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderBottomWidth: StyleSheet.hairlineWidth,
  },
  side: { width: 72, flexDirection: 'row' },
  right: { justifyContent: 'flex-end' },
  title: { flex: 1, textAlign: 'center', fontSize: 17, fontWeight: '600' },
  done: { fontSize: 17, fontWeight: '600' },
  body: { flex: 1 },
});
