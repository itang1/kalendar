import { describe, expect, it } from 'vitest';
import { liturgicalInfo, dateOnly } from './engine/kalendar-engine';
import { buildWindow, countdownText, dayKey, todaysColorNote, WINDOW_DAYS, type Day } from './days';

function day(y: number, m: number, d: number): Day {
  const date = dateOnly(y, m, d);
  return { ...liturgicalInfo(date), date, dayOfYear: 0, countdown: null };
}

describe('dayKey (must match CalendarViewModel.dayKey in the iPhone app)', () => {
  it('keys ordinary and fixed-feast days by month-day', () => {
    expect(dayKey(day(2026, 7, 10))).toBe('07-10');
    expect(dayKey(day(2026, 12, 25))).toBe('12-25');
    expect(dayKey(day(2026, 10, 31))).toBe('10-31');
  });

  it('keys movable feasts by feast identity, so a note on Easter follows Easter', () => {
    expect(dayKey(day(2026, 4, 5))).toBe('feast:easterSunday');
    expect(dayKey(day(2027, 3, 28))).toBe('feast:easterSunday');
    expect(dayKey(day(2026, 2, 18))).toBe('feast:ashWednesday');
    expect(dayKey(day(2026, 11, 22))).toBe('feast:christTheKing');
  });

  it('keeps a transferred solemnity on its date key, as the Swift engine does', () => {
    // In 2024 the Annunciation (Mar 25) fell in Holy Week and moved to Apr 8.
    const moved = day(2024, 4, 8);
    expect(moved.feastId).toBe('annunciation');
    expect(moved.isMovableFeast).toBe(false);
    expect(dayKey(moved)).toBe('04-08');
  });
});

describe('buildWindow', () => {
  it('covers a full year starting on the given day', () => {
    const days = buildWindow(dateOnly(2026, 10, 10));
    expect(days).toHaveLength(WINDOW_DAYS);
    expect(days[0].date).toEqual(dateOnly(2026, 10, 10));
    expect(days[365].date).toEqual(dateOnly(2027, 10, 10));
    expect(days[0].dayOfYear).toBe(283);
  });

  it('gives the first and last tile the same note key in years without Feb 29', () => {
    // Notes are looked up by key, so both tiles always show the same notes; the
    // iPhone app needs reconcileDuplicateKeys for this, the Expo app doesn't.
    const days = buildWindow(dateOnly(2026, 10, 10));
    expect(dayKey(days[0])).toBe(dayKey(days[365]));
  });
});

describe('countdownText', () => {
  it('counts to the nearest anchor ahead', () => {
    expect(countdownText(dateOnly(2026, 12, 24))).toBe('1 day until Christmas');
    expect(countdownText(dateOnly(2026, 10, 10))).toBe('50 days until Advent');
  });
});

describe('todaysColorNote', () => {
  it('explains a feast that changes the season color', () => {
    expect(todaysColorNote(day(2026, 10, 18))).toBe('Today is red for Luke the Evangelist.');
  });
  it('is silent when the day wears its season color', () => {
    expect(todaysColorNote(day(2026, 7, 10))).toBeNull();
  });
});
