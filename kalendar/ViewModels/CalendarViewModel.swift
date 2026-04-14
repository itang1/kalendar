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
/// - Feast days are keyed by feast name so Easter memos follow Easter
///   even when the date shifts year to year.
/// - Regular days are keyed by month-day (no year) so a memo on
///   July 10 stays on July 10 every year.
private func dayKey(for day: DayCard) -> String {
    if let feast = day.feastName {
        return "feast:\(feast)"
    }
    return monthDayFormatter.string(from: day.date)
}

// MARK: - ViewModel

class CalendarViewModel: ObservableObject {
    @Published var days: [DayCard]
    let liturgicalCalendar = LiturgicalCalendar()
    let year: Int

    private var cancellables = Set<AnyCancellable>()

    private static let monthNames = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]

    init() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        self.year = calendar.component(.year, from: today)
        let litCal = LiturgicalCalendar()

        var builtDays = (0..<365).map { offset -> DayCard in
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
                weekOfSeason: info.weekOfSeason
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

    /// Returns days grouped by month as (monthName, [index into days])
    func daysByMonth() -> [(month: String, indices: [Int])] {
        let calendar = Calendar.current
        var result: [(month: String, indices: [Int])] = []
        var currentMonth = -1
        var currentIndices: [Int] = []

        for (i, day) in days.enumerated() {
            let month = calendar.component(.month, from: day.date)
            if month != currentMonth {
                if !currentIndices.isEmpty {
                    result.append((Self.monthNames[currentMonth - 1], currentIndices))
                }
                currentMonth = month
                currentIndices = [i]
            } else {
                currentIndices.append(i)
            }
        }
        if !currentIndices.isEmpty {
            result.append((Self.monthNames[currentMonth - 1], currentIndices))
        }
        return result
    }
}

