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

class CalendarViewModel: ObservableObject {
    @Published var days: [DayCard]
    let liturgicalCalendar = LiturgicalCalendar()
    let year: Int

    private static let monthNames = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]

    init() {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        self.year = currentYear
        let startOfYear = calendar.date(from: DateComponents(year: currentYear, month: 1, day: 1))!
        let daysInYear = calendar.range(of: .day, in: .year, for: startOfYear)!.count
        let litCal = LiturgicalCalendar()

        self.days = (0..<daysInYear).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: startOfYear)!
            let info = litCal.liturgicalInfo(for: date)
            return DayCard(
                dayOfYear: offset + 1,
                date: date,
                color: info.liturgicalColor.color,
                memo: "",
                comments: [],
                liturgicalSeason: info.season,
                liturgicalColor: info.liturgicalColor,
                feastName: info.feastName,
                feastDescription: info.feastDescription,
                isSolemnity: info.isSolemnity,
                weekOfSeason: info.weekOfSeason
            )
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

