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

    /// Taille du logo du badge — ajuster ici pour toute la grille des seuils.
    private let badgeSize: CGFloat = 92

    var body: some View {
        VStack(spacing: 6) {
            badgeVisual
                .frame(width: badgeSize, height: badgeSize)
                .shadow(
                    color: isUnlocked ? badge.tint.opacity(0.3) : .clear,
                    radius: 6, x: 0, y: 0
                )
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: isUnlocked)

            // Titre du badge (ex. « Objectif 5 K »).
            Text(badge.title)
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundStyle(isUnlocked ? Color.primary : Color.secondary)
                .opacity(isUnlocked ? 1 : 0.5)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            // Pastille du nombre de réussites — masquée tant que l'objectif n'a jamais été atteint.
            if isUnlocked {
                Text("\(count) x")
                    .font(.system(.caption2, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(badge.tint, in: Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isUnlocked
            ? "\(badge.label), atteint \(count) fois"
            : "\(badge.label), jamais atteint")
        .accessibilityAddTraits(isUnlocked ? .isButton : [])
        .onTapGesture { if isUnlocked { showAlert = true } }
        .sheet(isPresented: $showAlert) {
            detailSheet
                .presentationDetents([.height(380)])
                .presentationDragIndicator(.visible)
        }
    }

    /// Modale affichée au tap sur un badge débloqué : image, titre centré et compteur.
    private var detailSheet: some View {
        VStack(spacing: 18) {
            badgeVisual
                .frame(width: 120, height: 120)
                .shadow(color: badge.tint.opacity(0.35), radius: 10, x: 0, y: 0)

            Text(badge.title)
                .font(.system(.title2, design: .rounded).weight(.bold))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            Text("\(count) x")
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 5)
                .background(badge.tint, in: Capsule())

            Text("Objectif de \(badge.label) atteint en une seule journée, réussi \(count) fois.")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 28)
        .padding(.top, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    /// Visuel du badge : image dédiée si `imageName` est défini, sinon cercle générique avec le compteur.
    @ViewBuilder
    private var badgeVisual: some View {
        if let imageName = badge.imageName {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .grayscale(isUnlocked ? 0 : 1)
                .opacity(isUnlocked ? 1 : 0.35)
        } else {
            ZStack {
                Circle()
                    .fill(isUnlocked
                          ? badge.tint.opacity(0.15)
                          : Color.secondary.opacity(0.08))

                Text("\(count)")
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundStyle(isUnlocked ? badge.tint : Color.secondary.opacity(0.35))
            }
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

#Preview("Badges — tous débloqués") {
    let viewModel = StepCountViewModel()
    viewModel.milestoneCounts = ["5k": 128, "10k": 64, "20k": 12, "30k": 5, "50k": 2, "100k": 1]
    allJourneys.forEach { viewModel.markJourneyCompleted($0.id.uuidString) }
    return List {
        Section("Badges") {
            BadgeGridView(viewModel: viewModel)
        }
    }
}

#Preview("Badges — tous verrouillés") {
    let viewModel = StepCountViewModel()
    viewModel.milestoneCounts = ["5k": 0, "10k": 0, "20k": 0, "30k": 0, "50k": 0, "100k": 0]
    return List {
        Section("Badges") {
            BadgeGridView(viewModel: viewModel)
        }
    }
}

#Preview("Badge 5k — verrouillé vs débloqué") {
    let unlockedVM = StepCountViewModel()
    unlockedVM.milestoneCounts = ["5k": 47]
    let lockedVM = StepCountViewModel()
    lockedVM.milestoneCounts = ["5k": 0]
    let badge = BadgeData.stepMilestoneBadges[0] // 5k, illustré (logo_5k)

    return HStack(spacing: 40) {
        VStack {
            StepMilestoneBadgeCell(badge: badge, count: 47, viewModel: unlockedVM)
            Text("Débloqué").font(.caption2).foregroundStyle(.secondary)
        }
        VStack {
            StepMilestoneBadgeCell(badge: badge, count: 0, viewModel: lockedVM)
            Text("Verrouillé").font(.caption2).foregroundStyle(.secondary)
        }
    }
    .padding(40)
}
