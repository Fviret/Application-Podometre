import Foundation
import Combine
import UserNotifications

/// Service en charge du recueil d'aphorismes et de la logique « pensée du jour ».
///
/// Charge le JSON du bundle une seule fois, expose l'aphorisme déterministe du jour
/// (basé sur le quantième de l'année) et arbitre l'affichage de la popup matinale.
final class AphorismManager: ObservableObject {

    /// Recueil complet chargé depuis le bundle. Vide si le fichier est absent/illisible.
    @Published private(set) var aphorisms: [Aphorism]

    private let preferences: Preferences
    private let calendar = Calendar.current
    private let notificationCenter = UNUserNotificationCenter.current()

    /// Identifiant du rappel de midi — réutilisé pour remplacer/annuler la notification en attente.
    private let noonReminderIdentifier = "aphorism-noon-reminder"

    /// - Parameters:
    ///   - aphorisms: recueil injecté (tests) ; si `nil`, chargé depuis `bundle`.
    ///   - preferences: store de persistance (injectable pour les tests).
    ///   - bundle: bundle où lire le JSON (défaut : `.main`).
    init(aphorisms: [Aphorism]? = nil, preferences: Preferences = .shared, bundle: Bundle = .main) {
        self.preferences = preferences
        self.aphorisms = aphorisms ?? Self.loadAphorisms(from: bundle)
    }

    /// Décode le recueil adapté à la langue de l'utilisateur depuis le bundle.
    /// Retourne `[]` en cas d'échec (pas de crash).
    static func loadAphorisms(from bundle: Bundle = .main) -> [Aphorism] {
        guard let url = bundle.url(forResource: resourceName(for: bundle), withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(AphorismData.self, from: data) else {
            return []
        }
        return decoded.aphorisms
    }

    /// Choisit le recueil à charger selon la langue la mieux adaptée parmi celles supportées
    /// par l'app (`preferredLocalizations`, pas `Locale.current` — respecte le repli d'Apple si
    /// la langue système n'est pas supportée). Anglais → recueil traduit ; tout le reste → français
    /// (langue source). Les deux recueils sont des œuvres du domaine public distinctes, pas des
    /// traductions l'un de l'autre — voir CLAUDE.md, section Localisation.
    private static func resourceName(for bundle: Bundle) -> String {
        let preferred = bundle.preferredLocalizations.first ?? "fr"
        return preferred.hasPrefix("en") ? "aphorisms_humor_en" : "aphorisms_humor_400"
    }

    /// Aphorisme correspondant à un quantième d'année donné (1...366), sélection déterministe.
    /// `nil` seulement si le recueil est vide. Exposé pour la testabilité.
    func aphorism(forDayOfYear day: Int) -> Aphorism? {
        guard !aphorisms.isEmpty else { return nil }
        let index = ((day - 1) % aphorisms.count + aphorisms.count) % aphorisms.count
        return aphorisms[index]
    }

    /// Aphorisme du jour, sélectionné de façon déterministe via le quantième de l'année.
    /// Stable sur une journée entière ; `nil` seulement si le recueil est vide.
    var todayAphorism: Aphorism? {
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return aphorism(forDayOfYear: dayOfYear)
    }

    /// Indique si l'utilisateur a activé la pensée du jour (défaut : activé).
    var isEnabled: Bool {
        if !preferences.hasValue(.aphorismPopupEnabled) { return true }
        return preferences.bool(.aphorismPopupEnabled)
    }

    /// Vrai si la popup doit s'afficher : fonctionnalité activée, recueil chargé,
    /// et aucune popup déjà affichée aujourd'hui.
    func shouldShowPopup() -> Bool {
        guard isEnabled, todayAphorism != nil else { return false }
        guard let last = preferences.date(.lastAphorismDisplayDate) else {
            return true
        }
        return !calendar.isDateInToday(last)
    }

    /// Mémorise que la popup a été affichée aujourd'hui (garde max 1x/jour).
    func markAphorismDisplayed() {
        preferences.set(Date(), for: .lastAphorismDisplayDate)
    }

    /// Réinitialise la garde quotidienne : permet de revoir la popup aujourd'hui.
    /// Appelé quand l'utilisateur réactive la pensée du jour dans les Paramètres.
    func resetDailyGuard() {
        preferences.removeObject(.lastAphorismDisplayDate)
    }

    // MARK: - Rappel de midi

    /// (Re)programme le rappel de midi pour **demain**, ou l'annule si la fonctionnalité est
    /// désactivée ou si le recueil n'a rien à proposer ce jour-là.
    ///
    /// Appelé à chaque ouverture de l'app (`onAppear` + retour au premier plan) : l'app venant
    /// d'être ouverte aujourd'hui, aucun rappel n'a de sens pour aujourd'hui — seul celui de
    /// demain est utile, au cas où l'utilisateur ne rouvrirait pas l'app avant midi ce jour-là.
    /// Un rappel de midi ne peut donc jamais être en attente pour le jour courant : la condition
    /// « app déjà ouverte aujourd'hui → pas de notification » est ainsi automatiquement respectée.
    func scheduleNoonReminderIfNeeded() async {
        guard isEnabled else {
            cancelNoonReminder()
            return
        }

        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let tomorrowDayOfYear = calendar.ordinality(of: .day, in: .year, for: tomorrow) ?? 1
        guard aphorism(forDayOfYear: tomorrowDayOfYear) != nil else {
            cancelNoonReminder()
            return
        }

        if await notificationCenter.notificationSettings().authorizationStatus == .notDetermined {
            try? await notificationCenter.requestAuthorization(options: [.alert, .sound])
        }
        guard await notificationCenter.notificationSettings().authorizationStatus == .authorized else { return }

        var components = calendar.dateComponents([.year, .month, .day], from: tomorrow)
        components.hour = 12
        components.minute = 0

        let content = UNMutableNotificationContent()
        content.title = "Pensée du jour"
        content.body = "Une nouvelle pensée t'attend aujourd'hui."
        content.sound = .default

        // Même identifiant à chaque appel : remplace automatiquement le rappel précédemment
        // programmé (pas besoin de l'annuler explicitement avant de reprogrammer).
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: noonReminderIdentifier, content: content, trigger: trigger)
        try? await notificationCenter.add(request)
    }

    /// Annule le rappel de midi programmé, s'il y en a un. Appelé quand l'utilisateur
    /// désactive la pensée du jour dans les Paramètres.
    func cancelNoonReminder() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [noonReminderIdentifier])
    }
}

extension AphorismManager {
    /// Instance de prévisualisation avec le recueil réel chargé depuis le bundle.
    static var preview: AphorismManager { AphorismManager() }
}
