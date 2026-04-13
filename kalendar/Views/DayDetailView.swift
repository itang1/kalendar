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
                            .foregroundStyle(.secondary)
                    }

                    // Season
                    VStack(alignment: .leading, spacing: 8) {
                        Label {
                            Text("Liturgical Season")
                                .font(.caption.bold())
                                .textCase(.uppercase)
                                .foregroundStyle(.secondary)
                        } icon: {
                            Image(systemName: "info.circle")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Text("'Liturgical' means related to the Church's public worship and calendar. The Church organizes the year into seasons rather than months.")
                            .font(.caption)
                            .foregroundStyle(.tertiary)

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
                                .foregroundStyle(.secondary)
                        }

                        Text(day.liturgicalSeason.explanation)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // Vestment color
                    VStack(alignment: .leading, spacing: 8) {
                        Label {
                            Text("Vestment Color")
                                .font(.caption.bold())
                                .textCase(.uppercase)
                                .foregroundStyle(.secondary)
                        } icon: {
                            Image(systemName: "info.circle")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Text("The priest wears vestments (robes) of a specific color at Mass each day. The color reflects the character of the season or feast being celebrated.")
                            .font(.caption)
                            .foregroundStyle(.tertiary)

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
                                    .foregroundStyle(.secondary)
                            }

                            Text(rankExplanation)
                                .font(.caption)
                                .foregroundStyle(.tertiary)

                            Text(feast)
                                .font(.body.bold())

                            if let description = day.feastDescription {
                                Text(description)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    // Memo
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Memo")
                            .font(.caption.bold())
                            .textCase(.uppercase)
                            .foregroundStyle(.secondary)

                        TextEditor(text: $day.memo)
                            .frame(minHeight: 100)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
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
            return "A solemnity is the highest rank of celebration in the Church. These mark the most important mysteries and events of the faith, like Easter, Christmas, or major saints. They take priority over the regular season."
        } else {
            return "Feasts and memorials are celebrations of saints or events in the life of Jesus and Mary. A feast is more important than a memorial. Some memorials are optional, while others are observed by the whole Church."
        }
    }
}
