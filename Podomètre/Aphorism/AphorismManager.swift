import Foundation
import Combine

/// Clé UserDefaults : active/désactive la pensée du jour (popup + carte).
let aphorismEnabledKey = "aphorismPopupEnabled"
/// Clé UserDefaults : date du dernier affichage de la popup (garde 1x/jour).
let aphorismLastDisplayKey = "lastAphorismDisplayDate"

/// Service en charge du recueil d'aphorismes et de la logique « pensée du jour ».
///
/// Charge le JSON du bundle une seule fois, expose l'aphorisme déterministe du jour
/// (basé sur le quantième de l'année) et arbitre l'affichage de la popup matinale.
final class AphorismManager: ObservableObject {

    /// Recueil complet chargé depuis le bundle. Vide si le fichier est absent/illisible.
    @Published private(set) var aphorisms: [Aphorism]

    private let defaults: UserDefaults
    private let calendar = Calendar.current

    /// - Parameters:
    ///   - aphorisms: recueil injecté (tests) ; si `nil`, chargé depuis `bundle`.
    ///   - defaults: store de persistance (injectable pour les tests).
    ///   - bundle: bundle où lire le JSON (défaut : `.main`).
    init(aphorisms: [Aphorism]? = nil, defaults: UserDefaults = .standard, bundle: Bundle = .main) {
        self.defaults = defaults
        self.aphorisms = aphorisms ?? Self.loadAphorisms(from: bundle)
    }

    /// Décode `aphorisms_humor_400.json` depuis le bundle. Retourne `[]` en cas d'échec (pas de crash).
    static func loadAphorisms(from bundle: Bundle = .main) -> [Aphorism] {
        guard let url = bundle.url(forResource: "aphorisms_humor_400", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(AphorismData.self, from: data) else {
            return []
        }
        return decoded.aphorisms
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
        if defaults.object(forKey: aphorismEnabledKey) == nil { return true }
        return defaults.bool(forKey: aphorismEnabledKey)
    }

    /// Vrai si la popup doit s'afficher : fonctionnalité activée, recueil chargé,
    /// et aucune popup déjà affichée aujourd'hui.
    func shouldShowPopup() -> Bool {
        guard isEnabled, todayAphorism != nil else { return false }
        guard let last = defaults.object(forKey: aphorismLastDisplayKey) as? Date else {
            return true
        }
        return !calendar.isDateInToday(last)
    }

    /// Mémorise que la popup a été affichée aujourd'hui (garde max 1x/jour).
    func markAphorismDisplayed() {
        defaults.set(Date(), forKey: aphorismLastDisplayKey)
    }
}

extension AphorismManager {
    /// Instance de prévisualisation avec le recueil réel chargé depuis le bundle.
    static var preview: AphorismManager { AphorismManager() }
}
