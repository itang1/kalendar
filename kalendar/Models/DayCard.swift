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

// MARK: - Obligation & discipline flags

extension DayCard {
    /// Fixed-date Holy Days of Obligation under the General Roman Calendar,
    /// plus the Ascension (movable). Which days actually bind can vary by
    /// country and diocese; the detail view notes that alongside the flag.
    var isHolyDayOfObligation: Bool {
        let month = Calendar.current.component(.month, from: date)
        let dayOfMonth = Calendar.current.component(.day, from: date)
        switch (month, dayOfMonth) {
        case (1, 1), (8, 15), (11, 1), (12, 8), (12, 25):
            return true
        default:
            return feastName == "Ascension of the Lord"
        }
    }

    /// Ash Wednesday and Good Friday: a day of both fasting and abstinence.
    var isDayOfFastingAndAbstinence: Bool {
        feastName == "Ash Wednesday" || feastName == "Good Friday of the Lord's Passion"
    }

    /// Fridays in Lent (Ash Wednesday and Good Friday are already covered by
    /// the stronger fasting-and-abstinence flag): abstinence from meat only.
    var isDayOfAbstinenceFromMeat: Bool {
        liturgicalSeason == .lent && Calendar.current.component(.weekday, from: date) == 6
    }
}

// MARK: - Lectionary cycle & readings

extension DayCard {
    /// The civil year whose cycle governs this day. The lectionary year turns over
    /// on the First Sunday of Advent, so Advent days already belong to the next
    /// civil year's cycle.
    private var lectionaryYear: Int {
        let calendar = Calendar.current
        let civilYear = calendar.component(.year, from: date)
        let adventStart = LiturgicalCalendar().keyDates(year: civilYear).adventStart
        return calendar.startOfDay(for: date) >= calendar.startOfDay(for: adventStart)
            ? civilYear + 1
            : civilYear
    }

    /// The Sunday lectionary cycle (Year A, B, or C): the three-year rotation of
    /// Sunday and solemnity readings.
    var sundayLectionaryCycle: String {
        switch lectionaryYear % 3 {
        case 1: return "A"
        case 2: return "B"
        default: return "C"
        }
    }

    /// The weekday lectionary cycle (Year I in odd liturgical years, Year II in
    /// even ones): the two-year rotation of weekday first readings.
    var weekdayLectionaryCycle: String {
        lectionaryYear % 2 == 1 ? "I" : "II"
    }

    /// USCCB's daily readings page for this date, listing the actual Reading 1,
    /// Psalm, and Gospel citations. A date-based deep link, so no offline lectionary
    /// data is bundled.
    var usccbReadingsURL: URL? {
        URL(string: "https://bible.usccb.org/bible/readings/\(Self.usccbDateFormatter.string(from: date)).cfm")
    }

    private static let usccbDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMddyy"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.calendar = Calendar(identifier: .gregorian)
        return f
    }()
}
