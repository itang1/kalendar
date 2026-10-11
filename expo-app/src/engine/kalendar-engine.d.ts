// Types for kalendar-engine.js, which stays plain JavaScript so Node can load it
// directly in tools/liturgical-golden.mjs.

export type ColorKey = 'green' | 'violet' | 'white' | 'red' | 'rose';

export interface LiturgicalColorValue {
  key: ColorKey;
  name: string;
  hex: string;
}

export type Season = 'Advent' | 'Christmas' | 'Ordinary Time' | 'Lent' | 'Triduum' | 'Easter';

export interface LiturgicalInfo {
  season: Season;
  color: LiturgicalColorValue;
  feastName: string | null;
  /** Stable identifier matching the Swift `FeastID` raw value. */
  feastId: string | null;
  /** True for Easter-cycle feasts, whose date moves year to year. */
  isMovableFeast: boolean;
  feastDescription: string | null;
  isSolemnity: boolean;
  weekOfSeason: number | null;
  civilHolidayName: string | null;
  civilHolidayDescription: string | null;
}

export interface KeyDates {
  easter: Date;
  ashWednesday: Date;
  palmSunday: Date;
  holyThursday: Date;
  goodFriday: Date;
  holySaturday: Date;
  ascension: Date;
  pentecost: Date;
  trinitySunday: Date;
  adventStart: Date;
  christmas: Date;
  baptismOfLord: Date;
  christTheKing: Date;
}

export const LiturgicalColor: Record<ColorKey, LiturgicalColorValue>;
export const LiturgicalSeason: {
  advent: 'Advent';
  christmas: 'Christmas';
  ordinaryTime: 'Ordinary Time';
  lent: 'Lent';
  triduum: 'Triduum';
  easter: 'Easter';
};
export const SEASON_EXPLANATION: Record<Season, string>;
export const SEASON_CONTEXTUAL_ITEMS: Record<Season, string[]>;
export const COLOR_EXPLANATION: Record<ColorKey, string>;

export function liturgicalInfo(date: Date): LiturgicalInfo;
export function liturgicalDayTitle(
  info: Pick<LiturgicalInfo, 'feastName' | 'weekOfSeason' | 'season'>,
  date: Date,
): string | null;
export function seasonWeekLabel(info: Pick<LiturgicalInfo, 'weekOfSeason' | 'season'>): string | null;
export function keyDates(year: number): KeyDates;
export function addDays(date: Date, n: number): Date;
export function daysBetween(from: Date, to: Date): number;
export function dateOnly(y: number, m: number, d: number): Date;
