//
//  DayDetailView.swift
//  kalendar
//
//  Created by Irene Tang on 12/20/25.
//
//  Shows when a user taps a card

import SwiftUI

struct DayDetailView: View {
    @Binding var day: DayCard
    @Environment(\.dismiss) private var dismiss
    @State private var newComment = ""

    private var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.dateFormat = "EEEE"
        return "\(dateFormatter.string(from: day.date)) (\(weekdayFormatter.string(from: day.date)))"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // MARK: Date
                    VStack(alignment: .leading, spacing: 4) {
                        Text(formattedDate)
                            .font(.title2.bold())
                        Text("Day \(day.dayOfYear) of the year")
                            .font(.system(size: 17))
                            .foregroundStyle(.secondary)
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
                            .font(.system(size: 17, weight: .bold))
                        if let week = day.weekOfSeason {
                            Text("· Week \(week)")
                                .font(.system(size: 17))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 6)

                    Text(day.liturgicalSeason.explanation)
                        .font(.system(size: 17))
                        .padding(.top, 8)

                    Text("Traditionally during \(day.liturgicalSeason.rawValue):")
                        .font(.system(size: 17, weight: .semibold))
                        .padding(.top, 16)

                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(day.liturgicalSeason.contextualItems, id: \.self) { item in
                            HStack(alignment: .top, spacing: 8) {
                                Text("·")
                                    .font(.system(size: 17, weight: .bold))
                                Text(item)
                                    .font(.system(size: 17))
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
                                    .font(.system(size: 15))
                            }
                            Text(feast)
                                .font(.system(size: 17, weight: .bold))
                        }
                        .padding(.top, 6)

                        if let description = day.feastDescription {
                            Text(description)
                                .font(.system(size: 17))
                                .padding(.top, 8)
                        }

                        Text(rankExplanation)
                            .font(.system(size: 17))
                            .foregroundStyle(.secondary)
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
                            .font(.system(size: 17, weight: .bold))
                    }
                    .padding(.top, 6)

                    Text("The priest wears vestments of this color at Mass. The color reflects the character of the season or feast.")
                        .font(.system(size: 17))
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)

                    Divider()
                        .padding(.vertical, 28)

                    // MARK: Comments
                    sectionLabel("Comments")

                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(day.comments.enumerated()), id: \.offset) { index, comment in
                            HStack(alignment: .top, spacing: 8) {
                                Text(comment)
                                    .font(.system(size: 17))
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
                        TextField("Add a comment...", text: $newComment)
                            .font(.system(size: 17))
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
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold))
            .textCase(.uppercase)
            .tracking(0.5)
            .foregroundStyle(.secondary)
    }

    private var rankExplanation: String {
        if day.isSolemnity {
            return "A solemnity is the highest rank of celebration in Christian worship. These mark the most important mysteries and events of the faith, like Easter, Christmas, or major saints. They take priority over the regular season."
        } else {
            return "Feasts and memorials are celebrations of saints or events in the life of Jesus and Mary. A feast is more important than a memorial. Some memorials are optional, while others are observed throughout Christianity."
        }
    }
}
