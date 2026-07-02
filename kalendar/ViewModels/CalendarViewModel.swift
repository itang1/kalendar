//
//  CalendarViewModel.swift
//  kalendar
//
//  Created by Irene Tang on 12/20/25.
//
//  Holds the data and logic

import SwiftUI
import Foundation
import Combine

// MARK: - Persistence

private struct UserDayData: Codable {
    var comments: [String]
}

private let persistenceKey = "com.kalendar.userDayData"

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

class CalendarViewModel: ObservableObject {
    @Published var days: [DayCard]

    private var cancellables = Set<AnyCancellable>()

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

        // Apply any saved memos and comments
        let saved = Self.loadPersistedData()
        for i in builtDays.indices {
            let key = dayKey(for: builtDays[i])
            if let data = saved[key] {
                builtDays[i].comments = data.comments
            }
        }

        self.days = builtDays

        // Auto-save whenever days change (debounced to avoid saving on every keystroke)
        $days
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { Self.persistDays($0) }
            .store(in: &cancellables)
    }

    // MARK: - Persistence helpers

    private static func loadPersistedData() -> [String: UserDayData] {
        guard let data = UserDefaults.standard.data(forKey: persistenceKey),
              let decoded = try? JSONDecoder().decode([String: UserDayData].self, from: data)
        else { return [:] }
        return decoded
    }

    private static func persistDays(_ days: [DayCard]) {
        var userData: [String: UserDayData] = [:]
        for day in days where !day.comments.isEmpty {
            userData[dayKey(for: day)] = UserDayData(comments: day.comments)
        }
        if let encoded = try? JSONEncoder().encode(userData) {
            UserDefaults.standard.set(encoded, forKey: persistenceKey)
        }
    }

}

