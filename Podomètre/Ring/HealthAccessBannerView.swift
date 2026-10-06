import SwiftUI

/// Bannière affichée sur l'écran Activité quand l'app ne reçoit aucun pas alors que le prompt
/// HealthKit a déjà été présenté — cas d'un accès en lecture refusé.
///
/// Invite l'utilisateur à rétablir l'accès depuis les Réglages. Non bloquante : l'app reste
/// utilisable (trajets, pensée du jour) même sans données de santé.
struct HealthAccessBannerView: View {

    /// Donnée Santé manquante à signaler.
    enum Kind {
        /// Aucun pas lisible : accès aux pas refusé.
        case steps
        /// Pas lisibles mais aucune distance : les trajets ne progressent pas.
        case distance

        var title: LocalizedStringKey {
            switch self {
            case .steps: "Accès à vos pas désactivé"
            case .distance: "Accès à la distance désactivé"
            }
        }

        var message: LocalizedStringKey {
            switch self {
            case .steps: "Autorisez Podomètre à lire vos pas dans les Réglages pour suivre votre progression."
            case .distance: "Autorisez la distance de marche et de course dans les Réglages : sans elle, vos trajets ne progressent pas."
            }
        }

        var hint: LocalizedStringKey {
            switch self {
            case .steps: "Ouvre les Réglages pour autoriser l'accès à vos pas"
            case .distance: "Ouvre les Réglages pour autoriser l'accès à la distance"
            }
        }
    }

    var kind: Kind = .steps

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "heart.slash.fill")
                .font(.title3)
                .foregroundStyle(.orange)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(kind.title)
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color.primary)
                Text(kind.message)
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Button("Réglages") {
                SystemSettings.openApp()
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
        .accessibilityHint(kind.hint)
    }
}

#Preview {
    VStack {
        HealthAccessBannerView()
        HealthAccessBannerView(kind: .distance)
        Spacer()
    }
}
