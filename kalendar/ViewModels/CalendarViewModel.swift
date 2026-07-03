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
/// - Movable feasts (the Easter cycle) are keyed by feast name so a note on
///   Easter follows Easter even when its date shifts year to year.
/// - Everything else (fixed-date feasts and regular days) is keyed by month-day
///   so a note on July 10 stays on July 10, and a note on a fixed feast stays put
///   even in years when that feast is outranked and not shown.
private func dayKey(for day: DayCard) -> String {
    if day.isMovableFeast, let feast = day.feastName {
        return "feast:\(feast)"
    }
    return monthDayFormatter.string(from: day.date)
}

// MARK: - ViewModel

@Observable
@MainActor
final class CalendarViewModel {
    var days: [DayCard] {
        didSet { scheduleSave() }
    }

    private var saveTask: Task<Void, Never>?
    private var mergeTask: Task<Void, Never>?

    init() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let litCal = LiturgicalCalendar()

        // 366 days so a full year is always covered, including Feb 29 in leap years.
        var builtDays = (0..<366).map { offset -> DayCard in
            let date = calendar.date(byAdding: .day, value: offset, to: today)!
            let info = litCal.liturgicalInfo(for: date)
            return DayCard(
                dayOfYear: date.dayOfYear,
                date: date,
                comments: [],
                liturgicalSeason: info.season,
                liturgicalColor: info.liturgicalColor,
                feastName: info.feastName,
                feastDescription: info.feastDescription,
                isSolemnity: info.isSolemnity,
                weekOfSeason: info.weekOfSeason,
                isMovableFeast: info.isMovableFeast
            )
        }

        // Migrate any legacy storage and start iCloud syncing before loading, so
        // the load below reads the up-to-date per-day keys.
        NotePersistenceStore.startSyncing()

        // Apply any saved notes (merged from iCloud and local storage)
        Self.applyNotes(NotePersistenceStore.load(), to: &builtDays)

        self.days = builtDays
        observeExternalChanges()
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
