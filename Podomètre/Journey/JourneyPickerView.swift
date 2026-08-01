import SwiftUI

/// Vue catalogue des trajets disponibles, organisée par catégorie.
struct JourneyPickerView: View {
    @EnvironmentObject private var progressService: JourneyProgressService
    @EnvironmentObject private var stepViewModel: StepCountViewModel

    @State private var selectedJourney: Journey?
    /// Trajet dont on affiche la prévisualisation (nouveau ou déjà en cours).
    @State private var journeyToPreview: Journey?
    /// Trajet terminé dont on affiche la popup de détail (date de complétion), au tap sur son badge.
    @State private var completedJourneyForDetail: Journey?
    /// Catégories actuellement dépliées. Repliées par défaut pour alléger le scroll ;
    /// initialisée dans `onAppear` avec la catégorie ayant une progression, si besoin.
    @State private var expandedCategories: Set<JourneyCategory> = []
    @State private var hasInitializedExpansion = false

    /// Force les catégories dépliées à l'affichage initial, à la place du calcul
    /// automatique (catégorie ayant une progression). Réservé aux previews/tests.
    var initiallyExpandedCategories: Set<JourneyCategory>?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Ordre d'affichage des catégories.
    private let categoryOrder: [JourneyCategory] = [.walk, .trail, .history, .myth]

    /// Trajets groupés par catégorie, en excluant le trajet en cours
    /// (déjà mis en avant dans la card épinglée en tête).
    private var grouped: [JourneyCategory: [Journey]] {
        let activeId = activeJourney?.journey.id
        let journeys = allJourneys.filter { $0.id != activeId }
        return Dictionary(grouping: journeys, by: \.category)
    }

    /// Trajet en cours à épingler : a une progression, n'est pas terminé, et n'a pas atteint 100 %.
    /// S'il y en avait plusieurs, on retient le plus récemment mis à jour.
    private var activeJourney: (journey: Journey, progress: JourneyProgress)? {
        allJourneys
            .compactMap { journey -> (Journey, JourneyProgress)? in
                guard let progress = progressService.progress(for: journey),
                      !stepViewModel.isJourneyCompleted(journey.id.uuidString),
                      journey.progressPercent(for: progress) < 1.0
                else { return nil }
                return (journey, progress)
            }
            .max { $0.1.lastUpdatedDate < $1.1.lastUpdatedDate }
            .map { (journey: $0.0, progress: $0.1) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24, pinnedViews: []) {
                    // Trajet en cours épinglé en tête ; sinon, card d'incitation
                    // au démarrage (même emplacement, mêmes dimensions).
                    if let active = activeJourney {
                        ActiveJourneyCardView(
                            journey: active.journey,
                            progress: active.progress,
                            ringColor: stepViewModel.ringColor,
                            averageDailySteps: stepViewModel.averageDailySteps,
                            onTap: { selectedJourney = active.journey }
                        )
                    } else {
                        StartJourneyPromptCardView(ringColor: stepViewModel.ringColor)
                    }

                    ForEach(categoryOrder, id: \.self) { category in
                        if let journeys = grouped[category] {
                            categorySection(category, journeys: journeys)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .onAppear {
                // Déplie une seule fois la catégorie contenant un trajet déjà commencé,
                // pour ne pas la cacher derrière un accordéon replié au premier affichage.
                guard !hasInitializedExpansion else { return }
                hasInitializedExpansion = true
                if let initiallyExpandedCategories {
                    expandedCategories = initiallyExpandedCategories
                } else {
                    let startedCategories = allJourneys
                        .filter { progressService.progress(for: $0) != nil }
                        .map(\.category)
                    expandedCategories = Set(startedCategories)
                }
            }
            .navigationTitle("Trajets")
            .navigationDestination(item: $selectedJourney) { journey in
                JourneyDetailView(journey: journey)
                    .environmentObject(progressService)
                    .environmentObject(stepViewModel)
            }
            .sheet(item: $journeyToPreview) { journey in
                JourneyPreviewSheet(
                    journey: journey,
                    isInProgress: progressService.progress(for: journey) != nil,
                    requiresAbandon: progressService.hasActiveJourney(otherThan: journey),
                    unlockedMilestoneIds: progressService.progress(for: journey)?.unlockedMilestoneIds ?? []
                ) {
                    progressService.startJourney(journey)
                    selectedJourney = journey
                } onContinue: {
                    selectedJourney = journey
                }
            }
            .sheet(item: $completedJourneyForDetail) { journey in
                CompletedJourneyDetailSheet(
                    journey: journey,
                    completionDate: stepViewModel.completionDate(for: journey.id.uuidString)
                )
                .presentationDetents([.height(340)])
                .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Section catégorie

    @ViewBuilder
    private func categorySection(_ category: JourneyCategory, journeys: [Journey]) -> some View {
        let isExpanded = expandedCategories.contains(category)
        // Trajets terminés affichés en badges compacts en tête d'accordéon ; le reste
        // en cards complètes. Le compteur du header ne porte que sur les restants,
        // seuls pertinents pour inciter à démarrer un nouveau trajet.
        let completedJourneys = journeys.filter { stepViewModel.isJourneyCompleted($0.id.uuidString) }
        let remainingJourneys = journeys.filter { !stepViewModel.isJourneyCompleted($0.id.uuidString) }

        VStack(alignment: .leading, spacing: 12) {
            Button {
                toggleCategory(category)
            } label: {
                HStack(spacing: 6) {
                    Text(LocalizedStringKey(category.rawValue))
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(Color.secondary)
                        .kerning(1.2)
                        .textCase(.uppercase)

                    Text("(\(remainingJourneys.count))")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(Color.secondary.opacity(0.7))

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits([.isHeader, .isButton])
            .accessibilityLabel("\(category.rawValue), \(remainingJourneys.count) trajets restants")
            .accessibilityValue(isExpanded ? "Déplié" : "Replié")
            .accessibilityHint(isExpanded ? "Touchez pour replier" : "Touchez pour déplier")

            if isExpanded {
                if !completedJourneys.isEmpty {
                    CompletedJourneyBadgeGrid(
                        journeys: completedJourneys,
                        ringColor: stepViewModel.ringColor,
                        onSelect: { completedJourneyForDetail = $0 }
                    )
                }

                ForEach(remainingJourneys) { journey in
                    JourneyCard(
                        journey: journey,
                        progress: progressService.progress(for: journey),
                        ringColor: stepViewModel.ringColor,
                        onAction: { journeyToPreview = journey }
                    )
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    /// Replie/déplie une catégorie. Le mouvement d'accordéon est coupé si
    /// « Réduire les animations » est activé (accessibilité vestibulaire).
    private func toggleCategory(_ category: JourneyCategory) {
        let toggle = {
            if expandedCategories.contains(category) {
                expandedCategories.remove(category)
            } else {
                expandedCategories.insert(category)
            }
        }
        if reduceMotion {
            toggle()
        } else {
            withAnimation(.easeInOut(duration: 0.25), toggle)
        }
    }
}

// MARK: - JourneyCard

/// Card d'un trajet non terminé dans le catalogue. Les trajets terminés sont
/// affichés à part, en badges compacts (`CompletedJourneyBadgeGrid`).
private struct JourneyCard: View {
    let journey: Journey
    let progress: JourneyProgress?
    let ringColor: Color
    let onAction: () -> Void

    private var progressPercent: Double {
        journey.progressPercent(for: progress ?? JourneyProgress(
            journeyId: journey.id, totalKm: 0,
            unlockedMilestoneIds: [], startDate: Date(), lastUpdatedDate: Date()
        ))
    }

    private var hasProgress: Bool { progress != nil }

    var body: some View {
        Button(action: onAction) { cardContent }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(journey.name). \(journey.subtitle). \(Int(journey.totalKm)) km, \(journey.milestones.count) étapes.\(hasProgress ? " Progression : \(Int(progressPercent * 100)) %." : "")")
            .accessibilityHint(hasProgress ? "Voir mes étapes" : "Voir le trajet")
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack(alignment: .top, spacing: 14) {
                Text(journey.emoji)
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedStringKey(journey.name))
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(Color.primary)

                    Text(LocalizedStringKey(journey.subtitle))
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                        .lineLimit(2)
                }

                Spacer()
            }

            HStack(spacing: 16) {
                Label(String(format: "%.0f km", journey.totalKm), systemImage: "arrow.left.and.right")
                    .font(.caption)
                    .foregroundStyle(Color.secondary)

                Label("\(journey.milestones.count) étapes", systemImage: "mappin.circle")
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
            }
            .accessibilityElement(children: .combine)

            if let progress {
                VStack(alignment: .leading, spacing: 6) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.secondary.opacity(0.15))
                                .frame(height: 6)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(ringColor)
                                .frame(width: geo.size.width * progressPercent, height: 6)
                        }
                    }
                    .frame(height: 6)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Progression : \(Int(progressPercent * 100)) %")

                    Text(String(format: "%.1f / %.0f km", progress.totalKm, journey.totalKm))
                        .font(.caption2)
                        .foregroundStyle(Color.secondary)
                }
            }

            // Pastille d'appel à l'action, purement visuelle : c'est la carte entière
            // qui est le bouton (voir `body`), pas cette pastille.
            Text(hasProgress ? "Voir mes étapes" : "Voir le trajet")
                .font(.system(.subheadline, design: .rounded).weight(.medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(hasProgress ? ringColor : ringColor.opacity(0.12))
                .foregroundStyle(hasProgress ? Color.white : ringColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .accessibilityHidden(true)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - CompletedJourneyBadgeGrid

/// Grille compacte des trajets terminés d'une catégorie, affichée en tête de l'accordéon.
/// Chaque badge est tappable et ouvre le détail du trajet, qui affiche la date de complétion.
private struct CompletedJourneyBadgeGrid: View {
    let journeys: [Journey]
    let ringColor: Color
    let onSelect: (Journey) -> Void

    private let columns = [GridItem(.adaptive(minimum: 72, maximum: 92), spacing: 14)]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TERMINÉS")
                .font(.system(.caption2, design: .rounded).weight(.semibold))
                .foregroundStyle(Color.secondary.opacity(0.7))
                .kerning(1)

            LazyVGrid(columns: columns, alignment: .leading, spacing: 14) {
                ForEach(journeys) { journey in
                    Button {
                        onSelect(journey)
                    } label: {
                        VStack(spacing: 4) {
                            Text(journey.emoji)
                                .font(.system(size: 34))
                                .shadow(color: ringColor.opacity(0.4), radius: 6, x: 0, y: 0)
                                .accessibilityHidden(true)

                            Text(LocalizedStringKey(journey.name))
                                .font(.caption2)
                                .foregroundStyle(Color.primary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(journey.name), trajet terminé")
                    .accessibilityHint("Touchez pour voir la date de complétion")
                    .accessibilityAddTraits(.isButton)
                }
            }
        }
        .padding(.bottom, 4)
    }
}

// MARK: - CompletedJourneyDetailSheet

/// Popup affichée au tap sur un badge de trajet terminé : emoji, nom, date de complétion.
private struct CompletedJourneyDetailSheet: View {
    let journey: Journey
    let completionDate: Date?

    private var dateText: String {
        guard let completionDate else { return "Date inconnue" }
        return completionDate.formatted(.dateTime.day().month(.wide).year())
    }

    var body: some View {
        VStack(spacing: 18) {
            Text(journey.emoji)
                .font(.system(size: 64))
                .accessibilityHidden(true)

            VStack(spacing: 4) {
                Text(LocalizedStringKey(journey.name))
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .multilineTextAlignment(.center)
                Text(LocalizedStringKey(journey.subtitle))
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                Text("Terminé le \(dateText)")
            }
            .font(.system(.subheadline, design: .rounded).weight(.semibold))
            .foregroundStyle(Color.accentColor)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.accentColor.opacity(0.12), in: Capsule())

            Label(String(format: "%.0f km · %d étapes", journey.totalKm, journey.milestones.count), systemImage: "mappin.and.ellipse")
                .font(.caption)
                .foregroundStyle(Color.secondary)
        }
        .padding(.horizontal, 28)
        .padding(.top, 36)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(journey.name), terminé le \(dateText). \(journey.subtitle). \(Int(journey.totalKm)) km, \(journey.milestones.count) étapes.")
    }
}

// MARK: - Preview

#Preview("Popup — trajet terminé") {
    let journey = allJourneys[0]
    return CompletedJourneyDetailSheet(journey: journey, completionDate: Date())
}

#Preview("Popup — date inconnue") {
    let journey = allJourneys[0]
    return CompletedJourneyDetailSheet(journey: journey, completionDate: nil)
}

#Preview("Sans trajet en cours (incitation)") {
    // JourneyProgressService charge depuis UserDefaults.standard (réel) : une progression
    // persistée par une autre preview/exécution dans le même process serait rechargée
    // malgré injectMockData: false. On la purge explicitement pour garantir l'état vide.
    Preferences.shared.removeObject(.journeyProgressMap)

    let viewModel = StepCountViewModel()
    viewModel.currentWeekSteps = [8_100, 9_400, 7_200, 10_600, 6_800, 11_200, 5_900]

    return JourneyPickerView()
        .environmentObject(JourneyProgressService(injectMockData: false))
        .environmentObject(viewModel)
}

#Preview("Catégorie avec 2 trajets terminés") {
    // Purge les clés persistées (UserDefaults.standard réel) pour garantir un état
    // reproductible : sans ça, une progression ou une complétion laissée par une
    // autre preview/exécution dans le même process serait rechargée.
    Preferences.shared.removeObject(.journeyProgressMap)
    Preferences.shared.removeObject(.completedJourneyIds)
    Preferences.shared.removeObject(.journeyCompletionDates)

    let walks = allJourneys.filter { $0.category == .walk }.prefix(2)
    let viewModel = StepCountViewModel()
    for journey in walks {
        viewModel.markJourneyCompleted(journey.id.uuidString)
    }

    return JourneyPickerView(initiallyExpandedCategories: [.walk])
        .environmentObject(JourneyProgressService(injectMockData: false))
        .environmentObject(viewModel)
}

#Preview("Avec trajet en cours (catégorie dépliée)") {
    let gr20 = allJourneys.first { $0.name.contains("GR20") } ?? allJourneys[5]
    let service = JourneyProgressService()
    service.startJourney(gr20)
    service.addKilometers(72, to: gr20)

    let viewModel = StepCountViewModel()
    // Historique de pas pour alimenter la moyenne (donc l'ETA de la card).
    viewModel.currentWeekSteps = [9_200, 11_400, 8_800, 10_100, 7_600, 12_300, 6_500]

    return JourneyPickerView()
        .environmentObject(service)
        .environmentObject(viewModel)
}
