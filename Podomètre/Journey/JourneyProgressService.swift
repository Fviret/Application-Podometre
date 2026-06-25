import Foundation
import Combine
import HealthKit

/// Service gérant la persistance et la mise à jour de la progression sur les trajets.
/// Exposé via @EnvironmentObject — une seule instance partagée dans l'app.
@MainActor
class JourneyProgressService: ObservableObject {

    /// Clé UserDefaults utilisée pour persister le dictionnaire de progressions.
    private let storageKey = "journeyProgressMap"

    private let healthStore = HKHealthStore()

    /// Toutes les progressions indexées par journeyId.
    @Published private(set) var progressMap: [UUID: JourneyProgress] = [:]

    /// Étapes nouvellement débloquées lors du dernier sync — consommées par la vue pour afficher une sheet.
    @Published var newlyUnlockedMilestones: [Milestone] = []

    init() {
        load()
    }

    // MARK: - Lecture

    /// Retourne la progression pour un trajet donné, ou nil si jamais commencé.
    func progress(for journey: Journey) -> JourneyProgress? {
        progressMap[journey.id]
    }

    /// Retourne true si un trajet autre que `journey` est actuellement en cours.
    func hasActiveJourney(otherThan journey: Journey) -> Bool {
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

    /// Ajoute des kilomètres à la progression du trajet actif et détecte les nouvelles étapes débloquées.
    func addKilometers(_ km: Double, to journey: Journey) {
        guard var progress = progressMap[journey.id] else { return }

        progress.totalKm += km
        progress.lastUpdatedDate = Date()

        let unlocked = journey.milestones.filter {
            $0.kmFromStart <= progress.totalKm &&
            !progress.unlockedMilestoneIds.contains($0.id)
        }
        for milestone in unlocked {
            progress.unlockedMilestoneIds.insert(milestone.id)
        }
        newlyUnlockedMilestones = unlocked.sorted { $0.kmFromStart < $1.kmFromStart }

        progressMap[journey.id] = progress
        save()
    }

    /// Synchronise la progression du trajet avec le nombre total de pas marchés depuis le démarrage.
    /// Requête HealthKit idempotente : `totalKm` est recalculé depuis la date de départ, pas incrémenté.
    func syncTodaySteps(for journey: Journey) async {
        guard var progress = progressMap[journey.id] else { return }

        let totalSteps = await fetchSteps(from: progress.startDate)
        guard totalSteps > 0 else { return }

        let newTotalKm = Double(totalSteps) * 0.0008
        guard newTotalKm > progress.totalKm else { return }

        let addedKm = newTotalKm - progress.totalKm
        progress.totalKm = newTotalKm
        progress.lastUpdatedDate = Date()

        let unlocked = journey.milestones.filter {
            $0.kmFromStart <= newTotalKm &&
            !progress.unlockedMilestoneIds.contains($0.id)
        }
        for milestone in unlocked {
            progress.unlockedMilestoneIds.insert(milestone.id)
        }

        let _ = addedKm
        newlyUnlockedMilestones = unlocked.sorted { $0.kmFromStart < $1.kmFromStart }

        progressMap[journey.id] = progress
        save()
    }

    /// Vide la liste des étapes nouvellement débloquées après traitement par la vue.
    func clearNewlyUnlocked() {
        newlyUnlockedMilestones = []
    }

    // MARK: - HealthKit

    /// Retourne le nombre total de pas entre `startDate` et maintenant.
    private func fetchSteps(from startDate: Date) async -> Int {
        #if targetEnvironment(simulator)
        return 94_000
        #else
        guard HKHealthStore.isHealthDataAvailable(),
              let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)
        else { return 0 }

        return await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
            let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                let steps = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                continuation.resume(returning: Int(steps))
            }
            healthStore.execute(query)
        }
        #endif
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
