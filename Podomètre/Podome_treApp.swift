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
    private func applyUITestingOverrides() {
        let env = ProcessInfo.processInfo.environment
        if env["RESET_ONBOARDING"] == "1" {
            UserDefaults.standard.set(false, forKey: onboardingCompletedKey)
        }
        if env["SKIP_ONBOARDING"] == "1" {
            UserDefaults.standard.set(true, forKey: onboardingCompletedKey)
        }
    }
}
