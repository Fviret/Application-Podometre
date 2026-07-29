import SwiftUI

/// Section Paramètres « Pensée du jour » : toggle d'activation + carte de l'aphorisme du jour.
///
/// Reçoit l'`AphorismManager` partagé pour afficher l'aphorisme courant.
struct AphorismSettingsView: View {
    @ObservedObject var manager: AphorismManager
    @AppStorage(.aphorismPopupEnabled) private var aphorismEnabled: Bool = true

    var body: some View {
        Section("Pensée du jour") {
            Toggle(isOn: $aphorismEnabled) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Afficher la pensée du jour")
                    Text("Une pensée s'affiche à la première ouverture du jour, avec un rappel à midi si l'app n'a pas encore été ouverte")
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                }
            }
            .accessibilityIdentifier("aphorism_toggle")
            .accessibilityLabel("Afficher la pensée du jour")
            .onChange(of: aphorismEnabled) { _, enabled in
                if enabled {
                    // Réactiver la pensée du jour réarme la garde pour la revoir aujourd'hui.
                    manager.resetDailyGuard()
                    Task { await manager.scheduleNoonReminderIfNeeded() }
                } else {
                    manager.cancelNoonReminder()
                }
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
