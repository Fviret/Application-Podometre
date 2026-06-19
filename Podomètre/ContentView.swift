//
//  ContentView.swift
//  Podomètre
//
//  Created by Flo Viret on 15/06/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = StepCountViewModel()

    var body: some View {
        TabView {
            StepRingView(viewModel: viewModel)
                .tabItem {
                    Label("Activité", systemImage: "figure.walk")
                }

            SettingsView(viewModel: viewModel)
                .tabItem {
                    Label("Paramètres", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    ContentView()
}
