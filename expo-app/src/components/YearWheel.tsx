// The whole year as colored slices, today at the top and running clockwise,
// with a tick where each month begins and its name just outside the rim.
// Mirrors KalendarWheel in the iPhone app.

import { Fragment, memo } from 'react';
import { Platform, View } from 'react-native';
import Svg, { Circle, Line, Path, Text as SvgText } from 'react-native-svg';
import type { Day } from '../days';
import { useTheme } from '../theme';

interface Props {
  days: Day[];
  size: number;
  onDayPress: (index: number) => void;
}

const monthShort = new Intl.DateTimeFormat(undefined, { month: 'short' });

/** Room outside the rim for the month names. */
const LABEL_MARGIN = 22;

/** SVG text otherwise falls back to a serif face in browsers. */
const LABEL_FONT = Platform.select({ web: 'system-ui, -apple-system, sans-serif', android: 'sans-serif', default: undefined });

/** Each month in the window: where it starts and its middle, as day indices. */
function monthSpans(days: Day[]): { start: number; mid: number; label: string }[] {
  const spans: { start: number; mid: number; label: string }[] = [];
  days.forEach((day, i) => {
    if (i === 0 || day.date.getDate() === 1) spans.push({ start: i, mid: i, label: monthShort.format(day.date) });
  });
  spans.forEach((span, k) => {
    const end = k + 1 < spans.length ? spans[k + 1].start : days.length;
    span.mid = (span.start + end) / 2;
  });
  // The window runs a few days into the month it started in; label that month
  // once, and skip any sliver too narrow to hold a name.
  return spans.filter((s, k) => {
    const end = k + 1 < spans.length ? spans[k + 1].start : days.length;
    const repeatsFirst = k > 0 && k === spans.length - 1 && s.label === spans[0].label;
    return end - s.start >= 10 && !repeatsFirst;
  });
}

function polar(c: number, r: number, index: number, total: number) {
  const a = (index / total) * 2 * Math.PI - Math.PI / 2;
  return { x: c + r * Math.cos(a), y: c + r * Math.sin(a) };
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
  const r = size / 2 - LABEL_MARGIN;
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
        {monthSpans(days).map(({ start, mid, label }) => {
          const t0 = polar(c, r + 2, start, days.length);
          const t1 = polar(c, r + 8, start, days.length);
          const at = polar(c, r + 13, mid, days.length);
          return (
            <Fragment key={start}>
              {start > 0 && <Line x1={t0.x} y1={t0.y} x2={t1.x} y2={t1.y} stroke={t.muted} strokeWidth={1.5} />}
              <SvgText x={at.x} y={at.y + 4} fontSize={11} fontWeight="600" fontFamily={LABEL_FONT} fill={t.muted} textAnchor="middle">
                {label}
              </SvgText>
            </Fragment>
          );
        })}
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
