import UserNotifications

/// Gère les notifications locales liées aux trajets virtuels.
@MainActor
class JourneyNotificationService {

    private let center = UNUserNotificationCenter.current()

    // MARK: - Autorisation

    /// Demande l'autorisation d'envoyer des notifications si elle n'a pas encore été accordée.
    func requestAuthorization() async {
        guard await authorizationStatus() == .notDetermined else { return }
        try? await center.requestAuthorization(options: [.alert, .sound])
    }

    // MARK: - Envoi

    /// Envoie une notification immédiate pour chaque étape nouvellement débloquée.
    func notifyUnlockedMilestones(_ milestones: [Milestone], journey: Journey) async {
        guard await authorizationStatus() == .authorized else { return }

        for (index, milestone) in milestones.enumerated() {
            let isJourneyComplete = milestone.kmFromStart >= journey.totalKm

            let content = UNMutableNotificationContent()
            content.sound = .default

            if isJourneyComplete {
                content.title = "Trajet terminé ! 🏁"
                content.body = "Tu as complété \(journey.title) en marchant \(String(format: "%.0f", journey.totalKm)) km. Bravo !"
            } else {
                content.title = "Nouvelle étape débloquée !"
                content.body = "\(milestone.locationName) — \(milestone.ambiance.prefix(80))…"
            }

            // Décalage d'une seconde entre chaque notification si plusieurs d'un coup
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(index + 1), repeats: false)
            let request = UNNotificationRequest(
                identifier: "milestone-\(milestone.id.uuidString)",
                content: content,
                trigger: trigger
            )
            try? await center.add(request)
        }
    }

    // MARK: - Privé

    private func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }
}
