//
//  DayDetailView.swift
//  kalendar
//
//  Created by Irene Tang on 12/20/25.
//
//  Content view for a single day. Presented inside DayBrowserSheet
//  (see CircleCalendarView) which provides the NavigationStack and toolbar.

import SwiftUI
import StoreKit

struct DayDetailView: View {
    @Binding var day: DayCard
    @State private var newComment = ""
    @Environment(\.requestReview) private var requestReview

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM d, yyyy"
        return f
    }()

    private static let weekdayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        return f
    }()

    private var formattedDate: String {
        "\(Self.dateFormatter.string(from: day.date)) (\(Self.weekdayFormatter.string(from: day.date)))"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // MARK: Header — leads with the feast, or the day's proper
                // title, since that is what makes the day unique.
                headerSection
                    .padding(.bottom, 20)

                // MARK: Rank explanation (collapsed; identical across every
                // solemnity, or every feast/memorial)
                if day.feastName != nil {
                    DisclosureGroup(day.isSolemnity ? "About solemnities" : "About feasts & memorials") {
                        Text(rankExplanation)
                            .font(.body)
                            .padding(.top, 8)
                    }
                    .font(.body.weight(.semibold))
                    .padding(.bottom, 28)
                }

                // MARK: US Holiday — a secular layer beside the church year
                if let holiday = day.civilHolidayName {
                    sectionLabel("US Holiday")
                    HStack(spacing: 8) {
                        Image(systemName: "flag.fill")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                        Text(holiday)
                            .font(.body.weight(.bold))
                    }
                    .padding(.top, 6)
                    if let description = day.civilHolidayDescription {
                        Text(description)
                            .font(.body)
                            .padding(.top, 8)
                    }
                    Divider()
                        .padding(.vertical, 28)
                }

                // MARK: Season
                sectionLabel("Season")

                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(day.liturgicalSeason.color)
                        .overlay(RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 3))
                        .frame(width: 22, height: 22)
                    Text(day.liturgicalSeason.rawValue)
                        .font(.body.weight(.bold))
                    if let week = day.weekOfSeason {
                        Text("· Week \(week)")
                            .font(.body)
                    }
                }
                .padding(.top, 6)

                Text(day.liturgicalSeason.explanation)
                    .font(.body)
                    .padding(.top, 8)

                DisclosureGroup("Traditionally during \(day.liturgicalSeason.rawValue)") {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(day.liturgicalSeason.contextualItems, id: \.self) { item in
                            HStack(alignment: .top, spacing: 8) {
                                Text("·")
                                    .font(.body.weight(.bold))
                                Text(item)
                                    .font(.body)
                            }
                        }
                    }
                    .padding(.top, 10)
                }
                .font(.body.weight(.semibold))
                .padding(.top, 14)
                .padding(.bottom, 28)

                // MARK: Today's Color
                sectionLabel("Today's color")

                HStack(spacing: 10) {
                    Circle()
                        .fill(day.liturgicalColor.color)
                        .overlay(Circle().stroke(Color.secondary.opacity(0.3), lineWidth: 3))
                        .frame(width: 18, height: 18)
                    Text(day.liturgicalColor.rawValue)
                        .font(.body.weight(.bold))
                }
                .padding(.top, 6)

                // Point out when today breaks from the season's usual color, e.g.
                // an apostle's red day inside green Ordinary Time.
                if let note = todaysColorNote {
                    Text(note)
                        .font(.body)
                        .padding(.top, 8)
                }

                Text(day.liturgicalColor.explanation)
                    .font(.body)
                    .padding(.top, 8)

                Divider()
                    .padding(.vertical, 28)

                // MARK: Notes
                sectionLabel("Notes")

                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(day.comments.enumerated()), id: \.offset) { index, comment in
                        HStack(alignment: .top, spacing: 8) {
                            Text(comment)
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Button {
                                day.comments.remove(at: index)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                            .accessibilityLabel("Delete note")
                        }
                        .padding(.vertical, 10)
                        if index < day.comments.count - 1 {
                            Divider()
                        }
                    }
                }
                .padding(.top, 6)

                HStack {
                    TextField("Add a note...", text: $newComment)
                        .font(.body)
                        .textFieldStyle(.roundedBorder)
                    Button("Add") {
                        let trimmed = newComment.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty else { return }
                        day.comments.append(trimmed)
                        newComment = ""
                        if ReviewPromptManager.noteWasAdded() {
                            // A brief pause so the prompt doesn't interrupt the
                            // keyboard-dismiss animation from adding the note.
                            Task {
                                try? await Task.sleep(for: .seconds(0.5))
                                requestReview()
                            }
                        }
                    }
                    .disabled(newComment.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.top, 8)
            }
            .padding()
        }
    }

    // MARK: - Header

    @ViewBuilder
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(formattedDate)
                .font(.title2.bold())

            Text(daySubtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let feast = day.feastName {
                sectionLabel(day.isSolemnity ? "Solemnity" : "Feast / Memorial")
                    .padding(.top, 18)
                HStack(spacing: 8) {
                    if day.isSolemnity {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                            .font(.title3)
                    }
                    Text(feast)
                        .font(.title2.bold())
                }
                .padding(.top, 2)
                if let description = day.feastDescription {
                    Text(description)
                        .font(.body)
                        .padding(.top, 8)
                }
            }
        }
    }

    @ViewBuilder
    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .font(.footnote.weight(.semibold))
            .textCase(.uppercase)
            .tracking(0.5)
    }

    /// "Day 185 of the year · 17 days until Easter" (countdown omitted when unavailable).
    private var daySubtitle: String {
        if let countdown = day.countdownText {
            return "Day \(day.dayOfYear) of the year · \(countdown)"
        }
        return "Day \(day.dayOfYear) of the year"
    }

    /// The color the current season normally wears, ignoring day-level overrides.
    /// Used to tell when a day steps out of its season's color (rose Sundays and
    /// feasts like an apostle's red day in green Ordinary Time).
    private var seasonDefaultColor: LiturgicalColor {
        switch day.liturgicalSeason {
        case .advent, .lent: return .violet
        case .christmas, .easter: return .white
        case .triduum: return .red
        case .ordinaryTime: return .green
        }
    }

    /// A one-line note shown only when today's color differs from the season's and
    /// a feast is the reason, e.g. "Today is red for St. Luke, Evangelist." Nil when
    /// the day just wears its season's color, or when there's no feast to name.
    private var todaysColorNote: String? {
        guard day.liturgicalColor != seasonDefaultColor, let feast = day.feastName else { return nil }
        return "Today is \(day.liturgicalColor.rawValue.lowercased()) for \(feast)."
    }

    private var rankExplanation: String {
        if day.isSolemnity {
            return "A solemnity is the highest rank of day in the church year. These mark the most important events of the faith, like Easter, Christmas, and Pentecost. They take priority over the regular season."
        } else {
            return "Feasts and memorials mark people and events from the life of Jesus and the early church. A feast is the more important of the two; a memorial is a smaller remembrance."
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        DayDetailView(day: .constant(.preview))
    }
}
#endif
