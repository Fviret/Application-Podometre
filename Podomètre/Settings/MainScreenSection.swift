import Foundation

/// Sections optionnelles affichées sous l'anneau sur l'écran Activité.
/// L'ordre d'affichage est choisi par l'utilisateur (Paramètres > Écran principal, réorganisable).
enum MainScreenSection: String, CaseIterable, Codable, Identifiable, Hashable {
    case todayMetrics
    case weather
    case monthCalendar
    case weeklyChart

    var id: String { rawValue }

    /// Libellé affiché dans la liste réorganisable des Paramètres.
    var title: String {
        switch self {
        case .todayMetrics: return "Distance · temps actif · calories"
        case .weather: return "Météo & prévisions"
        case .monthCalendar: return "Calendrier mensuel"
        case .weeklyChart: return "Graphe hebdomadaire"
        }
    }

    /// Ordre par défaut, identique à l'ordre historique fixe de l'écran Activité.
    static let defaultOrder: [MainScreenSection] = [.todayMetrics, .weather, .monthCalendar, .weeklyChart]

    /// Décode l'ordre persisté ; retombe sur `defaultOrder` si absent, invalide, ou incomplet
    /// (ex. après l'ajout d'une nouvelle section future non encore présente dans la donnée sauvegardée).
    static func decode(_ data: Data) -> [MainScreenSection] {
        guard let decoded = try? JSONDecoder().decode([MainScreenSection].self, from: data),
              Set(decoded) == Set(allCases)
        else { return defaultOrder }
        return decoded
    }

    static func encode(_ order: [MainScreenSection]) -> Data {
        (try? JSONEncoder().encode(order)) ?? Data()
    }
}
