import SwiftUI

/// Carte affichée dans la section météo quand l'accès à la position a été refusé : explique
/// pourquoi aucune prévision n'apparaît, et propose d'ouvrir les Réglages ou de masquer la
/// section (le réglage « Météo & prévisions » reste modifiable dans les Paramètres).
struct LocationDeniedCardView: View {
    let color: Color
    let onHide: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "location.slash.fill")
                    .font(.title3)
                    .foregroundStyle(.orange)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Localisation désactivée")
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(Color.primary)
                    Text("Autorisez la position approximative dans les Réglages pour afficher la météo, ou masquez cette section.")
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack(spacing: 12) {
                Spacer(minLength: 0)
                Button("Masquer la météo", action: onHide)
                    .buttonStyle(.bordered)
                    .tint(.secondary)
                Button("Réglages") { SystemSettings.openApp() }
                    .buttonStyle(.borderedProminent)
                    .tint(color)
            }
            .font(.system(.subheadline, design: .rounded).weight(.semibold))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 24)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("location_denied_card")
    }
}

#Preview {
    LocationDeniedCardView(color: .green) {}
}
