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
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: day.date)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Date
                    VStack(alignment: .leading, spacing: 4) {
                        Text(formattedDate)
                            .font(.title2.bold())
                        Text("Day \(day.dayOfYear) of the year")
                            .font(.subheadline)
                    }

                    // Season
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Liturgical Season")
                            .font(.caption.bold())
                            .textCase(.uppercase)

                        Text("'Liturgical' means related to the Christian community's public worship and calendar. Christians organize the year into seasons rather than months.")
                            .font(.caption)

                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(day.liturgicalSeason.color)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.secondary.opacity(0.3), lineWidth: 0.5)
                                )
                                .frame(width: 20, height: 20)
                            Text(day.liturgicalSeason.rawValue)
                                .font(.body.bold())
                        }

                        if let week = day.weekOfSeason {
                            Text("Week \(week) of \(day.liturgicalSeason.rawValue)")
                                .font(.subheadline)
                        }

                        Text(day.liturgicalSeason.explanation)
                            .font(.subheadline)
                    }

                    // Vestment color
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Vestment Color")
                            .font(.caption.bold())
                            .textCase(.uppercase)

                        Text("The priest wears vestments (robes) of a specific color at Mass each day. The color reflects the character of the season or feast being celebrated.")
                            .font(.caption)

                        HStack(spacing: 8) {
                            Circle()
                                .fill(day.liturgicalColor.color)
                                .overlay(
                                    Circle().stroke(Color.secondary.opacity(0.3), lineWidth: 0.5)
                                )
                                .frame(width: 16, height: 16)
                            Text(day.liturgicalColor.rawValue)
                                .font(.subheadline)
                        }
                    }

                    // Feast
                    if let feast = day.feastName {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 4) {
                                if day.isSolemnity {
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(.yellow)
                                        .font(.caption)
                                }
                                Text(day.isSolemnity ? "Solemnity" : "Feast / Memorial")
                                    .font(.caption.bold())
                                    .textCase(.uppercase)
                            }

                            Text(rankExplanation)
                                .font(.caption)

                            Text(feast)
                                .font(.body.bold())

                            if let description = day.feastDescription {
                                Text(description)
                                    .font(.subheadline)
                            }
                        }
                    }

                    // Memo
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Memo")
                            .font(.caption.bold())
                            .textCase(.uppercase)

                        TextEditor(text: $day.memo)
                            .frame(minHeight: 100)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }

                    // Comments
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Comments")
                            .font(.caption.bold())
                            .textCase(.uppercase)

                        ForEach(Array(day.comments.enumerated()), id: \.offset) { index, comment in
                            HStack(alignment: .top, spacing: 8) {
                                Text(comment)
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Button {
                                    day.comments.remove(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 2)
                            if index < day.comments.count - 1 {
                                Divider()
                            }
                        }

                        HStack {
                            TextField("Add a comment...", text: $newComment)
                                .textFieldStyle(.roundedBorder)
                            Button("Add") {
                                let trimmed = newComment.trimmingCharacters(in: .whitespaces)
                                guard !trimmed.isEmpty else { return }
                                day.comments.append(trimmed)
                                newComment = ""
                            }
                            .disabled(newComment.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(formattedDate)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var rankExplanation: String {
        if day.isSolemnity {
            return "A solemnity is the highest rank of celebration in Christian worship. These mark the most important mysteries and events of the faith, like Easter, Christmas, or major saints. They take priority over the regular season."
        } else {
            return "Feasts and memorials are celebrations of saints or events in the life of Jesus and Mary. A feast is more important than a memorial. Some memorials are optional, while others are observed throughout Christianity."
        }
    }
}
