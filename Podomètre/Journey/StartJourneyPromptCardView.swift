import SwiftUI

/// Card d'incitation affichée en tête de l'écran Trajets quand aucun trajet n'est en cours.
///
/// Occupe la même place et les mêmes dimensions que `ActiveJourneyCardView` (padding, coins,
/// fond `secondarySystemBackground`) pour garder une mise en page stable entre les deux états.
/// Met en avant un trajet court pour débuter ; un tap ouvre sa prévisualisation.
struct StartJourneyPromptCardView: View {
    /// Trajet suggéré pour un premier départ (le plus court). Le tap ouvre sa preview.
    let suggestedJourney: Journey
    let ringColor: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 14) {

                // En-tête : icône + intitulé, aligné sur la card du trajet en cours.
                HStack(spacing: 12) {
                    Image(systemName: "map.fill")
                        .font(.title3)
                        .foregroundStyle(ringColor)
                        .frame(width: 40, height: 40)
                        .background(ringColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 1) {
                        Text("Aucun trajet en cours")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Color.secondary)
                            .textCase(.uppercase)
                        Text("Choisis ta destination")
                            .font(.system(.headline, design: .rounded))
                            .foregroundStyle(Color.primary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.secondary)
                        .accessibilityHidden(true)
                }

                Text("Transforme tes pas en aventure : chaque kilomètre parcouru débloque une nouvelle étape du trajet.")
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                // Appel à l'action : démarrer par le trajet suggéré (purement visuel,
                // c'est la card entière qui est le bouton).
                HStack(spacing: 8) {
                    Text(suggestedJourney.emoji)
                        .font(.subheadline)
                    Text("Débuter par « \(suggestedJourney.name) »")
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .lineLimit(1)
                    Spacer(minLength: 8)
                    Text(String(format: "%.0f km", suggestedJourney.totalKm))
                        .font(.caption.weight(.medium))
                }
                .foregroundStyle(ringColor)
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity)
                .background(ringColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                .accessibilityHidden(true)
            }
            .padding(16)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Aucun trajet en cours. Choisis ta destination pour transformer tes pas en aventure.")
        .accessibilityHint("Ouvre la prévisualisation du trajet « \(suggestedJourney.name) » pour débuter")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Preview

#Preview("Incitation — aucun trajet") {
    let suggested = allJourneys
        .filter { $0.category == .walk }
        .min { $0.totalKm < $1.totalKm } ?? allJourneys[0]

    return VStack {
        StartJourneyPromptCardView(
            suggestedJourney: suggested,
            ringColor: AppColors.ringColorOptions[0].color,
            onTap: {}
        )
        Spacer()
    }
    .padding()
}
