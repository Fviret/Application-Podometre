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
    @AppStorage(.hasCompletedOnboarding) private var hasCompletedOnboarding: Bool = false

    /// Taille des pastilles de couleur et de leur cible tactile — suivent la taille de texte
    /// (Dynamic Type) pour rester utilisables aux tailles Accessibilité.
    @ScaledMetric(relativeTo: .body) private var colorSwatchSize: CGFloat = 36
    @ScaledMetric(relativeTo: .body) private var colorTapTarget: CGFloat = 44

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Retour haptique léger, cohérent avec le reste de l'app (anneau, calendrier).
    private let haptic = UIImpactFeedbackGenerator(style: .light)

    /// Bornes et pas du sélecteur d'objectif.
    private let goalStep = 500
    private let goalMin = 5_000
    private let goalMax = 20_000

    /// Échelle animée de la valeur d'objectif — pilote l'effet « bounce » à l'incrément/décrément.
    @State private var goalScale: CGFloat = 1

    var body: some View {
        NavigationStack {
            List {
                // MARK: Mon objectif
                Section {
                    HStack(spacing: 20) {
                        goalStepButton(system: "minus", enabled: viewModel.goal > goalMin) {
                            changeGoal(by: -goalStep)
                        }

                        VStack(spacing: 0) {
                            Text(viewModel.goal.formatted())
                                .font(.system(.title2, design: .rounded).weight(.bold))
                                .monospacedDigit()
                                .foregroundStyle(Color.primary)
                                .scaleEffect(goalScale)
                            Text("pas / jour")
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Objectif quotidien")
                        .accessibilityValue("\(viewModel.goal.formatted()) pas")
                        .accessibilityAdjustableAction { direction in
                            switch direction {
                            case .increment: changeGoal(by: goalStep)
                            case .decrement: changeGoal(by: -goalStep)
                            @unknown default: break
                            }
                        }

                        goalStepButton(system: "plus", enabled: viewModel.goal < goalMax) {
                            changeGoal(by: goalStep)
                        }
                    }
                    .padding(.vertical, 6)
                } header: {
                    Text("Mon objectif")
                } footer: {
                    Text("Réglable par paliers de 500 pas, de 5 000 à 20 000.")
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

                // MARK: Contenu
                AphorismSettingsView(manager: aphorismManager)

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

                // MARK: Revoir la présentation
                Section {
                    Button {
                        // Ré-affiche l'onboarding (fullScreenCover piloté par cette clé à la racine).
                        hasCompletedOnboarding = false
                    } label: {
                        Label("Revoir la présentation", systemImage: "sparkles")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                    }
                }

                // MARK: À propos
                aboutSection
            }
            .navigationTitle("Paramètres")
        }
    }

    // MARK: - Sélecteur d'objectif

    /// Modifie l'objectif d'un pas (borné), avec haptique et effet « bounce » directionnel.
    private func changeGoal(by delta: Int) {
        let newGoal = min(max(viewModel.goal + delta, goalMin), goalMax)
        guard newGoal != viewModel.goal else { return }
        viewModel.goal = newGoal
        haptic.impactOccurred()
        bounce(grow: delta > 0)
    }

    /// Anime la valeur : pic (grossissant si incrément, rétrécissant si décrément) puis retour
    /// élastique à 1 → sensation de rebond. Neutralisé si « Réduire les animations » est actif.
    private func bounce(grow: Bool) {
        guard !reduceMotion else { return }
        goalScale = grow ? 1.3 : 0.75
        withAnimation(.spring(response: 0.34, dampingFraction: 0.45)) {
            goalScale = 1
        }
    }

    /// Bouton circulaire − / + du sélecteur d'objectif.
    private func goalStepButton(system: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.system(.body, weight: .semibold))
                .foregroundStyle(enabled ? viewModel.ringColor : Color.secondary.opacity(0.4))
                .frame(width: 44, height: 44)
                .background(
                    Circle().fill(enabled ? viewModel.ringColor.opacity(0.12) : Color.secondary.opacity(0.08))
                )
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .accessibilityLabel(system == "plus" ? "Augmenter l'objectif" : "Diminuer l'objectif")
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
