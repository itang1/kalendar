//
//  DayCard.swift
//  kalendar
//
//  Created by Irene Tang on 12/20/25.
//
//  Represents one day of the year

import SwiftUI

struct DayCard: Identifiable {
    /// The day itself is the stable identity: it is unique within the window and,
    /// unlike a fresh UUID, survives a window rebuild (e.g. the midnight roll-over),
    /// so SwiftUI diffing and animations stay correct across rebuilds.
    var id: Date { date }
    let dayOfYear: Int  // 1–365
    let date: Date
    var comments: [String]

    // Liturgical calendar data
    var liturgicalSeason: LiturgicalSeason
    var liturgicalColor: LiturgicalColor
    var feastName: String?
    var feastID: FeastID?
    var feastDescription: String?
    var isSolemnity: Bool
    var weekOfSeason: Int?
    var isMovableFeast: Bool = false
    /// The "N days until <anchor>" line, computed once when the window is built
    /// (see `DayCard.countdownText(for:)`) rather than re-derived in the detail
    /// view's body, since the paged day browser instantiates its pages eagerly.
    var countdownText: String?
}

// MARK: - Liturgical day naming

/// Numeric ordinal (e.g. "14th"), not spelled out: the date line already
/// carries the weekday, so this title never repeats it and stays quick to parse.
private func ordinalName(_ n: Int) -> String {
    let mod100 = n % 100
    if mod100 >= 11 && mod100 <= 13 { return "\(n)th" }
    switch n % 10 {
    case 1: return "\(n)st"
    case 2: return "\(n)nd"
    case 3: return "\(n)rd"
    default: return "\(n)th"
    }
}

extension DayCard {
    /// The day's proper liturgical name, the way a missal titles it, e.g.
    /// "2nd Week of Advent" or "3rd Sunday in Ordinary Time". Nil on feast days
    /// (the feast is the day's name) and in seasons without counted weeks
    /// (Christmas, Triduum). Leaves out the weekday name, since the date line
    /// in the header already shows it (e.g. "July 3, 2026 (Friday)").
    var liturgicalDayTitle: String? {
        guard feastName == nil, let week = weekOfSeason else { return nil }

        let isSunday = Calendar.liturgical.component(.weekday, from: date) == 1

        switch liturgicalSeason {
        case .lent where week == 0:
            // The days between Ash Wednesday and the First Sunday of Lent.
            return "After Ash Wednesday"
        case .easter where week == 1 && !isSunday:
            return "Octave of Easter"
        case .advent, .lent, .easter:
            return isSunday
                ? "\(ordinalName(week)) Sunday of \(liturgicalSeason.rawValue)"
                : "\(ordinalName(week)) Week of \(liturgicalSeason.rawValue)"
        case .ordinaryTime:
            return isSunday
                ? "\(ordinalName(week)) Sunday in Ordinary Time"
                : "\(ordinalName(week)) Week in Ordinary Time"
        default:
            return nil
        }
    }

    /// Days until the next major moment of the year, e.g. "17 days until Easter".
    /// Nil only if no anchor lies ahead (which cannot happen in practice, since
    /// Christmas recurs every year). Computed at window-build time and stored on
    /// the card, so it is not re-derived for every eagerly built browser page.
    static func countdownText(for date: Date) -> String? {
        let calendar = Calendar.liturgical
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

// MARK: - Lectionary cycle

extension DayCard {
    /// The civil year whose cycle governs this day. The lectionary year turns over
    /// on the First Sunday of Advent, so Advent days already belong to the next
    /// civil year's cycle.
    private var lectionaryYear: Int {
        let calendar = Calendar.liturgical
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
}

#if DEBUG
extension DayCard {
    /// A representative day (Christmas, with a note) for SwiftUI previews.
    static var preview: DayCard {
        DayCard(
            dayOfYear: 359,
            date: Calendar.liturgical.date(from: DateComponents(year: 2025, month: 12, day: 25))!,
            comments: ["Christmas Eve service with family"],
            liturgicalSeason: .christmas,
            liturgicalColor: .white,
            feastName: "Nativity of the Lord (Christmas)",
            feastID: .nativityOfTheLord,
            feastDescription: "The joyful celebration of Jesus' birth in Bethlehem. Christians believe God became a human baby, born to Mary in humble circumstances.",
            isSolemnity: true,
            weekOfSeason: nil,
            isMovableFeast: false,
            countdownText: nil
        )
    }
}
#endif
