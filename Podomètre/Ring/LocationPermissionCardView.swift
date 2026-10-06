import SwiftUI

/// Carte affichée dans la section météo tant que l'accès à la position n'a pas été décidé
/// (« Plus tard » à l'onboarding). La localisation n'est demandée qu'à ce moment, dans son
/// contexte : les prévisions près de chez soi.
struct LocationPermissionCardView: View {
    let color: Color
    let action: () -> Void
    /// Si fourni, affiche une croix pour masquer la carte.
    var onDismiss: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "location.fill")
                    .font(.title3)
                    .foregroundStyle(color)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Météo près de chez vous")
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(Color.primary)
                    Text("Autorisez la localisation approximative pour afficher les prévisions.")
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let onDismiss {
                    Spacer(minLength: 0)
                    DismissButton(action: onDismiss)
                        .padding(.top, -12)
                        .padding(.trailing, -12)
                }
            }

            Button("Autoriser la localisation", action: action)
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .buttonStyle(.borderedProminent)
                .tint(color)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 24)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("location_permission_card")
    }
}

#Preview {
    LocationPermissionCardView(color: .green) {}
}
