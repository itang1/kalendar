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
                    .stroke(Color.secondary.opacity(strokeOpacity), lineWidth: strokeWidth)
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
            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityHint("Tap to view details about this day")
    }

    private var strokeOpacity: Double {
        0.3
    }

    private var strokeWidth: CGFloat {
        3.0
    }

    private var dotColor: Color {
        switch day.liturgicalColor {
        case .white, .rose, .gold:
            return .black.opacity(0.5)
        default:
            return .white.opacity(0.7)
        }
    }

    private var accessibilityLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        let dateStr = formatter.string(from: day.date)

        var label = "\(dateStr), \(day.liturgicalSeason.rawValue)"
        if let feast = day.feastName {
            label += ", \(feast)"
        }
        return label
    }
}

