// Small persisted preferences. On the web these fall back to localStorage
// through AsyncStorage, which is fine: they hold nothing personal.

import AsyncStorage from '@react-native-async-storage/async-storage';

const KEYS = {
  hasSeenOnboarding: 'hasSeenOnboarding',
  notificationsEnabled: 'solemnityNotificationsEnabled',
} as const;

export async function getFlag(name: keyof typeof KEYS): Promise<boolean> {
  return (await AsyncStorage.getItem(KEYS[name])) === 'true';
}

export async function setFlag(name: keyof typeof KEYS, value: boolean): Promise<void> {
  await AsyncStorage.setItem(KEYS[name], value ? 'true' : 'false');
}
