//
//  DayCard.swift
//  kalendar
//
//  Created by Irene Tang on 12/20/25.
//
//  Represents one day of the year

import SwiftUI

struct DayCard: Identifiable {
    let id = UUID()
    let dayOfYear: Int  // 1–365
    let date: Date
    var comments: [String]

    // Liturgical calendar data
    var liturgicalSeason: LiturgicalSeason
    var liturgicalColor: LiturgicalColor
    var feastName: String?
    var feastDescription: String?
    var isSolemnity: Bool
    var weekOfSeason: Int?
    var isMovableFeast: Bool = false
}

// MARK: - Liturgical day naming

private let weekdayNameFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "EEEE"
    return f
}()

private let ordinalNames = [
    "First", "Second", "Third", "Fourth", "Fifth", "Sixth", "Seventh", "Eighth",
    "Ninth", "Tenth", "Eleventh", "Twelfth", "Thirteenth", "Fourteenth",
    "Fifteenth", "Sixteenth", "Seventeenth", "Eighteenth", "Nineteenth",
    "Twentieth", "Twenty-First", "Twenty-Second", "Twenty-Third", "Twenty-Fourth",
    "Twenty-Fifth", "Twenty-Sixth", "Twenty-Seventh", "Twenty-Eighth",
    "Twenty-Ninth", "Thirtieth", "Thirty-First", "Thirty-Second", "Thirty-Third",
    "Thirty-Fourth"
]

private func ordinalName(_ n: Int) -> String {
    guard n >= 1 && n <= ordinalNames.count else { return "\(n)" }
    return ordinalNames[n - 1]
}

extension DayCard {
    /// The day's proper liturgical name, the way a missal titles it, e.g.
    /// "Tuesday of the Second Week of Advent" or "Third Sunday in Ordinary Time".
    /// Nil on feast days (the feast is the day's name) and in seasons without
    /// counted weeks (Christmas, Triduum).
    var liturgicalDayTitle: String? {
        guard feastName == nil, let week = weekOfSeason else { return nil }

        let weekday = weekdayNameFormatter.string(from: date)
        let isSunday = Calendar.current.component(.weekday, from: date) == 1

        switch liturgicalSeason {
        case .lent where week == 0:
            // The days between Ash Wednesday and the First Sunday of Lent.
            return "\(weekday) after Ash Wednesday"
        case .easter where week == 1 && !isSunday:
            return "\(weekday) in the Octave of Easter"
        case .advent, .lent, .easter:
            return isSunday
                ? "\(ordinalName(week)) Sunday of \(liturgicalSeason.rawValue)"
                : "\(weekday) of the \(ordinalName(week)) Week of \(liturgicalSeason.rawValue)"
        case .ordinaryTime:
            return isSunday
                ? "\(ordinalName(week)) Sunday in Ordinary Time"
                : "\(weekday) of the \(ordinalName(week)) Week in Ordinary Time"
        default:
            return nil
        }
    }

    /// Days until the next major moment of the year, e.g. "17 days until Easter".
    /// Nil only if no anchor lies ahead (which cannot happen in practice, since
    /// Christmas recurs every year).
    var countdownText: String? {
        let calendar = Calendar.current
        let engine = LiturgicalCalendar()
        let year = calendar.component(.year, from: date)
        let start = calendar.startOfDay(for: date)

        var nearest: (name: String, days: Int)?
        for y in [year, year + 1] {
            let keys = engine.keyDates(year: y)
            let anchors: [(String, Date)] = [
                ("Ash Wednesday", keys.ashWednesday),
                ("Easter", keys.easter),
                ("Pentecost", keys.pentecost),
                ("Advent", keys.adventStart),
                ("Christmas", keys.christmas),
            ]
            for (name, target) in anchors {
                let days = calendar.dateComponents(
                    [.day], from: start, to: calendar.startOfDay(for: target)
                ).day ?? 0
                if days > 0 && days < (nearest?.days ?? .max) {
                    nearest = (name, days)
                }
            }
        }
        guard let nearest else { return nil }
        return nearest.days == 1
            ? "1 day until \(nearest.name)"
            : "\(nearest.days) days until \(nearest.name)"
    }
}
