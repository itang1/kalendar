// This file creates a wheel-shaped calendar view with 365 colored slices, each representing one day.

import SwiftUI

struct KalendarWheel: View {
    let days: [DayCard]
    let radius: CGFloat = 160
    let sliceLineWidth: CGFloat = 2

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            ZStack {
                ForEach(days) { day in
                    WheelSliceShape(
                        index: day.dayOfYear - 1,
                        total: days.count,
                        radius: radius
                    )
                    .fill(day.color)
                    .overlay(
                        WheelSliceShape(
                            index: day.dayOfYear - 1,
                            total: days.count,
                            radius: radius
                        )
                        .stroke(Color.white, lineWidth: sliceLineWidth)
                    )
                }
            }
            .frame(width: size, height: size)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct WheelSliceShape: Shape {
    let index: Int
    let total: Int
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let angle = (2 * .pi) / CGFloat(total)
        let startAngle = CGFloat(index) * angle - .pi / 2
        let endAngle = startAngle + angle

        var path = Path()
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: .radians(startAngle), endAngle: .radians(endAngle), clockwise: false)
        path.closeSubpath()
        return path
    }
}

#if DEBUG
#Preview {
    // Demo: 365 slices, default gray, Advent as green, Easter as pink pattern
    let adventRange = 335...365 // Approximate last 4 weeks as Advent
    let easterDay = 95 // Approximate Easter for demonstration
    let calendar = Calendar.current
    let startOfYear = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1))!
    let days = (0..<365).map { offset -> DayCard in
        let i = offset + 1
        let date = calendar.date(byAdding: .day, value: offset, to: startOfYear)!
        var color: Color = .gray
        if adventRange.contains(i) {
            color = .green
        }
        if i == easterDay {
            color = .pink
        }
        return DayCard(dayOfYear: i, date: date, color: color, memo: "", comments: [])
    }
    KalendarWheel(days: days)
}
#endif

