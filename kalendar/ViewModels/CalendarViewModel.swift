//
//  CalendarViewModel.swift
//  kalendar
//
//  Created by Irene Tang on 12/20/25.
//
//  Holds the data and logic

import SwiftUI
import Foundation
import Observation

// MARK: - Persistence

private let monthDayFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "MM-dd"
    f.locale = Locale(identifier: "en_US_POSIX")
    f.calendar = Calendar(identifier: .gregorian)
    return f
}()

/// Stable key for a day that survives year changes:
/// - Movable feasts (the Easter cycle) are keyed by feast identity so a note on
///   Easter follows Easter even when its date shifts year to year. The stable
///   `FeastID` is used rather than the display name, so re-wording a feast never
///   orphans the notes saved under it (`NotePersistenceStore` migrates the old
///   name-based keys once).
/// - Everything else (fixed-date feasts and regular days) is keyed by month-day
///   so a note on July 10 stays on July 10, and a note on a fixed feast stays put
///   even in years when that feast is outranked and not shown.
private func dayKey(for day: DayCard) -> String {
    if day.isMovableFeast, let id = day.feastID {
        return "feast:\(id.rawValue)"
    }
    return monthDayFormatter.string(from: day.date)
}

// MARK: - ViewModel

@Observable
@MainActor
final class CalendarViewModel {
    var days: [DayCard] {
        didSet {
            guard !isReconciling else { return }
            reconcileDuplicateKeys(from: oldValue)
            scheduleSave()
        }
    }

    private var saveTask: Task<Void, Never>?
    private var mergeTask: Task<Void, Never>?
    private var dayChangeTask: Task<Void, Never>?
    /// Guards `days` mutations made while unifying duplicate-key cards so the
    /// reconciliation below does not recurse through `didSet`.
    private var isReconciling = false

    init() {
        // Migrate any legacy storage and start iCloud syncing before loading, so
        // the load below reads the up-to-date per-day keys.
        NotePersistenceStore.startSyncing()

        var builtDays = Self.buildWindow()
        // Apply any saved notes (merged from iCloud and local storage)
        Self.applyNotes(NotePersistenceStore.load(), to: &builtDays)

        self.days = builtDays
        observeExternalChanges()
        observeDayChanges()
    }

    /// Builds the rolling 366-day window starting at `startDate` (default today).
    /// 366 days so a full year is always covered, including Feb 29 in leap years.
    private static func buildWindow(from startDate: Date = Date()) -> [DayCard] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: startDate)
        let litCal = LiturgicalCalendar()
        return (0..<366).map { offset -> DayCard in
            let date = calendar.date(byAdding: .day, value: offset, to: today)!
            let info = litCal.liturgicalInfo(for: date)
            return DayCard(
                dayOfYear: date.dayOfYear,
                date: date,
                comments: [],
                liturgicalSeason: info.season,
                liturgicalColor: info.liturgicalColor,
                feastName: info.feastName,
                feastID: info.feastID,
                feastDescription: info.feastDescription,
                isSolemnity: info.isSolemnity,
                weekOfSeason: info.weekOfSeason,
                isMovableFeast: info.isMovableFeast,
                countdownText: DayCard.countdownText(for: date)
            )
        }
    }

    // MARK: - Keeping "today" current

    /// Rebuilds the window when the calendar day changes while the app stays open.
    private func observeDayChanges() {
        dayChangeTask = Task { [weak self] in
            let changes = NotificationCenter.default.notifications(named: .NSCalendarDayChanged)
            for await _ in changes {
                self?.refreshForCurrentDate()
            }
        }
    }

    /// Rebuilds the 366-day window if it no longer starts on today. The window is
    /// built once at init, so after midnight passes (app left open overnight, or
    /// returning from the background) the wheel's today marker and the Open Today
    /// button would otherwise point at yesterday while the live grid outline moves.
    /// Call on scene activation as well as on the day-changed notification. Notes
    /// already in memory carry over.
    func refreshForCurrentDate() {
        let today = Calendar.current.startOfDay(for: Date())
        guard let first = days.first?.date,
              !Calendar.current.isDate(first, inSameDayAs: today) else { return }
        rebuildWindow()
    }

    private func rebuildWindow() {
        // Preserve notes: in-memory values win (they include unsaved edits), with
        // persisted values covering any day newly entering the window at the tail.
        let carried = Dictionary(
            days.map { (dayKey(for: $0), $0.comments) },
            uniquingKeysWith: { current, _ in current }
        )
        var rebuilt = Self.buildWindow()
        let saved = NotePersistenceStore.load()
        for i in rebuilt.indices {
            let key = dayKey(for: rebuilt[i])
            if let inMemory = carried[key] {
                rebuilt[i].comments = inMemory
            } else if let data = saved[key] {
                rebuilt[i].comments = data.comments
            }
        }
        days = rebuilt
    }

    // MARK: - Duplicate-key reconciliation

    /// The window is always 366 days, so in the roughly three years of four that
    /// contain no Feb 29 the first and last tiles share the same month-day key
    /// (e.g. a window from Jul 3 ends on Jul 3 the next year). When the user edits
    /// one of those tiles, the other still holds the stale note; because
    /// `persistDays` is last-writer-wins per key, the stale copy would overwrite
    /// the edit (or resurrect a deleted note) on the next launch. So whenever a
    /// day's notes change, copy the new value onto every other card sharing its
    /// key, keeping the whole window internally consistent before it is saved.
    private func reconcileDuplicateKeys(from oldValue: [DayCard]) {
        guard oldValue.count == days.count else { return }
        var changed: [String: [String]] = [:]
        for i in days.indices where days[i].comments != oldValue[i].comments {
            changed[dayKey(for: days[i])] = days[i].comments
        }
        guard !changed.isEmpty else { return }
        isReconciling = true
        defer { isReconciling = false }
        for i in days.indices {
            if let value = changed[dayKey(for: days[i])], days[i].comments != value {
                days[i].comments = value
            }
        }
    }

    // MARK: - Auto-save (debounced to avoid saving on every keystroke)

    private func scheduleSave() {
        saveTask?.cancel()
        let snapshot = days
        saveTask = Task {
            try? await Task.sleep(for: .seconds(0.5))
            guard !Task.isCancelled else { return }
            Self.persistDays(snapshot)
        }
    }

    /// Persists the current window immediately, cancelling any pending debounce.
    /// Called when the scene leaves the foreground so a note added a moment before
    /// the app is suspended or terminated is not lost with the debounce still
    /// pending, and before applying an external iCloud merge.
    func flushPendingSave() {
        saveTask?.cancel()
        saveTask = nil
        Self.persistDays(days)
    }

    // MARK: - iCloud merge

    /// Re-merges notes when iCloud reports a change from another device.
    private func observeExternalChanges() {
        mergeTask = Task { [weak self] in
            let changes = NotificationCenter.default.notifications(named: NotePersistenceStore.didChangeExternally)
            for await _ in changes {
                self?.mergeExternalNotes()
            }
        }
    }

    /// Applies the authoritative iCloud state. A day absent from that state had its
    /// note deleted on another device, so we clear it here rather than keep the
    /// stale value, which is what lets deletions propagate across devices.
    private func mergeExternalNotes() {
        // Flush any pending local edit first so it is committed to the store and the
        // merge resolves as last-writer-wins there, rather than silently dropping an
        // unsaved edit still sitting in the debounce window.
        flushPendingSave()
        let saved = NotePersistenceStore.loadAuthoritative()
        for i in days.indices {
            let incoming = saved[dayKey(for: days[i])]?.comments ?? []
            if incoming != days[i].comments {
                days[i].comments = incoming
            }
        }
    }

    // MARK: - Persistence helpers

    private static func applyNotes(_ saved: [String: UserDayData], to days: inout [DayCard]) {
        for i in days.indices {
            let key = dayKey(for: days[i])
            if let data = saved[key] {
                days[i].comments = data.comments
            }
        }
    }

    private static func persistDays(_ days: [DayCard]) {
        var userData: [String: UserDayData] = [:]
        var allKeys: Set<String> = []
        for day in days {
            let key = dayKey(for: day)
            allKeys.insert(key)
            if !day.comments.isEmpty {
                userData[key] = UserDayData(comments: day.comments)
            }
        }
        NotePersistenceStore.save(userData, allKeys: allKeys)
    }

}
