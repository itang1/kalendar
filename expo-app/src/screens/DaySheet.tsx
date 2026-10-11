// Everything about one day, with Previous/Next to walk the year and notes at
// the bottom. Mirrors DayBrowserSheet + DayDetailView in the iPhone app.

import { useEffect, useRef, useState, type ReactNode } from 'react';
import { Platform, Pressable, ScrollView, Share, StyleSheet, Text, TextInput, View } from 'react-native';
import {
  COLOR_EXPLANATION,
  liturgicalDayTitle,
  SEASON_CONTEXTUAL_ITEMS,
  SEASON_EXPLANATION,
  seasonWeekLabel,
} from '../engine/kalendar-engine';
import { formatFull, formatLong, formatShort, RANK_EXPLANATION, seasonHex, todaysColorNote, type Day } from '../days';
import { NOTES_SUPPORTED } from '../notes';
import { Sheet } from '../components/Sheet';
import { useTheme, type Theme } from '../theme';

interface Props {
  days: Day[];
  index: number | null;
  onIndexChange: (index: number) => void;
  onClose: () => void;
  notesFor: (day: Day) => string[];
  onNotesChange: (day: Day, comments: string[]) => void;
}

/** The Web Share API only exists in some browsers; elsewhere hide the button. */
const CAN_SHARE = Platform.OS !== 'web' || (typeof navigator !== 'undefined' && typeof navigator.share === 'function');

function shareText(day: Day): string {
  const lines = [formatFull(day.date)];
  const title = liturgicalDayTitle(day, day.date);
  if (day.feastName) lines.push(day.feastName);
  else if (title) lines.push(title);
  const label = seasonWeekLabel(day);
  lines.push([day.season, label, day.color.name].filter(Boolean).join(' · '));
  if (day.civilHolidayName) lines.push(`U.S. holiday: ${day.civilHolidayName}`);
  if (day.feastDescription) lines.push('', day.feastDescription);
  lines.push('', 'Shared from Kalendar');
  return lines.join('\n');
}

export function DaySheet({ days, index, onIndexChange, onClose, notesFor, onNotesChange }: Props) {
  const t = useTheme();
  const scroll = useRef<ScrollView>(null);
  const day = index == null ? null : days[index];

  useEffect(() => {
    scroll.current?.scrollTo({ y: 0, animated: false });
  }, [index]);

  const share = day && CAN_SHARE ? (
    <Pressable onPress={() => Share.share({ message: shareText(day) }).catch(() => {})} hitSlop={10} accessibilityRole="button">
      <Text style={{ color: t.text, fontSize: 17 }}>Share</Text>
    </Pressable>
  ) : null;

  return (
    <Sheet visible={day != null} title={day ? formatShort(day.date) : ''} onClose={onClose} left={share}>
      {day && index != null && (
        <>
          <View style={styles.navRow}>
            {index > 0 ? (
              <NavButton t={t} label={`← ${formatShort(days[index - 1].date)}`} onPress={() => onIndexChange(index - 1)} />
            ) : (
              <View />
            )}
            {index < days.length - 1 ? (
              <NavButton t={t} label={`${formatShort(days[index + 1].date)} →`} onPress={() => onIndexChange(index + 1)} />
            ) : (
              <View />
            )}
          </View>
          <ScrollView ref={scroll} contentContainerStyle={styles.content} keyboardShouldPersistTaps="handled">
            <DayContent t={t} day={day} notes={notesFor(day)} onNotesChange={(c) => onNotesChange(day, c)} />
          </ScrollView>
        </>
      )}
    </Sheet>
  );
}

function NavButton({ t, label, onPress }: { t: Theme; label: string; onPress: () => void }) {
  return (
    <Pressable onPress={onPress} style={[styles.navButton, { backgroundColor: t.chip }]} accessibilityRole="button">
      <Text style={[styles.navText, { color: t.muted }]}>{label}</Text>
    </Pressable>
  );
}

function DayContent({ t, day, notes, onNotesChange }: { t: Theme; day: Day; notes: string[]; onNotesChange: (c: string[]) => void }) {
  const title = liturgicalDayTitle(day, day.date);
  const weekLabel = seasonWeekLabel(day);
  const colorNote = todaysColorNote(day);
  const subtitle = day.countdown ? `Day ${day.dayOfYear} of the year · ${day.countdown}` : `Day ${day.dayOfYear} of the year`;
  const text = { color: t.text };

  return (
    <View>
      <Text style={[styles.h1, text]}>{formatLong(day.date)}</Text>
      {title && <Text style={[styles.dayTitle, text]}>{title}</Text>}
      <Text style={[styles.subtitle, { color: t.muted }]}>{subtitle}</Text>

      {day.feastName && (
        <View style={{ marginTop: 22 }}>
          <Label t={t}>{day.isSolemnity ? 'Solemnity' : 'Feast'}</Label>
          <Text style={[styles.h1, text, { marginTop: 2 }]}>
            {day.isSolemnity && <Text style={{ color: t.star }}>★ </Text>}
            {day.feastName}
          </Text>
          {day.feastDescription && <Text style={[styles.body, text]}>{day.feastDescription}</Text>}
          <Disclosure t={t} title={day.isSolemnity ? 'About solemnities' : 'About feasts'}>
            <Text style={[styles.body, text]}>{day.isSolemnity ? RANK_EXPLANATION.solemnity : RANK_EXPLANATION.feast}</Text>
          </Disclosure>
        </View>
      )}

      {day.civilHolidayName && (
        <View style={styles.section}>
          <Label t={t}>U.S. holiday</Label>
          <Text style={[styles.strong, text]}>⚑ {day.civilHolidayName}</Text>
          {day.civilHolidayDescription && <Text style={[styles.body, text]}>{day.civilHolidayDescription}</Text>}
        </View>
      )}

      <View style={styles.section}>
        <Label t={t}>Season</Label>
        <View style={styles.swatchRow}>
          <View style={[styles.swatch, { backgroundColor: seasonHex(day.season), borderColor: t.hairline }]} />
          <Text style={[styles.strong, text]}>
            {day.season}
            {weekLabel && <Text style={{ fontWeight: '400' }}>{` · ${weekLabel}`}</Text>}
          </Text>
        </View>
        <Text style={[styles.body, text]}>{SEASON_EXPLANATION[day.season]}</Text>
        <Disclosure t={t} title={`Traditionally during ${day.season}`}>
          {SEASON_CONTEXTUAL_ITEMS[day.season].map((item) => (
            <Text key={item} style={[styles.body, text]}>· {item}</Text>
          ))}
        </Disclosure>
      </View>

      <View style={styles.section}>
        <Label t={t}>Color</Label>
        <View style={styles.swatchRow}>
          <View style={[styles.swatch, styles.round, { backgroundColor: day.color.hex, borderColor: t.hairline }]} />
          <Text style={[styles.strong, text]}>{day.color.name}</Text>
        </View>
        {colorNote && <Text style={[styles.body, text]}>{colorNote}</Text>}
        <Text style={[styles.body, text]}>{COLOR_EXPLANATION[day.color.key]}</Text>
      </View>

      <View style={styles.section}>
        <Label t={t}>Notes</Label>
        {NOTES_SUPPORTED ? (
          <Notes t={t} notes={notes} onChange={onNotesChange} />
        ) : (
          <Text style={[styles.body, { color: t.muted }]}>
            Notes are kept in the Kalendar app for iPhone and Android, where they stay on your own devices.
          </Text>
        )}
      </View>
    </View>
  );
}

function Notes({ t, notes, onChange }: { t: Theme; notes: string[]; onChange: (c: string[]) => void }) {
  const [draft, setDraft] = useState('');
  const trimmed = draft.trim();
  const add = () => {
    if (!trimmed) return;
    onChange([...notes, trimmed]);
    setDraft('');
  };
  return (
    <View>
      {notes.map((note, i) => (
        <View key={`${i}-${note}`} style={[styles.noteRow, i > 0 && { borderTopWidth: StyleSheet.hairlineWidth, borderTopColor: t.hairline }]}>
          <Text style={[styles.body, { color: t.text, flex: 1, marginTop: 0 }]}>{note}</Text>
          <Pressable
            onPress={() => onChange(notes.filter((_, j) => j !== i))}
            hitSlop={10}
            accessibilityRole="button"
            accessibilityLabel="Delete note"
          >
            <Text style={{ color: t.muted, fontSize: 18 }}>✕</Text>
          </Pressable>
        </View>
      ))}
      <View style={styles.addRow}>
        <TextInput
          value={draft}
          onChangeText={setDraft}
          onSubmitEditing={add}
          placeholder="Add a note..."
          placeholderTextColor={t.muted}
          returnKeyType="done"
          style={[styles.input, { color: t.text, borderColor: t.hairline }]}
        />
        <Pressable onPress={add} disabled={!trimmed} hitSlop={8} accessibilityRole="button">
          <Text style={[styles.strong, { color: t.text, opacity: trimmed ? 1 : 0.35 }]}>Add</Text>
        </Pressable>
      </View>
    </View>
  );
}

function Label({ t, children }: { t: Theme; children: ReactNode }) {
  return <Text style={[styles.label, { color: t.text }]}>{children}</Text>;
}

function Disclosure({ t, title, children }: { t: Theme; title: string; children: ReactNode }) {
  const [open, setOpen] = useState(false);
  return (
    <View style={{ marginTop: 14 }}>
      <Pressable onPress={() => setOpen((o) => !o)} accessibilityRole="button" accessibilityState={{ expanded: open }}>
        <Text style={[styles.strong, { color: t.text }]}>
          {open ? '▾' : '▸'} {title}
        </Text>
      </Pressable>
      {open && <View style={{ marginTop: 4 }}>{children}</View>}
    </View>
  );
}

const styles = StyleSheet.create({
  navRow: { flexDirection: 'row', justifyContent: 'space-between', paddingHorizontal: 14, paddingVertical: 8 },
  navButton: { paddingVertical: 6, paddingHorizontal: 12, borderRadius: 999 },
  navText: { fontSize: 13, fontWeight: '500' },
  content: { padding: 18, paddingBottom: 48, maxWidth: 680, width: '100%', alignSelf: 'center' },
  h1: { fontSize: 22, fontWeight: '700' },
  dayTitle: { fontSize: 16, fontWeight: '600', marginTop: 4 },
  subtitle: { fontSize: 14, marginTop: 4 },
  section: { marginTop: 30 },
  label: { fontSize: 12, fontWeight: '600', letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 6 },
  strong: { fontSize: 16, fontWeight: '700' },
  body: { fontSize: 16, lineHeight: 23, marginTop: 8 },
  swatchRow: { flexDirection: 'row', alignItems: 'center', gap: 10 },
  swatch: { width: 22, height: 22, borderRadius: 4, borderWidth: 2 },
  round: { width: 18, height: 18, borderRadius: 9 },
  noteRow: { flexDirection: 'row', alignItems: 'flex-start', gap: 10, paddingVertical: 10 },
  addRow: { flexDirection: 'row', alignItems: 'center', gap: 12, marginTop: 8 },
  input: { flex: 1, borderWidth: 1, borderRadius: 8, paddingHorizontal: 10, paddingVertical: 8, fontSize: 16 },
});
