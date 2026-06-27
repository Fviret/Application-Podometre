//
//  ContentView.swift
//  Podomètre
//
//  Created by Flo Viret on 15/06/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = StepCountViewModel()
    @StateObject private var journeyProgressService = JourneyProgressService()
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    var body: some View {
        TabView {
            StepRingView(viewModel: viewModel)
                .tabItem {
                    Label("Activité", systemImage: "figure.walk")
                }

            JourneyPickerView()
                .environmentObject(journeyProgressService)
                .tabItem {
                    Label("Trajets", systemImage: "map")
                }

            SettingsView(viewModel: viewModel)
                .tabItem {
                    Label("Paramètres", systemImage: "gearshape")
                }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#Preview {
    ContentView()
}
