import SwiftUI

/// Section Paramètres « Pensée du jour » : toggle d'activation + carte de l'aphorisme du jour.
///
/// Reçoit l'`AphorismManager` partagé pour afficher l'aphorisme courant.
struct AphorismSettingsView: View {
    @ObservedObject var manager: AphorismManager
    @AppStorage(aphorismEnabledKey) private var aphorismEnabled: Bool = true

    var body: some View {
        Section("Pensée du jour") {
            Toggle(isOn: $aphorismEnabled) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Afficher la pensée du jour")
                    Text("Une pensée s'affiche à la première ouverture du jour")
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                }
            }
            .accessibilityIdentifier("aphorism_toggle")
            .accessibilityLabel("Afficher la pensée du jour")
            .onChange(of: aphorismEnabled) { _, enabled in
                // Réactiver la pensée du jour réarme la garde pour la revoir aujourd'hui.
                if enabled { manager.resetDailyGuard() }
            }

            if let aphorism = manager.todayAphorism {
                AphorismCardView(aphorism: aphorism)
                    .padding(.vertical, 4)
            }
        }
    }
}

#Preview {
    List {
        AphorismSettingsView(manager: .preview)
    }
}
