import SwiftUI

/// Sheet de prévisualisation d'un trajet.
/// Affiche les étapes dans l'ordre et propose le bouton de démarrage en bas.
struct JourneyPreviewSheet: View {
    let journey: Journey
    /// `true` si ce trajet est déjà en cours de progression.
    let isInProgress: Bool
    /// `true` si un autre trajet est actif — "Commencer" affichera une confirmation d'abandon.
    let requiresAbandon: Bool
    /// Jalons déjà débloqués — cercles remplis dans la timeline.
    var unlockedMilestoneIds: Set<UUID> = []
    /// Appelé quand l'utilisateur démarre ce trajet pour la première fois (ou après abandon confirmé).
    let onStart: () -> Void
    /// Appelé quand l'utilisateur reprend un trajet déjà en cours.
    let onContinue: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showAbandonAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    headerSection
                    milestonesSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.secondary)
                            .padding(8)
                            .background(Color.secondary.opacity(0.12))
                            .clipShape(Circle())
                    }
                }
            }
            .overlay(alignment: .bottom) {
                bottomAction
            }
            .alert("Trajet en cours", isPresented: $showAbandonAlert) {
                Button("Annuler ce trajet", role: .destructive) {
                    dismiss()
                    onStart()
                }
                Button("Garder mon trajet", role: .cancel) {}
            } message: {
                Text("Vous avez déjà un trajet en cours. Voulez-vous l'annuler pour commencer celui-ci ? (L'avancée sera perdue)")
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 14) {
                Text(journey.emoji)
                    .font(.largeTitle)
                    .frame(width: 56, height: 56)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 4) {
                    Text(journey.name)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.primary)

                    Text(journey.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                }
            }

            HStack(spacing: 20) {
                statBadge(icon: "arrow.left.and.right", value: String(format: "%.0f km", journey.totalKm))
                statBadge(icon: "mappin.circle", value: "\(journey.milestones.count) étapes")
                statBadge(icon: "tag", value: journey.category.rawValue)
            }
            .padding(.top, 4)
        }
    }

    private func statBadge(icon: String, value: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption2)
            Text(value)
                .font(.caption)
        }
        .foregroundStyle(Color.secondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.secondary.opacity(0.08))
        .clipShape(Capsule())
    }

    // MARK: - Liste des étapes

    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Étapes du trajet")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.secondary)
                .kerning(0.8)
                .padding(.bottom, 14)

            ForEach(Array(journey.sortedMilestones.enumerated()), id: \.offset) { index, milestone in
                MilestonePreviewRow(
                    milestone: milestone,
                    index: index,
                    isUnlocked: unlockedMilestoneIds.contains(milestone.id),
                    isLast: index == journey.sortedMilestones.count - 1
                )
            }
        }
    }

    // MARK: - Bouton principal

    private var bottomAction: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Color(.systemBackground).opacity(0), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 24)

            Button {
                if isInProgress {
                    // Trajet déjà en cours — bouton sans action
                } else if requiresAbandon {
                    showAbandonAlert = true
                } else {
                    dismiss()
                    onStart()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: isInProgress ? "checkmark.circle.fill" : "play.fill")
                        .font(.subheadline)
                    Text(isInProgress ? "Trajet en cours" : "Commencer le trajet")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isInProgress ? Color.secondary.opacity(0.2) : Color.accentColor)
                .foregroundStyle(isInProgress ? Color.secondary : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(isInProgress)
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
            .background(Color(.systemBackground))
        }
    }
}

// MARK: - MilestonePreviewRow

/// Ligne de la timeline de prévisualisation.
private struct MilestonePreviewRow: View {
    let milestone: Milestone
    let index: Int
    let isUnlocked: Bool
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {

            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(isUnlocked ? Color.accentColor : Color.clear)
                        .frame(width: 28, height: 28)

                    Circle()
                        .strokeBorder(Color.accentColor.opacity(isUnlocked ? 1 : 0.4), lineWidth: 1.5)
                        .frame(width: 28, height: 28)

                    if isUnlocked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.white)
                    } else {
                        Text("\(index + 1)")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.accentColor)
                    }
                }
                .padding(.top, 2)

                if !isLast {
                    Rectangle()
                        .fill(Color.accentColor.opacity(0.15))
                        .frame(width: 1.5)
                        .frame(minHeight: 44)
                }
            }
            .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(milestone.label)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.primary)

                    Spacer()

                    Text(String(format: "%.0f km", milestone.km))
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                }

                Text(milestone.description)
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.bottom, isLast ? 0 : 20)
        }
    }
}

// MARK: - Preview

#Preview("Nouveau trajet") {
    JourneyPreviewSheet(
        journey: allJourneys[0],
        isInProgress: false,
        requiresAbandon: false,
        onStart: {},
        onContinue: {}
    )
}

#Preview("Trajet en cours") {
    JourneyPreviewSheet(
        journey: allJourneys[0],
        isInProgress: true,
        requiresAbandon: false,
        onStart: {},
        onContinue: {}
    )
}

#Preview("Abandon requis") {
    JourneyPreviewSheet(
        journey: allJourneys[1],
        isInProgress: false,
        requiresAbandon: true,
        onStart: {},
        onContinue: {}
    )
}
