//
//  LiturgicalCalendar.swift
//  kalendar
//
//  Computes the seasons, feasts, and colors of the church year.
//
//  This calendar is written for a Reformed reader. It keeps the shape of the
//  historic church year (the seasons that follow the life of Jesus) and the
//  days that remember people and events from Scripture. It leaves out the
//  devotional and saint-veneration observances that the Reformed tradition does
//  not hold. Where it describes a practice, it says who keeps it rather than
//  telling the reader to keep it.

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
                "Light the Advent wreath candles week by week (three violet, one rose), marking time in a way that feels more honest than a countdown.",
                "Read Isaiah. The prophetic passages this season draws from are worth sitting with on their own.",
                "Keep a quiet morning or evening. Advent is a season of watching, and watching takes some stillness.",
                "The tone is expectant. The world is rushing toward Christmas; this season moves slower."
            ]
        case .christmas:
            return [
                "Keep celebrating past December 25. The season runs for weeks, and most people stop far too early.",
                "Read the opening of John's Gospel. It has been the Christmas reading for centuries, and it is not about a manger.",
                "Notice the days that cluster here: Stephen on the 26th, John on the 27th, the Holy Innocents on the 28th.",
                "The tone is warm and unhurried. Lent will come soon enough."
            ]
        case .ordinaryTime:
            return [
                "Follow the Sunday Gospel readings week by week, watching the ministry of Jesus unfold gradually.",
                "Notice the days that remember figures from Scripture as they come; many of them fall in this season.",
                "The tone is steady. This is the ordinary stretch, where most of the actual work of following happens."
            ]
        case .lent:
            return [
                "Consider a fast, and consider taking something on as well. The season is not only subtraction.",
                "Set aside time for prayer and honest self-examination. Lent is a turning back toward God.",
                "Read John chapters 11 through 19 before Holy Week arrives. Knowing them makes everything that follows land differently.",
                "The tone is serious but not without hope. Lent is pointing toward something."
            ]
        case .triduum:
            return [
                "These three days (Thursday, Friday, and the long wait of Saturday) are best kept together as one movement, not three separate days.",
                "Keep Holy Saturday quiet. The stillness before Easter is intentional.",
                "The tone moves from tenderness to grief to stillness to joy, in that order."
            ]
        case .easter:
            return [
                "Say Alleluia. It was held back all through Lent, and this is the season it belongs to.",
                "Read Acts of the Apostles from the beginning, the story of what happened after the resurrection, and it moves fast.",
                "The tone is joyful and sustained. Easter is not one day but fifty, longer than Lent."
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

    /// What this color signifies, shown with the color swatch in the day detail
    /// view. One tailored sentence per color rather than a generic line.
    var explanation: String {
        switch self {
        case .green:
            return "Green stands for life and growth. It marks Ordinary Time, the long stretch of steady, everyday discipleship."
        case .violet:
            return "Violet stands for repentance and preparation. It marks Advent and Lent, the two seasons of waiting and turning back to God."
        case .white:
            return "White stands for glory, purity, and celebration. It marks Christmas, Easter, and the great days that remember Jesus."
        case .red:
            return "Red stands for blood and fire. It marks the suffering and death of Jesus, the coming of the Holy Spirit, and those who were killed for their faith."
        case .rose:
            return "Rose is violet lightened with joy. It appears just twice a year, on the third Sunday of Advent and the fourth Sunday of Lent, a breath of encouragement partway through a season of waiting."
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
    case reformationDay
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
    /// A secular U.S. holiday falling on this day (federal or common cultural), if
    /// any. This is a separate layer from the church year: it never sets the
    /// liturgical color or counts as a feast, and a day can carry both (e.g.
    /// Reformation Day and Halloween on October 31).
    let civilHolidayName: String?
    let civilHolidayDescription: String?
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

        // Advent: starts on the Sunday closest to Nov 30 (4 Sundays before Christmas)
        let christmas = calendar.date(from: DateComponents(year: year, month: 12, day: 25))!
        let christmasWeekday = calendar.component(.weekday, from: christmas)
        // 4th Sunday before Christmas
        let daysToSunday = (christmasWeekday == 1) ? 28 : (christmasWeekday - 1 + 21)
        let adventStart = calendar.date(byAdding: .day, value: -daysToSunday, to: christmas)!

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
            adventStart: adventStart,
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
        let civil = civilHoliday(for: date)

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
                isMovableFeast: false,
                civilHolidayName: civil?.name,
                civilHolidayDescription: civil?.description
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
                isMovableFeast: false,
                civilHolidayName: civil?.name,
                civilHolidayDescription: civil?.description
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
                isMovableFeast: true,
                civilHolidayName: civil?.name,
                civilHolidayDescription: civil?.description
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
            isMovableFeast: false,
            civilHolidayName: civil?.name,
            civilHolidayDescription: civil?.description
        )
    }

    // MARK: - Season Determination

    private func seasonForDate(_ date: Date, keys: KeyLiturgicalDates, prevYearKeys: KeyLiturgicalDates) -> LiturgicalSeason {
        let year = calendar.component(.year, from: date)

        // Jan 1 to Baptism of the Lord: still Christmas season. (December dates are
        // caught by the `date >= keys.christmas` branch below; a date can never
        // precede Jan 1 of its own year, so no separate prev-year branch is needed.)
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

        return false
    }

    /// If a solemnity that was impeded on its usual date this year is transferred
    /// onto `date`, return it. The two fixed solemnities that can be outranked are
    /// St. Joseph (Mar 19) and the Annunciation (Mar 25). When impeded they move to
    /// a nearby open day per the Table of Liturgical Days.
    private func transferredSolemnity(for date: Date, keys: KeyLiturgicalDates, prevYearKeys: KeyLiturgicalDates) -> (id: FeastID, name: String, color: LiturgicalColor, isSolemnity: Bool, description: String)? {
        let year = calendar.component(.year, from: date)
        let candidates = [
            calendar.date(from: DateComponents(year: year, month: 3, day: 19))!,   // St. Joseph
            calendar.date(from: DateComponents(year: year, month: 3, day: 25))!,   // Annunciation
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
        // Impeded by a privileged Sunday: move to the next day.
        return calendar.date(byAdding: .day, value: 1, to: natural)!
    }

    // MARK: - Fixed Feasts (by month/day)

    private func fixedFeast(for date: Date) -> (id: FeastID, name: String, color: LiturgicalColor, isSolemnity: Bool, description: String)? {
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)

        switch (month, day) {
        case (1, 6): return (.epiphany, "Epiphany of the Lord", .white, true,
            "Celebrates the visit of the Magi (Wise Men) to the infant Jesus. 'Epiphany' means 'revelation,' and this feast marks Jesus being revealed to the whole world, not just the Jewish people.")
        case (1, 25): return (.conversionOfPaul, "Conversion of Paul", .white, false,
            "Recalls the dramatic moment when Saul of Tarsus, who was hunting down and imprisoning Christians, was struck blind on the road to Damascus by a vision of the risen Jesus. He recovered, was baptized, changed his name to Paul, and became the greatest missionary the Christian faith has ever produced.")
        case (2, 2): return (.presentationOfTheLord, "Presentation of the Lord", .white, false,
            "Forty days after Christmas, Mary and Joseph brought baby Jesus to the Temple in Jerusalem, as Jewish law required for firstborn sons. The elderly prophet Simeon recognized him as the Messiah and called him 'a light for revelation to the Gentiles.' Also called Candlemas.")
        case (3, 19): return (.josephSpouseOfMary, "Joseph, Husband of Mary", .white, true,
            "Remembers Joseph, the earthly father of Jesus and husband of Mary. He was a carpenter from Nazareth who protected and raised Jesus, remembered for his quiet, faithful obedience.")
        case (3, 25): return (.annunciation, "Annunciation of the Lord", .white, true,
            "Celebrates the moment the angel Gabriel appeared to Mary and announced she would conceive Jesus by the Holy Spirit. Mary said 'yes,' and Christians believe that is when God became human. Exactly 9 months before Christmas.")
        case (4, 25): return (.markEvangelist, "Mark the Evangelist", .red, false,
            "Honors Mark, the author of the shortest and most urgent of the four Gospels. He wrote it in Rome, likely drawing on Peter's eyewitness accounts, and his Gospel reads like it is in a hurry. The word 'immediately' appears over forty times.")
        case (5, 14): return (.matthias, "Matthias the Apostle", .red, false,
            "Matthias was chosen by lot to replace Judas Iscariot among the twelve apostles. The account in Acts is brief. He is a reminder that the structure of the early community mattered enough to be filled, and that ordinary people were chosen for extraordinary roles.")
        case (5, 31): return (.visitation, "The Visitation", .white, false,
            "Celebrates Mary's journey to visit her cousin Elizabeth, who was pregnant with John the Baptist. When Mary arrived, Elizabeth's child leapt in her womb, and Elizabeth cried out 'Blessed are you among women.' Mary responded with the Magnificat, one of the most beautiful prayers in Scripture.")
        case (6, 11): return (.barnabas, "Barnabas the Apostle", .red, false,
            "Barnabas was not one of the original twelve but is called an apostle because of the scope of his missionary work. He was the one who vouched for Paul to the early community when everyone was afraid of him. He and Paul traveled together through Cyprus and Asia Minor, planting churches in city after city.")
        case (6, 24): return (.nativityOfJohnTheBaptist, "Nativity of John the Baptist", .white, true,
            "The birth of John the Baptist, Jesus' cousin, who grew up to be the prophet who prepared the way for Jesus' ministry. He baptized people in the Jordan River and is the one who baptized Jesus himself.")
        case (6, 29): return (.peterAndPaul, "Peter and Paul, Apostles", .red, true,
            "Honors the two greatest apostles: Peter, the fisherman Jesus chose to lead his followers, and Paul, who started out persecuting Christians but converted and became the greatest missionary of the early Christian world. Both were martyred in Rome.")
        case (7, 22): return (.maryMagdalene, "Mary Magdalene", .white, false,
            "Mary Magdalene was among Jesus' closest followers, present at his crucifixion when most of the apostles had fled, and the first person to see him after the resurrection. She is called the 'apostle to the apostles' because she carried the news of the resurrection to the others. Her feast was elevated to a proper feast in 2016.")
        case (7, 25): return (.james, "James the Apostle", .red, false,
            "James was one of the sons of Zebedee and one of Jesus' inner circle of three, along with Peter and John. He was the first of the apostles to be martyred, killed by King Herod Agrippa around 44 AD. His shrine in Santiago de Compostela in Spain has been one of the great pilgrimage destinations for over a thousand years.")
        case (8, 6): return (.transfiguration, "Transfiguration of the Lord", .white, false,
            "Recalls when Jesus took three disciples up a mountain, and his appearance was transformed. His face shone like the sun and his clothes became dazzling white. Moses and Elijah appeared beside him, and God's voice said 'This is my beloved Son.'")
        case (9, 21): return (.matthewEvangelist, "Matthew the Apostle and Evangelist", .red, false,
            "Matthew was a tax collector, which made him a social outcast in his community. Jesus called him anyway. He went on to write the first of the four Gospels, the most Jewish in character, the one most concerned with showing how Jesus fulfills the Hebrew scriptures.")
        case (10, 18): return (.lukeEvangelist, "Luke the Evangelist", .red, false,
            "Luke was a physician and the only Gentile author in the New Testament. He wrote both the Gospel that bears his name and the Acts of the Apostles, together the longest single contribution to the New Testament. His Gospel is the one most attentive to women, the poor, and outsiders. He is the patron of doctors and artists.")
        case (10, 28): return (.simonAndJude, "Simon and Jude, Apostles", .red, false,
            "Two apostles honored together because little is known about either of them. Simon was called 'the Zealot,' probably indicating a political background. Jude (not Judas Iscariot) is traditionally linked to one of the short letters near the end of the New Testament.")
        case (10, 31): return (.reformationDay, "Reformation Day", .red, false,
            "On October 31, 1517, Martin Luther is said to have posted his Ninety-Five Theses in Wittenberg, protesting abuses in the church of his day. The date became the marker of the Reformation, the movement that returned the Bible to the center of Christian life and gave rise to the Protestant and Reformed traditions.")
        case (11, 30): return (.andrew, "Andrew the Apostle", .red, false,
            "Andrew was Simon Peter's brother and, according to John's Gospel, the first of the apostles to follow Jesus. He brought Peter to Jesus. By tradition he was crucified on an X-shaped cross, which became his symbol.")
        case (12, 25): return (.nativityOfTheLord, "Nativity of the Lord (Christmas)", .white, true,
            "The joyful celebration of Jesus' birth in Bethlehem. Christians believe God became a human baby, born to Mary in humble circumstances. It is one of the two greatest feasts of the liturgical year (along with Easter).")
        case (12, 26): return (.stephen, "Stephen, the First Martyr", .red, false,
            "Honors Stephen, one of the first deacons of the early Christian community, who became the very first Christian martyr. He was stoned to death for his faith, and as he died he prayed for his persecutors, just as Jesus had done on the cross.")
        case (12, 27): return (.johnEvangelist, "John the Apostle and Evangelist", .white, false,
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
                "The start of Lent. In many churches ashes are placed on the forehead in the shape of a cross, a sign of repentance and mortality that recalls the words 'Remember that you are dust, and to dust you shall return.' It is a day of fasting and reflection.")
        }
        if calendar.isDate(date, inSameDayAs: keys.palmSunday) {
            return (.palmSunday, "Palm Sunday of the Lord's Passion", .red, false,
                "The last Sunday before Easter, marking Jesus' triumphant entry into Jerusalem when crowds waved palm branches and shouted 'Hosanna.' But the mood shifts as the long account of Jesus' suffering and death (the Passion) is also read. It begins Holy Week.")
        }
        if calendar.isDate(date, inSameDayAs: keys.holyThursday) {
            return (.holyThursday, "Holy Thursday", .white, true,
                "Commemorates the Last Supper, when Jesus shared a final meal with his apostles, washed their feet as a sign of humble service, and gave them the bread and cup to remember him by. That night he was arrested in the Garden of Gethsemane.")
        }
        if calendar.isDate(date, inSameDayAs: keys.goodFriday) {
            return (.goodFriday, "Good Friday of the Lord's Passion", .red, true,
                "The most solemn day of the year, when Christians remember Jesus' crucifixion and death. Services are stark and stripped down: Scripture readings, prayers, and reflection on the cross, often in bare surroundings. It is a day of solemn reflection and mourning.")
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
        if calendar.isDate(date, inSameDayAs: keys.christTheKing) {
            return (.christTheKing, "Our Lord Jesus Christ, King of the Universe", .white, true,
                "The last Sunday of the liturgical year, proclaiming Jesus as king, but not a worldly king with armies and palaces. His kingdom is one of truth, justice, love, and peace. The next week, the cycle starts all over again with Advent.")
        }
        return nil
    }

    // MARK: - Civil Holidays (secular U.S. observances, a layer beside the church year)

    /// A secular U.S. holiday on `date`, if any: federal holidays plus common
    /// cultural days. Independent of the liturgical calendar; it never sets the
    /// day's color or rank, and can coexist with a feast.
    private func civilHoliday(for date: Date) -> (name: String, description: String)? {
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)

        // Fixed-date observances.
        switch (month, day) {
        case (1, 1):   return ("New Year's Day", "The first day of the civil year, and a federal holiday.")
        case (2, 14):  return ("Valentine's Day", "A day associated with love and affection, named for an early Christian martyr.")
        case (3, 17):  return ("St. Patrick's Day", "A cultural celebration of Irish heritage, on the traditional death date of the patron saint of Ireland.")
        case (4, 1):   return ("April Fools' Day", "A day of pranks and hoaxes observed across many countries.")
        case (4, 22):  return ("Earth Day", "An annual day of support for environmental protection, first held in 1970.")
        case (5, 5):   return ("Cinco de Mayo", "A celebration of Mexican heritage, marking an 1862 Mexican victory at the Battle of Puebla.")
        case (6, 19):  return ("Juneteenth", "A federal holiday marking the end of slavery in the United States in 1865.")
        case (7, 4):   return ("Independence Day", "A federal holiday marking the adoption of the Declaration of Independence in 1776.")
        case (10, 31): return ("Halloween", "The evening before All Hallows', now a cultural night of costumes and candy.")
        case (11, 11): return ("Veterans Day", "A federal holiday honoring those who have served in the U.S. armed forces.")
        case (12, 24): return ("Christmas Eve", "The evening before Christmas Day.")
        case (12, 31): return ("New Year's Eve", "The last day of the civil year.")
        default:       break
        }

        // Movable observances: the Nth (or last) given weekday of a month. Weekday
        // numbers follow Calendar: 1 = Sunday ... 7 = Saturday.
        let movable: [(name: String, description: String, target: Date)] = [
            ("Martin Luther King Jr. Day", "A federal holiday honoring the civil-rights leader, on the third Monday of January.",
             nthWeekday(year: year, month: 1, weekday: 2, ordinal: 3)),
            ("Presidents' Day", "A federal holiday (officially Washington's Birthday) on the third Monday of February.",
             nthWeekday(year: year, month: 2, weekday: 2, ordinal: 3)),
            ("Mother's Day", "A day honoring mothers, on the second Sunday of May.",
             nthWeekday(year: year, month: 5, weekday: 1, ordinal: 2)),
            ("Memorial Day", "A federal holiday honoring those who died in military service, on the last Monday of May.",
             lastWeekday(year: year, month: 5, weekday: 2)),
            ("Father's Day", "A day honoring fathers, on the third Sunday of June.",
             nthWeekday(year: year, month: 6, weekday: 1, ordinal: 3)),
            ("Labor Day", "A federal holiday honoring the American worker, on the first Monday of September.",
             nthWeekday(year: year, month: 9, weekday: 2, ordinal: 1)),
            ("Columbus Day", "A federal holiday on the second Monday of October, observed in some places as Indigenous Peoples' Day.",
             nthWeekday(year: year, month: 10, weekday: 2, ordinal: 2)),
            ("Thanksgiving", "A federal holiday of gratitude and gathering, on the fourth Thursday of November.",
             nthWeekday(year: year, month: 11, weekday: 5, ordinal: 4)),
        ]
        for holiday in movable where calendar.isDate(date, inSameDayAs: holiday.target) {
            return (holiday.name, holiday.description)
        }
        return nil
    }

    /// The `ordinal`-th `weekday` of the given month (weekday 1 = Sunday).
    private func nthWeekday(year: Int, month: Int, weekday: Int, ordinal: Int) -> Date {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.weekday = weekday
        comps.weekdayOrdinal = ordinal
        return calendar.date(from: comps)!
    }

    /// The last `weekday` of the given month (weekday 1 = Sunday).
    private func lastWeekday(year: Int, month: Int, weekday: Int) -> Date {
        let firstOfNextMonth = calendar.date(from: DateComponents(
            year: month == 12 ? year + 1 : year,
            month: month == 12 ? 1 : month + 1,
            day: 1
        ))!
        let lastOfMonth = calendar.date(byAdding: .day, value: -1, to: firstOfNextMonth)!
        let wd = calendar.component(.weekday, from: lastOfMonth)
        let diff = (wd - weekday + 7) % 7
        return calendar.date(byAdding: .day, value: -diff, to: lastOfMonth)!
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
    let adventStart: Date
    let christmas: Date
    let baptismOfLord: Date
    let christTheKing: Date
}
