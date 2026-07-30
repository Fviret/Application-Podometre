import SwiftUI

/// Représente un seuil de pas quotidiens à atteindre pour débloquer un badge.
struct StepMilestoneBadge: Identifiable {
    let id: String
    /// Nombre de pas requis en une seule journée pour compter une occurrence.
    let threshold: Int
    /// Libellé affiché sous le badge.
    let label: String
    /// Nom d'un asset image à afficher à la place du cercle générique (optionnel).
    let imageName: String?
    /// Couleur d'accent du badge (compteur, halo, cercle générique).
    /// Indépendante de la couleur de l'anneau : la personnalisation n'y touche pas.
    let tint: Color

    init(id: String, threshold: Int, label: String, imageName: String? = nil, tint: Color = .accentColor) {
        self.id = id
        self.threshold = threshold
        self.label = label
        self.imageName = imageName
        self.tint = tint
    }

    /// Titre affiché sous l'image, ex. « Objectif 5 K ».
    var title: String {
        "Objectif \(threshold / 1000) K"
    }

    /// Couleur de texte lisible par-dessus `tint` : noir sur les teintes claires,
    /// blanc sur les foncées. Le blanc systématique tombait sous le ratio de
    /// contraste minimal sur l'orange et le vert clair.
    var onTintColor: Color {
        UIColor(tint).relativeLuminance > 0.179 ? .black : .white
    }
}

private extension UIColor {
    /// Luminance relative (WCAG) — sert à choisir un texte noir ou blanc.
    var relativeLuminance: CGFloat {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        func linear(_ c: CGFloat) -> CGFloat {
            c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linear(r) + 0.7152 * linear(g) + 0.0722 * linear(b)
    }
}

enum BadgeData {
    // Chaque badge peut porter sa propre illustration (`imageName`) et sa propre couleur (`tint`).
    // Ces couleurs sont fixes et NE dépendent PAS de la couleur d'anneau choisie dans les réglages :
    // pour changer le fond/accent d'un badge, il suffit de modifier son `tint` ci-dessous.
    static let stepMilestoneBadges: [StepMilestoneBadge] = [
        StepMilestoneBadge(id: "5k",   threshold: 5_000,   label: "5 000 pas",   tint: Color(red: 0.20, green: 0.78, blue: 0.35)),
        StepMilestoneBadge(id: "10k",  threshold: 10_000,  label: "10 000 pas",  tint: Color(red: 0.20, green: 0.60, blue: 0.95)),
        StepMilestoneBadge(id: "20k",  threshold: 20_000,  label: "20 000 pas",  tint: Color(red: 0.15, green: 0.80, blue: 0.75)),
        StepMilestoneBadge(id: "30k",  threshold: 30_000,  label: "30 000 pas",  tint: Color(red: 1.00, green: 0.62, blue: 0.10)),
        StepMilestoneBadge(id: "50k",  threshold: 50_000,  label: "50 000 pas",  tint: Color(red: 0.65, green: 0.30, blue: 0.95)),
        StepMilestoneBadge(id: "100k", threshold: 100_000, label: "100 000 pas", tint: Color(red: 0.95, green: 0.25, blue: 0.30)),
    ]
}
