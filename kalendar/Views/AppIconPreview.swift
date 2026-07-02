//
//  AppIconPreview.swift
//  kalendar
//
//  Render this view, screenshot it at 1024×1024, and drag the PNG into
//  Assets.xcassets → AppIcon. Not used anywhere in the app itself.
//

import SwiftUI

#if DEBUG
struct AppIconView: View {
    private let seasons: [(color: Color, fraction: Double)] = [
        (Color(red: 0.45, green: 0.20, blue: 0.55), 4.0 / 52),   // Advent (violet)
        (Color(red: 1.0,  green: 1.0,  blue: 1.0),  6.0 / 52),   // Christmas (white)
        (Color(red: 0.20, green: 0.55, blue: 0.30), 13.0 / 52),   // Ordinary Time I (green)
        (Color(red: 0.45, green: 0.20, blue: 0.55),  6.0 / 52),   // Lent (violet)
        (Color(red: 0.75, green: 0.15, blue: 0.15),  0.5 / 52),   // Triduum (red)
        (Color(red: 1.0,  green: 1.0,  blue: 1.0),  7.0 / 52),   // Easter (white)
        (Color(red: 0.20, green: 0.55, blue: 0.30), 15.5 / 52),   // Ordinary Time II (green)
    ]

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: size / 2, y: size / 2)
            let outerRadius = size * 0.42
            let innerRadius = size * 0.22
            let cornerRadius = size * 0.22   // iOS icon rounding

            ZStack {
                // Background
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(red: 0.10, green: 0.10, blue: 0.13))

                // Season arcs
                Canvas { ctx, _ in
                    var startAngle = -CGFloat.pi / 2
                    for season in seasons {
                        let sweep = CGFloat(season.fraction) * 2 * .pi
                        let endAngle = startAngle + sweep

                        var path = Path()
                        path.move(to: center)
                        path.addArc(center: center,
                                    radius: outerRadius,
                                    startAngle: .radians(startAngle),
                                    endAngle: .radians(endAngle),
                                    clockwise: false)
                        path.closeSubpath()

                        ctx.fill(path, with: .color(season.color))
                        startAngle = endAngle
                    }

                    // White separator lines between slices
                    startAngle = -CGFloat.pi / 2
                    for season in seasons {
                        let sweep = CGFloat(season.fraction) * 2 * .pi
                        var line = Path()
                        line.move(to: center)
                        let edgePoint = CGPoint(
                            x: center.x + outerRadius * cos(startAngle),
                            y: center.y + outerRadius * sin(startAngle)
                        )
                        line.addLine(to: edgePoint)
                        ctx.stroke(line, with: .color(.white.opacity(0.25)), lineWidth: size * 0.006)
                        startAngle += sweep
                    }

                    // Dark center circle (donut hole)
                    var hole = Path()
                    hole.addArc(center: center,
                                radius: innerRadius,
                                startAngle: .radians(0),
                                endAngle: .radians(2 * .pi),
                                clockwise: false)
                    ctx.fill(hole, with: .color(Color(red: 0.10, green: 0.10, blue: 0.13)))

                    // Thin ring border on the outer edge
                    var ring = Path()
                    ring.addArc(center: center,
                                radius: outerRadius,
                                startAngle: .radians(0),
                                endAngle: .radians(2 * .pi),
                                clockwise: false)
                    ctx.stroke(ring, with: .color(.white.opacity(0.12)), lineWidth: size * 0.008)
                }

                // Wordmark
                VStack(spacing: size * 0.012) {
                    Text("K")
                        .font(.system(size: size * 0.16, weight: .thin, design: .serif))
                        .foregroundStyle(.white)
                }
            }
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview("Icon 1024pt") {
    AppIconView()
        .frame(width: 400, height: 400)
        .padding()
}
#endif
