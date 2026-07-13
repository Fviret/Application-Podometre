import Foundation

/// Petit service typé au-dessus de `UserDefaults`, indexé par `PreferenceKey`.
///
/// Objectif : supprimer les chaînes de clés en dur des ViewModels/services et offrir
/// un point d'injection unique (testable via `Preferences(defaults:)`).
/// Les Views continuent d'utiliser `@AppStorage(_ key: PreferenceKey)` (cf. extension dédiée).
final class Preferences {
    /// Instance partagée adossée à `UserDefaults.standard`.
    static let shared = Preferences()

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Lecture

    func bool(_ key: PreferenceKey) -> Bool { defaults.bool(forKey: key.rawValue) }
    func integer(_ key: PreferenceKey) -> Int { defaults.integer(forKey: key.rawValue) }
    func string(_ key: PreferenceKey) -> String? { defaults.string(forKey: key.rawValue) }
    func stringArray(_ key: PreferenceKey) -> [String]? { defaults.stringArray(forKey: key.rawValue) }
    func data(_ key: PreferenceKey) -> Data? { defaults.data(forKey: key.rawValue) }
    func date(_ key: PreferenceKey) -> Date? { defaults.object(forKey: key.rawValue) as? Date }

    /// `true` si une valeur a déjà été écrite pour cette clé (utile pour distinguer « non défini » de « false »).
    func hasValue(_ key: PreferenceKey) -> Bool { defaults.object(forKey: key.rawValue) != nil }

    // MARK: - Écriture

    func set(_ value: Bool, for key: PreferenceKey) { defaults.set(value, forKey: key.rawValue) }
    func set(_ value: Int, for key: PreferenceKey) { defaults.set(value, forKey: key.rawValue) }
    func set(_ value: String, for key: PreferenceKey) { defaults.set(value, forKey: key.rawValue) }
    func set(_ value: [String], for key: PreferenceKey) { defaults.set(value, forKey: key.rawValue) }
    func set(_ value: Data, for key: PreferenceKey) { defaults.set(value, forKey: key.rawValue) }
    func set(_ value: Date, for key: PreferenceKey) { defaults.set(value, forKey: key.rawValue) }

    func removeObject(_ key: PreferenceKey) { defaults.removeObject(forKey: key.rawValue) }
}
