//
//  CircleCalendarView.swift
//  kalendar
//
//  Created by Irene Tang on 12/20/25.
//
//  Lay out the cards in a circle. Handle taps, navigate to details

import SwiftUI

struct CircleCalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var selectedIndex: Int?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20, pinnedViews: .sectionHeaders) {
                ForEach(viewModel.daysByMonth(), id: \.month) { section in
                    Section {
                        LazyVGrid(columns: columns, spacing: 6) {
                            // Add empty spacers for weekday offset
                            let firstDate = viewModel.days[section.indices[0]].date
                            let weekday = Calendar.current.component(.weekday, from: firstDate)
                            let offset = weekday - 1 // Sunday = 1
                            ForEach(0..<offset, id: \.self) { i in
                                Color.clear
                                    .aspectRatio(1, contentMode: .fit)
                                    .id("spacer-\(section.month)-\(i)")
                            }

                            ForEach(section.indices, id: \.self) { index in
                                DayCardView(day: viewModel.days[index])
                                    .aspectRatio(1, contentMode: .fit)
                                    .onTapGesture {
                                        selectedIndex = index
                                    }
                            }
                        }
                    } header: {
                        Text(section.month)
                            .font(.title3.bold())
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.bar)
                    }
                }
            }
            .padding(.horizontal)
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

