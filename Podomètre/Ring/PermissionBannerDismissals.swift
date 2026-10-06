import Foundation

/// Bannières et cartes d'autorisation de l'écran Activité que l'utilisateur peut masquer.
enum PermissionBanner: String, CaseIterable {
    case healthPermission, healthSteps, healthDistance, motion, locationPermission
}

/// Mémorise le masquage des bannières d'autorisation (`PreferenceKey.dismissedPermissionBanners`).
/// Une bannière masquée réapparaît après `redisplayDelay` : le problème n'est pas résolu et
/// l'utilisateur doit pouvoir le retrouver sans fouiller les Paramètres.
struct PermissionBannerDismissals {
    /// Délai avant qu'une bannière masquée ne réapparaisse (7 jours).
    static let redisplayDelay: TimeInterval = 7 * 24 * 60 * 60

    /// Date de masquage par bannière (`PermissionBanner.rawValue`).
    private(set) var dates: [String: Date]

    init(dates: [String: Date]) {
        self.dates = dates
    }

    /// Relit les masquages enregistrés (vide si rien n'est enregistré ou illisible).
    init(preferences: Preferences = .shared) {
        if let data = preferences.data(.dismissedPermissionBanners),
           let decoded = try? JSONDecoder().decode([String: Date].self, from: data) {
            dates = decoded
        } else {
            dates = [:]
        }
    }

    /// `true` si la bannière a été masquée il y a moins de `redisplayDelay`.
    func isDismissed(_ banner: PermissionBanner, now: Date = Date()) -> Bool {
        guard let date = dates[banner.rawValue] else { return false }
        return now.timeIntervalSince(date) < Self.redisplayDelay
    }

    /// Masque la bannière et persiste le choix.
    mutating func dismiss(_ banner: PermissionBanner, now: Date = Date(), preferences: Preferences = .shared) {
        dates[banner.rawValue] = now
        if let data = try? JSONEncoder().encode(dates) {
            preferences.set(data, for: .dismissedPermissionBanners)
        }
    }
}
