//
//  ContentView.swift
//  Podomètre
//
//  Created by Flo Viret on 15/06/2026.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: StepCountViewModel
    @StateObject private var journeyProgressService = JourneyProgressService()
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("journeyNotificationsEnabled") private var journeyNotificationsEnabled: Bool = true
    @AppStorage(onboardingCompletedKey) private var hasCompletedOnboarding: Bool = false

    var body: some View {
        TabView {
            StepRingView(viewModel: viewModel)
                .tabItem {
                    Label("Activité", systemImage: "figure.walk")
                }
                .accessibilityIdentifier("tab_activity")

            JourneyPickerView()
                .environmentObject(journeyProgressService)
                .environmentObject(viewModel)
                .tabItem {
                    Label("Trajets", systemImage: "map")
                }
                .accessibilityIdentifier("tab_journeys")

            SettingsView(viewModel: viewModel)
                .tabItem {
                    Label("Paramètres", systemImage: "gearshape")
                }
                .accessibilityIdentifier("tab_settings")
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear {
            journeyProgressService.onJourneyCompleted = { id in
                viewModel.markJourneyCompleted(id)
            }
            journeyProgressService.notificationsEnabled = journeyNotificationsEnabled
        }
        .onChange(of: journeyNotificationsEnabled) { _, enabled in
            journeyProgressService.notificationsEnabled = enabled
        }
        .onChange(of: hasCompletedOnboarding) { _, completed in
            guard completed else { return }
            journeyProgressService.startIfNeeded()
        }
    }
}

#Preview {
    ContentView(viewModel: StepCountViewModel())
}
