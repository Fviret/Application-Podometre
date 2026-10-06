import UIKit

/// Accès aux Réglages iOS de l'app, pour les bannières et cartes qui invitent à rétablir une
/// autorisation refusée.
enum SystemSettings {
    /// Ouvre la page de Réglages de Podomètre (Santé, position, notifications…).
    static func openApp() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
