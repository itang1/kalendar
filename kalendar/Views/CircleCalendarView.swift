//
//  CircleCalendarView.swift
//  kalendar
//
//  Main calendar view — switchable between grid and wheel modes.

import SwiftUI

// MARK: - View Mode

private enum CalendarViewMode {
    case grid, wheel
}

// MARK: - Main View

struct CircleCalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var selectedIndex: Int?
    @State private var viewMode: CalendarViewMode = .grid
    @State private var showInfo = false
    @State private var showFeastList = false
    @State private var scrollToIndex: Int? = nil
    @State private var pendingSelectedIndex: Int? = nil
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    var body: some View {
        Group {
            switch viewMode {
            case .grid:  gridView
            case .wheel: wheelView
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { showInfo = true } label: {
                    Image(systemName: "info.circle")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 20) {
                    Button { showFeastList = true } label: {
                        Image(systemName: "list.star")
                    }
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            viewMode = (viewMode == .grid) ? .wheel : .grid
                        }
                    } label: {
                        Image(systemName: viewMode == .grid ? "chart.pie" : "square.grid.3x3")
                    }
                }
            }
        }
        .sheet(isPresented: $showInfo) {
            InfoSheet()
        }
        .sheet(isPresented: $showFeastList, onDismiss: {
            selectedIndex = pendingSelectedIndex
            pendingSelectedIndex = nil
        }) {
            FeastListSheet(days: viewModel.days) { index in
                viewMode = .grid
                scrollToIndex = index
                pendingSelectedIndex = index
            }
        }
        .sheet(
            isPresented: Binding(
                get: { selectedIndex != nil },
                set: { if !$0 { selectedIndex = nil } }
            )
        ) {
            if let index = selectedIndex {
                DayDetailView(day: $viewModel.days[index])
            }
        }
    }

    // MARK: - Grid

    private var gridView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVGrid(columns: columns, spacing: 6) {
                    ForEach(Array(viewModel.days.enumerated()), id: \.offset) { index, day in
                        DayCardView(day: day)
                            .aspectRatio(1, contentMode: .fit)
                            .id(index)
                            .onTapGesture { selectedIndex = index }
                    }
                }
                .padding(12)
            }
            .background(Color(red: 0.78, green: 0.80, blue: 0.84))
            .onChange(of: scrollToIndex) {
                guard let idx = scrollToIndex else { return }
                withAnimation { proxy.scrollTo(idx, anchor: .center) }
                scrollToIndex = nil
            }
        }
    }

    // MARK: - Wheel

    private var wheelView: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height) - 48
            VStack(spacing: 20) {
                KalendarWheel(days: viewModel.days, radius: size / 2)
                    .frame(width: size, height: size)
                Text("A full-year overview. Switch to grid view to explore individual days.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 24)
        }
    }
}

// MARK: - Feast List Sheet

private struct FeastListSheet: View {
    let days: [DayCard]
    let onSelect: (Int) -> Void
    @Environment(\.dismiss) private var dismiss

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

    private var feastDays: [(index: Int, day: DayCard)] {
        days.enumerated().compactMap { index, day in
            day.feastName != nil ? (index, day) : nil
        }
    }

    var body: some View {
        NavigationStack {
            List(feastDays, id: \.index) { item in
                Button {
                    onSelect(item.index)
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(item.day.liturgicalSeason.color)
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(Color.secondary.opacity(0.4), lineWidth: 3)
                            )
                            .frame(width: 18, height: 18)

                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 5) {
                                if item.day.isSolemnity {
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(.yellow)
                                        .font(.system(size: 12))
                                }
                                Text(item.day.feastName!)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(.primary)
                            }
                            Text("\(Self.dateFormatter.string(from: item.day.date)) (\(Self.weekdayFormatter.string(from: item.day.date)))")
                                .font(.system(size: 15))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Feasts & Solemnities")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Info Sheet

private struct InfoSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("The liturgical kalendar, also called the Christian Year, is how Christians mark time. Instead of months, the year is organized into seasons that follow the life of Jesus, from anticipation of his birth through his death, resurrection, and beyond. 'Kalendar' is the traditional spelling used in many liturgical texts.")
                        .font(.system(size: 17))

                    Divider()

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Seasons")
                            .font(.system(size: 17, weight: .bold))
                            .textCase(.uppercase)
                            .padding(.bottom, 12)

                        ForEach(LiturgicalSeason.allCases, id: \.rawValue) { season in
                            HStack(spacing: 10) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(season.color)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 3)
                                            .stroke(Color.secondary.opacity(0.4), lineWidth: 3)
                                    )
                                    .frame(width: 20, height: 20)
                                Text(season.rawValue)
                                    .font(.system(size: 17, weight: .bold))
                                Spacer()
                            }
                            .padding(.vertical, 2)

                            Text(season.explanation)
                                .font(.system(size: 17))
                                .padding(.bottom, 8)
                        }
                    }

                    Divider()

                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.primary)
                            .frame(width: 7, height: 7)
                        Text("A dot marks a feast day or special celebration. Tap any tile in grid view to read about it.")
                            .font(.system(size: 17))
                    }
                }
                .padding()
            }
            .navigationTitle("About the Kalendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
