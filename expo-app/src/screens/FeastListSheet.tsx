// Every feast and solemnity in the coming year, in date order.

import { FlatList, Pressable, StyleSheet, Text, View } from 'react-native';
import { formatLong, type Day } from '../days';
import { Sheet } from '../components/Sheet';
import { useTheme } from '../theme';

interface Props {
  visible: boolean;
  days: Day[];
  onSelect: (index: number) => void;
  onClose: () => void;
}

export function FeastListSheet({ visible, days, onSelect, onClose }: Props) {
  const t = useTheme();
  const feasts = days.map((day, index) => ({ day, index })).filter(({ day }) => day.feastName);

  return (
    <Sheet visible={visible} title="Feasts & Solemnities" onClose={onClose}>
      <FlatList
        data={feasts}
        keyExtractor={({ index }) => String(index)}
        ItemSeparatorComponent={() => <View style={{ height: StyleSheet.hairlineWidth, backgroundColor: t.hairline }} />}
        renderItem={({ item: { day, index } }) => (
          <Pressable onPress={() => onSelect(index)} style={styles.row} accessibilityRole="button">
            <View style={[styles.swatch, { backgroundColor: day.color.hex, borderColor: t.hairline }]} />
            <View style={{ flex: 1 }}>
              <Text style={[styles.name, { color: t.text }]}>
                {day.isSolemnity && <Text style={{ color: t.star }}>★ </Text>}
                {day.feastName}
              </Text>
              <Text style={[styles.date, { color: t.muted }]}>{formatLong(day.date)}</Text>
            </View>
          </Pressable>
        )}
        contentContainerStyle={styles.list}
      />
    </Sheet>
  );
}

const styles = StyleSheet.create({
  list: { maxWidth: 680, width: '100%', alignSelf: 'center', paddingHorizontal: 16 },
  row: { flexDirection: 'row', alignItems: 'center', gap: 12, paddingVertical: 12 },
  swatch: { width: 18, height: 18, borderRadius: 3, borderWidth: 2 },
  name: { fontSize: 16, fontWeight: '600' },
  date: { fontSize: 14, marginTop: 3 },
});
