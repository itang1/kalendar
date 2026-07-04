//
//  LiturgicalCalendar.swift
//  kalendar
//
//  Computes liturgical seasons, feast days, and colors for the Church Year.
//  Supports the Roman Rite / General Roman Calendar.

import SwiftUI

// MARK: - Liturgical Season

enum LiturgicalSeason: String, CaseIterable {
    case advent = "Advent"
    case christmas = "Christmas"
    case ordinaryTime = "Ordinary Time"
    case lent = "Lent"
    case triduum = "Triduum"
    case easter = "Easter"

    /// The primary liturgical vestment color for this season
    var color: Color {
        switch self {
        case .advent: return LiturgicalColor.violet.color
        case .christmas: return LiturgicalColor.white.color
        case .ordinaryTime: return LiturgicalColor.green.color
        case .lent: return LiturgicalColor.violet.color
        case .triduum: return LiturgicalColor.red.color
        case .easter: return LiturgicalColor.white.color
        }
    }

    var contextualItems: [String] {
        switch self {
        case .advent:
            return [
                "Light the Advent wreath candles week by week. Three are violet, one is rose, and the progression marks time in a way that feels more honest than a countdown.",
                "Read Isaiah. The prophetic passages the liturgy draws from during these weeks are worth sitting with on their own, outside of Mass.",
                "Pray in the morning or the evening. Advent is a season of watching, and watching takes some quiet.",
                "The tone is expectant. The world is rushing toward Christmas. The liturgy is doing something slower."
            ]
        case .christmas:
            return [
                "Keep celebrating through January. Most people are done by December 26, which means missing the better half of the season.",
                "Read the prologue of John's Gospel. It is what the liturgy has called the Christmas reading for centuries, and it is not about a manger.",
                "Mark the feast days that cluster in these weeks: St. Stephen on the 26th, St. John on the 27th, the Holy Innocents on the 28th.",
                "The tone is warm and unhurried. Lent will come soon enough."
            ]
        case .ordinaryTime:
            return [
                "Follow the Sunday Gospel readings week by week. The three-year lectionary cycle moves through Matthew, Mark, and Luke in sequence, and tracking it lets you watch the ministry of Jesus unfold gradually.",
                "Pay attention to the saints' feasts as they come. Most of them fall in Ordinary Time, and they are the tradition's way of saying that holiness looks like something specific and concrete.",
                "The tone is steady. This is not the dramatic part of the year. It is the part where most of the actual work of following happens."
            ]
        case .lent:
            return [
                "Fast on Ash Wednesday and Good Friday. Abstain from meat on Fridays through the season.",
                "Take on one practice and give up one thing. The tradition is not only subtraction.",
                "Go to Stations of the Cross on a Friday. It is slower and older than a Sunday Mass and worth experiencing at least once in the season.",
                "Read John chapters 11 through 19 before Holy Week arrives. The liturgy moves through them and knowing them makes everything that follows land differently.",
                "The tone is serious without being without hope. Lent is pointing toward something."
            ]
        case .triduum:
            return [
                "Go to all three liturgies if you possibly can. Holy Thursday, Good Friday, and the Easter Vigil are not three separate services. They are one rite spread across three days.",
                "Keep Holy Saturday quiet. There is no liturgy until the Vigil, and the silence is intentional.",
                "Plan to stay for the full Easter Vigil. It takes hours, begins in darkness, and moves through a long sweep of readings before it erupts. That is the design, not the inconvenience.",
                "The Vigil is the night new members are baptized. If someone you know is entering the faith, this is when it happens.",
                "The tone goes from tenderness to grief to stillness to joy, in that order."
            ]
        case .easter:
            return [
                "Say Alleluia. It was held back all through Lent and this is the season it belongs to.",
                "Read Acts of the Apostles from the beginning. It is the season's companion text, the story of what happened after the resurrection, and it moves fast.",
                "Think about baptism. Easter Vigil is when new Christians are received, and the whole season carries that sense of new life.",
                "The tone is joyful and sustained. Easter is not one day. It is fifty days, longer than Lent, and the tradition takes that seriously."
            ]
        }
    }

    var explanation: String {
        switch self {
        case .advent:
            return "The four-week season of preparation and anticipation before Christmas. Christians reflect on the coming of Jesus, both his birth and his promised return. The word 'Advent' means 'coming.'"
        case .christmas:
            return "The joyful celebration of Jesus' birth, lasting from December 25 through the Baptism of the Lord in January. It is not just one day; Christians celebrate for weeks."
        case .ordinaryTime:
            return "The longest season of the liturgical year, split into two stretches (after Christmas and after Pentecost). 'Ordinary' does not mean boring. It comes from 'ordinal' (counted). These weeks focus on Jesus' public life and teachings."
        case .lent:
            return "A 40-day season of prayer, fasting, and giving that prepares Christians for Easter. It begins on Ash Wednesday and is a time for self-reflection and turning back toward God."
        case .triduum:
            return "The holiest three days of the entire liturgical year: Holy Thursday (Jesus' Last Supper), Good Friday (his crucifixion and death), and Holy Saturday (waiting at the tomb). It is the heart of the Christian faith."
        case .easter:
            return "The most important and joyful season, celebrating Jesus' resurrection from the dead. It lasts 50 days, from Easter Sunday all the way to Pentecost. It is treated as one long feast day."
        }
    }
}

// MARK: - Liturgical Color (vestment color for specific days)

enum LiturgicalColor: String {
    case green = "Green"
    case violet = "Violet"
    case white = "White"
    case red = "Red"
    case rose = "Rose"

    var color: Color {
        switch self {
        case .green: return Color(red: 0.2, green: 0.55, blue: 0.3)
        case .violet: return Color(red: 0.45, green: 0.2, blue: 0.55)
        case .white: return Color(red: 1.0, green: 1.0, blue: 1.0)
        case .red: return Color(red: 0.75, green: 0.15, blue: 0.15)
        case .rose: return Color(red: 0.85, green: 0.5, blue: 0.6)
        }
    }

    /// Why this color is worn, shown with the vestment swatch in the day detail
    /// view. One tailored sentence per color rather than a generic line.
    var explanation: String {
        switch self {
        case .green:
            return "Green is the color of life and growth. The priest wears it through Ordinary Time, the long stretch of steady, unhurried discipleship."
        case .violet:
            return "Violet is the color of penance and preparation. The priest wears it through Advent and Lent, the two seasons of waiting and turning back."
        case .white:
            return "White is the color of glory, purity, and celebration. The priest wears it for Christmas, Easter, feasts of Jesus and Mary, and saints who were not martyred."
        case .red:
            return "Red is the color of blood and fire. The priest wears it for the Passion of Jesus, for the Holy Spirit, and for the martyrs."
        case .rose:
            return "Rose is violet lightened with joy. The priest wears it just twice a year, on Gaudete Sunday in Advent and Laetare Sunday in Lent, a breath of encouragement partway through a penitential season."
        }
    }
}

// MARK: - Feast Identity

/// A stable identifier for every feast the engine can name. Persisted note keys
/// and the obligation/discipline flags reference these cases instead of display
/// strings, so renaming a feast (even fixing a typo) never orphans a user's notes
/// or silently breaks a flag. The raw value is the case name and is what gets
/// stored, so cases must not be renamed once shipped.
enum FeastID: String {
    // Fixed feasts (by month/day)
    case maryMotherOfGod, epiphany, conversionOfPaul, presentationOfTheLord
    case chairOfPeter, josephSpouseOfMary, annunciation, markEvangelist
    case josephTheWorker, matthias, visitation, barnabas
    case nativityOfJohnTheBaptist, peterAndPaul, maryMagdalene, james
    case transfiguration, lawrence, assumption, queenshipOfMary
    case nativityOfMary, exaltationOfTheCross, matthewEvangelist, archangels
    case thereseOfLisieux, guardianAngels, francisOfAssisi, ladyOfTheRosary
    case lukeEvangelist, simonAndJude, allSaints, allSouls
    case dedicationOfLateran, andrew, immaculateConception, ladyOfGuadalupe
    case nativityOfTheLord, stephen, johnEvangelist, holyInnocents
    // Movable feasts (relative to Easter, or the Christmas-octave Sunday)
    case ashWednesday, palmSunday, holyThursday, goodFriday
    case holySaturday, easterSunday, easterMonday, divineMercy
    case sacredHeart, holyFamily, ascension, pentecost
    case trinitySunday, corpusChristi, christTheKing
}

// MARK: - Liturgical Day Info

struct LiturgicalDayInfo {
    let season: LiturgicalSeason
    let liturgicalColor: LiturgicalColor
    let feastName: String?
    /// Stable identifier for the feast, independent of its display name, so notes
    /// keyed to a feast survive a wording change and flag logic can match on identity
    /// rather than string literals. Nil on days with no feast.
    let feastID: FeastID?
    let feastDescription: String?
    let isSolemnity: Bool
    let weekOfSeason: Int?
    /// True when the feast's date shifts year to year (Easter cycle, etc.), as
    /// opposed to a fixed-date feast. Used to key saved notes correctly.
    let isMovableFeast: Bool
}

// MARK: - Liturgical Calendar Engine

struct LiturgicalCalendar {

    private let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 1 // Sunday
        return cal
    }()

    /// Shared, lock-guarded cache of computed key dates, keyed by year. Shared across
    /// every engine instance (the widget computes off the main actor, so it is locked).
    private static let keyDatesCache = KeyLiturgicalDatesCache()

    // MARK: - Easter (Anonymous Gregorian Algorithm / Computus)

    func easterDate(year: Int) -> Date {
        let a = year % 19
        let b = year / 100
        let c = year % 100
        let d = b / 4
        let e = b % 4
        let f = (b + 8) / 25
        let g = (b - f + 1) / 3
        let h = (19 * a + b - d - g + 15) % 30
        let i = c / 4
        let k = c % 4
        let l = (32 + 2 * e + 2 * i - h - k) % 7
        let m = (a + 11 * h + 22 * l) / 451
        let month = (h + l - 7 * m + 114) / 31
        let day = ((h + l - 7 * m + 114) % 31) + 1
        return calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    // MARK: - Key Dates for a Given Year

    func keyDates(year: Int) -> KeyLiturgicalDates {
        // keyDates is pure per year, but launch builds 366 days and every countdown
        // constructs a fresh engine, so the same years are recomputed hundreds of
        // times. Memoize per year across all instances.
        Self.keyDatesCache.value(for: year) { computeKeyDates(year: year) }
    }

    private func computeKeyDates(year: Int) -> KeyLiturgicalDates {
        let easter = easterDate(year: year)

        let ashWednesday = calendar.date(byAdding: .day, value: -46, to: easter)!
        let palmSunday = calendar.date(byAdding: .day, value: -7, to: easter)!
        let holyThursday = calendar.date(byAdding: .day, value: -3, to: easter)!
        let goodFriday = calendar.date(byAdding: .day, value: -2, to: easter)!
        let holySaturday = calendar.date(byAdding: .day, value: -1, to: easter)!
        let ascension = calendar.date(byAdding: .day, value: 39, to: easter)!
        let pentecost = calendar.date(byAdding: .day, value: 49, to: easter)!
        let trinitySunday = calendar.date(byAdding: .day, value: 56, to: easter)!
        let corpusChristi = calendar.date(byAdding: .day, value: 63, to: easter)!
        // Divine Mercy Sunday: the Second Sunday of Easter (octave day).
        let divineMercy = calendar.date(byAdding: .day, value: 7, to: easter)!
        // Sacred Heart of Jesus: the Friday after Corpus Christi, 19 days after Pentecost.
        let sacredHeart = calendar.date(byAdding: .day, value: 68, to: easter)!

        // Advent: starts on the Sunday closest to Nov 30 (4 Sundays before Christmas)
        let christmas = calendar.date(from: DateComponents(year: year, month: 12, day: 25))!
        let christmasWeekday = calendar.component(.weekday, from: christmas)
        // 4th Sunday before Christmas
        let daysToSunday = (christmasWeekday == 1) ? 28 : (christmasWeekday - 1 + 21)
        let adventStart = calendar.date(byAdding: .day, value: -daysToSunday, to: christmas)!

        // Holy Family: the Sunday within the Octave of Christmas. When Christmas
        // itself is a Sunday there is no Sunday between Dec 26 and 31, so the feast
        // moves to Dec 30 per the General Roman Calendar.
        let holyFamily: Date
        if christmasWeekday == 1 {
            holyFamily = calendar.date(from: DateComponents(year: year, month: 12, day: 30))!
        } else {
            holyFamily = calendar.date(byAdding: .day, value: 8 - christmasWeekday, to: christmas)!
        }

        let epiphany = calendar.date(from: DateComponents(year: year, month: 1, day: 6))!
        // Baptism of the Lord: normally the Sunday after Epiphany. With Epiphany
        // fixed on Jan 6, if Jan 6 is itself a Sunday the Baptism is the following
        // Sunday (Jan 13), not the next day.
        let epiphanyWeekday = calendar.component(.weekday, from: epiphany)
        let baptismOfLord: Date
        if epiphanyWeekday == 1 {
            baptismOfLord = calendar.date(byAdding: .day, value: 7, to: epiphany)!
        } else {
            baptismOfLord = calendar.date(byAdding: .day, value: 8 - epiphanyWeekday, to: epiphany)!
        }

        // Christ the King: last Sunday before Advent
        let christTheKing = calendar.date(byAdding: .day, value: -7, to: adventStart)!

        return KeyLiturgicalDates(
            easter: easter,
            ashWednesday: ashWednesday,
            palmSunday: palmSunday,
            holyThursday: holyThursday,
            goodFriday: goodFriday,
            holySaturday: holySaturday,
            ascension: ascension,
            pentecost: pentecost,
            trinitySunday: trinitySunday,
            corpusChristi: corpusChristi,
            divineMercy: divineMercy,
            sacredHeart: sacredHeart,
            adventStart: adventStart,
            holyFamily: holyFamily,
            christmas: christmas,
            baptismOfLord: baptismOfLord,
            christTheKing: christTheKing
        )
    }

    // MARK: - Compute Liturgical Info for a Date

    func liturgicalInfo(for date: Date) -> LiturgicalDayInfo {
        let year = calendar.component(.year, from: date)
        let keys = keyDates(year: year)
        let prevYearKeys = keyDates(year: year - 1)

        let isSunday = calendar.component(.weekday, from: date) == 1
        let season = seasonForDate(date, keys: keys, prevYearKeys: prevYearKeys)

        // A solemnity that was outranked on its usual date is transferred onto this
        // day (e.g. the Annunciation moved out of Holy Week). This outranks the
        // ordinary fixed feast for the day.
        if let feast = transferredSolemnity(for: date, keys: keys, prevYearKeys: prevYearKeys) {
            return LiturgicalDayInfo(
                season: season,
                liturgicalColor: feast.color,
                feastName: feast.name,
                feastID: feast.id,
                feastDescription: feast.description,
                isSolemnity: true,
                weekOfSeason: nil,
                isMovableFeast: false
            )
        }

        // Check fixed feasts (saints' days) first, unless the day outranks them.
        // The Triduum, Holy Week, the Octave of Easter, and the Sundays of Advent,
        // Lent, and Easter all take precedence, so a saint's day landing on one is
        // omitted (a solemnity like the Annunciation is transferred to another date).
        if !fixedFeastIsImpeded(date: date, season: season, isSunday: isSunday, keys: keys),
           let feast = fixedFeast(for: date) {
            return LiturgicalDayInfo(
                season: season,
                liturgicalColor: feast.color,
                feastName: feast.name,
                feastID: feast.id,
                feastDescription: feast.description,
                isSolemnity: feast.isSolemnity,
                weekOfSeason: nil,
                isMovableFeast: false
            )
        }

        // Check movable feasts (Easter cycle, Ascension, Pentecost, etc.)
        if let feast = movableFeast(for: date, keys: keys) {
            return LiturgicalDayInfo(
                season: season,
                liturgicalColor: feast.color,
                feastName: feast.name,
                feastID: feast.id,
                feastDescription: feast.description,
                isSolemnity: feast.isSolemnity,
                weekOfSeason: nil,
                isMovableFeast: true
            )
        }

        let color = defaultColorForSeason(season, isSunday: isSunday, date: date, keys: keys)

        return LiturgicalDayInfo(
            season: season,
            liturgicalColor: color,
            feastName: nil,
            feastID: nil,
            feastDescription: nil,
            isSolemnity: false,
            weekOfSeason: weekOfSeason(date: date, season: season, keys: keys, prevYearKeys: prevYearKeys),
            isMovableFeast: false
        )
    }

    // MARK: - Season Determination

    private func seasonForDate(_ date: Date, keys: KeyLiturgicalDates, prevYearKeys: KeyLiturgicalDates) -> LiturgicalSeason {
        let year = calendar.component(.year, from: date)

        // Christmas season from previous year (Dec 25 of prev year to Baptism of Lord this year)
        if date >= prevYearKeys.christmas && date < calendar.date(from: DateComponents(year: year, month: 1, day: 1))! {
            return .christmas
        }

        // Jan 1 to Baptism of the Lord: still Christmas season
        let janFirst = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        if date >= janFirst && date <= keys.baptismOfLord {
            return .christmas
        }

        // Ordinary Time I: after Baptism of the Lord to Ash Wednesday
        if date > keys.baptismOfLord && date < keys.ashWednesday {
            return .ordinaryTime
        }

        // Lent: Ash Wednesday to Holy Thursday (exclusive of Triduum)
        if date >= keys.ashWednesday && date < keys.holyThursday {
            return .lent
        }

        // Triduum: Holy Thursday evening to Easter Sunday (inclusive)
        if date >= keys.holyThursday && date <= keys.easter {
            return .triduum
        }

        // Easter Season: Easter to Pentecost (inclusive)
        if date > keys.easter && date <= keys.pentecost {
            return .easter
        }

        // Advent
        if date >= keys.adventStart && date < keys.christmas {
            return .advent
        }

        // Christmas season (Dec 25 onward)
        if date >= keys.christmas {
            return .christmas
        }

        // Otherwise Ordinary Time II (after Pentecost to Advent)
        return .ordinaryTime
    }

    // MARK: - Default Liturgical Color for a Season

    private func defaultColorForSeason(_ season: LiturgicalSeason, isSunday: Bool, date: Date, keys: KeyLiturgicalDates) -> LiturgicalColor {
        switch season {
        case .advent:
            // Gaudete Sunday (3rd Sunday of Advent) is rose
            if isSunday {
                let daysSinceAdvent = calendar.dateComponents([.day], from: keys.adventStart, to: date).day ?? 0
                let sundayNumber = (daysSinceAdvent / 7) + 1
                if sundayNumber == 3 { return .rose }
            }
            return .violet
        case .christmas:
            return .white
        case .lent:
            // Laetare Sunday (4th Sunday of Lent) is rose
            if isSunday {
                let daysSinceLent = calendar.dateComponents([.day], from: keys.ashWednesday, to: date).day ?? 0
                let ashWedWeekday = calendar.component(.weekday, from: keys.ashWednesday)
                let daysToFirstSunday = (8 - ashWedWeekday) % 7
                let firstSundayOffset = daysToFirstSunday == 0 ? 7 : daysToFirstSunday
                if daysSinceLent == firstSundayOffset + 21 { return .rose } // 4th Sunday
            }
            return .violet
        case .triduum:
            if calendar.isDate(date, inSameDayAs: keys.goodFriday) { return .red }
            if calendar.isDate(date, inSameDayAs: keys.holySaturday) { return .white }
            if calendar.isDate(date, inSameDayAs: keys.easter) { return .white }
            return .white // Holy Thursday
        case .easter:
            return .white
        case .ordinaryTime:
            return .green
        }
    }

    // MARK: - Week of Season

    private func weekOfSeason(date: Date, season: LiturgicalSeason, keys: KeyLiturgicalDates, prevYearKeys: KeyLiturgicalDates) -> Int? {
        switch season {
        case .advent:
            let days = calendar.dateComponents([.day], from: keys.adventStart, to: date).day ?? 0
            return (days / 7) + 1
        case .lent:
            let days = calendar.dateComponents([.day], from: keys.ashWednesday, to: date).day ?? 0
            let ashWedWeekday = calendar.component(.weekday, from: keys.ashWednesday)
            let daysToFirstSunday = (8 - ashWedWeekday) % 7
            let adjusted = daysToFirstSunday == 0 ? 7 : daysToFirstSunday
            if days < adjusted { return 0 }
            return ((days - adjusted) / 7) + 1
        case .easter:
            let days = calendar.dateComponents([.day], from: keys.easter, to: date).day ?? 0
            return (days / 7) + 1
        case .ordinaryTime:
            if date > keys.baptismOfLord && date < keys.ashWednesday {
                let days = calendar.dateComponents([.day], from: keys.baptismOfLord, to: date).day ?? 0
                return (days / 7) + 1
            } else {
                // The second stretch is numbered backward from Christ the King,
                // which always begins Week 34, per the General Roman Calendar.
                let weekday = calendar.component(.weekday, from: date)
                let sunday = calendar.date(byAdding: .day, value: -(weekday - 1), to: date)!
                let weeksToChristTheKing = (calendar.dateComponents([.day], from: sunday, to: keys.christTheKing).day ?? 0) / 7
                return 34 - weeksToChristTheKing
            }
        default:
            return nil
        }
    }

    // MARK: - Feast Precedence

    /// Whether a fixed feast (a saint's day) is outranked by the day it falls on and
    /// so should not be shown. Based on the Table of Liturgical Days: the Triduum,
    /// Holy Week, the Octave of Easter, and the Sundays of Advent, Lent, and Easter
    /// all take precedence over feasts and memorials of saints, and even over
    /// solemnities (which are then transferred to another date).
    private func fixedFeastIsImpeded(date: Date, season: LiturgicalSeason, isSunday: Bool, keys: KeyLiturgicalDates) -> Bool {
        // Holy Week and the Triduum: Palm Sunday through Easter Sunday.
        if date >= keys.palmSunday && date <= keys.easter { return true }

        // Octave of Easter: the eight days from Easter through the Second Sunday of
        // Easter, each of which ranks as a solemnity.
        let octaveEnd = calendar.date(byAdding: .day, value: 7, to: keys.easter)!
        if date > keys.easter && date <= octaveEnd { return true }

        // Privileged Sundays of Advent, Lent, and Easter outrank saints' days.
        if isSunday && (season == .advent || season == .lent || season == .easter) { return true }

        // Feasts of the Lord that land amid fixed feasts outrank a coincident
        // saint's day: the Holy Family (a Christmas-octave Sunday that can fall on
        // St. Stephen, St. John, or the Holy Innocents) and the Sacred Heart (a
        // solemnity of the Lord). In the rare year the Sacred Heart coincides with
        // a fixed solemnity of a saint, that saint is superseded rather than
        // transferred; this is a deliberate simplification.
        if calendar.isDate(date, inSameDayAs: keys.holyFamily) { return true }
        if calendar.isDate(date, inSameDayAs: keys.sacredHeart) { return true }

        return false
    }

    /// If a solemnity that was impeded on its usual date this year is transferred
    /// onto `date`, return it. The three fixed solemnities that can be outranked are
    /// St. Joseph (Mar 19), the Annunciation (Mar 25), and the Immaculate Conception
    /// (Dec 8). When impeded they move to a nearby open day per the Table of
    /// Liturgical Days.
    private func transferredSolemnity(for date: Date, keys: KeyLiturgicalDates, prevYearKeys: KeyLiturgicalDates) -> (id: FeastID, name: String, color: LiturgicalColor, isSolemnity: Bool, description: String)? {
        let year = calendar.component(.year, from: date)
        let candidates = [
            calendar.date(from: DateComponents(year: year, month: 3, day: 19))!,   // St. Joseph
            calendar.date(from: DateComponents(year: year, month: 3, day: 25))!,   // Annunciation
            calendar.date(from: DateComponents(year: year, month: 12, day: 8))!,   // Immaculate Conception
        ]

        for natural in candidates {
            guard let feast = fixedFeast(for: natural), feast.isSolemnity else { continue }
            let naturalSeason = seasonForDate(natural, keys: keys, prevYearKeys: prevYearKeys)
            let naturalIsSunday = calendar.component(.weekday, from: natural) == 1
            guard fixedFeastIsImpeded(date: natural, season: naturalSeason, isSunday: naturalIsSunday, keys: keys) else { continue }

            if calendar.isDate(date, inSameDayAs: transferTarget(for: natural, keys: keys)) {
                let note = " Its usual date was outranked this year, so it is observed today instead."
                return (feast.id, feast.name, feast.color, true, feast.description + note)
            }
        }
        return nil
    }

    /// Where an impeded solemnity moves. The Annunciation clears Holy Week and the
    /// Octave of Easter by moving to the Monday after the Second Sunday of Easter;
    /// St. Joseph clears Holy Week by moving to the Saturday before Palm Sunday.
    /// Otherwise (impeded only by a privileged Sunday) the solemnity moves to the
    /// following day.
    private func transferTarget(for natural: Date, keys: KeyLiturgicalDates) -> Date {
        let month = calendar.component(.month, from: natural)
        let day = calendar.component(.day, from: natural)
        let inHolyWeekOrLater = natural >= keys.palmSunday

        if month == 3 && day == 25 && inHolyWeekOrLater {   // Annunciation in Holy Week / Octave
            return calendar.date(byAdding: .day, value: 8, to: keys.easter)!
        }
        if month == 3 && day == 19 && inHolyWeekOrLater {   // St. Joseph in Holy Week
            return calendar.date(byAdding: .day, value: -1, to: keys.palmSunday)!
        }
        // Impeded by a privileged Sunday (or Immaculate Conception on Advent Sunday):
        // move to the next day.
        return calendar.date(byAdding: .day, value: 1, to: natural)!
    }

    // MARK: - Fixed Feasts (by month/day)

    private func fixedFeast(for date: Date) -> (id: FeastID, name: String, color: LiturgicalColor, isSolemnity: Bool, description: String)? {
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)

        switch (month, day) {
        case (1, 1): return (.maryMotherOfGod, "Solemnity of Mary, Mother of God", .white, true,
            "The oldest feast honoring Mary. On the first day of the year, Christians celebrate Mary's role as the mother of Jesus (who Christians believe is God). It is also the World Day of Peace.")
        case (1, 6): return (.epiphany, "Epiphany of the Lord", .white, true,
            "Celebrates the visit of the Magi (Wise Men) to the infant Jesus. 'Epiphany' means 'revelation,' and this feast marks Jesus being revealed to the whole world, not just the Jewish people.")
        case (1, 25): return (.conversionOfPaul, "Conversion of St. Paul", .white, false,
            "Recalls the dramatic moment when Saul of Tarsus, who was hunting down and imprisoning Christians, was struck blind on the road to Damascus by a vision of the risen Jesus. He recovered, was baptized, changed his name to Paul, and became the greatest missionary the Christian faith has ever produced.")
        case (2, 2): return (.presentationOfTheLord, "Presentation of the Lord", .white, false,
            "Forty days after Christmas, Mary and Joseph brought baby Jesus to the Temple in Jerusalem, as Jewish law required for firstborn sons. The elderly prophet Simeon recognized him as the Messiah and called him 'a light for revelation to the Gentiles.' Also called Candlemas.")
        case (2, 22): return (.chairOfPeter, "Chair of St. Peter", .white, false,
            "Celebrates Peter's role as the leader of the apostles and the first bishop of Rome. The 'chair' is not a piece of furniture so much as a symbol of teaching authority. This feast is about the office of leadership that traces through every pope back to Peter.")
        case (3, 19): return (.josephSpouseOfMary, "St. Joseph, Spouse of the Blessed Virgin Mary", .white, true,
            "Honors Joseph, the foster-father of Jesus and husband of Mary. He was a humble carpenter from Nazareth who protected and raised Jesus. He is the patron saint of workers, fathers, and all Christians.")
        case (3, 25): return (.annunciation, "Annunciation of the Lord", .white, true,
            "Celebrates the moment the angel Gabriel appeared to Mary and announced she would conceive Jesus by the Holy Spirit. Mary said 'yes,' and Christians believe that is when God became human. Exactly 9 months before Christmas.")
        case (4, 25): return (.markEvangelist, "St. Mark, Evangelist", .red, false,
            "Honors Mark, the author of the shortest and most urgent of the four Gospels. He wrote it in Rome, likely drawing on Peter's eyewitness accounts, and his Gospel reads like it is in a hurry. The word 'immediately' appears over forty times.")
        case (5, 1): return (.josephTheWorker, "St. Joseph the Worker", .white, false,
            "A feast established in 1955, celebrating Joseph as a model for all working people. It falls on May Day and is the tradition's answer to secular labor observances, offering a patron for the dignity and sanctity of ordinary work.")
        case (5, 14): return (.matthias, "St. Matthias, Apostle", .red, false,
            "Matthias was chosen by lot to replace Judas Iscariot among the twelve apostles. The account in Acts is brief. He is a reminder that the structure of the early community mattered enough to be filled, and that ordinary people were chosen for extraordinary roles.")
        case (5, 31): return (.visitation, "Visitation of the Blessed Virgin Mary", .white, false,
            "Celebrates Mary's journey to visit her cousin Elizabeth, who was pregnant with John the Baptist. When Mary arrived, Elizabeth's child leapt in her womb, and Elizabeth cried out 'Blessed are you among women.' Mary responded with the Magnificat, one of the most beautiful prayers in Scripture.")
        case (6, 11): return (.barnabas, "St. Barnabas, Apostle", .red, false,
            "Barnabas was not one of the original twelve but is called an apostle because of the scope of his missionary work. He was the one who vouched for Paul to the early community when everyone was afraid of him. He and Paul traveled together through Cyprus and Asia Minor, planting churches in city after city.")
        case (6, 24): return (.nativityOfJohnTheBaptist, "Nativity of St. John the Baptist", .white, true,
            "The birth of John the Baptist, Jesus' cousin, who grew up to be the prophet who prepared the way for Jesus' ministry. He baptized people in the Jordan River and is the one who baptized Jesus himself.")
        case (6, 29): return (.peterAndPaul, "Sts. Peter and Paul, Apostles", .red, true,
            "Honors the two greatest apostles: Peter, the fisherman Jesus chose to lead his followers (the first pope), and Paul, who started out persecuting Christians but converted and became the greatest missionary of the early Christian world. Both were martyred in Rome.")
        case (7, 22): return (.maryMagdalene, "St. Mary Magdalene", .white, false,
            "Mary Magdalene was among Jesus' closest followers, present at his crucifixion when most of the apostles had fled, and the first person to see him after the resurrection. She is called the 'apostle to the apostles' because she carried the news of the resurrection to the others. Her feast was elevated to a proper feast in 2016.")
        case (7, 25): return (.james, "St. James, Apostle", .red, false,
            "James was one of the sons of Zebedee and one of Jesus' inner circle of three, along with Peter and John. He was the first of the apostles to be martyred, killed by King Herod Agrippa around 44 AD. His shrine in Santiago de Compostela in Spain has been one of the great pilgrimage destinations for over a thousand years.")
        case (8, 6): return (.transfiguration, "Transfiguration of the Lord", .white, false,
            "Recalls when Jesus took three disciples up a mountain, and his appearance was transformed. His face shone like the sun and his clothes became dazzling white. Moses and Elijah appeared beside him, and God's voice said 'This is my beloved Son.'")
        case (8, 10): return (.lawrence, "St. Lawrence, Deacon and Martyr", .red, false,
            "Lawrence was one of the seven deacons of Rome under Pope Sixtus II. When Sixtus was martyred in 258, Lawrence was given three days to hand over the wealth of the community to the emperor. He spent the time distributing it to the poor, then presented the poor themselves as 'the treasure of the community.' He was executed on a gridiron. He is the patron of deacons, cooks, and the poor.")
        case (8, 15): return (.assumption, "Assumption of the Blessed Virgin Mary", .white, true,
            "Celebrates the belief that at the end of Mary's earthly life, she was taken up ('assumed') body and soul into heaven. It is one of the most important Marian feasts, and a Holy Day of Obligation in many countries.")
        case (8, 22): return (.queenshipOfMary, "Queenship of the Blessed Virgin Mary", .white, false,
            "One week after the Assumption, this feast celebrates Mary's role in heaven. It flows naturally from the one before it: if Mary was assumed body and soul into heaven, what is she there? The tradition answers with the title of queen, not a political one, but a dignity that comes from her closeness to Christ.")
        case (9, 8): return (.nativityOfMary, "Nativity of the Blessed Virgin Mary", .white, false,
            "The birth of Mary, celebrated nine months after the Immaculate Conception on December 8. This is one of only three birthdays celebrated in the liturgical calendar: Jesus, John the Baptist, and Mary. The others are commemorated on the anniversary of their death, but these three are celebrated from their first day.")
        case (9, 14): return (.exaltationOfTheCross, "Exaltation of the Holy Cross", .red, false,
            "Honors the cross on which Jesus was crucified. Rather than a symbol of defeat, Christians see it as the instrument of salvation. This feast dates back to the 4th century when St. Helena (Emperor Constantine's mother) is believed to have found the actual cross in Jerusalem.")
        case (9, 21): return (.matthewEvangelist, "St. Matthew, Apostle and Evangelist", .red, false,
            "Matthew was a tax collector, which made him a social outcast in his community. Jesus called him anyway. He went on to write the first of the four Gospels, the most Jewish in character, the one most concerned with showing how Jesus fulfills the Hebrew scriptures.")
        case (9, 29): return (.archangels, "Sts. Michael, Gabriel, and Raphael, Archangels", .white, false,
            "The only feast day dedicated to angels. Michael is the warrior archangel who leads the heavenly army against evil. Gabriel is the messenger who announced Jesus' birth to Mary. Raphael guided the young Tobias in the book of Tobit and is the patron of travelers and healing. Three names, three roles, one feast.")
        case (10, 1): return (.thereseOfLisieux, "St. Thérèse of Lisieux, Doctor of the Church", .white, false,
            "Thérèse Martin entered the Carmelite convent at fifteen and died of tuberculosis at twenty-four. She wrote an autobiography that became one of the most widely read spiritual books of the modern era. Her 'little way,' the conviction that small acts done with great love matter as much as grand gestures, made her a Doctor of the Church.")
        case (10, 2): return (.guardianAngels, "Guardian Angels", .white, false,
            "A feast celebrating the belief that each person has an angel assigned to them for protection and guidance. The tradition is ancient, drawn from passages in the Psalms, the book of Daniel, and Jesus' own words about not despising 'one of these little ones, for their angels in heaven always see the face of my Father.'")
        case (10, 4): return (.francisOfAssisi, "St. Francis of Assisi", .white, false,
            "Francis of Assisi gave up a wealthy merchant's life in 13th-century Italy to live in radical poverty, preach the Gospel, and care for lepers. He founded the Franciscan order, received the stigmata (the wounds of Christ on his body), and wrote the Canticle of the Sun. He is the patron of animals, ecology, and Italy.")
        case (10, 7): return (.ladyOfTheRosary, "Our Lady of the Rosary", .white, false,
            "This feast commemorates the victory at the Battle of Lepanto in 1571, which was attributed to the intercession of Mary through the praying of the Rosary. It was established to give thanks for that protection and to honor the Rosary as a devotional prayer. The Rosary itself meditates on twenty scenes from the lives of Jesus and Mary.")
        case (10, 18): return (.lukeEvangelist, "St. Luke, Evangelist", .red, false,
            "Luke was a physician and the only Gentile author in the New Testament. He wrote both the Gospel that bears his name and the Acts of the Apostles, together the longest single contribution to the New Testament. His Gospel is the one most attentive to women, the poor, and outsiders. He is the patron of doctors and artists.")
        case (10, 28): return (.simonAndJude, "Sts. Simon and Jude, Apostles", .red, false,
            "Two apostles honored together because little is known about either of them. Simon was called 'the Zealot,' probably indicating a political background. Jude (not Judas Iscariot) wrote one of the short letters near the end of the New Testament and is the patron of lost causes, for the simple reason that people only pray to him when all else has failed.")
        case (11, 1): return (.allSaints, "All Saints", .white, true,
            "A day to honor all saints, not just the famous ones with their own feast days, but every holy person in heaven, including ordinary people who lived faithful lives. It is a reminder that everyone is called to holiness.")
        case (11, 2): return (.allSouls, "All Souls' Day (Commemoration of All the Faithful Departed)", .violet, false,
            "A day to remember and pray for all who have died, especially loved ones. Christians pray that those still being purified may reach heaven. It is a tender day of remembrance, often marked by visiting cemeteries.")
        case (11, 9): return (.dedicationOfLateran, "Dedication of the Lateran Basilica", .white, false,
            "The Lateran Basilica in Rome is the cathedral of the bishop of Rome, which means it is technically the mother church of all Roman Catholics worldwide, outranking even St. Peter's. This feast, celebrating its dedication, is a way of marking unity with the broader Christian community.")
        case (11, 30): return (.andrew, "St. Andrew, Apostle", .red, false,
            "Andrew was Simon Peter's brother and, according to John's Gospel, the first of the apostles to follow Jesus. He brought Peter to Jesus. He is said to have been crucified on an X-shaped cross, which became his symbol. He is the patron saint of Scotland, Greece, and Russia.")
        case (12, 8): return (.immaculateConception, "Immaculate Conception of the Blessed Virgin Mary", .white, true,
            "Celebrates the belief that Mary was conceived without original sin, meaning from the very first moment of her existence, she was full of grace. This is often confused with Jesus' conception, but it is about Mary's own conception by her parents, Anne and Joachim. It is the patron feast of the United States.")
        case (12, 12): return (.ladyOfGuadalupe, "Our Lady of Guadalupe", .white, false,
            "In 1531, Mary appeared to a young Aztec man named Juan Diego on a hill outside Mexico City, speaking to him in his own language, Nahuatl. She asked for a church to be built there. When he reported the apparition to the bishop, she left her image miraculously imprinted on his cloak as evidence. That image still exists. She is the patron of the Americas.")
        case (12, 25): return (.nativityOfTheLord, "Nativity of the Lord (Christmas)", .white, true,
            "The joyful celebration of Jesus' birth in Bethlehem. Christians believe God became a human baby, born to Mary in humble circumstances. It is one of the two greatest feasts of the liturgical year (along with Easter).")
        case (12, 26): return (.stephen, "St. Stephen, First Martyr", .red, false,
            "Honors Stephen, one of the first deacons of the early Christian community, who became the very first Christian martyr. He was stoned to death for his faith, and as he died he prayed for his persecutors, just as Jesus had done on the cross.")
        case (12, 27): return (.johnEvangelist, "St. John, Apostle and Evangelist", .white, false,
            "Honors John, one of Jesus' closest disciples (the 'beloved disciple'), who is traditionally credited with writing the Gospel of John, three letters, and the Book of Revelation. He is the only apostle believed to have died of natural causes.")
        case (12, 28): return (.holyInnocents, "Holy Innocents, Martyrs", .red, false,
            "Remembers the infant boys of Bethlehem who were killed by King Herod in his attempt to destroy the newborn Jesus. They are considered the first martyrs for Christ, even though they were too young to know it.")
        default: return nil
        }
    }

    // MARK: - Movable Feasts (relative to Easter)

    private func movableFeast(for date: Date, keys: KeyLiturgicalDates) -> (id: FeastID, name: String, color: LiturgicalColor, isSolemnity: Bool, description: String)? {
        if calendar.isDate(date, inSameDayAs: keys.ashWednesday) {
            return (.ashWednesday, "Ash Wednesday", .violet, false,
                "The start of Lent. Christians receive ashes on their foreheads in the shape of a cross as a sign of repentance and mortality. The priest says 'Remember that you are dust, and to dust you shall return.' It is a day of fasting and reflection.")
        }
        if calendar.isDate(date, inSameDayAs: keys.palmSunday) {
            return (.palmSunday, "Palm Sunday of the Lord's Passion", .red, false,
                "The last Sunday before Easter, marking Jesus' triumphant entry into Jerusalem when crowds waved palm branches and shouted 'Hosanna.' But the mood shifts as the long account of Jesus' suffering and death (the Passion) is also read. It begins Holy Week.")
        }
        if calendar.isDate(date, inSameDayAs: keys.holyThursday) {
            return (.holyThursday, "Holy Thursday", .white, true,
                "Commemorates the Last Supper, when Jesus shared a final meal with his apostles, washed their feet as a sign of humble service, and instituted the Eucharist (communion). That night he was arrested in the Garden of Gethsemane.")
        }
        if calendar.isDate(date, inSameDayAs: keys.goodFriday) {
            return (.goodFriday, "Good Friday of the Lord's Passion", .red, true,
                "The most solemn day of the year. Christians remember Jesus' crucifixion and death. There is no Mass. Instead, a stark service of readings, prayers, and veneration of the cross takes place in bare, stripped buildings. It is a day of fasting and mourning.")
        }
        if calendar.isDate(date, inSameDayAs: keys.holySaturday) {
            return (.holySaturday, "Holy Saturday / Easter Vigil", .white, true,
                "A day of quiet waiting at the tomb. The Easter Vigil on Saturday night is the most elaborate liturgy of the entire year: it begins in darkness with a blazing fire, traces salvation history through readings, and erupts in joy as Easter is proclaimed. New members are baptized into the faith.")
        }
        if calendar.isDate(date, inSameDayAs: keys.easter) {
            return (.easterSunday, "Easter Sunday of the Resurrection", .white, true,
                "The most important day in Christianity. Christians celebrate their core belief: that Jesus rose from the dead on the third day after his crucifixion, conquering death itself. 'He is risen.' The joy of this day extends for 50 days.")
        }
        let easterMonday = calendar.date(byAdding: .day, value: 1, to: keys.easter)!
        if calendar.isDate(date, inSameDayAs: easterMonday) {
            return (.easterMonday, "Easter Monday", .white, false,
                "The celebration of Easter continues. In many countries this is a public holiday. The Gospel tells of two disciples meeting the risen Jesus on the road to Emmaus without recognizing him at first.")
        }
        if calendar.isDate(date, inSameDayAs: keys.divineMercy) {
            return (.divineMercy, "Divine Mercy Sunday", .white, false,
                "The Second Sunday of Easter, named Divine Mercy Sunday by Pope John Paul II in the year 2000. Drawing on the writings of St. Faustina Kowalska, it dwells on God's mercy as the heart of the Easter mystery: the risen Jesus appearing to his disciples and giving them the power to forgive sins.")
        }
        if calendar.isDate(date, inSameDayAs: keys.sacredHeart) {
            return (.sacredHeart, "Most Sacred Heart of Jesus", .white, true,
                "A solemnity celebrating the love of Jesus for humanity, symbolized by his heart. It falls on the Friday after Corpus Christi, nineteen days after Pentecost. The devotion draws on the image of Christ's heart, pierced on the cross, as an unfailing source of mercy and compassion.")
        }
        if calendar.isDate(date, inSameDayAs: keys.holyFamily) {
            return (.holyFamily, "The Holy Family of Jesus, Mary, and Joseph", .white, false,
                "Celebrated on the Sunday within the Octave of Christmas, this feast honors Jesus, Mary, and Joseph together as a household. It holds up the ordinary life of a family, with its work and its love, as something holy, and asks Christians to see their own homes in the same light.")
        }
        if calendar.isDate(date, inSameDayAs: keys.ascension) {
            return (.ascension, "Ascension of the Lord", .white, true,
                "Forty days after Easter, Jesus ascended into heaven in the presence of his disciples, promising to send the Holy Spirit. His last words were a command: 'Go and make disciples of all nations.' This feast marks the completion of Jesus' earthly mission.")
        }
        if calendar.isDate(date, inSameDayAs: keys.pentecost) {
            return (.pentecost, "Pentecost Sunday", .red, true,
                "Fifty days after Easter, the Holy Spirit descended on the apostles like tongues of fire, giving them the courage and ability to preach in many languages. It is considered the 'birthday of the Christian faith,' the moment the apostles went from hiding in fear to boldly proclaiming the Gospel. Red vestments represent the fire of the Spirit.")
        }
        if calendar.isDate(date, inSameDayAs: keys.trinitySunday) {
            return (.trinitySunday, "Most Holy Trinity", .white, true,
                "The Sunday after Pentecost, celebrating the central mystery of Christian faith: that God is one God in three persons, Father, Son, and Holy Spirit. It is not three gods, but one God experienced in three ways. Even theologians say it is a mystery beyond full human understanding.")
        }
        if calendar.isDate(date, inSameDayAs: keys.corpusChristi) {
            return (.corpusChristi, "Most Holy Body and Blood of Christ (Corpus Christi)", .white, true,
                "A feast celebrating the Eucharist, the belief that bread and wine truly become the Body and Blood of Jesus during Mass. Many parishes hold outdoor processions carrying the Eucharist through the streets. 'Corpus Christi' is Latin for 'Body of Christ.'")
        }
        if calendar.isDate(date, inSameDayAs: keys.christTheKing) {
            return (.christTheKing, "Our Lord Jesus Christ, King of the Universe", .white, true,
                "The last Sunday of the liturgical year, proclaiming Jesus as king, but not a worldly king with armies and palaces. His kingdom is one of truth, justice, love, and peace. The next week, the cycle starts all over again with Advent.")
        }
        return nil
    }
}

// MARK: - Key Liturgical Dates

/// A tiny thread-safe memo for `keyDates(year:)`. Held as a `static let` of an
/// immutable, internally locked reference type so it is safe to share across
/// actors (the main-actor view model and the widget's timeline provider).
private final class KeyLiturgicalDatesCache: @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [Int: KeyLiturgicalDates] = [:]

    func value(for year: Int, compute: () -> KeyLiturgicalDates) -> KeyLiturgicalDates {
        lock.lock()
        defer { lock.unlock() }
        if let cached = storage[year] { return cached }
        let computed = compute()
        storage[year] = computed
        return computed
    }
}

struct KeyLiturgicalDates {
    let easter: Date
    let ashWednesday: Date
    let palmSunday: Date
    let holyThursday: Date
    let goodFriday: Date
    let holySaturday: Date
    let ascension: Date
    let pentecost: Date
    let trinitySunday: Date
    let corpusChristi: Date
    let divineMercy: Date
    let sacredHeart: Date
    let adventStart: Date
    let holyFamily: Date
    let christmas: Date
    let baptismOfLord: Date
    let christTheKing: Date
}
