import Foundation
import Combine
import HealthKit
import UserNotifications

/// Service gérant la persistance et la mise à jour de la progression sur les trajets.
/// Exposé via @EnvironmentObject — une seule instance partagée dans l'app.
@MainActor
class JourneyProgressService: ObservableObject {

    /// Clé UserDefaults utilisée pour persister le dictionnaire de progressions.
    private let storageKey = "journeyProgressMap"

    private let healthStore = HKHealthStore()
    private let notificationService = JourneyNotificationService()
    private var distanceObserverQuery: HKObserverQuery?

    /// Appelé quand un trajet est entièrement complété — permet de notifier StepCountViewModel.
    var onJourneyCompleted: ((String) -> Void)?

    /// Active les notifications (synchronisé depuis StepCountViewModel via ContentView).
    var notificationsEnabled: Bool = true

    /// Toutes les progressions indexées par journeyId.
    @Published private(set) var progressMap: [UUID: JourneyProgress] = [:]

    /// Étapes nouvellement débloquées lors du dernier sync — consommées par la vue pour afficher une sheet.
    @Published var newlyUnlockedMilestones: [Milestone] = []

    init() {
        load()
        #if targetEnvironment(simulator)
        loadMockData()
        #else
        if UserDefaults.standard.bool(forKey: onboardingCompletedKey) {
            startObservingDistance()
        }
        #endif
    }

    /// Démarre l'observation HealthKit si l'onboarding est terminé.
    /// À appeler depuis ContentView une fois hasCompletedOnboarding passé à true.
    func startIfNeeded() {
        #if !targetEnvironment(simulator)
        guard UserDefaults.standard.bool(forKey: onboardingCompletedKey) else { return }
        startObservingDistance()
        #endif
    }

    deinit {
        if let query = distanceObserverQuery {
            healthStore.stop(query)
        }
    }

    /// Installe un HKObserverQuery sur distanceWalkingRunning.
    /// Déclenche syncDistance pour le trajet actif à chaque nouveau sample enregistré par HealthKit.
    private func startObservingDistance() {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else { return }

        distanceObserverQuery = HKObserverQuery(sampleType: distanceType, predicate: nil) { [weak self] _, _, _ in
            Task { @MainActor in
                guard let self else { return }
                guard let journey = self.progressMap.keys.first.flatMap({ id in
                    allJourneys.first { $0.id == id }
                }) else { return }
                await self.syncDistance(for: journey)
            }
        }

        if let query = distanceObserverQuery {
            healthStore.execute(query)
        }
    }

    /// Injecte des données fictives pour tester l'interface sur simulateur.
    /// - Un trajet en cours (GR20) à mi-chemin avec 2 étapes débloquées
    /// - Un trajet terminé (Promenade 5k) pour afficher le badge
    private func loadMockData() {
        guard let gr20 = allJourneys.first(where: { $0.name == "GR20 complet" }),
              let berges = allJourneys.first(where: { $0.name == "Berges de la Seine" })
        else { return }

        // Trajet en cours : GR20 à ~55% (99 km sur 180)
        let activeKm = gr20.totalKm * 0.55
        let unlockedIds = Set(gr20.sortedMilestones.filter { $0.km <= activeKm }.map(\.id))
        progressMap[gr20.id] = JourneyProgress(
            journeyId: gr20.id,
            totalKm: activeKm,
            unlockedMilestoneIds: unlockedIds,
            startDate: Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date(),
            lastUpdatedDate: Date()
        )

        // Trajet terminé : Berges de la Seine (5 km) — pour tester l'état "Terminé"
        progressMap[berges.id] = JourneyProgress(
            journeyId: berges.id,
            totalKm: berges.totalKm,
            unlockedMilestoneIds: Set(berges.milestones.map(\.id)),
            startDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
            lastUpdatedDate: Date()
        )
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
    /// Demande l'autorisation de notifications au premier démarrage.
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
        Task { await notificationService.requestAuthorization() }
    }

    /// Ajoute des kilomètres à la progression du trajet actif et détecte les nouvelles étapes débloquées.
    func addKilometers(_ km: Double, to journey: Journey) {
        guard var progress = progressMap[journey.id] else { return }

        progress.totalKm += km
        progress.lastUpdatedDate = Date()

        let unlocked = detectUnlocked(in: &progress, for: journey, upTo: progress.totalKm)
        newlyUnlockedMilestones = unlocked

        progressMap[journey.id] = progress
        save()

        if !unlocked.isEmpty {
            Task { await notificationService.notifyUnlockedMilestones(unlocked, journey: journey) }
        }
    }

    /// Synchronise la progression du trajet avec la distance réelle marchée/courrue depuis le démarrage.
    /// Requête HealthKit idempotente : `totalKm` est recalculé depuis `startDate`, jamais incrémenté.
    func syncDistance(for journey: Journey) async {
        guard var progress = progressMap[journey.id] else { return }

        let newTotalKm = await fetchDistance(from: progress.startDate)
        guard newTotalKm > progress.totalKm else { return }

        progress.totalKm = newTotalKm
        progress.lastUpdatedDate = Date()

        let unlocked = detectUnlocked(in: &progress, for: journey, upTo: newTotalKm)
        newlyUnlockedMilestones = unlocked

        progressMap[journey.id] = progress
        save()

        if !unlocked.isEmpty {
            await notificationService.notifyUnlockedMilestones(unlocked, journey: journey)
        }

        if newTotalKm >= journey.totalKm {
            checkJourneyCompletion(journey)
        }
    }

    /// Vérifie si le trajet est terminé et déclenche la complétion (badge + notification).
    private func checkJourneyCompletion(_ journey: Journey) {
        guard let progress = progressMap[journey.id] else { return }
        guard progress.totalKm >= journey.totalKm else { return }

        let journeyIdStr = journey.id.uuidString
        onJourneyCompleted?(journeyIdStr)

        progressMap.removeValue(forKey: journey.id)
        save()

        if notificationsEnabled {
            sendJourneyCompletedNotification(journey: journey)
        }
    }

    /// Envoie une notification locale de fin de trajet.
    private func sendJourneyCompletedNotification(journey: Journey) {
        let content = UNMutableNotificationContent()
        content.title = "\(journey.emoji) Trajet terminé !"
        content.body = "Tu as parcouru \(Int(journey.totalKm)) km — \(journey.name) complété !"
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "journey-\(journey.id.uuidString)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    /// Vide la liste des étapes nouvellement débloquées après traitement par la vue.
    func clearNewlyUnlocked() {
        newlyUnlockedMilestones = []
    }

    // MARK: - Privé

    /// Détecte les jalons franchis pour un `totalKm` donné, les marque débloqués et retourne la liste triée.
    private func detectUnlocked(in progress: inout JourneyProgress, for journey: Journey, upTo totalKm: Double) -> [Milestone] {
        let unlocked = journey.milestones.filter {
            $0.km <= totalKm && !progress.unlockedMilestoneIds.contains($0.id)
        }
        for milestone in unlocked {
            progress.unlockedMilestoneIds.insert(milestone.id)
        }
        return unlocked.sorted { $0.km < $1.km }
    }

    // MARK: - HealthKit

    /// Retourne la distance marchée/courrue en km entre `startDate` et maintenant.
    private func fetchDistance(from startDate: Date) async -> Double {
        #if targetEnvironment(simulator)
        return 94.0
        #else
        guard HKHealthStore.isHealthDataAvailable(),
              let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)
        else { return 0 }

        return await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
            let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                let km = result?.sumQuantity()?.doubleValue(for: HKUnit.meterUnit(with: .kilo)) ?? 0
                continuation.resume(returning: km)
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
