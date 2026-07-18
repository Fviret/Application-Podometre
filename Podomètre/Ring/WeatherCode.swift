import Foundation

/// Emoji météo correspondant à un code WMO (Open-Meteo).
func weatherEmoji(for code: Int) -> String {
    switch code {
    case 0:        return "☀️"
    case 1:        return "🌤️"
    case 2:        return "⛅"
    case 3:        return "☁️"
    case 45, 48:   return "🌫️"
    case 51, 53, 55, 56, 57: return "🌦️"
    case 61, 63, 65: return "🌧️"
    case 66, 67:   return "🌨️"
    case 71, 73, 75, 77: return "❄️"
    case 80, 81, 82: return "🌧️"
    case 85, 86:   return "🌨️"
    case 95:       return "⛈️"
    case 96, 99:   return "⛈️"
    default:       return "🌡️"
    }
}

/// Description textuelle (minuscule) d'un code météo WMO — pour VoiceOver.
func weatherDescription(for code: Int) -> String {
    switch code {
    case 0:        return "ciel dégagé"
    case 1:        return "principalement dégagé"
    case 2:        return "partiellement nuageux"
    case 3:        return "couvert"
    case 45, 48:   return "brouillard"
    case 51...57:  return "bruine"
    case 61, 63, 65: return "pluie"
    case 66, 67:   return "pluie verglaçante"
    case 71, 73, 75, 77: return "neige"
    case 80, 81, 82: return "averses"
    case 85, 86:   return "averses de neige"
    case 95, 96, 99: return "orages"
    default:       return "conditions variables"
    }
}

/// Libellé de condition avec majuscule initiale — pour l'en-tête du détail météo.
func weatherLabel(for code: Int) -> String {
    let description = weatherDescription(for: code)
    return description.prefix(1).uppercased() + description.dropFirst()
}
