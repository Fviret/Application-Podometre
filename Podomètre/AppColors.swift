import SwiftUI

/// Option de couleur sélectionnable pour l'anneau de progression.
struct RingColorOption: Identifiable {
    let id: String
    let name: String
    let color: Color
}

extension Color {
    /// Retourne une variante plus claire de la couleur (baisse la saturation, monte la luminosité).
    /// Utilisé pour l'arc de dépassement de l'anneau (teinte plus douce que la couleur de base).
    func lightened(by amount: Double = 0.25) -> Color {
        let ui = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard ui.getHue(&h, saturation: &s, brightness: &b, alpha: &a) else { return self }
        return Color(
            hue: Double(h),
            saturation: Double(max(s - amount, 0)),
            brightness: Double(min(b + amount * 0.35, 1)),
            opacity: Double(a)
        )
    }
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
