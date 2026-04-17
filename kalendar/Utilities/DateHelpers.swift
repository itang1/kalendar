//
//  DateHelpers.swift
//  kalendar
//
//  Created by Irene Tang on 12/20/25.
//

import Foundation
import SwiftUI

extension Date {
    var dayOfYear: Int {
        Calendar.current.ordinality(of: .day, in: .year, for: self) ?? 1
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
