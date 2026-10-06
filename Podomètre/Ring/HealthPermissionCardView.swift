import SwiftUI

/// Carte d'invitation affichée sur l'écran Activité tant que l'utilisateur n'a pas répondu au prompt
/// Santé (onboarding passé avec « Plus tard »). Remplace un anneau à 0 muet par une action claire ;
/// le tap présente le prompt système, puis les données s'affichent sans rafraîchissement manuel.
struct HealthPermissionCardView: View {
    let color: Color
    let action: () -> Void
    /// Si fourni, affiche une croix pour masquer la carte.
    var onDismiss: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "heart.fill")
                    .font(.title3)
                    .foregroundStyle(.red)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Autorisez l'accès à Santé pour afficher vos pas")
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(Color.primary)
                    Text("Podomètre lit uniquement vos pas et votre distance. Ces données restent sur votre iPhone.")
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

            Button("Autoriser l'accès", action: action)
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .buttonStyle(.borderedProminent)
                .tint(color)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("health_permission_card")
    }
}

#Preview {
    HealthPermissionCardView(color: .green) {}
}
