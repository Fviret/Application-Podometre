import Foundation

// MARK: - JourneyCategory

/// Catégorie thématique d'un trajet.
enum JourneyCategory: String, Codable, CaseIterable {
    case trail   = "Sentiers"
    case history = "Histoire"
    case myth    = "Mythes & Épopées"
}

// MARK: - Journey

/// Trajet virtuel que l'utilisateur parcourt grâce à ses pas quotidiens.
struct Journey: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    /// Nom du trajet (ex. "GR20 complet").
    let name: String
    /// Description courte affichée sous le titre.
    let subtitle: String
    /// Distance totale du trajet en kilomètres.
    let totalKm: Double
    /// Catégorie thématique du trajet.
    let category: JourneyCategory
    /// Emoji représentant le trajet (un seul caractère).
    let emoji: String
    /// Étapes jalonnant le trajet, triées par `km`.
    let milestones: [Milestone]
}

// MARK: - Milestone

/// Étape intermédiaire sur un trajet, débloquée quand l'utilisateur atteint sa position.
struct Milestone: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    /// Distance depuis le départ en kilomètres.
    let km: Double
    /// Nom du lieu ou de l'événement.
    let label: String
    /// Une ou deux phrases de contexte sur cette étape.
    let description: String
}

// MARK: - JourneyProgress

/// Progression de l'utilisateur sur un trajet donné.
/// Persistée en JSON dans UserDefaults.
struct JourneyProgress: Codable, Identifiable, Equatable {
    /// Identifiant du `Journey` associé.
    let journeyId: UUID

    var id: UUID { journeyId }

    /// Kilométrage total parcouru depuis le début du trajet.
    var totalKm: Double
    /// Identifiants des étapes déjà débloquées.
    var unlockedMilestoneIds: Set<UUID>
    /// Date de démarrage du trajet.
    let startDate: Date
    /// Date de la dernière mise à jour de la progression.
    var lastUpdatedDate: Date
}

// MARK: - Journey + Progress extensions

extension Journey {

    /// Retourne la progression entre 0.0 et 1.0 pour un état de progression donné.
    func progressPercent(for progress: JourneyProgress) -> Double {
        guard totalKm > 0 else { return 0 }
        return min(progress.totalKm / totalKm, 1.0)
    }

    /// Retourne le prochain `Milestone` non encore débloqué, trié par `km`.
    /// Retourne `nil` si toutes les étapes sont débloquées.
    func nextMilestone(for progress: JourneyProgress) -> Milestone? {
        milestones
            .sorted { $0.km < $1.km }
            .first { !progress.unlockedMilestoneIds.contains($0.id) }
    }

    /// Retourne les jalons triés par distance croissante.
    var sortedMilestones: [Milestone] {
        milestones.sorted { $0.km < $1.km }
    }
}

// MARK: - Conversion pas → kilomètres

extension Int {
    /// Convertit un nombre de pas en kilomètres (1 pas = 0,0008 km).
    var asKilometers: Double { Double(self) * 0.0008 }
}
