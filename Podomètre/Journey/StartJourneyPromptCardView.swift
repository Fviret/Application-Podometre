import SwiftUI

/// Card explicative affichée en tête de l'écran Trajets quand aucun trajet n'est en cours.
///
/// Occupe la même place et les mêmes dimensions que `ActiveJourneyCardView` (padding, coins,
/// fond `secondarySystemBackground`) pour garder une mise en page stable entre les deux états.
/// Invite simplement à choisir un trajet dans le catalogue affiché en dessous.
struct StartJourneyPromptCardView: View {
    let ringColor: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "map.fill")
                .font(.title3)
                .foregroundStyle(ringColor)
                .frame(width: 44, height: 44)
                .background(ringColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text("Aucun trajet en cours")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Color.primary)
                Text("Choisissez votre prochain trajet ci-dessous.")
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Preview

#Preview("Incitation — aucun trajet") {
    VStack {
        StartJourneyPromptCardView(ringColor: AppColors.ringColorOptions[0].color)
        Spacer()
    }
    .padding()
}
