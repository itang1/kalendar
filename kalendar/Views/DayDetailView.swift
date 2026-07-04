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

                // MARK: Obligation & discipline flags
                if hasFlags {
                    flagsSection
                        .padding(.bottom, 24)
                }

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

                // MARK: Vestment Color
                sectionLabel("Vestment")

                HStack(spacing: 10) {
                    Circle()
                        .fill(day.liturgicalColor.color)
                        .overlay(Circle().stroke(Color.secondary.opacity(0.3), lineWidth: 3))
                        .frame(width: 18, height: 18)
                    Text(day.liturgicalColor.rawValue)
                        .font(.body.weight(.bold))
                }
                .padding(.top, 6)

                Text(day.liturgicalColor.explanation)
                    .font(.body)
                    .padding(.top, 8)

                // MARK: Readings
                sectionLabel("Readings")
                    .padding(.top, 28)

                Text("This liturgical year, Sunday readings come mainly from the Gospel of \(sundayGospelName).")
                    .font(.body)
                    .padding(.top, 6)

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

    // MARK: - Obligation & discipline flags

    private var hasFlags: Bool {
        day.isHolyDayOfObligation || day.isDayOfFastingAndAbstinence || day.isDayOfAbstinenceFromMeat
    }

    @ViewBuilder
    private var flagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if day.isHolyDayOfObligation {
                flagRow(
                    icon: "checkmark.seal.fill",
                    title: "Holy Day of Obligation",
                    detail: "Catholics are asked to attend Mass today, as on a Sunday. Which days are observed can vary by country and diocese."
                )
            }
            if day.isDayOfFastingAndAbstinence {
                flagRow(
                    icon: "fork.knife.circle.fill",
                    title: "Fasting and Abstinence",
                    detail: "A day of fasting (one full meal, plus two smaller ones that together don't equal a full meal) for Catholics ages 18 to 59, and abstinence from meat for those 14 and up."
                )
            } else if day.isDayOfAbstinenceFromMeat {
                flagRow(
                    icon: "fish.fill",
                    title: "Abstinence from Meat",
                    detail: "Fridays in Lent are a day of abstinence from meat, for Catholics age 14 and up."
                )
            }
        }
    }

    @ViewBuilder
    private func flagRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body.weight(.semibold))
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
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

    /// The three-year Sunday cycle rotates which Gospel supplies most Sunday
    /// readings: Matthew in Year A, Mark in Year B, Luke in Year C (John fills
    /// in at points in every year, especially in Year B and during Easter).
    private var sundayGospelName: String {
        switch day.sundayLectionaryCycle {
        case "A": return "Matthew"
        case "B": return "Mark"
        default: return "Luke"
        }
    }

    private var rankExplanation: String {
        if day.isSolemnity {
            return "A solemnity is the highest rank of celebration in the liturgical year. These mark the most important mysteries and events of the faith, like Easter, Christmas, or major saints. They take priority over the regular season."
        } else {
            return "Feasts and memorials are celebrations of saints or events in the life of Jesus and Mary. A feast is more important than a memorial. Some memorials are optional, while others are observed throughout the liturgical calendar."
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
