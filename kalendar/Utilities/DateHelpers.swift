//
//  DateHelpers.swift
//  kalendar
//
//  Created by Irene Tang on 12/20/25.
//

import Foundation
import SwiftUI

extension Calendar {
    /// A fixed Gregorian calendar used for every liturgical component extraction
    /// (year, month, day, day-of-year, weekday). The device's `Calendar.current`
    /// can be Buddhist, Japanese, Hijri, etc., where those components carry a
    /// different year number or month/day mapping, which would corrupt derived
    /// facts like the lectionary cycle or obligation flags. `Calendar.current`
    /// stays for user-facing date formatting only.
    static let liturgical: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = 1 // Sunday
        return c
    }()
}

extension Date {
    var dayOfYear: Int {
        Calendar.liturgical.ordinality(of: .day, in: .year, for: self) ?? 1
    }
}

// MARK: - Adaptive Colors

extension Color {
    /// The main grid background. Cool slate in light mode, deep slate in dark mode.
    static var kalendarBackground: Color {
        Color(UIColor { tc in
            tc.userInterfaceStyle == .dark
                ? UIColor(red: 0.12, green: 0.13, blue: 0.16, alpha: 1)
                : UIColor(red: 0.78, green: 0.80, blue: 0.84, alpha: 1)
        })
    }
}
