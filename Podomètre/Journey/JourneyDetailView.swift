import SwiftUI

/// Vue de détail d'un trajet — affiche la progression globale, la prochaine étape et la timeline des jalons.
struct JourneyDetailView: View {
    let journey: Journey

    @EnvironmentObject private var progressService: JourneyProgressService

    /// Étape sélectionnée pour affichage dans la sheet de détail.
    @State private var selectedMilestone: Milestone?

    private var progress: JourneyProgress? {
        progressService.progress(for: journey)
    }

    private var progressPercent: Double {
        guard let p = progress else { return 0 }
        return journey.progressPercent(for: p)
    }

    private var sortedMilestones: [Milestone] {
        journey.milestones.sorted { $0.kmFromStart < $1.kmFromStart }
    }

    /// Dernier jalon débloqué (pour l'ancrage du ScrollView).
    private var lastUnlockedIndex: Int? {
        guard let p = progress else { return nil }
        let indices = sortedMilestones.indices.filter { p.unlockedMilestoneIds.contains(sortedMilestones[$0].id) }
        return indices.last
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    headerSection
                    timelineSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .navigationTitle(journey.title)
            .navigationBarTitleDisplayMode(.large)
            .task {
                await progressService.syncTodaySteps(for: journey)
                if let idx = lastUnlockedIndex {
                    withAnimation {
                        proxy.scrollTo("milestone-\(idx)", anchor: .center)
                    }
                }
            }
            .onChange(of: progressService.newlyUnlockedMilestones) { _, milestones in
                if let first = milestones.first {
                    selectedMilestone = first
                }
            }
            .sheet(item: $selectedMilestone, onDismiss: {
                progressService.clearNewlyUnlocked()
            }) { milestone in
                MilestoneDetailSheet(milestone: milestone)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Kilométrage global
            if let p = progress {
                VStack(alignment: .leading, spacing: 6) {
                    Text(String(format: "%.1f km parcourus sur %.0f km total", p.totalKm, journey.totalKm))
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.secondary)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.secondary.opacity(0.15))
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.accentColor)
                                .frame(width: geo.size.width * progressPercent, height: 8)
                        }
                    }
                    .frame(height: 8)

                    Text(String(format: "%.0f %%", progressPercent * 100))
                        .font(.caption2)
                        .foregroundStyle(Color.secondary)
                }
            }

            // Prochaine étape
            if let p = progress, let next = journey.nextMilestone(for: p) {
                let remaining = next.kmFromStart - p.totalKm
                HStack(spacing: 10) {
                    Image(systemName: "flag.fill")
                        .font(.caption)
                        .foregroundStyle(Color.accentColor)

                    Text("Prochaine étape : **\(next.locationName)** dans \(String(format: "%.1f", max(remaining, 0))) km")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(Color.primary)
                }
                .padding(12)
                .background(Color.accentColor.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    // MARK: - Timeline

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(sortedMilestones.enumerated()), id: \.offset) { index, milestone in
                let isUnlocked = progress?.unlockedMilestoneIds.contains(milestone.id) ?? false
                let isLast = index == sortedMilestones.count - 1

                MilestoneRow(
                    milestone: milestone,
                    isUnlocked: isUnlocked,
                    isLast: isLast,
                    onTap: { if isUnlocked { selectedMilestone = milestone } }
                )
                .id("milestone-\(index)")
            }
        }
    }
}

// MARK: - MilestoneRow

/// Ligne de la timeline représentant un jalon débloqué ou verrouillé.
private struct MilestoneRow: View {
    let milestone: Milestone
    let isUnlocked: Bool
    let isLast: Bool
    let onTap: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 14) {

            // Colonne indicateur + trait
            VStack(spacing: 0) {
                Circle()
                    .fill(isUnlocked ? Color.accentColor : Color.clear)
                    .overlay(
                        Circle()
                            .strokeBorder(isUnlocked ? Color.accentColor : Color.secondary.opacity(0.4), lineWidth: 2)
                    )
                    .frame(width: 20, height: 20)
                    .padding(.top, 2)

                if !isLast {
                    Rectangle()
                        .fill(isUnlocked ? Color.accentColor.opacity(0.3) : Color.secondary.opacity(0.15))
                        .frame(width: 2)
                        .frame(minHeight: 40)
                }
            }
            .frame(width: 20)

            // Contenu
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(milestone.locationName)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(isUnlocked ? Color.primary : Color.secondary)

                    if isUnlocked {
                        Text(milestone.ambiance)
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    } else {
                        Text(String(format: "%.0f km depuis le départ", milestone.kmFromStart))
                            .font(.caption)
                            .foregroundStyle(Color.secondary.opacity(0.6))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, isLast ? 0 : 20)
            }
            .buttonStyle(.plain)
            .disabled(!isUnlocked)
        }
    }
}

// MARK: - MilestoneDetailSheet

/// Sheet modale affichant le texte d'ambiance complet d'une étape débloquée.
private struct MilestoneDetailSheet: View {
    let milestone: Milestone
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(milestone.locationName)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.primary)

                    Text(milestone.ambiance)
                        .font(.system(size: 16, design: .serif))
                        .foregroundStyle(Color.primary)
                        .lineSpacing(6)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 28)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("40% progression") {
    let service = JourneyProgressService()
    let journey = allJourneys[0]
    service.startJourney(journey)
    service.addKilometers(372, to: journey) // ~40% de 930 km

    return NavigationStack {
        JourneyDetailView(journey: journey)
            .environmentObject(service)
    }
}
