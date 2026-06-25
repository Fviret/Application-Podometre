import Foundation

// MARK: - Journey

/// Trajet virtuel que l'utilisateur parcourt grâce à ses pas quotidiens.
struct Journey: Codable, Identifiable, Equatable {
    let id: UUID
    /// Nom du trajet (ex. "Paris → Nice").
    let title: String
    /// Description courte affichée sous le titre.
    let subtitle: String
    /// Nom de l'image de couverture dans les Assets.
    let coverImageName: String
    /// Distance totale du trajet en kilomètres.
    let totalKm: Double
    /// Étapes jalonnant le trajet, triées par `kmFromStart`.
    let milestones: [Milestone]
}

// MARK: - Milestone

/// Étape intermédiaire sur un trajet, débloquée quand l'utilisateur atteint sa position.
struct Milestone: Codable, Identifiable, Equatable {
    let id: UUID
    /// Distance depuis le départ en kilomètres.
    let kmFromStart: Double
    /// Nom du lieu (ex. "Lyon").
    let locationName: String
    /// Courte description de l'ambiance / anecdote du lieu.
    let ambiance: String
    /// Nom de l'image illustrant ce lieu dans les Assets (optionnel).
    let imageName: String?
}

// MARK: - JourneyProgress

/// Progression de l'utilisateur sur un trajet donné.
/// Persistée en JSON via @AppStorage.
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

    /// Retourne le prochain `Milestone` non encore débloqué, trié par `kmFromStart`.
    /// Retourne `nil` si toutes les étapes sont débloquées.
    func nextMilestone(for progress: JourneyProgress) -> Milestone? {
        milestones
            .sorted { $0.kmFromStart < $1.kmFromStart }
            .first { !progress.unlockedMilestoneIds.contains($0.id) }
    }
}

// MARK: - Conversion pas → kilomètres

extension Int {
    /// Convertit un nombre de pas en kilomètres (1 pas = 0,0008 km).
    var asKilometers: Double { Double(self) * 0.0008 }
}
