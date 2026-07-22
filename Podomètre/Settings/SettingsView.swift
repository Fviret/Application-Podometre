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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Taille des pastilles de couleur et de leur cible tactile — suivent la taille de texte
    /// (Dynamic Type) pour rester utilisables aux tailles Accessibilité.
    @ScaledMetric(relativeTo: .body) private var colorSwatchSize: CGFloat = 36
    @ScaledMetric(relativeTo: .body) private var colorTapTarget: CGFloat = 44

    /// Retour haptique léger, cohérent avec le reste de l'app (anneau, calendrier).
    private let haptic = UIImpactFeedbackGenerator(style: .light)

    private let goalOptions = Array(stride(from: 5_000, through: 20_000, by: 500))

    var body: some View {
        NavigationStack {
            List {
                // MARK: Mon objectif
                Section("Mon objectif") {
                    Button {
                        withAnimation(reduceMotion ? nil : .default) { showPicker.toggle() }
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
                        // Léger cran haptique à chaque changement de valeur, comme sur l'anneau.
                        .onChange(of: viewModel.goal) { _, _ in
                            haptic.impactOccurred()
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }

                // MARK: Apparence
                Section("Apparence") {
                    HStack {
                        Circle()
                            .fill(viewModel.ringColor)
                            .frame(width: 24, height: 24)
                        Text(AppColors.ringColorOptions.first { $0.id == viewModel.ringColorId }?.name ?? "")
                            .foregroundStyle(Color.primary)
                        Spacer()
                    }

                    // Grille adaptative : le nombre de colonnes s'ajuste à la largeur disponible
                    // et à la taille des pastilles, au lieu de forcer 6 colonnes qui débordent
                    // sur écran étroit ou en taille de texte Accessibilité.
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: colorTapTarget), spacing: 12)], spacing: 12) {
                        ForEach(AppColors.ringColorOptions) { option in
                            let isSelected = option.id == viewModel.ringColorId
                            Button {
                                haptic.impactOccurred()
                                viewModel.setRingColor(option.id)
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(option.color)
                                        .frame(width: colorSwatchSize, height: colorSwatchSize)
                                    if isSelected {
                                        Circle()
                                            .stroke(Color.primary, lineWidth: 2)
                                            .frame(width: colorSwatchSize + 6, height: colorSwatchSize + 6)
                                    }
                                }
                                // Cible tactile d'au moins 44 pt, même si la pastille est plus petite.
                                .frame(width: colorTapTarget, height: colorTapTarget)
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

                // MARK: Écran principal
                Section {
                    Toggle("Distance · temps actif · calories", isOn: $showTodayMetrics)
                    Toggle("Météo & prévisions", isOn: $showWeatherForecast)
                    Toggle("Calendrier mensuel", isOn: $showMonthCalendar)
                    Toggle("Graphe hebdomadaire", isOn: $showWeeklyChart)
                } header: {
                    Text("Écran principal")
                } footer: {
                    Text("Choisissez les sections affichées sous l'anneau. Désactiver la météo coupe aussi les appels réseau et la localisation.")
                }

                // MARK: Contenu
                AphorismSettingsView(manager: aphorismManager)

                // MARK: Notifications
                Section {
                    Toggle("Objectif journalier", isOn: $viewModel.notificationsEnabled)
                        .onChange(of: viewModel.notificationsEnabled) { _, enabled in
                            if enabled { viewModel.requestNotificationPermission() }
                        }
                    Toggle("Progression des trajets", isOn: $journeyNotificationsEnabled)
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("L'objectif journalier est notifié une seule fois par jour.")
                }

                // MARK: Récompenses
                if viewModel.currentStreak > 0 {
                    Section("Récompenses") {
                        StreakBannerView(streak: viewModel.currentStreak, viewModel: viewModel)
                    }
                }

                Section {
                    BadgeGridView(viewModel: viewModel)
                } header: {
                    Text(viewModel.currentStreak > 0 ? "Badges" : "Récompenses")
                }

                // MARK: À propos
                aboutSection
            }
            .navigationTitle("Paramètres")
        }
    }

    /// Informations sur l'application : version, source des données, crédits.
    private var aboutSection: some View {
        Section {
            LabeledContent("Version", value: appVersion)
                .accessibilityElement(children: .combine)

            LabeledContent("Données de santé", value: "HealthKit")
                .accessibilityElement(children: .combine)
        } header: {
            Text("À propos")
        } footer: {
            Text("Vos pas et distances sont lus depuis HealthKit et ne quittent jamais votre iPhone. Recueil de pensées du jour : 400 aphorismes du domaine public (CC0).")
        }
    }

    /// Version courte et numéro de build issus du bundle (ex. « 1.2 (34) »).
    private var appVersion: String {
        let info = Bundle.main.infoDictionary
        let short = info?["CFBundleShortVersionString"] as? String ?? "—"
        let build = info?["CFBundleVersion"] as? String
        return build.map { "\(short) (\($0))" } ?? short
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

#Preview("Taille Accessibilité XXL") {
    let viewModel = StepCountViewModel()
    viewModel.goal = 10_000
    viewModel.currentStreak = 12
    viewModel.milestoneCounts = ["5k": 47, "10k": 23, "20k": 4,
                                 "30k": 1, "50k": 0, "100k": 0]
    // Vérifie que la grille de couleurs se réorganise au lieu de déborder.
    return SettingsView(viewModel: viewModel, aphorismManager: .preview)
        .dynamicTypeSize(.accessibility3)
}
