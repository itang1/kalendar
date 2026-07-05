//
//  LiturgicalEngineTests.swift
//  KalendarTests
//
//  The liturgical engine is pure, deterministic logic, so it is worth pinning down.
//  These tests cover published Easter dates, the season boundaries (especially around
//  the Baptism of the Lord), the rose Sundays, transferred solemnities, and the
//  celebrations added to the engine. The final test replays a decade of golden output
//  to guard the Swift engine against drift; tools/liturgical-golden.mjs does the same
//  for the JS copy and checks the widget copy against the app copy.

import XCTest
@testable import kalendar

@MainActor
final class LiturgicalEngineTests: XCTestCase {

    private let engine = LiturgicalCalendar()
    private let calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = 1
        return c
    }()

    private func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        calendar.date(from: DateComponents(year: y, month: m, day: d))!
    }

    private func info(_ y: Int, _ m: Int, _ d: Int) -> LiturgicalDayInfo {
        engine.liturgicalInfo(for: date(y, m, d))
    }

    /// A fully populated `DayCard` for a date, mirroring `CalendarViewModel.buildWindow`,
    /// so the derived properties (lectionary cycle, obligation and discipline flags)
    /// can be checked directly.
    private func card(_ y: Int, _ m: Int, _ d: Int) -> DayCard {
        let day = date(y, m, d)
        let dayInfo = engine.liturgicalInfo(for: day)
        return DayCard(
            dayOfYear: day.dayOfYear,
            date: day,
            comments: [],
            liturgicalSeason: dayInfo.season,
            liturgicalColor: dayInfo.liturgicalColor,
            feastName: dayInfo.feastName,
            feastID: dayInfo.feastID,
            feastDescription: dayInfo.feastDescription,
            isSolemnity: dayInfo.isSolemnity,
            weekOfSeason: dayInfo.weekOfSeason,
            isMovableFeast: dayInfo.isMovableFeast,
            civilHolidayName: dayInfo.civilHolidayName,
            civilHolidayDescription: dayInfo.civilHolidayDescription
        )
    }

    // MARK: - Easter against published tables

    func testEasterDatesMatchPublishedTable() {
        let expected: [(year: Int, month: Int, day: Int)] = [
            (2025, 4, 20), (2026, 4, 5), (2027, 3, 28), (2028, 4, 16), (2029, 4, 1),
            (2030, 4, 21), (2031, 4, 13), (2032, 3, 28), (2033, 4, 17), (2034, 4, 9),
        ]
        for e in expected {
            XCTAssertTrue(
                calendar.isDate(engine.easterDate(year: e.year), inSameDayAs: date(e.year, e.month, e.day)),
                "Easter \(e.year) should be \(e.month)/\(e.day)"
            )
        }
    }

    // MARK: - Advent start and Christ the King

    func testChristTheKingIsTheSundayBeforeAdvent() {
        for year in 2025...2034 {
            let keys = engine.keyDates(year: year)
            XCTAssertEqual(calendar.component(.weekday, from: keys.adventStart), 1, "Advent starts on a Sunday")
            XCTAssertEqual(calendar.component(.weekday, from: keys.christTheKing), 1, "Christ the King is a Sunday")
            let expected = calendar.date(byAdding: .day, value: -7, to: keys.adventStart)!
            XCTAssertTrue(calendar.isDate(keys.christTheKing, inSameDayAs: expected))
        }
    }

    // MARK: - Gaudete and Laetare (rose) Sundays

    func testRoseSundays() {
        // Gaudete: Third Sunday of Advent. Laetare: Fourth Sunday of Lent.
        XCTAssertEqual(info(2025, 12, 14).liturgicalColor, .rose, "Gaudete 2025")
        XCTAssertEqual(info(2025, 3, 30).liturgicalColor, .rose, "Laetare 2025")
        XCTAssertEqual(info(2026, 12, 13).liturgicalColor, .rose, "Gaudete 2026")
        XCTAssertEqual(info(2026, 3, 15).liturgicalColor, .rose, "Laetare 2026")
    }

    // MARK: - Baptism of the Lord boundary

    func testBaptismOfTheLordAndChristmasSeasonEnd() {
        // Normal year: Jan 6 2025 is a Monday, so the Baptism is the following Sunday.
        XCTAssertTrue(calendar.isDate(engine.keyDates(year: 2025).baptismOfLord, inSameDayAs: date(2025, 1, 12)))
        // Jan 6 2029 is a Saturday, so the Baptism is Sunday Jan 7.
        XCTAssertTrue(calendar.isDate(engine.keyDates(year: 2029).baptismOfLord, inSameDayAs: date(2029, 1, 7)))
        // Jan 6 2030 is itself a Sunday (Epiphany), so the Baptism is the FOLLOWING
        // Sunday, Jan 13, not Monday Jan 7. This keeps Christmas its full length.
        XCTAssertTrue(calendar.isDate(engine.keyDates(year: 2030).baptismOfLord, inSameDayAs: date(2030, 1, 13)))
        XCTAssertEqual(info(2030, 1, 13).season, .christmas, "Baptism day is still Christmas season")
        XCTAssertEqual(info(2030, 1, 14).season, .ordinaryTime, "Ordinary Time begins the next day")
    }

    // MARK: - Transferred solemnities

    func testAnnunciationTransfersOutOfHolyWeek() {
        // Easter 2027 is March 28, so March 25 falls in Holy Week. The Annunciation
        // transfers to the Monday after the Second Sunday of Easter, April 5.
        XCTAssertNotEqual(info(2027, 3, 25).feastName, "Annunciation of the Lord",
                          "Annunciation is impeded on its usual date (Holy Thursday that year)")
        let transferred = info(2027, 4, 5)
        XCTAssertEqual(transferred.feastName, "Annunciation of the Lord")
        XCTAssertTrue(transferred.isSolemnity)
    }

    // MARK: - Reformed calendar scope

    func testReformationDay() {
        // Added as a Reformed marker on Oct 31 (the day Luther is said to have posted
        // the Ninety-Five Theses in 1517).
        let day = info(2025, 10, 31)
        XCTAssertEqual(day.feastName, "Reformation Day")
        XCTAssertEqual(day.liturgicalColor, .red)
        XCTAssertFalse(day.isSolemnity)
    }

    func testDelistedDevotionsAndSaintsAreGone() {
        // Feasts dropped in the move to a Reformed calendar no longer resolve; the
        // day falls through to its season (or to an underlying biblical feast).
        XCTAssertNil(info(2025, 2, 22).feastName, "Chair of St. Peter is delisted")
        XCTAssertNil(info(2025, 8, 10).feastName, "St. Lawrence is delisted")
        XCTAssertNil(info(2025, 11, 1).feastName, "All Saints is delisted")
        // Divine Mercy (2nd Sunday of Easter 2025 = Apr 27) and Corpus Christi are gone.
        XCTAssertNil(info(2025, 4, 27).feastName, "Divine Mercy Sunday is delisted")
        // With the Holy Family removed, the Sunday in the Octave of Christmas
        // (Dec 28 2025) falls through to the fixed feast of the Holy Innocents.
        XCTAssertEqual(info(2025, 12, 28).feastName, "Holy Innocents, Martyrs")
    }

    func testBiblicalFiguresAreKept() {
        // Days remembering people and events from Scripture stay, reframed but present.
        XCTAssertEqual(info(2025, 6, 29).feastName, "Peter and Paul, Apostles")
        XCTAssertEqual(info(2025, 10, 18).feastName, "Luke the Evangelist")
        XCTAssertEqual(info(2025, 8, 6).feastName, "Transfiguration of the Lord")
    }

    // MARK: - Civil (U.S.) holidays, a layer beside the church year

    func testCivilHolidays() {
        // Fixed-date and computed-weekday holidays both resolve.
        XCTAssertEqual(info(2025, 7, 4).civilHolidayName, "Independence Day")
        XCTAssertEqual(info(2025, 11, 27).civilHolidayName, "Thanksgiving")   // 4th Thursday of Nov
        XCTAssertEqual(info(2025, 5, 26).civilHolidayName, "Memorial Day")    // last Monday of May
        XCTAssertEqual(info(2025, 1, 20).civilHolidayName, "Martin Luther King Jr. Day")
        XCTAssertNil(info(2025, 7, 5).civilHolidayName, "an ordinary day has no civil holiday")
    }

    func testCivilHolidayIsSeparateFromTheChurchYear() {
        // A civil holiday never sets the liturgical color or counts as a feast, and a
        // day can carry both independently (Reformation Day and Halloween on Oct 31;
        // Father's Day on Trinity Sunday).
        let oct31 = info(2025, 10, 31)
        XCTAssertEqual(oct31.feastName, "Reformation Day")
        XCTAssertEqual(oct31.civilHolidayName, "Halloween")
        XCTAssertEqual(info(2025, 7, 4).liturgicalColor, .green, "Independence Day stays Ordinary Time green")
        XCTAssertEqual(info(2025, 6, 15).feastName, "Most Holy Trinity")
        XCTAssertEqual(info(2025, 6, 15).civilHolidayName, "Father's Day")
    }

    // MARK: - Lectionary cycles and obligation flags (derived DayCard facts)

    func testLectionaryCyclesTurnOverAtAdvent() {
        // Ordinary Time 2025 (liturgical year that began Advent 2024) is Sunday Year C,
        // weekday Year I. These derive from the Gregorian year, independent of the
        // device's regional calendar.
        let june2025 = card(2025, 6, 15)
        XCTAssertEqual(june2025.sundayLectionaryCycle, "C")
        XCTAssertEqual(june2025.weekdayLectionaryCycle, "I")
        // Once Advent 2025 begins, the cycle rolls to Sunday Year A, weekday Year II.
        let dec2025 = card(2025, 12, 7) // First Sunday of Advent 2025
        XCTAssertEqual(dec2025.sundayLectionaryCycle, "A")
        XCTAssertEqual(dec2025.weekdayLectionaryCycle, "II")
    }

    // MARK: - Drift guard against the golden decade

    func testSwiftEngineMatchesGoldenDecade() {
        let lines = LiturgicalGolden.lines.split(separator: "\n", omittingEmptySubsequences: true)
        XCTAssertGreaterThan(lines.count, 3000, "golden should cover a full decade")
        for raw in lines {
            let line = String(raw)
            let dateStr = String(line.prefix(10)) // YYYY-MM-DD
            let comps = dateStr.split(separator: "-")
            guard comps.count == 3,
                  let y = Int(comps[0]), let m = Int(comps[1]), let d = Int(comps[2]) else {
                XCTFail("malformed golden line: \(line)")
                continue
            }
            XCTAssertEqual(goldenLine(for: date(y, m, d)), line)
        }
    }

    /// Formats one day exactly as tools/liturgical-golden.mjs does, so the two engines
    /// can be compared line for line.
    private func goldenLine(for date: Date) -> String {
        let dayInfo = engine.liturgicalInfo(for: date)
        let y = calendar.component(.year, from: date)
        let m = calendar.component(.month, from: date)
        let d = calendar.component(.day, from: date)
        let ymd = String(format: "%04d-%02d-%02d", y, m, d)
        let week = dayInfo.weekOfSeason.map(String.init) ?? ""
        let feast = dayInfo.feastName ?? ""
        let title = card(y, m, d).liturgicalDayTitle ?? ""
        let civil = dayInfo.civilHolidayName ?? ""
        return "\(ymd)|\(dayInfo.season.rawValue)|\(dayInfo.liturgicalColor.rawValue)|\(dayInfo.isSolemnity ? 1 : 0)|\(week)|\(feast)|\(title)|\(civil)"
    }
}
