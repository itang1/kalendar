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

    private var isToday: Bool {
        Calendar.current.isDateInToday(day.date)
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(day.color)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 0.5)
            )
            .overlay(
                Group {
                    if day.feastName != nil {
                        Circle()
                            .fill(dotColor)
                            .frame(width: 7, height: 7)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isToday ? Color.primary : Color.clear, lineWidth: 2)
            )
    }

    private var dotColor: Color {
        switch day.liturgicalColor {
        case .white, .rose, .gold:
            return .black.opacity(0.5)
        default:
            return .white.opacity(0.7)
        }
    }
}

