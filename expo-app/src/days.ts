// The rolling year of days the app shows, and the facts derived from each day.
// Mirrors CalendarViewModel.buildWindow and DayCard in the iPhone app.

import {
  addDays,
  daysBetween,
  keyDates,
  liturgicalInfo,
  LiturgicalColor,
  type ColorKey,
  type LiturgicalInfo,
  type Season,
} from './engine/kalendar-engine';

/** 366 days so a full year is always covered, including Feb 29 in leap years. */
export const WINDOW_DAYS = 366;

export interface Day extends LiturgicalInfo {
  date: Date;
  dayOfYear: number;
  countdown: string | null;
}

export function startOfToday(): Date {
  const now = new Date();
  return new Date(now.getFullYear(), now.getMonth(), now.getDate());
}

export function sameDay(a: Date, b: Date): boolean {
  return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
}

function dayOfYearOf(date: Date): number {
  return daysBetween(new Date(date.getFullYear(), 0, 1), date) + 1;
}

export function buildWindow(start: Date = startOfToday()): Day[] {
  const days: Day[] = [];
  for (let i = 0; i < WINDOW_DAYS; i++) {
    const date = addDays(start, i);
    days.push({ ...liturgicalInfo(date), date, dayOfYear: dayOfYearOf(date), countdown: countdownText(date) });
  }
  return days;
}

/**
 * Stable key for a day's notes that survives year changes, identical to the
 * iPhone app's: movable feasts are keyed by feast identity so a note on Easter
 * follows Easter, and everything else by month-day so a note on July 10 stays
 * on July 10.
 */
export function dayKey(day: Day): string {
  if (day.isMovableFeast && day.feastId) return `feast:${day.feastId}`;
  const mm = String(day.date.getMonth() + 1).padStart(2, '0');
  const dd = String(day.date.getDate()).padStart(2, '0');
  return `${mm}-${dd}`;
}

/** Days until the next major moment of the year, e.g. "17 days until Easter". */
export function countdownText(date: Date): string | null {
  const year = date.getFullYear();
  let nearest: { name: string; days: number } | null = null;
  for (const y of [year, year + 1]) {
    const keys = keyDates(y);
    const anchors: [string, Date][] = [
      ['Ash Wednesday', keys.ashWednesday],
      ['Easter', keys.easter],
      ['Pentecost', keys.pentecost],
      ['Advent', keys.adventStart],
      ['Christmas', keys.christmas],
    ];
    for (const [name, target] of anchors) {
      const days = daysBetween(date, target);
      if (days > 0 && days < (nearest?.days ?? Infinity)) nearest = { name, days };
    }
  }
  if (!nearest) return null;
  return nearest.days === 1 ? `1 day until ${nearest.name}` : `${nearest.days} days until ${nearest.name}`;
}

/** The color a season normally wears, ignoring day-level overrides. */
export function seasonDefaultColor(season: Season): ColorKey {
  switch (season) {
    case 'Advent':
    case 'Lent':
      return 'violet';
    case 'Christmas':
    case 'Easter':
      return 'white';
    case 'Triduum':
      return 'red';
    default:
      return 'green';
  }
}

export function seasonHex(season: Season): string {
  return LiturgicalColor[seasonDefaultColor(season)].hex;
}

/** Marks drawn on a tile need to read on both white and saturated tiles. */
export function markColor(color: ColorKey): string {
  return color === 'white' || color === 'rose' ? 'rgba(0,0,0,0.5)' : 'rgba(255,255,255,0.7)';
}

/**
 * "Today is red for Luke the Evangelist." Only when the day steps out of its
 * season's usual color and a feast is the reason.
 */
export function todaysColorNote(day: Day): string | null {
  if (day.color.key === seasonDefaultColor(day.season) || !day.feastName) return null;
  return `Today is ${day.color.name.toLowerCase()} for ${day.feastName}.`;
}

export const RANK_EXPLANATION = {
  solemnity:
    'A solemnity is the highest rank of day in the church year. These mark the most important events of the faith, like Easter, Christmas, and Pentecost. They take priority over the regular season.',
  feast:
    'Feasts mark people and events from Scripture and the life of the early church, like the apostles, the Transfiguration, and Reformation Day.',
};

const longDate = new Intl.DateTimeFormat(undefined, { month: 'long', day: 'numeric', year: 'numeric' });
const weekday = new Intl.DateTimeFormat(undefined, { weekday: 'long' });
const shortDate = new Intl.DateTimeFormat(undefined, { month: 'short', day: 'numeric' });
const fullDate = new Intl.DateTimeFormat(undefined, { weekday: 'long', month: 'long', day: 'numeric', year: 'numeric' });

/** "October 10, 2026 (Saturday)" */
export function formatLong(date: Date): string {
  return `${longDate.format(date)} (${weekday.format(date)})`;
}
export function formatShort(date: Date): string {
  return shortDate.format(date);
}
export function formatFull(date: Date): string {
  return fullDate.format(date);
}
