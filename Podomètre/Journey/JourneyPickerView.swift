import SwiftUI

/// Vue catalogue des trajets disponibles, organisée par catégorie.
struct JourneyPickerView: View {
    @EnvironmentObject private var progressService: JourneyProgressService
    @EnvironmentObject private var stepViewModel: StepCountViewModel

    @State private var selectedJourney: Journey?
    /// Trajet dont on affiche la prévisualisation (nouveau ou déjà en cours).
    @State private var journeyToPreview: Journey?

    /// Ordre d'affichage des catégories.
    private let categoryOrder: [JourneyCategory] = [.walk, .trail, .history, .myth]

    /// Trajets groupés par catégorie.
    private var grouped: [JourneyCategory: [Journey]] {
        Dictionary(grouping: allJourneys, by: \.category)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24, pinnedViews: []) {
                    ForEach(categoryOrder, id: \.self) { category in
                        if let journeys = grouped[category] {
                            categorySection(category, journeys: journeys)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
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
                    requiresAbandon: progressService.hasActiveJourney(otherThan: journey)
                ) {
                    progressService.startJourney(journey)
                    selectedJourney = journey
                } onContinue: {
                    selectedJourney = journey
                }
            }
        }
    }

    // MARK: - Section catégorie

    @ViewBuilder
    private func categorySection(_ category: JourneyCategory, journeys: [Journey]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(category.rawValue.uppercased())
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.secondary)
                .kerning(1.2)

            ForEach(journeys) { journey in
                JourneyCard(
                    journey: journey,
                    progress: progressService.progress(for: journey),
                    isCompleted: stepViewModel.isJourneyCompleted(journey.id.uuidString),
                    ringColor: stepViewModel.ringColor,
                    onAction: { journeyToPreview = journey }
                )
            }
        }
    }
}

// MARK: - JourneyCard

/// Card d'un trajet dans le catalogue.
private struct JourneyCard: View {
    let journey: Journey
    let progress: JourneyProgress?
    let isCompleted: Bool
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
        VStack(alignment: .leading, spacing: 16) {

            HStack(alignment: .top, spacing: 14) {
                Text(journey.emoji)
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 4) {
                    Text(journey.name)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.primary)

                    Text(journey.subtitle)
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

            if isCompleted {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Terminé")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                }
                .foregroundStyle(ringColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(ringColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
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

                        Text(String(format: "%.1f / %.0f km", progress.totalKm, journey.totalKm))
                            .font(.caption2)
                            .foregroundStyle(Color.secondary)
                    }
                }

                Button(action: onAction) {
                    Text(hasProgress ? "Voir mes étapes" : "Voir le trajet")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(hasProgress ? ringColor : ringColor.opacity(0.12))
                        .foregroundStyle(hasProgress ? Color.white : ringColor)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .opacity(isCompleted ? 0.6 : 1.0)
    }
}

// MARK: - Preview

#Preview("Catalogue") {
    JourneyPickerView()
        .environmentObject(JourneyProgressService())
        .environmentObject(StepCountViewModel())
}

#Preview("Avec progression") {
    let service = JourneyProgressService()
    service.startJourney(allJourneys[0])
    service.addKilometers(72, to: allJourneys[0])
    return JourneyPickerView()
        .environmentObject(service)
        .environmentObject(StepCountViewModel())
}
