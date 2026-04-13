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
    var color: Color
    var memo: String
    var comments: [String]

    // Liturgical calendar data
    var liturgicalSeason: LiturgicalSeason
    var liturgicalColor: LiturgicalColor
    var feastName: String?
    var feastDescription: String?
    var isSolemnity: Bool
    var weekOfSeason: Int?
}
