//
//  DayDetailView.swift
//  kalendar
//
//  Created by Irene Tang on 12/20/25.
//
//  Content view for a single day. Presented inside DayBrowserSheet
//  (see CircleCalendarView) which provides the NavigationStack and toolbar.

import SwiftUI

struct DayDetailView: View {
    @Binding var day: DayCard
    @State private var newComment = ""

    private var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.dateFormat = "EEEE"
        return "\(dateFormatter.string(from: day.date)) (\(weekdayFormatter.string(from: day.date)))"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // MARK: Date
                VStack(alignment: .leading, spacing: 4) {
                    Text(formattedDate)
                        .font(.title2.bold())
                    Text("Day \(day.dayOfYear) of the year")
                        .font(.body)
                }
                .padding(.bottom, 28)

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

                Text("Traditionally during \(day.liturgicalSeason.rawValue):")
                    .font(.body.weight(.semibold))
                    .padding(.top, 16)

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
                .padding(.top, 8)
                .padding(.bottom, 28)

                // MARK: Feast (if any)
                if let feast = day.feastName {
                    sectionLabel(day.isSolemnity ? "Solemnity" : "Feast / Memorial")

                    HStack(spacing: 6) {
                        if day.isSolemnity {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                                .font(.subheadline)
                        }
                        Text(feast)
                            .font(.body.weight(.bold))
                    }
                    .padding(.top, 6)

                    if let description = day.feastDescription {
                        Text(description)
                            .font(.body)
                            .padding(.top, 8)
                    }

                    Text(rankExplanation)
                        .font(.body)
                        .padding(.top, 8)
                        .padding(.bottom, 28)
                }

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

                Text("The priest wears vestments of this color at Mass. The color reflects the character of the season or feast.")
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
                    }
                    .disabled(newComment.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.top, 8)
            }
            .padding()
        }
    }

    @ViewBuilder
    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .font(.footnote.weight(.semibold))
            .textCase(.uppercase)
            .tracking(0.5)
    }

    private var rankExplanation: String {
        if day.isSolemnity {
            return "A solemnity is the highest rank of celebration in Christian worship. These mark the most important mysteries and events of the faith, like Easter, Christmas, or major saints. They take priority over the regular season."
        } else {
            return "Feasts and memorials are celebrations of saints or events in the life of Jesus and Mary. A feast is more important than a memorial. Some memorials are optional, while others are observed throughout Christianity."
        }
    }
}
