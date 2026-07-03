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
                color: info.liturgicalColor.color,
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

        // Apply any saved notes (merged from iCloud and local storage)
        Self.applyNotes(NotePersistenceStore.load(), to: &builtDays)

        self.days = builtDays
        NotePersistenceStore.startSyncing()
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

    /// Merges in notes synced from another device. Only days present in the
    /// reloaded data are overwritten, so a note added on this device while
    /// offline is not clobbered by a merge that hasn't caught up yet.
    private func observeExternalChanges() {
        mergeTask = Task { [weak self] in
            let changes = NotificationCenter.default.notifications(named: NotePersistenceStore.didChangeExternally)
            for await _ in changes {
                self?.mergeExternalNotes()
            }
        }
    }

    private func mergeExternalNotes() {
        let saved = NotePersistenceStore.load()
        for i in days.indices {
            let key = dayKey(for: days[i])
            if let data = saved[key], data.comments != days[i].comments {
                days[i].comments = data.comments
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
        for day in days where !day.comments.isEmpty {
            userData[dayKey(for: day)] = UserDayData(comments: day.comments)
        }
        NotePersistenceStore.save(userData)
    }

}
