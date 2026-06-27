import Foundation

/// Représente un seuil de pas quotidiens à atteindre pour débloquer un badge.
struct StepMilestoneBadge: Identifiable {
    let id: String
    /// Nombre de pas requis en une seule journée pour compter une occurrence.
    let threshold: Int
    /// Libellé affiché sous le badge.
    let label: String
}

enum BadgeData {
    static let stepMilestoneBadges: [StepMilestoneBadge] = [
        StepMilestoneBadge(id: "5k",   threshold: 5_000,   label: "5 000 pas"),
        StepMilestoneBadge(id: "10k",  threshold: 10_000,  label: "10 000 pas"),
        StepMilestoneBadge(id: "20k",  threshold: 20_000,  label: "20 000 pas"),
        StepMilestoneBadge(id: "30k",  threshold: 30_000,  label: "30 000 pas"),
        StepMilestoneBadge(id: "50k",  threshold: 50_000,  label: "50 000 pas"),
        StepMilestoneBadge(id: "100k", threshold: 100_000, label: "100 000 pas"),
    ]
}
