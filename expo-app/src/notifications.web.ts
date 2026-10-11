// The web build has no notifications. Metro picks this file over
// notifications.ts on the web, so expo-notifications never loads there.

import type { Day } from './days';

export const NOTIFICATIONS_SUPPORTED = false;

export async function isAuthorized(): Promise<boolean> {
  return false;
}
export async function enable(_days: Day[]): Promise<boolean> {
  return false;
}
export async function disable(): Promise<void> {}
export async function schedule(_days: Day[]): Promise<void> {}
