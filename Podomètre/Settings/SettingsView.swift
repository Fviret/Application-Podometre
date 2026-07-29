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
    private let goalMin = 500
    private let goalMax = 100_000

    /// Déclencheur du rebond : incrémenté à chaque changement de valeur → `keyframeAnimator`
    /// rejoue l'animation de façon fiable, même entre deux taps rapprochés.
    @State private var goalBumpTrigger = 0
    /// Sens du dernier changement : grossit à l'incrément, rétrécit au décrément.
    @State private var lastBumpGrow = true
    /// Timer de répétition sur appui long, et intervalle courant (décroît → accélération).
    @State private var repeatTimer: Timer?
    @State private var repeatInterval: Double = 0.28
    /// `true` uniquement pendant un appui long (distingue le maintien d'un tap court).
    @State private var isRepeating = false

    var body: some View {
        NavigationStack {
            List {
                // MARK: Mon objectif
                Section {
                    HStack(spacing: 20) {
                        Spacer()
                        goalStepButton(system: "minus", delta: -goalStep, enabled: viewModel.goal > goalMin)

                        VStack(spacing: 0) {
                            Text(viewModel.goal.formatted())
                                .font(.system(.title2, design: .rounded).weight(.bold))
                                .monospacedDigit()
                                .foregroundStyle(Color.primary)
                                .modifier(GoalBounceEffect(trigger: goalBumpTrigger,
                                                           grow: lastBumpGrow,
                                                           enabled: !reduceMotion))
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

                        goalStepButton(system: "plus", delta: goalStep, enabled: viewModel.goal < goalMax)
                        Spacer()
                    }
                    .padding(.vertical, 6)
                } header: {
                    Text("Mon objectif")
                } footer: {
                    Text("Réglable par paliers de 500 pas, de 500 à 100 000.")
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

    /// Applique un delta borné à l'objectif. Retourne `true` si la valeur a changé.
    @discardableResult
    private func applyGoalDelta(_ delta: Int) -> Bool {
        let newGoal = min(max(viewModel.goal + delta, goalMin), goalMax)
        guard newGoal != viewModel.goal else { return false }
        viewModel.goal = newGoal
        return true
    }

    /// Déclenche un rebond directionnel de la valeur (via le `keyframeAnimator` de la vue).
    private func bump(grow: Bool) {
        lastBumpGrow = grow
        goalBumpTrigger &+= 1
    }

    /// Changement unitaire (tap) : valeur + haptique + rebond.
    private func changeGoal(by delta: Int) {
        guard applyGoalDelta(delta) else { return }
        haptic.impactOccurred()
        bump(grow: delta > 0)
    }

    // MARK: Appui long (répétition accélérée)

    /// Démarre la répétition sur maintien : un rebond initial, puis la valeur défile en accélérant.
    private func startRepeating(delta: Int) {
        isRepeating = true
        repeatInterval = 0.28
        bump(grow: delta > 0)
        tickRepeat(delta: delta, isFirst: true)
    }

    /// Un pas de la répétition : s'arrête aux bornes, sinon rejoue plus vite (intervalle × 0,82).
    /// Pas de rebond par cran (éviter le scintillement) — seul le défilement de la valeur bouge.
    private func tickRepeat(delta: Int, isFirst: Bool = false) {
        let atBound = (delta > 0 && viewModel.goal >= goalMax) || (delta < 0 && viewModel.goal <= goalMin)
        guard !atBound, applyGoalDelta(delta) else { stopRepeating(); return }
        if !isFirst { haptic.impactOccurred() }
        repeatInterval = max(0.04, repeatInterval * 0.82)
        repeatTimer?.invalidate()
        repeatTimer = Timer.scheduledTimer(withTimeInterval: repeatInterval, repeats: false) { _ in
            Task { @MainActor in tickRepeat(delta: delta) }
        }
    }

    /// Arrête la répétition. Ne fait rien pour un tap court (aucune répétition en cours).
    private func stopRepeating() {
        guard isRepeating else { return }
        isRepeating = false
        repeatTimer?.invalidate()
        repeatTimer = nil
    }

    /// Bouton circulaire − / + : tap = un pas ; appui long = répétition accélérée.
    private func goalStepButton(system: String, delta: Int, enabled: Bool) -> some View {
        Image(systemName: system)
            .font(.system(.body, weight: .semibold))
            .foregroundStyle(enabled ? viewModel.ringColor : Color.secondary.opacity(0.4))
            .frame(width: 44, height: 44)
            .background(
                Circle().fill(enabled ? viewModel.ringColor.opacity(0.12) : Color.secondary.opacity(0.08))
            )
            .contentShape(Circle())
            .onTapGesture { if enabled { changeGoal(by: delta) } }
            .onLongPressGesture(minimumDuration: 0.35, maximumDistance: 40) {
                if enabled { startRepeating(delta: delta) }
            } onPressingChanged: { pressing in
                if !pressing { stopRepeating() }
            }
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel(delta > 0 ? "Augmenter l'objectif" : "Diminuer l'objectif")
            .accessibilityAction { if enabled { changeGoal(by: delta) } }
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

// MARK: - Effet de rebond de la valeur d'objectif

/// Anime la valeur d'objectif à chaque changement de `trigger` : pic (grossissant si `grow`,
/// rétrécissant sinon) puis retour élastique. Le `keyframeAnimator` redémarre proprement à
/// chaque incrément du trigger — le rebond se joue donc de façon fiable même entre deux taps
/// rapprochés. Neutralisé quand `enabled` est faux (« Réduire les animations »).
private struct GoalBounceEffect: ViewModifier {
    let trigger: Int
    let grow: Bool
    let enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.keyframeAnimator(initialValue: 1.0, trigger: trigger) { view, scale in
                view.scaleEffect(scale)
            } keyframes: { _ in
                KeyframeTrack {
                    CubicKeyframe(grow ? 1.28 : 0.74, duration: 0.13)
                    SpringKeyframe(1.0, duration: 0.34, spring: .bouncy(duration: 0.34, extraBounce: 0.35))
                }
            }
        } else {
            content
        }
    }
}

#Preview {
    let viewModel = StepCountViewModel()
    viewModel.goal = 10_000
    viewModel.currentStreak = 12 // flamme rouge, 3 couches
    return SettingsView(viewModel: viewModel, aphorismManager: .preview)
}

#Preview("Taille Accessibilité XXL") {
    let viewModel = StepCountViewModel()
    viewModel.goal = 10_000
    viewModel.currentStreak = 12
    // Vérifie que la grille de couleurs se réorganise au lieu de déborder.
    return SettingsView(viewModel: viewModel, aphorismManager: .preview)
        .dynamicTypeSize(.accessibility3)
}
