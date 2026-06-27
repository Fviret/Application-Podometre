import SwiftUI

/// Grille de badges affichant tous les trajets disponibles.
/// Un badge est coloré quand le trajet correspondant a été entièrement complété.
struct BadgeGridView: View {
    @ObservedObject var viewModel: StepCountViewModel

    private let columns = Array(repeating: GridItem(.flexible()), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(allJourneys) { journey in
                BadgeCellView(
                    journey: journey,
                    isUnlocked: viewModel.isJourneyCompleted(journey.id.uuidString),
                    viewModel: viewModel
                )
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - BadgeCellView

/// Cellule d'un badge : emoji du trajet + nom, coloré si débloqué, grisé sinon.
struct BadgeCellView: View {
    let journey: Journey
    let isUnlocked: Bool
    @ObservedObject var viewModel: StepCountViewModel

    var body: some View {
        VStack(spacing: 4) {
            Text(journey.emoji)
                .font(.system(size: 36))
                .shadow(
                    color: isUnlocked ? viewModel.ringColor.opacity(0.5) : .clear,
                    radius: 8, x: 0, y: 0
                )
                .grayscale(isUnlocked ? 0 : 1)
                .opacity(isUnlocked ? 1 : 0.35)
                .animation(.easeInOut(duration: 0.3), value: isUnlocked)

            Text(journey.name)
                .font(.caption2)
                .foregroundStyle(isUnlocked ? Color.primary : Color.secondary)
                .opacity(isUnlocked ? 1 : 0.4)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview("Badges — 3 débloqués") {
    let viewModel = StepCountViewModel()
    allJourneys.prefix(3).forEach { viewModel.markJourneyCompleted($0.id.uuidString) }
    return List {
        Section("Badges") {
            BadgeGridView(viewModel: viewModel)
        }
    }
}
