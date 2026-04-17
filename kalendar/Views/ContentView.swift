//
//  ContentView.swift
//  kalendar
//
//  Created by Irene Tang on 12/20/25.
//
//  App entry UI, navigation setup, hosting the main calendar view

import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        if hasSeenOnboarding {
            NavigationStack {
                CircleCalendarView()
                    .navigationTitle("liturgical calendar")
            }
        } else {
            OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
        }
    }
}

#Preview {
    ContentView()
}
