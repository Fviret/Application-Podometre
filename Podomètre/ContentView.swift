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
    @StateObject private var aphorismManager = AphorismManager()
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("journeyNotificationsEnabled") private var journeyNotificationsEnabled: Bool = true
    @AppStorage(onboardingCompletedKey) private var hasCompletedOnboarding: Bool = false

    /// Aphorisme affiché dans la popup matinale ; non-nil déclenche l'overlay.
    @State private var popupAphorism: Aphorism?

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

            SettingsView(viewModel: viewModel, aphorismManager: aphorismManager)
                .tabItem {
                    Label("Paramètres", systemImage: "gearshape")
                }
                .accessibilityIdentifier("tab_settings")
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .overlay {
            if let aphorism = popupAphorism {
                AphorismPopupView(aphorism: aphorism, accentColor: viewModel.ringColor) {
                    withAnimation { popupAphorism = nil }
                }
            }
        }
        .onAppear {
            journeyProgressService.onJourneyCompleted = { id in
                viewModel.markJourneyCompleted(id)
            }
            journeyProgressService.notificationsEnabled = journeyNotificationsEnabled
            presentDailyAphorismIfNeeded()
        }
        .onChange(of: journeyNotificationsEnabled) { _, enabled in
            journeyProgressService.notificationsEnabled = enabled
        }
        .onChange(of: hasCompletedOnboarding) { _, completed in
            guard completed else { return }
            journeyProgressService.startIfNeeded()
            presentDailyAphorismIfNeeded()
        }
    }

    /// Affiche la popup « pensée du jour » si l'onboarding est terminé et qu'elle n'a pas
    /// déjà été montrée aujourd'hui. Mémorise l'affichage pour garantir 1x/jour maximum.
    private func presentDailyAphorismIfNeeded() {
        guard hasCompletedOnboarding,
              aphorismManager.shouldShowPopup(),
              let aphorism = aphorismManager.todayAphorism else { return }
        aphorismManager.markAphorismDisplayed()
        withAnimation { popupAphorism = aphorism }
    }
}

#Preview {
    ContentView(viewModel: StepCountViewModel())
}
