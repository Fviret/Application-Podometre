import Foundation

/// Représente un seuil de pas quotidiens à atteindre pour débloquer un badge.
struct StepMilestoneBadge: Identifiable {
    let id: String
    /// Nombre de pas requis en une seule journée pour compter une occurrence.
    let threshold: Int
    /// Libellé affiché sous le badge.
    let label: String
    /// Nom d'un asset image à afficher à la place du cercle générique (optionnel).
    let imageName: String?

    init(id: String, threshold: Int, label: String, imageName: String? = nil) {
        self.id = id
        self.threshold = threshold
        self.label = label
        self.imageName = imageName
    }
}

enum BadgeData {
    // Chaque badge peut porter sa propre illustration via `imageName`.
    // Tant que les assets dédiés (logo_10k, logo_20k, …) ne sont pas fournis,
    // tous pointent vers `logo_5k` : il suffira de remplacer le nom au fur et à mesure.
    static let stepMilestoneBadges: [StepMilestoneBadge] = [
        StepMilestoneBadge(id: "5k",   threshold: 5_000,   label: "5 000 pas",   imageName: "logo_5k"),
        StepMilestoneBadge(id: "10k",  threshold: 10_000,  label: "10 000 pas",  imageName: "logo_5k"),
        StepMilestoneBadge(id: "20k",  threshold: 20_000,  label: "20 000 pas",  imageName: "logo_5k"),
        StepMilestoneBadge(id: "30k",  threshold: 30_000,  label: "30 000 pas",  imageName: "logo_5k"),
        StepMilestoneBadge(id: "50k",  threshold: 50_000,  label: "50 000 pas",  imageName: "logo_5k"),
        StepMilestoneBadge(id: "100k", threshold: 100_000, label: "100 000 pas", imageName: "logo_5k"),
    ]
}
