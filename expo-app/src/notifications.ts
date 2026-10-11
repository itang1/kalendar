// A morning notification on each upcoming solemnity, plus one at the far edge
// of the window asking the user to open the app so the next year gets
// scheduled. Mirrors SolemnityNotificationScheduler in the iPhone app.
// Not available on the web.

import * as Notifications from 'expo-notifications';
import { Platform } from 'react-native';
import type { Day } from './days';

export const NOTIFICATIONS_SUPPORTED = Platform.OS !== 'web';

const ID_PREFIX = 'kalendar.solemnity.';
const WINDOW_EXPIRATION_ID = 'kalendar.windowExpiration';
const NOTIFICATION_HOUR = 8;
const CHANNEL_ID = 'solemnities';

if (NOTIFICATIONS_SUPPORTED) {
  Notifications.setNotificationHandler({
    handleNotification: async () => ({
      shouldShowBanner: true,
      shouldShowList: true,
      shouldPlaySound: true,
      shouldSetBadge: false,
    }),
  });
}

export async function isAuthorized(): Promise<boolean> {
  if (!NOTIFICATIONS_SUPPORTED) return false;
  const { granted } = await Notifications.getPermissionsAsync();
  return granted;
}

/** Asks for permission if needed, then schedules. Returns whether it's granted. */
export async function enable(days: Day[]): Promise<boolean> {
  if (!NOTIFICATIONS_SUPPORTED) return false;
  if (Platform.OS === 'android') {
    // Android 13+ only shows the permission prompt once a channel exists.
    await Notifications.setNotificationChannelAsync(CHANNEL_ID, {
      name: 'Solemnities',
      importance: Notifications.AndroidImportance.DEFAULT,
    });
  }
  let granted = await isAuthorized();
  if (!granted) {
    const result = await Notifications.requestPermissionsAsync();
    granted = result.granted;
  }
  if (granted) await schedule(days);
  return granted;
}

export async function disable(): Promise<void> {
  if (!NOTIFICATIONS_SUPPORTED) return;
  const pending = await Notifications.getAllScheduledNotificationsAsync();
  await Promise.all(
    pending
      .filter((n) => n.identifier.startsWith(ID_PREFIX) || n.identifier === WINDOW_EXPIRATION_ID)
      .map((n) => Notifications.cancelScheduledNotificationAsync(n.identifier)),
  );
}

function at8am(date: Date): Date {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate(), NOTIFICATION_HOUR);
}

/** Replaces any previously scheduled notifications with a fresh set for `days`. */
export async function schedule(days: Day[]): Promise<void> {
  if (!NOTIFICATIONS_SUPPORTED) return;
  await disable();
  const now = Date.now();
  const channel = Platform.OS === 'android' ? { channelId: CHANNEL_ID } : {};

  for (const day of days) {
    if (!day.isSolemnity || !day.feastName) continue;
    const when = at8am(day.date);
    if (when.getTime() <= now) continue;
    const y = day.date.getFullYear();
    const m = String(day.date.getMonth() + 1).padStart(2, '0');
    const d = String(day.date.getDate()).padStart(2, '0');
    await Notifications.scheduleNotificationAsync({
      identifier: `${ID_PREFIX}${y}-${m}-${d}`,
      content: { title: day.feastName, body: "A solemnity in the Church's calendar today.", sound: true },
      trigger: { type: Notifications.SchedulableTriggerInputTypes.DATE, date: when, ...channel },
    });
  }

  const last = days[days.length - 1];
  if (last) {
    await Notifications.scheduleNotificationAsync({
      identifier: WINDOW_EXPIRATION_ID,
      content: {
        title: 'Keep the reminders coming',
        body: "Open Kalendar to line up next year's solemnity notifications.",
        sound: true,
      },
      trigger: { type: Notifications.SchedulableTriggerInputTypes.DATE, date: at8am(last.date), ...channel },
    });
  }
}
