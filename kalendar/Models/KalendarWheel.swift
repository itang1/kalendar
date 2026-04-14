// This file creates a wheel-shaped calendar view with 365 colored slices, each representing one day.

import SwiftUI

struct KalendarWheel: View {
    let days: [DayCard]
    var radius: CGFloat = 160
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
    let cal = Calendar.current
    let litCal = LiturgicalCalendar()
    let startOfYear = cal.date(from: DateComponents(year: 2026, month: 1, day: 1))!
    let daysInYear = cal.range(of: .day, in: .year, for: startOfYear)!.count
    let days = (0..<daysInYear).map { offset -> DayCard in
        let date = cal.date(byAdding: .day, value: offset, to: startOfYear)!
        let info = litCal.liturgicalInfo(for: date)
        return DayCard(
            dayOfYear: offset + 1,
            date: date,
            color: info.liturgicalColor.color,
            memo: "",
            comments: [],
            liturgicalSeason: info.season,
            liturgicalColor: info.liturgicalColor,
            feastName: info.feastName,
            feastDescription: info.feastDescription,
            isSolemnity: info.isSolemnity,
            weekOfSeason: info.weekOfSeason
        )
    }
    KalendarWheel(days: days)
}
#endif

