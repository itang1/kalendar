//
//  DayCardView.swift
//  kalendar
//
//  Created by Irene Tang on 12/20/25.
//
//  A single card

import SwiftUI

struct DayCardView: View {
    let day: DayCard

    private var dayOfMonth: Int {
        Calendar.current.component(.day, from: day.date)
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(day.dayOfYear == 1 ? Color.red : day.color)
            .overlay(
                Text("\(dayOfMonth)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            )
    }
}

