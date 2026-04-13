//
//  DateHelpers.swift
//  kalendar
//
//  Created by Irene Tang on 12/20/25.
//

import Foundation

extension Date {
    var dayOfYear: Int {
        Calendar.current.ordinality(of: .day, in: .year, for: self) ?? 1
    }
}
