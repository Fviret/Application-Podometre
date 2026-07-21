import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: StepCountViewModel
    @ObservedObject var aphorismManager: AphorismManager
    @AppStorage(.isDarkMode) private var isDarkMode: Bool = false
    @AppStorage(.journeyNotificationsEnabled) private var journeyNotificationsEnabled: Bool = true
    @AppStorage(.showWeatherForecast) private var showWeatherForecast: Bool = true
    @AppStorage(.showMonthCalendar) private var showMonthCalendar: Bool = true
    @AppStorage(.showWeeklyChart) private var showWeeklyChart: Bool = true
    @AppStorage(.showTodayMetrics) private var showTodayMetrics: Bool = true
    @State private var showPicker = false

    private let goalOptions = Array(stride(from: 5_000, through: 20_000, by: 500))

    var body: some View {
        NavigationStack {
            List {
                Section("Objectif quotidien") {
                    Button {
                        withAnimation { showPicker.toggle() }
                    } label: {
                        HStack {
                            Text("Pas par jour")
                                .foregroundStyle(Color.primary)
                            Spacer()
                            Text(viewModel.goal.formatted())
                                .foregroundStyle(Color.secondary)
                            Image(systemName: showPicker ? "chevron.up" : "chevron.down")
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                        }
                    }

                    if showPicker {
                        Picker("Pas par jour", selection: $viewModel.goal) {
                            ForEach(goalOptions, id: \.self) { value in
                                Text(value.formatted()).tag(value)
                            }
                        }
                        .pickerStyle(.wheel)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }

                Section("Personnalisation des couleurs") {
                    HStack {
                        Circle()
                            .fill(viewModel.ringColor)
                            .frame(width: 24, height: 24)
                        Text(AppColors.ringColorOptions.first { $0.id == viewModel.ringColorId }?.name ?? "")
                            .foregroundStyle(Color.primary)
                        Spacer()
                    }

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(AppColors.ringColorOptions) { option in
                            let isSelected = option.id == viewModel.ringColorId
                            Button {
                                viewModel.setRingColor(option.id)
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(option.color)
                                        .frame(width: 36, height: 36)
                                    if isSelected {
                                        Circle()
                                            .stroke(Color.primary, lineWidth: 2)
                                            .frame(width: 42, height: 42)
                                    }
                                }
                                // Cible tactile d'au moins 44 pt, même si la pastille est plus petite.
                                .frame(width: 44, height: 44)
                                .contentShape(Circle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(option.name)
                            .accessibilityHint("Définit la couleur de l'anneau")
                            .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
                        }
                    }
                    .padding(.vertical, 4)

                    Toggle("Mode sombre", isOn: $isDarkMode)
                }
                Section("Mon écran principal") {
                    Toggle("Distance · temps actif · calories", isOn: $showTodayMetrics)
                    Toggle("Météo & prévisions", isOn: $showWeatherForecast)
                    Toggle("Calendrier mensuel", isOn: $showMonthCalendar)
                    Toggle("Graphe hebdomadaire", isOn: $showWeeklyChart)
                }

                AphorismSettingsView(manager: aphorismManager)

                Section("Notifications") {
                    Toggle("Objectif journalier", isOn: $viewModel.notificationsEnabled)
                        .onChange(of: viewModel.notificationsEnabled) { _, enabled in
                            if enabled { viewModel.requestNotificationPermission() }
                        }
                    Toggle("Progression des trajets", isOn: $journeyNotificationsEnabled)
                }

                if viewModel.currentStreak > 0 {
                    Section {
                        StreakBannerView(streak: viewModel.currentStreak, viewModel: viewModel)
                    }
                }

                Section {
                    BadgeGridView(viewModel: viewModel)
                } header: {
                    Text("Badges")
                }
            }
            .navigationTitle("Paramètres")


        }
    }
}

#Preview {
    let viewModel = StepCountViewModel()
    viewModel.goal = 10_000
    viewModel.currentStreak = 12                                   // flamme rouge, 3 couches
    viewModel.milestoneCounts = ["5k": 47, "10k": 23, "20k": 4,
                                 "30k": 1, "50k": 0, "100k": 0]    // badges de seuil
    allJourneys.prefix(4).forEach { viewModel.markJourneyCompleted($0.id.uuidString) } // badges de trajets
    return SettingsView(viewModel: viewModel, aphorismManager: .preview)
}
