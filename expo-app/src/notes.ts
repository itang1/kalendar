// Day notes, saved on this device. Each day is stored under its own key
// ("note.<dayKey>") holding {"comments": [...]}, the same shape and keys the
// iPhone app uses, so the two stay easy to reason about together.
//
// The web build is read-only and never stores notes.

import AsyncStorage from '@react-native-async-storage/async-storage';
import { Platform } from 'react-native';

export const NOTES_SUPPORTED = Platform.OS !== 'web';

const PREFIX = 'note.';

export type NotesByKey = Record<string, string[]>;

export async function loadNotes(): Promise<NotesByKey> {
  if (!NOTES_SUPPORTED) return {};
  const keys = (await AsyncStorage.getAllKeys()).filter((k) => k.startsWith(PREFIX));
  const pairs = await AsyncStorage.multiGet(keys);
  const result: NotesByKey = {};
  for (const [storageKey, raw] of pairs) {
    if (!raw) continue;
    try {
      const parsed = JSON.parse(raw) as { comments?: unknown };
      if (Array.isArray(parsed.comments) && parsed.comments.length > 0) {
        result[storageKey.slice(PREFIX.length)] = parsed.comments.filter((c): c is string => typeof c === 'string');
      }
    } catch {
      // A corrupt entry shouldn't take the rest of the notes down with it.
    }
  }
  return result;
}

/** Writes one day's notes, removing the key when there are none left. */
export async function saveNotes(key: string, comments: string[]): Promise<void> {
  if (!NOTES_SUPPORTED) return;
  if (comments.length === 0) {
    await AsyncStorage.removeItem(PREFIX + key);
  } else {
    await AsyncStorage.setItem(PREFIX + key, JSON.stringify({ comments }));
  }
}
