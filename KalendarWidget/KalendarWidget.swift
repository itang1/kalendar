//
//  KalendarWidget.swift
//  KalendarWidget
//
//  Shows today's liturgical season, color, and feast on the Home Screen.

import WidgetKit
import SwiftUI

struct KalendarEntry: TimelineEntry {
    let date: Date
    let season: LiturgicalSeason
    let color: LiturgicalColor
    let feastName: String?
    let isSolemnity: Bool
}

struct KalendarTimelineProvider: TimelineProvider {
    private let calendar = LiturgicalCalendar()

    func placeholder(in context: Context) -> KalendarEntry {
        entry(for: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (KalendarEntry) -> Void) {
        completion(entry(for: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<KalendarEntry>) -> Void) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        // Provide a week of daily entries, each dated to its own midnight, so the
        // widget self-advances to the correct day even when the system defers the
        // refresh under budget pressure (a single entry would otherwise show
        // yesterday's season and feast well past midnight). Refresh once the week runs out.
        let entries = (0..<7).map { offset in
            entry(for: calendar.date(byAdding: .day, value: offset, to: today)!)
        }
        let refreshDate = calendar.date(byAdding: .day, value: 7, to: today)!
        completion(Timeline(entries: entries, policy: .after(refreshDate)))
    }

    private func entry(for date: Date) -> KalendarEntry {
        let info = calendar.liturgicalInfo(for: date)
        return KalendarEntry(
            date: date,
            season: info.season,
            color: info.liturgicalColor,
            feastName: info.feastName,
            isSolemnity: info.isSolemnity
        )
    }
}

struct KalendarWidgetView: View {
    let entry: KalendarEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Spacer()
            if entry.isSolemnity {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundStyle(textColor.opacity(0.8))
            }
            Text(entry.feastName ?? entry.season.rawValue)
                .font(.headline)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .foregroundStyle(textColor)
            if entry.feastName != nil {
                Text(entry.season.rawValue)
                    .font(.caption)
                    .foregroundStyle(textColor.opacity(0.8))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .containerBackground(for: .widget) {
            entry.color.color
        }
    }

    private var textColor: Color {
        switch entry.color {
        case .white, .rose: return .black
        default: return .white
        }
    }
}

struct KalendarWidget: Widget {
    let kind = "KalendarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: KalendarTimelineProvider()) { entry in
            KalendarWidgetView(entry: entry)
        }
        .configurationDisplayName("Today in the Church Year")
        .description("Shows today's liturgical season, color, and feast.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
