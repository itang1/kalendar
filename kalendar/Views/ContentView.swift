//
//  ContentView.swift
//  kalendar
//
//  Created by Irene Tang on 12/20/25.
//
//  App entry UI, navigation setup, hosting the main calendar view

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            CircleCalendarView()
                .navigationTitle("liturgical calendar")
        }
    }
}

#Preview {
    ContentView()
}
