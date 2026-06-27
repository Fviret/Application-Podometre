import SwiftUI

/// Option de couleur sélectionnable pour l'anneau de progression.
struct RingColorOption: Identifiable {
    let id: String
    let name: String
    let color: Color
}

/// Palette de couleurs disponibles pour personnaliser l'anneau.
enum AppColors {
    static let ringColorOptions: [RingColorOption] = [
        RingColorOption(id: "green",  name: "Forêt",  color: Color(red: 0.20, green: 0.78, blue: 0.35)),
        RingColorOption(id: "blue",   name: "Océan",  color: Color(red: 0.20, green: 0.60, blue: 0.95)),
        RingColorOption(id: "orange", name: "Soleil", color: Color(red: 1.00, green: 0.62, blue: 0.10)),
        RingColorOption(id: "red",    name: "Corail", color: Color(red: 0.95, green: 0.25, blue: 0.30)),
        RingColorOption(id: "purple", name: "Violet", color: Color(red: 0.65, green: 0.30, blue: 0.95)),
        RingColorOption(id: "teal",   name: "Glace",  color: Color(red: 0.15, green: 0.80, blue: 0.75)),
    ]
}
