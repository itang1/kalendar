// One square of the grid: colored by the day's liturgical color, with a dot
// for a feast, a star for a solemnity, a square for notes, and a diamond for
// a U.S. holiday. Mirrors DayCardView in the iPhone app.

import { memo } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { formatShort, markColor, type Day } from '../days';
import { useTheme } from '../theme';

interface Props {
  day: Day;
  size: number;
  isToday: boolean;
  hasNotes: boolean;
  onPress: () => void;
}

export const DayTile = memo(function DayTile({ day, size, isToday, hasNotes, onPress }: Props) {
  const t = useTheme();
  const mark = markColor(day.color.key);

  let label = `${formatShort(day.date)}, ${day.season}`;
  if (day.feastName) label += day.isSolemnity ? `, ${day.feastName} (solemnity)` : `, ${day.feastName}`;
  if (day.civilHolidayName) label += `, ${day.civilHolidayName}`;
  if (hasNotes) label += ', has notes';

  return (
    <Pressable
      onPress={onPress}
      accessibilityRole="button"
      accessibilityLabel={label}
      style={({ pressed }) => [
        styles.tile,
        {
          width: size,
          height: size,
          backgroundColor: day.color.hex,
          borderColor: isToday ? t.text : t.hairline,
          borderWidth: isToday ? 2.5 : 2,
          opacity: pressed ? 0.75 : 1,
        },
      ]}
    >
      {day.isSolemnity ? (
        <Text style={[styles.star, { color: mark }]}>★</Text>
      ) : day.feastName ? (
        <View style={[styles.dot, { backgroundColor: mark }]} />
      ) : null}
      {hasNotes && <View style={[styles.noteMark, { backgroundColor: mark }]} />}
      {day.civilHolidayName && <View style={[styles.holidayMark, { backgroundColor: mark }]} />}
    </Pressable>
  );
});

const styles = StyleSheet.create({
  tile: { borderRadius: 5, alignItems: 'center', justifyContent: 'center' },
  dot: { width: 7, height: 7, borderRadius: 3.5 },
  star: { fontSize: 11, lineHeight: 13 },
  noteMark: { position: 'absolute', right: 3, bottom: 3, width: 5, height: 5, borderRadius: 1.5 },
  holidayMark: { position: 'absolute', left: 3, bottom: 3, width: 5, height: 5, transform: [{ rotate: '45deg' }] },
});
