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
            .fill(day.liturgicalColor.color)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.secondary.opacity(strokeOpacity), lineWidth: strokeWidth)
            )
            .overlay(
                Group {
                    if day.isSolemnity {
                        Image(systemName: "star.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 9, height: 9)
                            .foregroundStyle(dotColor)
                    } else if day.feastName != nil {
                        Circle()
                            .fill(dotColor)
                            .frame(width: 7, height: 7)
                    }
                }
            )
            .overlay(alignment: .bottomTrailing) {
                // Square corner mark for days with notes, distinct from the
                // round centered feast dot.
                if !day.comments.isEmpty {
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(dotColor)
                        .frame(width: 5, height: 5)
                        .padding(3)
                }
            }
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
        case .white, .rose:
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
            label += day.isSolemnity ? ", \(feast) (solemnity)" : ", \(feast)"
        }
        if !day.comments.isEmpty {
            label += ", has notes"
        }
        return label
    }
}

