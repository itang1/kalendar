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
    case gold = "Gold"
    case black = "Black"

    var color: Color {
        switch self {
        case .green: return Color(red: 0.2, green: 0.55, blue: 0.3)
        case .violet: return Color(red: 0.45, green: 0.2, blue: 0.55)
        case .white: return Color(red: 0.92, green: 0.9, blue: 0.85)
        case .red: return Color(red: 0.75, green: 0.15, blue: 0.15)
        case .rose: return Color(red: 0.85, green: 0.5, blue: 0.6)
        case .gold: return Color(red: 0.85, green: 0.75, blue: 0.25)
        case .black: return Color(red: 0.2, green: 0.2, blue: 0.2)
        }
    }
}

// MARK: - Liturgical Day Info

struct LiturgicalDayInfo {
    let season: LiturgicalSeason
    let liturgicalColor: LiturgicalColor
    let feastName: String?
    let feastDescription: String?
    let isSolemnity: Bool
    let isSunday: Bool
    let weekOfSeason: Int?
}

// MARK: - Liturgical Calendar Engine

struct LiturgicalCalendar {

    private let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 1 // Sunday
        return cal
    }()

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

        // Advent: starts on the Sunday closest to Nov 30 (4 Sundays before Christmas)
        let christmas = calendar.date(from: DateComponents(year: year, month: 12, day: 25))!
        let christmasWeekday = calendar.component(.weekday, from: christmas)
        // 4th Sunday before Christmas
        let daysToSunday = (christmasWeekday == 1) ? 28 : (christmasWeekday - 1 + 21)
        let adventStart = calendar.date(byAdding: .day, value: -daysToSunday, to: christmas)!

        let epiphany = calendar.date(from: DateComponents(year: year, month: 1, day: 6))!
        // Baptism of the Lord: Sunday after Epiphany (or Monday if Epiphany is Sunday)
        let epiphanyWeekday = calendar.component(.weekday, from: epiphany)
        let baptismOfLord: Date
        if epiphanyWeekday == 1 {
            baptismOfLord = calendar.date(byAdding: .day, value: 1, to: epiphany)!
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
            adventStart: adventStart,
            christmas: christmas,
            epiphany: epiphany,
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

        // Check fixed feasts first
        if let feast = fixedFeast(for: date) {
            return LiturgicalDayInfo(
                season: seasonForDate(date, keys: keys, prevYearKeys: prevYearKeys),
                liturgicalColor: feast.color,
                feastName: feast.name,
                feastDescription: feast.description,
                isSolemnity: feast.isSolemnity,
                isSunday: isSunday,
                weekOfSeason: nil
            )
        }

        // Check movable feasts
        if let feast = movableFeast(for: date, keys: keys) {
            let season = seasonForDate(date, keys: keys, prevYearKeys: prevYearKeys)
            return LiturgicalDayInfo(
                season: season,
                liturgicalColor: feast.color,
                feastName: feast.name,
                feastDescription: feast.description,
                isSolemnity: feast.isSolemnity,
                isSunday: isSunday,
                weekOfSeason: nil
            )
        }

        let season = seasonForDate(date, keys: keys, prevYearKeys: prevYearKeys)
        let color = defaultColorForSeason(season, isSunday: isSunday, date: date, keys: keys)

        return LiturgicalDayInfo(
            season: season,
            liturgicalColor: color,
            feastName: nil,
            feastDescription: nil,
            isSolemnity: false,
            isSunday: isSunday,
            weekOfSeason: weekOfSeason(date: date, season: season, keys: keys, prevYearKeys: prevYearKeys)
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
                let days = calendar.dateComponents([.day], from: keys.pentecost, to: date).day ?? 0
                return (days / 7) + 1
            }
        default:
            return nil
        }
    }

    // MARK: - Fixed Feasts (by month/day)

    private func fixedFeast(for date: Date) -> (name: String, color: LiturgicalColor, isSolemnity: Bool, description: String)? {
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)

        switch (month, day) {
        case (1, 1): return ("Solemnity of Mary, Mother of God", .white, true,
            "The oldest feast honoring Mary. On the first day of the year, Christians celebrate Mary's role as the mother of Jesus (who Christians believe is God). It is also the World Day of Peace.")
        case (1, 6): return ("Epiphany of the Lord", .white, true,
            "Celebrates the visit of the Magi (Wise Men) to the infant Jesus. 'Epiphany' means 'revelation,' and this feast marks Jesus being revealed to the whole world, not just the Jewish people.")
        case (2, 2): return ("Presentation of the Lord", .white, false,
            "Forty days after Christmas, Mary and Joseph brought baby Jesus to the Temple in Jerusalem, as Jewish law required for firstborn sons. The elderly prophet Simeon recognized him as the Messiah and called him 'a light for revelation to the Gentiles.' Also called Candlemas.")
        case (3, 19): return ("St. Joseph, Spouse of the Blessed Virgin Mary", .white, true,
            "Honors Joseph, the foster-father of Jesus and husband of Mary. He was a humble carpenter from Nazareth who protected and raised Jesus. He is the patron saint of workers, fathers, and all Christians.")
        case (3, 25): return ("Annunciation of the Lord", .white, true,
            "Celebrates the moment the angel Gabriel appeared to Mary and announced she would conceive Jesus by the Holy Spirit. Mary said 'yes,' and Christians believe that is when God became human. Exactly 9 months before Christmas.")
        case (6, 24): return ("Nativity of St. John the Baptist", .white, true,
            "The birth of John the Baptist, Jesus' cousin, who grew up to be the prophet who prepared the way for Jesus' ministry. He baptized people in the Jordan River and is the one who baptized Jesus himself.")
        case (6, 29): return ("Sts. Peter and Paul, Apostles", .red, true,
            "Honors the two greatest apostles: Peter, the fisherman Jesus chose to lead his followers (the first pope), and Paul, who started out persecuting Christians but converted and became the greatest missionary of the early Christian world. Both were martyred in Rome.")
        case (8, 6): return ("Transfiguration of the Lord", .white, false,
            "Recalls when Jesus took three disciples up a mountain, and his appearance was transformed. His face shone like the sun and his clothes became dazzling white. Moses and Elijah appeared beside him, and God's voice said 'This is my beloved Son.'")
        case (8, 15): return ("Assumption of the Blessed Virgin Mary", .white, true,
            "Celebrates the belief that at the end of Mary's earthly life, she was taken up ('assumed') body and soul into heaven. It is one of the most important Marian feasts, and a Holy Day of Obligation in many countries.")
        case (9, 14): return ("Exaltation of the Holy Cross", .red, false,
            "Honors the cross on which Jesus was crucified. Rather than a symbol of defeat, Christians see it as the instrument of salvation. This feast dates back to the 4th century when St. Helena (Emperor Constantine's mother) is believed to have found the actual cross in Jerusalem.")
        case (11, 1): return ("All Saints", .white, true,
            "A day to honor all saints, not just the famous ones with their own feast days, but every holy person in heaven, including ordinary people who lived faithful lives. It is a reminder that everyone is called to holiness.")
        case (11, 2): return ("All Souls' Day (Commemoration of All the Faithful Departed)", .violet, false,
            "A day to remember and pray for all who have died, especially loved ones. Christians pray that those still being purified may reach heaven. It is a tender day of remembrance, often marked by visiting cemeteries.")
        case (12, 8): return ("Immaculate Conception of the Blessed Virgin Mary", .white, true,
            "Celebrates the belief that Mary was conceived without original sin, meaning from the very first moment of her existence, she was full of grace. This is often confused with Jesus' conception, but it is about Mary's own conception by her parents, Anne and Joachim. It is the patron feast of the United States.")
        case (12, 25): return ("Nativity of the Lord (Christmas)", .white, true,
            "The joyful celebration of Jesus' birth in Bethlehem. Christians believe God became a human baby, born to Mary in humble circumstances. It is one of the two greatest feasts of the liturgical year (along with Easter).")
        case (12, 26): return ("St. Stephen, First Martyr", .red, false,
            "Honors Stephen, one of the first deacons of the early Christian community, who became the very first Christian martyr. He was stoned to death for his faith, and as he died he prayed for his persecutors, just as Jesus had done on the cross.")
        case (12, 27): return ("St. John, Apostle and Evangelist", .white, false,
            "Honors John, one of Jesus' closest disciples (the 'beloved disciple'), who is traditionally credited with writing the Gospel of John, three letters, and the Book of Revelation. He is the only apostle believed to have died of natural causes.")
        case (12, 28): return ("Holy Innocents, Martyrs", .red, false,
            "Remembers the infant boys of Bethlehem who were killed by King Herod in his attempt to destroy the newborn Jesus. They are considered the first martyrs for Christ, even though they were too young to know it.")
        default: return nil
        }
    }

    // MARK: - Movable Feasts (relative to Easter)

    private func movableFeast(for date: Date, keys: KeyLiturgicalDates) -> (name: String, color: LiturgicalColor, isSolemnity: Bool, description: String)? {
        if calendar.isDate(date, inSameDayAs: keys.ashWednesday) {
            return ("Ash Wednesday", .violet, false,
                "The start of Lent. Christians receive ashes on their foreheads in the shape of a cross as a sign of repentance and mortality. The priest says 'Remember that you are dust, and to dust you shall return.' It is a day of fasting and reflection.")
        }
        if calendar.isDate(date, inSameDayAs: keys.palmSunday) {
            return ("Palm Sunday of the Lord's Passion", .red, false,
                "The last Sunday before Easter, marking Jesus' triumphant entry into Jerusalem when crowds waved palm branches and shouted 'Hosanna.' But the mood shifts as the long account of Jesus' suffering and death (the Passion) is also read. It begins Holy Week.")
        }
        if calendar.isDate(date, inSameDayAs: keys.holyThursday) {
            return ("Holy Thursday", .white, true,
                "Commemorates the Last Supper, when Jesus shared a final meal with his apostles, washed their feet as a sign of humble service, and instituted the Eucharist (communion). That night he was arrested in the Garden of Gethsemane.")
        }
        if calendar.isDate(date, inSameDayAs: keys.goodFriday) {
            return ("Good Friday of the Lord's Passion", .red, true,
                "The most solemn day of the year. Christians remember Jesus' crucifixion and death. There is no Mass. Instead, a stark service of readings, prayers, and veneration of the cross takes place in bare, stripped buildings. It is a day of fasting and mourning.")
        }
        if calendar.isDate(date, inSameDayAs: keys.holySaturday) {
            return ("Holy Saturday / Easter Vigil", .white, true,
                "A day of quiet waiting at the tomb. The Easter Vigil on Saturday night is the most elaborate liturgy of the entire year: it begins in darkness with a blazing fire, traces salvation history through readings, and erupts in joy as Easter is proclaimed. New members are baptized into the faith.")
        }
        if calendar.isDate(date, inSameDayAs: keys.easter) {
            return ("Easter Sunday of the Resurrection", .white, true,
                "The most important day in Christianity. Christians celebrate their core belief: that Jesus rose from the dead on the third day after his crucifixion, conquering death itself. 'He is risen.' The joy of this day extends for 50 days.")
        }
        let easterMonday = calendar.date(byAdding: .day, value: 1, to: keys.easter)!
        if calendar.isDate(date, inSameDayAs: easterMonday) {
            return ("Easter Monday", .white, false,
                "The celebration of Easter continues. In many countries this is a public holiday. The Gospel tells of two disciples meeting the risen Jesus on the road to Emmaus without recognizing him at first.")
        }
        if calendar.isDate(date, inSameDayAs: keys.ascension) {
            return ("Ascension of the Lord", .white, true,
                "Forty days after Easter, Jesus ascended into heaven in the presence of his disciples, promising to send the Holy Spirit. His last words were a command: 'Go and make disciples of all nations.' This feast marks the completion of Jesus' earthly mission.")
        }
        if calendar.isDate(date, inSameDayAs: keys.pentecost) {
            return ("Pentecost Sunday", .red, true,
                "Fifty days after Easter, the Holy Spirit descended on the apostles like tongues of fire, giving them the courage and ability to preach in many languages. It is considered the 'birthday of the Christian faith,' the moment the apostles went from hiding in fear to boldly proclaiming the Gospel. Red vestments represent the fire of the Spirit.")
        }
        if calendar.isDate(date, inSameDayAs: keys.trinitySunday) {
            return ("Most Holy Trinity", .white, true,
                "The Sunday after Pentecost, celebrating the central mystery of Christian faith: that God is one God in three persons, Father, Son, and Holy Spirit. It is not three gods, but one God experienced in three ways. Even theologians say it is a mystery beyond full human understanding.")
        }
        if calendar.isDate(date, inSameDayAs: keys.corpusChristi) {
            return ("Most Holy Body and Blood of Christ (Corpus Christi)", .white, true,
                "A feast celebrating the Eucharist, the belief that bread and wine truly become the Body and Blood of Jesus during Mass. Many parishes hold outdoor processions carrying the Eucharist through the streets. 'Corpus Christi' is Latin for 'Body of Christ.'")
        }
        if calendar.isDate(date, inSameDayAs: keys.christTheKing) {
            return ("Our Lord Jesus Christ, King of the Universe", .white, true,
                "The last Sunday of the liturgical year, proclaiming Jesus as king, but not a worldly king with armies and palaces. His kingdom is one of truth, justice, love, and peace. The next week, the cycle starts all over again with Advent.")
        }
        return nil
    }
}

// MARK: - Key Liturgical Dates

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
    let adventStart: Date
    let christmas: Date
    let epiphany: Date
    let baptismOfLord: Date
    let christTheKing: Date
}
