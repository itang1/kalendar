// A month calendar limited to the year on screen; tapping a date opens it.
// Built by hand so it looks and works the same on Android and the web.

import { useEffect, useState } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { sameDay, type Day } from '../days';
import { Sheet } from '../components/Sheet';
import { useTheme } from '../theme';

interface Props {
  visible: boolean;
  days: Day[];
  onSelect: (index: number) => void;
  onClose: () => void;
}

const monthTitle = new Intl.DateTimeFormat(undefined, { month: 'long', year: 'numeric' });
const weekdayInitials = (() => {
  const f = new Intl.DateTimeFormat(undefined, { weekday: 'narrow' });
  // Jan 4, 1970 was a Sunday.
  return Array.from({ length: 7 }, (_, i) => f.format(new Date(1970, 0, 4 + i)));
})();

export function JumpToDateSheet({ visible, days, onSelect, onClose }: Props) {
  const t = useTheme();
  const first = days[0]?.date ?? new Date();
  const last = days[days.length - 1]?.date ?? new Date();
  const [month, setMonth] = useState(() => new Date(first.getFullYear(), first.getMonth(), 1));

  useEffect(() => {
    if (visible) setMonth(new Date(first.getFullYear(), first.getMonth(), 1));
  }, [visible]); // eslint-disable-line react-hooks/exhaustive-deps

  const canGoBack = month > new Date(first.getFullYear(), first.getMonth(), 1);
  const canGoForward = month < new Date(last.getFullYear(), last.getMonth(), 1);
  const daysInMonth = new Date(month.getFullYear(), month.getMonth() + 1, 0).getDate();
  const leading = month.getDay();
  const cells: (Date | null)[] = [
    ...Array.from({ length: leading }, () => null),
    ...Array.from({ length: daysInMonth }, (_, i) => new Date(month.getFullYear(), month.getMonth(), i + 1)),
  ];

  const shift = (n: number) => setMonth(new Date(month.getFullYear(), month.getMonth() + n, 1));

  return (
    <Sheet visible={visible} title="Jump to a Day" onClose={onClose} closeLabel="Cancel">
      <View style={styles.wrap}>
        <View style={styles.header}>
          <Arrow label="‹" enabled={canGoBack} onPress={() => shift(-1)} color={t.text} accessibilityLabel="Previous month" />
          <Text style={[styles.month, { color: t.text }]}>{monthTitle.format(month)}</Text>
          <Arrow label="›" enabled={canGoForward} onPress={() => shift(1)} color={t.text} accessibilityLabel="Next month" />
        </View>
        <View style={styles.grid}>
          {weekdayInitials.map((w, i) => (
            <Text key={`w${i}`} style={[styles.cell, styles.weekday, { color: t.muted }]}>{w}</Text>
          ))}
          {cells.map((date, i) => {
            if (!date) return <View key={`e${i}`} style={styles.cell} />;
            const index = days.findIndex((d) => sameDay(d.date, date));
            const day = index >= 0 ? days[index] : null;
            return (
              <Pressable
                key={i}
                disabled={!day}
                onPress={() => onSelect(index)}
                style={styles.cell}
                accessibilityRole="button"
                accessibilityLabel={date.toDateString()}
              >
                <View style={[styles.dayCircle, day && { borderColor: day.color.hex }]}>
                  <Text style={{ color: day ? t.text : t.muted, opacity: day ? 1 : 0.4, fontSize: 16 }}>{date.getDate()}</Text>
                </View>
              </Pressable>
            );
          })}
        </View>
      </View>
    </Sheet>
  );
}

function Arrow({ label, enabled, onPress, color, accessibilityLabel }: {
  label: string; enabled: boolean; onPress: () => void; color: string; accessibilityLabel: string;
}) {
  return (
    <Pressable onPress={onPress} disabled={!enabled} hitSlop={12} accessibilityRole="button" accessibilityLabel={accessibilityLabel}>
      <Text style={{ color, fontSize: 30, opacity: enabled ? 1 : 0.25, paddingHorizontal: 12 }}>{label}</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  wrap: { padding: 16, maxWidth: 460, width: '100%', alignSelf: 'center' },
  header: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 },
  month: { fontSize: 18, fontWeight: '700' },
  grid: { flexDirection: 'row', flexWrap: 'wrap' },
  cell: { width: `${100 / 7}%`, aspectRatio: 1, alignItems: 'center', justifyContent: 'center' },
  weekday: { fontSize: 13, fontWeight: '600', textAlign: 'center', aspectRatio: undefined, paddingVertical: 6 },
  dayCircle: { width: 38, height: 38, borderRadius: 19, borderWidth: 2.5, borderColor: 'transparent', alignItems: 'center', justifyContent: 'center' },
});
