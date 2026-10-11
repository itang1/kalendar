// The whole year as colored slices, today at the top and running clockwise.
// Mirrors KalendarWheel in the iPhone app.

import { memo } from 'react';
import { View } from 'react-native';
import Svg, { Circle, Path } from 'react-native-svg';
import type { Day } from '../days';
import { useTheme } from '../theme';

interface Props {
  days: Day[];
  size: number;
  onDayPress: (index: number) => void;
}

function wedge(index: number, total: number, c: number, r: number): string {
  const slice = (2 * Math.PI) / total;
  const a0 = index * slice - Math.PI / 2;
  const a1 = a0 + slice;
  const x0 = c + r * Math.cos(a0);
  const y0 = c + r * Math.sin(a0);
  const x1 = c + r * Math.cos(a1);
  const y1 = c + r * Math.sin(a1);
  return `M ${c} ${c} L ${x0.toFixed(2)} ${y0.toFixed(2)} A ${r} ${r} 0 0 1 ${x1.toFixed(2)} ${y1.toFixed(2)} Z`;
}

export const YearWheel = memo(function YearWheel({ days, size, onDayPress }: Props) {
  const t = useTheme();
  const c = size / 2;
  const r = size / 2 - 4;
  const markerAngle = -Math.PI / 2 + Math.PI / days.length;
  const markerR = r * 0.82;

  return (
    <View
      accessible
      accessibilityLabel={`Year wheel showing ${days.length} days colored by liturgical season, beginning with today at the top. Switch to grid view to open a specific day.`}
    >
      <Svg width={size} height={size}>
        {days.map((day, i) => (
          <Path
            key={i}
            d={wedge(i, days.length, c, r)}
            fill={day.color.hex}
            // No outline: with 366 slices, outlines pile up near the center and
            // wash it out. Adjacent days of the same color read as one band.
            onPress={() => onDayPress(i)}
          />
        ))}
        <Circle
          cx={c + markerR * Math.cos(markerAngle)}
          cy={c + markerR * Math.sin(markerAngle)}
          r={6}
          fill={t.text}
          stroke={t.canvas}
          strokeWidth={1.5}
        />
      </Svg>
    </View>
  );
});
