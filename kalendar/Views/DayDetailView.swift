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
            Form {
                Section("Date") {
                    Text(formattedDate)
                    Text("Day \(day.dayOfYear) of the year")
                        .foregroundStyle(.secondary)
                }

                Section("Memo") {
                    TextEditor(text: $day.memo)
                        .frame(minHeight: 100)
                }

                if !day.comments.isEmpty {
                    Section("Comments") {
                        ForEach(day.comments, id: \.self) { comment in
                            Text(comment)
                        }
                    }
                }
            }
            .navigationTitle("Day \(day.dayOfYear)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
