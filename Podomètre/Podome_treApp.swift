import SwiftUI
import UserNotifications

/// Délégué de notification : affiche les bannières même quand l'app est au premier plan.
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}

@main
struct Podome_treApp: App {
    private let notificationDelegate = NotificationDelegate()
    @StateObject private var viewModel = StepCountViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
        applyUITestingOverrides()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .fullScreenCover(isPresented: .constant(!hasCompletedOnboarding)) {
                    OnboardingView(viewModel: viewModel)
                }
        }
    }

    /// Applique les overrides UserDefaults demandés par les UI tests via les variables d'environnement.
    /// Sans effet en usage normal (aucune variable définie).
    private func applyUITestingOverrides() {
        let env = ProcessInfo.processInfo.environment
        let defaults = UserDefaults.standard

        if env["RESET_ONBOARDING"] == "1" {
            defaults.set(false, forKey: onboardingCompletedKey)
        }
        if env["SKIP_ONBOARDING"] == "1" {
            defaults.set(true, forKey: onboardingCompletedKey)
        }
        // Réinitialise l'état « pensée du jour » pour forcer l'affichage de la popup.
        if env["RESET_APHORISM"] == "1" {
            defaults.removeObject(forKey: aphorismLastDisplayKey)
            defaults.set(true, forKey: aphorismEnabledKey)
        }
        // Désactive la pensée du jour (popup ne doit jamais s'afficher).
        if env["DISABLE_APHORISM"] == "1" {
            defaults.set(false, forKey: aphorismEnabledKey)
        }
    }
}
