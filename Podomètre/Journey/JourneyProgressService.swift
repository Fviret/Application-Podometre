import Foundation
import Combine

/// Service gérant la persistance et la mise à jour de la progression sur les trajets.
/// Exposé via @EnvironmentObject — une seule instance partagée dans l'app.
@MainActor
class JourneyProgressService: ObservableObject {

    /// Clé UserDefaults utilisée pour persister le dictionnaire de progressions.
    private let storageKey = "journeyProgressMap"

    /// Toutes les progressions indexées par journeyId.
    @Published private(set) var progressMap: [UUID: JourneyProgress] = [:]

    init() {
        load()
    }

    // MARK: - Lecture

    /// Retourne la progression pour un trajet donné, ou nil si jamais commencé.
    func progress(for journey: Journey) -> JourneyProgress? {
        progressMap[journey.id]
    }

    /// Retourne true si un trajet autre que `journey` est actuellement en cours.
    func hasActiveJourney(other than journey: Journey) -> Bool {
        progressMap.keys.contains { $0 != journey.id }
    }

    // MARK: - Écriture

    /// Démarre un nouveau trajet en écrasant toute progression existante sur tous les autres.
    func startJourney(_ journey: Journey) {
        progressMap = [
            journey.id: JourneyProgress(
                journeyId: journey.id,
                totalKm: 0,
                unlockedMilestoneIds: [],
                startDate: Date(),
                lastUpdatedDate: Date()
            )
        ]
        save()
    }

    /// Ajoute des kilomètres à la progression du trajet actif et débloque les étapes franchies.
    func addKilometers(_ km: Double, to journey: Journey) {
        guard var progress = progressMap[journey.id] else { return }

        progress.totalKm += km
        progress.lastUpdatedDate = Date()

        let newlyUnlocked = journey.milestones.filter {
            $0.kmFromStart <= progress.totalKm &&
            !progress.unlockedMilestoneIds.contains($0.id)
        }
        for milestone in newlyUnlocked {
            progress.unlockedMilestoneIds.insert(milestone.id)
        }

        progressMap[journey.id] = progress
        save()
    }

    // MARK: - Persistance

    /// Charge les progressions depuis UserDefaults.
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([UUID: JourneyProgress].self, from: data)
        else { return }
        progressMap = decoded
    }

    /// Sauvegarde les progressions dans UserDefaults.
    private func save() {
        guard let encoded = try? JSONEncoder().encode(progressMap) else { return }
        UserDefaults.standard.set(encoded, forKey: storageKey)
    }
}
