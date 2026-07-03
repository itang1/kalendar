//
//  OnboardingView.swift
//  kalendar
//
//  Shown on first launch. Walks the user through how to read the calendar.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var page = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            symbol: "circle.grid.3x3.fill",
            symbolColor: Color(red: 0.45, green: 0.2, blue: 0.55),
            title: "The Christian Year",
            body: "The liturgical kalendar organizes time around the life of Jesus instead of months and quarters. It runs from Advent in late November all the way to the feast of Christ the King nearly a year later, then starts again.\n\n'Kalendar' is the traditional spelling used in many liturgical texts."
        ),
        OnboardingPage(
            symbol: "paintpalette.fill",
            symbolColor: Color(red: 0.75, green: 0.15, blue: 0.15),
            title: "Colors Mean Something",
            body: "Each tile is colored by the liturgical season or feast day it belongs to. The color is also what the priest wears at Mass that day.\n\nViolet for Advent and Lent. White for Christmas and Easter. Red for martyrs and the Holy Spirit. Green for the long stretches of Ordinary Time. Rose appears twice a year on days of joy within penitential seasons."
        ),
        OnboardingPage(
            symbol: "star.fill",
            symbolColor: .yellow,
            title: "Feasts and Solemnities",
            body: "A small dot on a tile means something is being celebrated that day. It might be a solemnity like Easter or Christmas, a feast of an apostle, or a memorial of a saint.\n\nSolemnities are the highest rank. They take priority over the season and are always worth knowing. Tap any tile to read about the day."
        ),
        OnboardingPage(
            symbol: "chart.pie.fill",
            symbolColor: Color(red: 0.2, green: 0.55, blue: 0.3),
            title: "Two Ways to Look",
            body: "The grid view shows every day of the next 365 days laid out as tiles, always starting with today and rolling forward one day at a time.\n\nTiles omit date numbers so color and season stand out at a glance. Tap any tile to see its exact date, feast, and notes.\n\nThe wheel view shows the whole year at once as colored slices, so you can see the shape of the Christian year from a distance.\n\nToggle between the two views in the top right."
        ),
        OnboardingPage(
            symbol: "text.bubble",
            symbolColor: Color(red: 0.2, green: 0.55, blue: 0.3),
            title: "Your Notes Stay",
            body: "Tap any day to open it, then add a comment at the bottom. Notes are saved automatically and persist year over year. Feast day notes follow the feast even when the date shifts (like Easter). Regular day notes stay on the same date each year.\n\nNotes are stored only on this device, not on a server. They won't appear on your other devices, and uninstalling the app will delete them."
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                ForEach(pages.indices, id: \.self) { i in
                    OnboardingPageView(page: pages[i])
                        .tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Page dots
            HStack(spacing: 8) {
                ForEach(pages.indices, id: \.self) { i in
                    Circle()
                        .fill(i == page ? Color.primary : Color.primary.opacity(0.25))
                        .frame(width: 7, height: 7)
                        .animation(.easeInOut(duration: 0.2), value: page)
                }
            }
            .padding(.top, 16)

            // Action button
            Button {
                if page < pages.count - 1 {
                    withAnimation { page += 1 }
                } else {
                    hasSeenOnboarding = true
                }
            } label: {
                Text(page < pages.count - 1 ? "Continue" : "Get Started")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.primary)
                    .foregroundStyle(Color(UIColor.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 28)
            .padding(.top, 24)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Page Model

private struct OnboardingPage {
    let symbol: String
    let symbolColor: Color
    let title: String
    let body: String
}

// MARK: - Page View

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        // Wrapped in a ScrollView so the page still centers at normal text sizes but
        // stays fully readable (scrollable) at large Dynamic Type sizes.
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer(minLength: 0)

                    Image(systemName: page.symbol)
                        .font(.system(size: 52))
                        .foregroundStyle(page.symbolColor)
                        .padding(.bottom, 28)

                    Text(page.title)
                        .font(.title.weight(.bold))
                        .padding(.bottom, 16)

                    Text(page.body)
                        .font(.body)
                        .lineSpacing(4)

                    Spacer(minLength: 0)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 28)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: geo.size.height)
            }
        }
    }
}


#Preview {
    ContentView()
}
