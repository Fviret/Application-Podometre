import SwiftUI

/// Vue catalogue des trajets disponibles.
/// Permet de commencer ou continuer un trajet, avec confirmation si un autre est en cours.
struct JourneyPickerView: View {
    @EnvironmentObject private var progressService: JourneyProgressService

    /// Trajet sélectionné pour navigation vers le détail.
    @State private var selectedJourney: Journey?
    /// Trajet en attente de confirmation avant démarrage (abandon d'un trajet en cours).
    @State private var journeyPendingConfirmation: Journey?
    /// Contrôle l'affichage de l'alert de confirmation.
    @State private var showAbandonAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(allJourneys) { journey in
                        JourneyCard(
                            journey: journey,
                            progress: progressService.progress(for: journey),
                            onAction: { handleAction(for: journey) }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .navigationTitle("Trajets")
            .navigationDestination(item: $selectedJourney) { journey in
                JourneyDetailView(journey: journey)
            }
            .alert("Abandonner le trajet en cours ?", isPresented: $showAbandonAlert) {
                Button("Abandonner", role: .destructive) {
                    if let journey = journeyPendingConfirmation {
                        progressService.startJourney(journey)
                        selectedJourney = journey
                    }
                    journeyPendingConfirmation = nil
                }
                Button("Annuler", role: .cancel) {
                    journeyPendingConfirmation = nil
                }
            } message: {
                Text("Ta progression actuelle sera perdue.")
            }
        }
    }

    /// Décide si on démarre directement, demande confirmation, ou reprend un trajet existant.
    private func handleAction(for journey: Journey) {
        let hasProgress = progressService.progress(for: journey) != nil
        if hasProgress {
            selectedJourney = journey
        } else if progressService.hasActiveJourney(otherThan: journey) {
            journeyPendingConfirmation = journey
            showAbandonAlert = true
        } else {
            progressService.startJourney(journey)
            selectedJourney = journey
        }
    }
}

// MARK: - JourneyCard

/// Card d'un trajet dans le catalogue.
private struct JourneyCard: View {
    let journey: Journey
    let progress: JourneyProgress?
    let onAction: () -> Void

    /// Pourcentage de progression entre 0 et 1.
    private var progressPercent: Double {
        journey.progressPercent(for: progress ?? JourneyProgress(
            journeyId: journey.id, totalKm: 0,
            unlockedMilestoneIds: [], startDate: Date(), lastUpdatedDate: Date()
        ))
    }

    private var hasProgress: Bool { progress != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // En-tête
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "map")
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 44, height: 44)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 4) {
                    Text(journey.title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.primary)

                    Text(journey.subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                        .lineLimit(2)
                }

                Spacer()
            }

            // Métadonnées
            HStack(spacing: 16) {
                Label(String(format: "%.0f km", journey.totalKm), systemImage: "arrow.left.and.right")
                    .font(.caption)
                    .foregroundStyle(Color.secondary)

                Label("\(journey.milestones.count) étapes", systemImage: "mappin.circle")
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
            }

            // Progression (si trajet commencé)
            if let progress {
                VStack(alignment: .leading, spacing: 6) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.secondary.opacity(0.15))
                                .frame(height: 6)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.accentColor)
                                .frame(width: geo.size.width * progressPercent, height: 6)
                        }
                    }
                    .frame(height: 6)

                    Text(String(format: "%.1f km parcourus sur %.0f", progress.totalKm, journey.totalKm))
                        .font(.caption2)
                        .foregroundStyle(Color.secondary)
                }
            }

            // Bouton d'action
            Button(action: onAction) {
                HStack {
                    Image(systemName: hasProgress ? "figure.walk" : "play.fill")
                        .font(.caption)
                    Text(hasProgress ? "Continuer" : "Commencer")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(hasProgress ? Color.accentColor : Color.accentColor.opacity(0.12))
                .foregroundStyle(hasProgress ? Color.white : Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Preview

#Preview("Sans progression") {
    JourneyPickerView()
        .environmentObject(JourneyProgressService())
}

#Preview("Avec progression") {
    let service = JourneyProgressService()
    service.startJourney(allJourneys[0])
    service.addKilometers(312, to: allJourneys[0])
    return JourneyPickerView()
        .environmentObject(service)
}
