import SwiftUI

/// Permet d'utiliser `@AppStorage(.isDarkMode)` au lieu de `@AppStorage("isDarkMode")`,
/// avec une clé typée issue de `PreferenceKey` (fini les chaînes en dur dans les Views).
extension AppStorage {
    init(wrappedValue: Value, _ key: PreferenceKey, store: UserDefaults? = nil) where Value == Bool {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

    init(wrappedValue: Value, _ key: PreferenceKey, store: UserDefaults? = nil) where Value == Int {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

    init(wrappedValue: Value, _ key: PreferenceKey, store: UserDefaults? = nil) where Value == String {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

    init(wrappedValue: Value, _ key: PreferenceKey, store: UserDefaults? = nil) where Value == Data {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }
}
