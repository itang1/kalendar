// What the kalendar is, the legend, the notification toggle, and feedback.
// Mirrors InfoSheet in the iPhone app.

import { Linking, Platform, Pressable, ScrollView, StyleSheet, Switch, Text, View } from 'react-native';
import Constants from 'expo-constants';
import { LiturgicalSeason, SEASON_CONTEXTUAL_ITEMS, SEASON_EXPLANATION } from '../engine/kalendar-engine';
import { seasonHex } from '../days';
import { NOTES_SUPPORTED } from '../notes';
import { NOTIFICATIONS_SUPPORTED } from '../notifications';
import { Sheet } from '../components/Sheet';
import { useTheme } from '../theme';

const FEEDBACK_EMAIL = 'poodlestrategy+kalendar@gmail.com';

interface Props {
  visible: boolean;
  onClose: () => void;
  notificationsEnabled: boolean;
  onToggleNotifications: (on: boolean) => void;
  /** Absent on the web, which has no introduction. */
  onReplayIntro?: () => void;
}

export function AboutSheet({ visible, onClose, notificationsEnabled, onToggleNotifications, onReplayIntro }: Props) {
  const t = useTheme();
  const text = { color: t.text };
  const version = Constants.expoConfig?.version ?? 'unknown';
  const platform = Platform.OS === 'web' ? 'web' : Platform.OS;
  const feedbackURL = `mailto:${FEEDBACK_EMAIL}?subject=${encodeURIComponent(`Kalendar Feedback (${platform}, v${version})`)}`;

  return (
    <Sheet visible={visible} title="About the Kalendar" onClose={onClose}>
      <ScrollView contentContainerStyle={styles.content}>
        <Text style={[styles.body, text]}>
          The liturgical kalendar is how the Church marks time. Instead of months, the year is organized into seasons
          that follow the life of Jesus, from anticipation of his birth through his death, resurrection, and beyond.
          'Kalendar' is the traditional spelling used in many liturgical texts.
        </Text>

        <Divider color={t.hairline} />

        <Text style={[styles.heading, text]}>SEASONS</Text>
        {Object.values(LiturgicalSeason).map((season) => (
          <View key={season} style={{ marginBottom: 16 }}>
            <View style={styles.row}>
              <View style={[styles.swatch, { backgroundColor: seasonHex(season), borderColor: t.hairline }]} />
              <Text style={[styles.strong, text]}>{season}</Text>
            </View>
            <Text style={[styles.body, text, { marginTop: 6 }]}>{SEASON_EXPLANATION[season]}</Text>
            {SEASON_CONTEXTUAL_ITEMS[season].map((item) => (
              <Text key={item} style={[styles.body, text, { marginTop: 6 }]}>· {item}</Text>
            ))}
          </View>
        ))}

        <Divider color={t.hairline} />

        <Text style={[styles.body, text]}>● A dot marks a feast day. Tap any tile to read about it.</Text>
        <Text style={[styles.body, text]}>★ A star marks a solemnity, the highest rank of celebration.</Text>
        <Text style={[styles.body, text]}>◆ A small diamond in the corner marks a U.S. holiday, a separate layer from the church year.</Text>
        {NOTES_SUPPORTED && <Text style={[styles.body, text]}>■ A small square in the corner marks a day with notes.</Text>}

        {NOTES_SUPPORTED && (
          <>
            <Divider color={t.hairline} />
            <Text style={[styles.body, text]}>
              Notes you add are saved on this device. They are never sent to us or to any other service.
            </Text>
          </>
        )}

        {NOTIFICATIONS_SUPPORTED && (
          <>
            <Divider color={t.hairline} />
            <View style={[styles.row, { justifyContent: 'space-between' }]}>
              <Text style={[styles.strong, text, { flex: 1 }]}>Notify me on solemnities</Text>
              <Switch value={notificationsEnabled} onValueChange={onToggleNotifications} />
            </View>
            <Text style={[styles.small, { color: t.muted }]}>
              A morning notification on solemnities like Easter, Christmas, and the other highest-ranked celebrations
              of the year.
            </Text>
          </>
        )}

        <Divider color={t.hairline} />

        <Pressable
          onPress={() => Linking.openURL(feedbackURL)}
          style={[styles.card, { backgroundColor: t.chip }]}
          accessibilityRole="button"
        >
          <Text style={[styles.strong, text]}>✉ Send Feedback</Text>
          <Text style={[styles.small, { color: t.muted }]}>Report a bug or suggest something, straight to the developer.</Text>
        </Pressable>

        {onReplayIntro && (
          <Pressable
            onPress={onReplayIntro}
            style={[styles.card, { backgroundColor: t.chip, alignItems: 'center' }]}
            accessibilityRole="button"
          >
            <Text style={[styles.strong, text]}>↺ Replay Introduction</Text>
          </Pressable>
        )}

        {Platform.OS === 'web' && (
          <Pressable onPress={() => Linking.openURL('../privacy.html')} accessibilityRole="link">
            <Text style={[styles.small, { color: t.muted, textAlign: 'center', marginTop: 8 }]}>Privacy policy</Text>
          </Pressable>
        )}
      </ScrollView>
    </Sheet>
  );
}

function Divider({ color }: { color: string }) {
  return <View style={{ height: StyleSheet.hairlineWidth, backgroundColor: color, marginVertical: 20 }} />;
}

const styles = StyleSheet.create({
  content: { padding: 18, paddingBottom: 48, maxWidth: 680, width: '100%', alignSelf: 'center' },
  heading: { fontSize: 16, fontWeight: '700', marginBottom: 12 },
  body: { fontSize: 16, lineHeight: 23, marginTop: 4 },
  small: { fontSize: 14, lineHeight: 20, marginTop: 4 },
  strong: { fontSize: 16, fontWeight: '700' },
  row: { flexDirection: 'row', alignItems: 'center', gap: 10 },
  swatch: { width: 20, height: 20, borderRadius: 3, borderWidth: 2 },
  card: { borderRadius: 12, padding: 12, marginBottom: 12 },
});
