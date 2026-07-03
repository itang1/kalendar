//
//  CircleCalendarView.swift
//  kalendar
//
//  Main calendar view, switchable between grid and wheel modes.

import SwiftUI

// MARK: - View Mode

private enum CalendarViewMode {
    case grid, wheel
}

// MARK: - Main View

struct CircleCalendarView: View {
    @State private var viewModel = CalendarViewModel()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @AppStorage("solemnityNotificationsEnabled") private var notificationsEnabled = false
    @State private var selectedIndex: Int?
    @State private var viewMode: CalendarViewMode = .grid
    @State private var showInfo = false
    @State private var showFeastList = false
    @State private var showJumpToDate = false
    @State private var scrollToIndex: Int? = nil
    @State private var pendingSelectedIndex: Int? = nil

    /// Seven tiles per row on iPhone; more on the wider iPad canvas so tiles
    /// don't shrink to specks.
    private var columns: [GridItem] {
        let count = horizontalSizeClass == .regular ? 12 : 7
        return Array(repeating: GridItem(.flexible(), spacing: 6), count: count)
    }

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
                    Button { showJumpToDate = true } label: {
                        Image(systemName: "calendar.badge.magnifyingglass")
                    }
                    .accessibilityLabel("Jump to a date")
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
            InfoSheet(days: viewModel.days)
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
        .sheet(isPresented: $showJumpToDate, onDismiss: {
            selectedIndex = pendingSelectedIndex
            pendingSelectedIndex = nil
        }) {
            JumpToDateSheet(days: viewModel.days) { index in
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
                DayBrowserSheet(
                    days: Bindable(viewModel).days,
                    initialIndex: index
                )
            }
        }
        .task {
            if notificationsEnabled {
                await SolemnityNotificationScheduler.schedule(for: viewModel.days)
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
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                selectedIndex = index
                            }
                    }
                }
                .padding(12)
            }
            .background(Color.kalendarBackground)
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
                KalendarWheel(days: viewModel.days, radius: size / 2) { index in
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    selectedIndex = index
                }
                .frame(width: size, height: size)

                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    selectedIndex = 0
                } label: {
                    Text("Open Today")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.thinMaterial)
                        .clipShape(Capsule())
                }

                Text("Tap any slice to explore that day.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 24)
        }
        .background(Color.kalendarBackground)
    }
}

// MARK: - Day Browser Sheet (swipeable day detail)

private struct DayBrowserSheet: View {
    @Binding var days: [DayCard]
    let initialIndex: Int
    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex: Int

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f
    }()

    init(days: Binding<[DayCard]>, initialIndex: Int) {
        self._days = days
        self.initialIndex = initialIndex
        self._currentIndex = State(initialValue: initialIndex)
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $currentIndex) {
                ForEach(days.indices, id: \.self) { i in
                    DayDetailView(day: $days[i])
                        .tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .safeAreaInset(edge: .top, spacing: 0) {
                HStack {
                    if currentIndex > 0 {
                        swipeHint(leading: true, label: Self.dateFormatter.string(from: days[currentIndex - 1].date))
                    }
                    Spacer()
                    if currentIndex < days.count - 1 {
                        swipeHint(leading: false, label: Self.dateFormatter.string(from: days[currentIndex + 1].date))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .allowsHitTesting(false)
            }
            .navigationTitle(Self.dateFormatter.string(from: days[currentIndex].date))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func swipeHint(leading: Bool, label: String) -> some View {
        HStack(spacing: 4) {
            if leading {
                Image(systemName: "arrow.left")
                    .font(.caption2.weight(.semibold))
            }
            Text(label)
                .font(.caption.weight(.medium))
            if !leading {
                Image(systemName: "arrow.right")
                    .font(.caption2.weight(.semibold))
            }
        }
        .foregroundStyle(.secondary)
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background(.thinMaterial, in: Capsule())
    }
}

// MARK: - Jump to Date Sheet

private struct JumpToDateSheet: View {
    let days: [DayCard]
    let onSelect: (Int) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate: Date

    init(days: [DayCard], onSelect: @escaping (Int) -> Void) {
        self.days = days
        self.onSelect = onSelect
        self._selectedDate = State(initialValue: days.first?.date ?? Date())
    }

    private var dateRange: ClosedRange<Date> {
        guard let first = days.first?.date, let last = days.last?.date else {
            return Date()...Date()
        }
        return first...last
    }

    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Date",
                    selection: $selectedDate,
                    in: dateRange,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                .padding()
                Spacer()
            }
            .navigationTitle("Jump to a Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Go") {
                        if let index = matchingIndex() {
                            onSelect(index)
                        }
                        dismiss()
                    }
                }
            }
        }
    }

    private func matchingIndex() -> Int? {
        let calendar = Calendar.current
        return days.firstIndex { calendar.isDate($0.date, inSameDayAs: selectedDate) }
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
                                        .font(.caption)
                                }
                                Text(item.day.feastName!)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(.primary)
                            }
                            Text("\(Self.dateFormatter.string(from: item.day.date)) (\(Self.weekdayFormatter.string(from: item.day.date)))")
                                .font(.subheadline)
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
    let days: [DayCard]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("solemnityNotificationsEnabled") private var notificationsEnabled = false
    @State private var showNotificationsDeniedAlert = false

    private var feedbackURL: URL? {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = "theworkingcell@gmail.com"
        components.queryItems = [URLQueryItem(name: "subject", value: "Kalendar Feedback (v\(version), build \(build))")]
        return components.url
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("The liturgical kalendar, also called the Christian Year, is how Christians mark time. Instead of months, the year is organized into seasons that follow the life of Jesus, from anticipation of his birth through his death, resurrection, and beyond. 'Kalendar' is the traditional spelling used in many liturgical texts.")
                        .font(.body)

                    Divider()

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Seasons")
                            .font(.body.weight(.bold))
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
                                    .font(.body.weight(.bold))
                                Spacer()
                            }
                            .padding(.vertical, 2)

                            Text(season.explanation)
                                .font(.body)
                                .padding(.bottom, 8)
                        }
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.primary)
                                .frame(width: 7, height: 7)
                            Text("A dot marks a feast day or memorial. Tap any tile in grid view to read about it.")
                                .font(.body)
                        }
                        HStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 9, height: 9)
                                .foregroundStyle(Color.primary)
                            Text("A star marks a solemnity, the highest rank of celebration.")
                                .font(.body)
                        }
                    }

                    Divider()

                    Text("Notes you add sync privately through your iCloud account, so they appear on your other devices signed into the same Apple ID. They are never sent to us or to any other service.")
                        .font(.body)

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Notify me on solemnities", isOn: notificationsToggleBinding)
                            .font(.body.weight(.semibold))
                        Text("A morning notification on solemnities like Easter, Christmas, and the other highest-ranked celebrations of the year.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .alert("Notifications Off", isPresented: $showNotificationsDeniedAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("Kalendar doesn't have permission to send notifications. Enable them for Kalendar in Settings to turn this on.")
                    }

                    Divider()

                    if let feedbackURL {
                        Button {
                            openURL(feedbackURL)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "envelope")
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Send Feedback")
                                        .font(.body.weight(.semibold))
                                    Text("Report a bug or suggest something, straight to the developer.")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 12)
                            .background(Color.primary.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .foregroundStyle(.primary)
                    }

                    Button {
                        hasSeenOnboarding = false
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Replay Introduction")
                        }
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.primary.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
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

    /// Requests notification permission before turning the toggle on; reverts and
    /// shows guidance if permission is denied. Turning off just cancels.
    private var notificationsToggleBinding: Binding<Bool> {
        Binding(
            get: { notificationsEnabled },
            set: { newValue in
                if newValue {
                    Task {
                        let granted = await SolemnityNotificationScheduler.enable(for: days)
                        notificationsEnabled = granted
                        if !granted { showNotificationsDeniedAlert = true }
                    }
                } else {
                    notificationsEnabled = false
                    Task {
                        await SolemnityNotificationScheduler.disable()
                    }
                }
            }
        )
    }
}
