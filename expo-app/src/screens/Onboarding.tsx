// Shown on first launch of the Android app. Mirrors OnboardingView in the
// iPhone app, with the notes page describing Android's on-device storage.

import { useState } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { LiturgicalColor } from '../engine/kalendar-engine';
import { useTheme } from '../theme';

const PAGES = [
  {
    symbol: '▦',
    color: LiturgicalColor.violet.hex,
    title: 'The Liturgical Year',
    body: "The liturgical kalendar organizes time around the life of Jesus instead of months and quarters. It runs from Advent in late November all the way to the feast of Christ the King nearly a year later, then starts again.\n\n'Kalendar' is the traditional spelling used in many liturgical texts.",
  },
  {
    symbol: '◐',
    color: LiturgicalColor.red.hex,
    title: 'Colors Mean Something',
    body: 'Each tile is colored by the liturgical season or feast day it belongs to. Churches that follow the church year use the same colors for pulpit hangings and clergy stoles.\n\nViolet for Advent and Lent. White for Christmas and Easter. Red for martyrs and the Holy Spirit. Green for the long stretches of Ordinary Time. Rose appears twice a year on days of joy within penitential seasons.',
  },
  {
    symbol: '★',
    color: '#E0B000',
    title: 'Feasts and Solemnities',
    body: 'A small dot on a tile means something is being celebrated that day. It might be a solemnity like Easter or Christmas, or a day remembering an apostle or another figure from Scripture.\n\nSolemnities are the highest rank. They take priority over the season and are always worth knowing. Tap any tile to read about the day.',
  },
  {
    symbol: '◔',
    color: LiturgicalColor.green.hex,
    title: 'Two Ways to Look',
    body: 'The grid view shows a full year of days laid out as tiles, always starting with today and rolling forward one day at a time.\n\nTiles omit date numbers so color and season stand out at a glance. Tap any tile to see its exact date, feast, and notes.\n\nThe wheel view shows the whole year at once as colored slices, so you can see the shape of the liturgical year from a distance.\n\nToggle between the two views at the top of the screen.',
  },
  {
    symbol: '✎',
    color: LiturgicalColor.green.hex,
    title: 'Your Notes Stay',
    body: 'Tap any day to open it, then add a note at the bottom. Notes are saved automatically and persist year over year. Feast day notes follow the feast even when the date shifts (like Easter). Regular day notes stay on the same date each year.\n\nNotes are saved on this device. They are never sent to us or to any other service.',
  },
];

export function Onboarding({ onDone }: { onDone: () => void }) {
  const t = useTheme();
  const [page, setPage] = useState(0);
  const p = PAGES[page];
  const isLast = page === PAGES.length - 1;

  return (
    <SafeAreaView style={[styles.root, { backgroundColor: t.surface }]}>
      <ScrollView contentContainerStyle={styles.content}>
        <Text style={[styles.symbol, { color: p.color }]}>{p.symbol}</Text>
        <Text style={[styles.title, { color: t.text }]} accessibilityRole="header">{p.title}</Text>
        <Text style={[styles.body, { color: t.text }]}>{p.body}</Text>
      </ScrollView>
      <View style={styles.dots}>
        {PAGES.map((_, i) => (
          <View key={i} style={[styles.dot, { backgroundColor: t.text, opacity: i === page ? 1 : 0.25 }]} />
        ))}
      </View>
      <View style={styles.buttons}>
        {page > 0 && (
          <Pressable onPress={() => setPage(page - 1)} style={[styles.button, { backgroundColor: t.chip }]} accessibilityRole="button">
            <Text style={[styles.buttonText, { color: t.text }]}>Back</Text>
          </Pressable>
        )}
        <Pressable
          onPress={() => (isLast ? onDone() : setPage(page + 1))}
          style={[styles.button, { backgroundColor: t.text, flex: 1 }]}
          accessibilityRole="button"
        >
          <Text style={[styles.buttonText, { color: t.surface }]}>{isLast ? 'Get Started' : 'Continue'}</Text>
        </Pressable>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1 },
  content: { flexGrow: 1, justifyContent: 'center', paddingHorizontal: 28, paddingVertical: 32, maxWidth: 620, width: '100%', alignSelf: 'center' },
  symbol: { fontSize: 52, marginBottom: 24 },
  title: { fontSize: 28, fontWeight: '700', marginBottom: 16 },
  body: { fontSize: 17, lineHeight: 26 },
  dots: { flexDirection: 'row', justifyContent: 'center', gap: 8, paddingTop: 12 },
  dot: { width: 7, height: 7, borderRadius: 3.5 },
  buttons: { flexDirection: 'row', gap: 12, paddingHorizontal: 28, paddingTop: 20, paddingBottom: 28 },
  button: { borderRadius: 14, paddingVertical: 16, paddingHorizontal: 22, alignItems: 'center' },
  buttonText: { fontSize: 17, fontWeight: '600' },
});
