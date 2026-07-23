import SwiftUI

/// Bannière affichée sur l'écran Activité quand l'app ne reçoit aucun pas alors que le prompt
/// HealthKit a déjà été présenté — cas d'un accès en lecture refusé.
///
/// Invite l'utilisateur à rétablir l'accès depuis les Réglages. Non bloquante : l'app reste
/// utilisable (trajets, pensée du jour) même sans données de santé.
struct HealthAccessBannerView: View {

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "heart.slash.fill")
                .font(.title3)
                .foregroundStyle(.orange)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text("Accès à vos pas désactivé")
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color.primary)
                Text("Autorisez Podomètre à lire vos pas dans les Réglages pour suivre votre progression.")
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Button("Réglages") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .font(.system(.subheadline, design: .rounded).weight(.semibold))
            .buttonStyle(.borderedProminent)
            .tint(.orange)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .accessibilityElement(children: .combine)
        .accessibilityHint("Ouvre les Réglages pour autoriser l'accès à vos pas")
    }
}

#Preview {
    VStack {
        HealthAccessBannerView()
        Spacer()
    }
}
