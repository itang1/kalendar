// The calendar: a grid or wheel of the coming year, starting today. Mirrors
// ContentView + CircleCalendarView in the iPhone app. On the web this is the
// read-only "browse the calendar" page linked from the Kalendar website.

import { useCallback, useEffect, useMemo, useRef, useState, type ReactNode } from 'react';
import {
  AppState,
  Linking,
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  useWindowDimensions,
  View,
  type LayoutChangeEvent,
} from 'react-native';
import { SafeAreaProvider, SafeAreaView } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';
import { buildWindow, dayKey, sameDay, startOfToday, type Day } from './src/days';
import { loadNotes, NOTES_SUPPORTED, saveNotes, type NotesByKey } from './src/notes';
import * as notifications from './src/notifications';
import { getFlag, setFlag } from './src/settings';
import { DayTile } from './src/components/DayTile';
import { YearWheel } from './src/components/YearWheel';
import { DaySheet } from './src/screens/DaySheet';
import { AboutSheet } from './src/screens/AboutSheet';
import { FeastListSheet } from './src/screens/FeastListSheet';
import { JumpToDateSheet } from './src/screens/JumpToDateSheet';
import { Onboarding } from './src/screens/Onboarding';
import { useTheme } from './src/theme';

const IS_WEB = Platform.OS === 'web';
const GAP = 6;
const PADDING = 12;
const MAX_GRID = 1100;

const monthShort = new Intl.DateTimeFormat(undefined, { month: 'short' });
const weekdayInitials = (() => {
  const f = new Intl.DateTimeFormat(undefined, { weekday: 'narrow' });
  // Jan 4, 1970 was a Sunday.
  return Array.from({ length: 7 }, (_, i) => f.format(new Date(1970, 0, 4 + i)));
})();

/** "OCT 10" on the first tile so the grid has a starting point, "NOV" on each 1st. */
function monthLabelFor(day: Day, index: number): string | undefined {
  const d = day.date.getDate();
  if (d === 1) return monthShort.format(day.date).toUpperCase();
  if (index === 0) return `${monthShort.format(day.date).toUpperCase()} ${d}`;
  return undefined;
}

type Mode = 'grid' | 'wheel';
type OpenSheet = 'about' | 'feasts' | 'jump' | null;

export default function App() {
  return (
    <SafeAreaProvider>
      <Root />
    </SafeAreaProvider>
  );
}

function Root() {
  const t = useTheme();
  // null until the stored flag has loaded, so the intro doesn't flash.
  const [showIntro, setShowIntro] = useState<boolean | null>(IS_WEB ? false : null);

  useEffect(() => {
    if (!IS_WEB) getFlag('hasSeenOnboarding').then((seen) => setShowIntro(!seen));
  }, []);

  const finishIntro = () => {
    setShowIntro(false);
    setFlag('hasSeenOnboarding', true);
  };

  return (
    <>
      <StatusBar style={t.dark ? 'light' : 'dark'} />
      {showIntro === null ? (
        <View style={{ flex: 1, backgroundColor: t.surface }} />
      ) : showIntro ? (
        <Onboarding onDone={finishIntro} />
      ) : (
        <CalendarScreen onReplayIntro={IS_WEB ? undefined : () => setShowIntro(true)} />
      )}
    </>
  );
}

function CalendarScreen({ onReplayIntro }: { onReplayIntro?: () => void }) {
  const t = useTheme();
  const { width, height } = useWindowDimensions();
  const [days, setDays] = useState<Day[]>(() => buildWindow());
  const [notes, setNotes] = useState<NotesByKey>({});
  const [mode, setMode] = useState<Mode>('grid');
  const [selected, setSelected] = useState<number | null>(null);
  const [sheet, setSheet] = useState<OpenSheet>(null);
  const [notificationsEnabled, setNotificationsEnabled] = useState(false);
  const [gridWidth, setGridWidth] = useState(0);
  const grid = useRef<ScrollView>(null);

  // Notes and the notification preference load once.
  useEffect(() => {
    loadNotes().then(setNotes);
    getFlag('notificationsEnabled').then(setNotificationsEnabled);
  }, []);

  // The window starts today; realign it when the app returns after midnight.
  useEffect(() => {
    const sub = AppState.addEventListener('change', (state) => {
      if (state === 'active') {
        setDays((current) => (current[0] && sameDay(current[0].date, startOfToday()) ? current : buildWindow()));
      }
    });
    return () => sub.remove();
  }, []);

  // Rescheduling on each launch keeps a full year of reminders lined up, and
  // turns the toggle off if permission was revoked in system settings.
  useEffect(() => {
    if (!notificationsEnabled) return;
    notifications.isAuthorized().then((ok) => {
      if (ok) notifications.schedule(days);
      else {
        setNotificationsEnabled(false);
        setFlag('notificationsEnabled', false);
      }
    });
  }, [notificationsEnabled, days]);

  const toggleNotifications = useCallback(
    async (on: boolean) => {
      if (on) {
        const granted = await notifications.enable(days);
        setNotificationsEnabled(granted);
        setFlag('notificationsEnabled', granted);
      } else {
        setNotificationsEnabled(false);
        setFlag('notificationsEnabled', false);
        notifications.disable();
      }
    },
    [days],
  );

  const notesFor = useCallback((day: Day) => notes[dayKey(day)] ?? [], [notes]);
  const changeNotes = useCallback((day: Day, comments: string[]) => {
    const key = dayKey(day);
    setNotes((current) => {
      const next = { ...current };
      if (comments.length) next[key] = comments;
      else delete next[key];
      return next;
    });
    saveNotes(key, comments);
  }, []);

  // Whole weeks per row (one on phones, two on wide screens), so each column
  // is a weekday under the header. The window starts today, so the first row
  // opens with blank slots for the earlier days of this week.
  const columns = width >= 700 ? 14 : 7;
  const leading = days[0] ? days[0].date.getDay() : 0;
  const tileSize = gridWidth > 0 ? Math.floor((gridWidth - GAP * (columns - 1)) / columns) : 0;
  const today = startOfToday();

  // Opening a day from the feast list or jump sheet also scrolls the grid to it.
  const openFromSheet = (index: number) => {
    setSheet(null);
    setMode('grid');
    const row = Math.floor((index + leading) / columns);
    grid.current?.scrollTo({ y: Math.max(0, row * (tileSize + GAP) - height / 3), animated: false });
    setSelected(index);
  };

  const wheelSize = Math.min(width, height - 220, 560) - 32;

  const header = useMemo(
    () => (
      <View style={[styles.header, { borderBottomColor: t.hairline, backgroundColor: t.surface }]}>
        <View style={styles.headerSide}>
          {IS_WEB && (
            <HeaderButton label="← Home" color={t.muted} onPress={() => Linking.openURL('../')} a11y="Back to the Kalendar website" />
          )}
          <HeaderButton label="ⓘ" color={t.text} onPress={() => setSheet('about')} a11y="About the Kalendar" big />
        </View>
        <Text style={[styles.title, { color: t.text }]} numberOfLines={1}>Kalendar</Text>
        <View style={styles.headerSide}>
          <HeaderButton label="⌕" color={t.text} onPress={() => setSheet('jump')} a11y="Jump to a date" big />
          <HeaderButton label="☆" color={t.text} onPress={() => setSheet('feasts')} a11y="Feasts and solemnities" big />
          <HeaderButton
            label={mode === 'grid' ? '◔' : '▦'}
            color={t.text}
            onPress={() => setMode(mode === 'grid' ? 'wheel' : 'grid')}
            a11y={mode === 'grid' ? 'Show wheel view' : 'Show grid view'}
            big
          />
        </View>
      </View>
    ),
    [t, mode],
  );

  return (
    <SafeAreaView style={[styles.root, { backgroundColor: t.surface }]} edges={['top']}>
      {header}
      <View style={[styles.main, { backgroundColor: t.canvas }]}>
        {mode === 'grid' ? (
          <ScrollView ref={grid} contentContainerStyle={{ paddingHorizontal: PADDING, paddingBottom: PADDING }} stickyHeaderIndices={[1]}>
            <Legend />
            {/* The weekday header stays pinned while the year scrolls under it. */}
            <View style={{ backgroundColor: t.canvas, paddingBottom: GAP }}>
              <View style={[styles.grid, { gap: GAP, maxWidth: MAX_GRID }]}>
                {tileSize > 0 &&
                  Array.from({ length: columns }, (_, i) => (
                    <Text key={i} style={[styles.weekday, { width: tileSize, color: t.muted }]}>
                      {weekdayInitials[i % 7]}
                    </Text>
                  ))}
              </View>
            </View>
            {/* Measured inside the scroll view, so a visible scrollbar (web) is
                already subtracted and the row really fits `columns` tiles. */}
            <View
              onLayout={(e: LayoutChangeEvent) => setGridWidth(e.nativeEvent.layout.width)}
              style={[styles.grid, { gap: GAP, maxWidth: MAX_GRID }]}
            >
              {tileSize > 0 &&
                Array.from({ length: leading }, (_, i) => <View key={`lead${i}`} style={{ width: tileSize, height: tileSize }} />)}
              {tileSize > 0 &&
                days.map((day, i) => (
                  <DayTile
                    key={day.date.getTime()}
                    day={day}
                    size={tileSize}
                    isToday={sameDay(day.date, today)}
                    hasNotes={NOTES_SUPPORTED && notesFor(day).length > 0}
                    monthLabel={monthLabelFor(day, i)}
                    onPress={() => setSelected(i)}
                  />
                ))}
            </View>
          </ScrollView>
        ) : (
          <ScrollView contentContainerStyle={styles.wheelWrap}>
            <YearWheel days={days} size={wheelSize} onDayPress={setSelected} />
            <Pressable onPress={() => setSelected(0)} style={[styles.todayButton, { backgroundColor: t.chip }]} accessibilityRole="button">
              <Text style={{ color: t.text, fontWeight: '600', fontSize: 15 }}>Open Today</Text>
            </Pressable>
            <Text style={[styles.hint, { color: t.text }]}>Tap any slice to explore that day.</Text>
          </ScrollView>
        )}
      </View>

      <DaySheet
        days={days}
        index={selected}
        onIndexChange={setSelected}
        onClose={() => setSelected(null)}
        notesFor={notesFor}
        onNotesChange={changeNotes}
      />
      <AboutSheet
        visible={sheet === 'about'}
        onClose={() => setSheet(null)}
        notificationsEnabled={notificationsEnabled}
        onToggleNotifications={toggleNotifications}
        onReplayIntro={
          onReplayIntro &&
          (() => {
            setSheet(null);
            setFlag('hasSeenOnboarding', false);
            onReplayIntro();
          })
        }
      />
      <FeastListSheet visible={sheet === 'feasts'} days={days} onSelect={openFromSheet} onClose={() => setSheet(null)} />
      <JumpToDateSheet visible={sheet === 'jump'} days={days} onSelect={openFromSheet} onClose={() => setSheet(null)} />
    </SafeAreaView>
  );
}

/** What the marks on a tile mean, shown above the grid instead of only in About. */
function Legend() {
  const t = useTheme();
  const mark = t.text;
  const item = (glyph: ReactNode, label: string) => (
    <View style={styles.legendItem}>
      {glyph}
      <Text style={[styles.legendText, { color: t.muted }]}>{label}</Text>
    </View>
  );
  return (
    <View style={styles.legend} accessibilityRole="text">
      <Text style={[styles.legendText, { color: t.muted, width: '100%', textAlign: 'center' }]}>
        Tap any day to see its season, feast, and color.
      </Text>
      {item(<View style={[styles.legendDot, { backgroundColor: mark }]} />, 'Feast')}
      {item(<Text style={{ color: mark, fontSize: 11 }}>★</Text>, 'Solemnity')}
      {item(<View style={[styles.legendDiamond, { backgroundColor: mark }]} />, 'U.S. holiday')}
      {NOTES_SUPPORTED && item(<View style={[styles.legendSquare, { backgroundColor: mark }]} />, 'Your note')}
    </View>
  );
}

function HeaderButton({ label, color, onPress, a11y, big }: { label: string; color: string; onPress: () => void; a11y: string; big?: boolean }) {
  return (
    <Pressable onPress={onPress} hitSlop={8} accessibilityRole="button" accessibilityLabel={a11y} style={styles.headerButton}>
      <Text style={{ color, fontSize: big ? 22 : 15 }}>{label}</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1 },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 10,
    paddingVertical: 8,
    borderBottomWidth: StyleSheet.hairlineWidth,
  },
  headerSide: { flexDirection: 'row', alignItems: 'center', gap: 2, flexShrink: 0 },
  headerButton: { paddingHorizontal: 7, paddingVertical: 4 },
  // The title gives way first on narrow screens so no button gets cut off.
  title: { flex: 1, fontSize: 17, fontWeight: '600', textAlign: 'center' },
  main: { flex: 1 },
  grid: { flexDirection: 'row', flexWrap: 'wrap', alignSelf: 'center', width: '100%' },
  hint: { width: '100%', textAlign: 'center', fontSize: 14, marginBottom: 6 },
  weekday: { textAlign: 'center', fontSize: 12, fontWeight: '600', paddingTop: 6 },
  legend: { flexDirection: 'row', flexWrap: 'wrap', justifyContent: 'center', columnGap: 16, rowGap: 6, paddingTop: 10, paddingBottom: 4 },
  legendItem: { flexDirection: 'row', alignItems: 'center', gap: 5 },
  legendText: { fontSize: 13 },
  legendDot: { width: 7, height: 7, borderRadius: 3.5 },
  legendDiamond: { width: 6, height: 6, transform: [{ rotate: '45deg' }] },
  legendSquare: { width: 6, height: 6, borderRadius: 1.5 },
  wheelWrap: { alignItems: 'center', gap: 18, paddingVertical: 24 },
  todayButton: { paddingHorizontal: 20, paddingVertical: 10, borderRadius: 999 },
});
