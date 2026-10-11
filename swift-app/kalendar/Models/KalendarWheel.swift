// This file creates a wheel-shaped calendar view with 365 colored slices, each representing one day.

import SwiftUI

struct KalendarWheel: View {
    let days: [DayCard]
    var radius: CGFloat = 160
    let sliceLineWidth: CGFloat = 2
    var onDayTap: ((Int) -> Void)? = nil

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: size / 2, y: size / 2)

            ZStack {
                // Slices are positioned by their index in `days` (day 0 = today at the
                // top), so the wheel matches the grid and the tap hit-test, which also
                // maps an angle back to an array index, lands on the day that was tapped.
                ForEach(Array(days.enumerated()), id: \.element.id) { index, day in
                    WheelSliceShape(
                        index: index,
                        total: days.count,
                        radius: radius
                    )
                    .fill(day.liturgicalColor.color)
                    .overlay(
                        WheelSliceShape(
                            index: index,
                            total: days.count,
                            radius: radius
                        )
                        .stroke(Color.secondary.opacity(0.35), lineWidth: sliceLineWidth)
                    )
                }

                // Marker on the first slice (today, at the top) so it is easy to find.
                if !days.isEmpty {
                    Circle()
                        .fill(Color.primary)
                        .overlay(Circle().stroke(.white, lineWidth: 1.5))
                        .frame(width: 12, height: 12)
                        .position(todayMarkerPosition(center: center))
                }
            }
            .frame(width: size, height: size)
            .gesture(
                SpatialTapGesture()
                    .onEnded { value in
                        guard let index = sliceIndex(
                            at: value.location,
                            center: center,
                            radius: radius,
                            total: days.count
                        ) else { return }
                        onDayTap?(index)
                    }
            )
        }
        .aspectRatio(1, contentMode: .fit)
        // VoiceOver treats the wheel as one element; individual days are reachable
        // through the grid view and the Open Today button.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Year wheel showing \(days.count) days colored by liturgical season, beginning with today at the top. Switch to grid view to open a specific day.")
    }

    /// Center point of the marker sitting near the rim of the first slice.
    private func todayMarkerPosition(center: CGPoint) -> CGPoint {
        let sliceAngle = 2 * .pi / CGFloat(max(days.count, 1))
        let angle = -CGFloat.pi / 2 + sliceAngle / 2  // middle of the top slice
        let r = radius * 0.82
        return CGPoint(x: center.x + r * cos(angle), y: center.y + r * sin(angle))
    }

    // MARK: - Hit testing

    /// Returns the 0-based index into `days` for a tap at `point`, or nil if outside the wheel.
    private func sliceIndex(at point: CGPoint, center: CGPoint, radius: CGFloat, total: Int) -> Int? {
        let dx = point.x - center.x
        let dy = point.y - center.y
        let distance = sqrt(dx * dx + dy * dy)
        guard distance <= radius && distance > 0 else { return nil }

        // atan2 gives angle from positive x-axis, CCW in standard math coords.
        // SwiftUI's Y axis points down, so atan2(dy, dx) gives CW from positive x-axis.
        // The first slice starts at -π/2 (top of circle).
        var angle = atan2(dy, dx) + .pi / 2  // rotate so 0 = top
        if angle < 0 { angle += 2 * .pi }

        let sliceAngle = 2 * .pi / CGFloat(total)
        let index = Int(angle / sliceAngle) % total
        return index
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
            comments: [],
            liturgicalSeason: info.season,
            liturgicalColor: info.liturgicalColor,
            feastName: info.feastName,
            feastDescription: info.feastDescription,
            isSolemnity: info.isSolemnity,
            weekOfSeason: info.weekOfSeason,
            isMovableFeast: info.isMovableFeast
        )
    }
    KalendarWheel(days: days) { index in
        print("Tapped day index \(index)")
    }
}
#endif
