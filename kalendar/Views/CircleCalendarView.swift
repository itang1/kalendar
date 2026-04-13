//
//  CircleCalendarView.swift
//  kalendar
//
//  Created by Irene Tang on 12/20/25.

import SwiftUI

struct CircleCalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var selectedIndex: Int?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Intro
                VStack(alignment: .leading, spacing: 8) {
                    Text("The liturgical kalendar is the Church's way of marking time. Instead of months, the year is organized into seasons that follow the life of Jesus, from anticipation of his birth through his death, resurrection, and beyond.")
                        .font(.subheadline)

                    Text("Each color below represents a liturgical season. Tap any day to learn more.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                // Color legend with explanations
                VStack(spacing: 2) {
                    ForEach(LiturgicalSeason.allCases, id: \.rawValue) { season in
                        HStack(spacing: 10) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(season.color)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 3)
                                        .stroke(Color.secondary.opacity(0.3), lineWidth: 0.5)
                                )
                                .frame(width: 16, height: 16)
                            Text(season.rawValue)
                                .font(.subheadline.bold())
                            Spacer()
                        }
                        .padding(.vertical, 4)

                        Text(season.explanation)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 8)
                    }
                }
                .padding(.horizontal)

                // Dot explanation
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.secondary)
                        .frame(width: 5, height: 5)
                    Text("A dot marks a feast day or special celebration. Tap to read about it.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                // The year, one tile per day
                LazyVGrid(columns: columns, spacing: 4) {
                    let firstWeekday = Calendar.current.component(.weekday, from: viewModel.days[0].date)
                    let leadingSpacers = firstWeekday - 1
                    ForEach(0..<leadingSpacers, id: \.self) { i in
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                            .id("leading-spacer-\(i)")
                    }

                    ForEach(Array(viewModel.days.enumerated()), id: \.offset) { index, day in
                        DayCardView(day: day)
                            .aspectRatio(1, contentMode: .fit)
                            .onTapGesture {
                                selectedIndex = index
                            }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .sheet(isPresented: Binding(
            get: { selectedIndex != nil },
            set: { if !$0 { selectedIndex = nil } }
        )) {
            if let index = selectedIndex {
                DayDetailView(day: $viewModel.days[index])
            }
        }
    }
}
