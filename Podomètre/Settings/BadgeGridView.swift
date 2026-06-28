import SwiftUI

/// Grille de badges affichant d'abord les badges de seuils de pas, puis les trajets.
struct BadgeGridView: View {
    @ObservedObject var viewModel: StepCountViewModel

    private let columns = Array(repeating: GridItem(.flexible()), count: 3)

    var body: some View {
        VStack(spacing: 16) {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(BadgeData.stepMilestoneBadges) { badge in
                    StepMilestoneBadgeCell(
                        badge: badge,
                        count: viewModel.milestoneCounts[badge.id] ?? 0,
                        viewModel: viewModel
                    )
                }
            }

            Color.secondary.opacity(0.15)
                .frame(height: 0.5)
                .accessibilityHidden(true)

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(allJourneys) { journey in
                    BadgeCellView(
                        journey: journey,
                        isUnlocked: viewModel.isJourneyCompleted(journey.id.uuidString),
                        viewModel: viewModel
                    )
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - StepMilestoneBadgeCell

/// Cellule d'un badge de seuil de pas : cercle avec le nombre de jours atteints + libellé.
struct StepMilestoneBadgeCell: View {
    let badge: StepMilestoneBadge
    let count: Int
    @ObservedObject var viewModel: StepCountViewModel

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showAlert = false
    private var isUnlocked: Bool { count > 0 }

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(isUnlocked
                          ? viewModel.ringColor.opacity(0.15)
                          : Color.secondary.opacity(0.08))
                    .frame(width: 52, height: 52)

                Text("\(count)")
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundStyle(isUnlocked ? viewModel.ringColor : Color.secondary.opacity(0.35))
            }
            .shadow(
                color: isUnlocked ? viewModel.ringColor.opacity(0.3) : .clear,
                radius: 6, x: 0, y: 0
            )
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: isUnlocked)

            Text(badge.label)
                .font(.caption2)
                .foregroundStyle(isUnlocked ? Color.primary : Color.secondary)
                .opacity(isUnlocked ? 1 : 0.4)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isUnlocked
            ? "\(badge.label), atteint \(count) fois"
            : "\(badge.label), jamais atteint")
        .accessibilityAddTraits(isUnlocked ? .isButton : [])
        .onTapGesture { if isUnlocked { showAlert = true } }
        .alert(badge.label, isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Vous avez réussi ce défi \(count) fois !")
        }
    }
}

// MARK: - BadgeCellView

/// Cellule d'un badge de trajet : emoji du trajet + nom, coloré si débloqué, grisé sinon.
struct BadgeCellView: View {
    let journey: Journey
    let isUnlocked: Bool
    @ObservedObject var viewModel: StepCountViewModel

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 4) {
            Text(journey.emoji)
                .font(.system(size: 36))
                .accessibilityHidden(true)
                .shadow(
                    color: isUnlocked ? viewModel.ringColor.opacity(0.5) : .clear,
                    radius: 8, x: 0, y: 0
                )
                .grayscale(isUnlocked ? 0 : 1)
                .opacity(isUnlocked ? 1 : 0.35)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: isUnlocked)

            Text(journey.name)
                .font(.caption2)
                .foregroundStyle(isUnlocked ? Color.primary : Color.secondary)
                .opacity(isUnlocked ? 1 : 0.4)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isUnlocked
            ? "\(journey.name), trajet terminé"
            : "\(journey.name), trajet non terminé")
    }
}

// MARK: - Preview

#Preview("Badges — seuils + 3 trajets débloqués") {
    let viewModel = StepCountViewModel()
    viewModel.milestoneCounts = ["5k": 47, "10k": 23, "20k": 4, "30k": 1, "50k": 0, "100k": 0]
    allJourneys.prefix(3).forEach { viewModel.markJourneyCompleted($0.id.uuidString) }
    return List {
        Section("Badges") {
            BadgeGridView(viewModel: viewModel)
        }
    }
}
