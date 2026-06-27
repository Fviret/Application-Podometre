import Foundation
import HealthKit
import SwiftUI
import Combine
import UserNotifications

/// ViewModel principal de l'anneau de pas.
/// Centralise les données HealthKit, la navigation par jour/mois et l'objectif quotidien.
@MainActor
class StepCountViewModel: ObservableObject {

    /// Identifiant de la couleur sélectionnée pour l'anneau. Persisté dans UserDefaults ; défaut "green".
    @Published var ringColorId: String = UserDefaults.standard.string(forKey: "ringColorId") ?? "green"

    /// Couleur effective de l'anneau, dérivée de `ringColorId`.
    var ringColor: Color {
        AppColors.ringColorOptions.first { $0.id == ringColorId }?.color
            ?? AppColors.ringColorOptions[0].color
    }

    /// Met à jour la couleur de l'anneau et la persiste dans UserDefaults.
    func setRingColor(_ id: String) {
        ringColorId = id
        UserDefaults.standard.set(id, forKey: "ringColorId")
    }

    /// Active ou désactive les notifications de l'objectif journalier. Persisté dans UserDefaults.
    @Published var notificationsEnabled: Bool = UserDefaults.standard.bool(forKey: "notificationsEnabled") {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled") }
    }

    /// Nombre de jours consécutifs où l'objectif quotidien a été atteint, en remontant depuis aujourd'hui.
    @Published var currentStreak: Int = 0

    /// Nombre de jours où chaque seuil de pas a été atteint. Clé = StepMilestoneBadge.id.
    @Published var milestoneCounts: [String: Int] = [:]

    /// Identifiants (UUID string) des trajets entièrement complétés. Persisté dans UserDefaults.
    @Published var completedJourneyIds: [String] = UserDefaults.standard.stringArray(forKey: "completedJourneyIds") ?? []

    /// Marque un trajet comme complété si ce n'est pas déjà le cas.
    func markJourneyCompleted(_ id: String) {
        guard !completedJourneyIds.contains(id) else { return }
        completedJourneyIds.append(id)
        UserDefaults.standard.set(completedJourneyIds, forKey: "completedJourneyIds")
    }

    /// Retourne `true` si le trajet identifié par `id` a été entièrement complété.
    func isJourneyCompleted(_ id: String) -> Bool {
        completedJourneyIds.contains(id)
    }

    /// Demande l'autorisation de notifications (alerte, son, badge).
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    /// `true` si une notification d'objectif a déjà été envoyée aujourd'hui (vérifie UserDefaults).
    private var goalNotifiedToday: Bool {
        get {
            guard let saved = UserDefaults.standard.object(forKey: "goalNotifiedDate") as? Date else { return false }
            return Calendar.current.isDateInToday(saved)
        }
        set {
            if newValue { UserDefaults.standard.set(Date(), forKey: "goalNotifiedDate") }
        }
    }

    /// Envoie une notification locale si l'objectif vient d'être franchi et n'a pas encore été notifié aujourd'hui.
    func checkAndNotifyGoalReached() {
        guard stepCount >= goal else { return }
        guard !goalNotifiedToday else { return }
        goalNotifiedToday = true
        sendGoalReachedNotification()
    }

    /// Planifie immédiatement la notification "Objectif atteint".
    private func sendGoalReachedNotification() {
        guard notificationsEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "Objectif atteint ! 🎉"
        content.body = "Tu as atteint \(goal.formatted()) pas aujourd'hui. Continue comme ça !"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let identifier = "goalReached-\(Date().formatted(.dateTime.day().month().year()))"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error { print("Notification error: \(error)") }
        }
    }

    /// Calcule la série de jours consécutifs où l'objectif a été atteint, en remontant depuis aujourd'hui.
    /// Aujourd'hui est inclus uniquement si `stepCount` >= `goal`. Plafond à 365 jours.
    func computeStreak() {
        Task {
            let result = await computeStreakAsync()
            currentStreak = result
        }
    }

    private func computeStreakAsync() async -> Int {
        #if targetEnvironment(simulator)
        return stepCount >= goal ? 5 : 4
        #else
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return 0 }
        let calendar = Calendar.current
        var streak = 0
        var offset = 0

        if stepCount >= goal {
            streak = 1
            offset = 1
        }

        while offset <= 365 {
            let date = calendar.date(byAdding: .day, value: -offset, to: Date()) ?? Date()
            let start = calendar.startOfDay(for: date)
            guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { break }
            let predicate = HKQuery.predicateForSamples(withStart: start, end: end)

            let steps: Int = await withCheckedContinuation { continuation in
                let query = HKStatisticsQuery(
                    quantityType: stepType,
                    quantitySamplePredicate: predicate,
                    options: .cumulativeSum
                ) { _, stats, _ in
                    continuation.resume(returning: Int(stats?.sumQuantity()?.doubleValue(for: .count()) ?? 0))
                }
                healthStore.execute(query)
            }

            if steps >= goal {
                streak += 1
                offset += 1
            } else {
                break
            }
        }

        return streak
        #endif
    }

    /// Récupère sur toute l'historique HealthKit le nombre de jours où chaque seuil de pas a été atteint.
    /// Sur simulateur, injecte des valeurs fictives.
    func fetchMilestoneCounts() {
        #if targetEnvironment(simulator)
        milestoneCounts = ["5k": 47, "10k": 23, "20k": 4, "30k": 1, "50k": 0, "100k": 0]
        #else
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }

        let intervalComponents = DateComponents(day: 1)
        let anchorDate = Calendar.current.startOfDay(for: Date(timeIntervalSince1970: 0))
        let predicate = HKQuery.predicateForSamples(withStart: .distantPast, end: Date())

        let query = HKStatisticsCollectionQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: anchorDate,
            intervalComponents: intervalComponents
        )

        query.initialResultsHandler = { [weak self] _, results, _ in
            guard let results else { return }
            let badges = BadgeData.stepMilestoneBadges
            var counts: [String: Int] = Dictionary(uniqueKeysWithValues: badges.map { ($0.id, 0) })

            results.enumerateStatistics(from: .distantPast, to: Date()) { statistics, _ in
                let steps = Int(statistics.sumQuantity()?.doubleValue(for: .count()) ?? 0)
                guard steps > 0 else { return }
                for badge in badges where steps >= badge.threshold {
                    counts[badge.id, default: 0] += 1
                }
            }

            Task { @MainActor in
                self?.milestoneCounts = counts
            }
        }

        healthStore.execute(query)
        #endif
    }

    /// Objectif quotidien en pas. Persisté dans UserDefaults ; défaut 10 000.
    @Published var goal: Int = {
        let stored = UserDefaults.standard.integer(forKey: "dailyStepGoal")
        return stored > 0 ? stored : 10_000
    }() {
        didSet { UserDefaults.standard.set(goal, forKey: "dailyStepGoal") }
    }

    /// Nombre de pas pour le jour sélectionné.
    /// Quand le jour affiché est aujourd'hui, met à jour le graphe, recalcule la série et vérifie l'objectif.
    @Published var stepCount: Int = 0 {
        didSet {
            if selectedDayOffset == 0, currentWeekSteps.count == 7 {
                currentWeekSteps[6] = stepCount
                computeStreak()
                checkAndNotifyGoalReached()
            }
        }
    }

    /// `true` si l'autorisation HealthKit a été accordée.
    @Published var isAuthorized: Bool = false

    /// Décalage en jours depuis aujourd'hui (0 = aujourd'hui, 1 = hier, …).
    /// Chaque changement déclenche un fetch du jour et une synchro du mois affiché.
    @Published var selectedDayOffset: Int = 0 {
        didSet {
            fetchSteps(for: selectedDate)
            syncSelectedMonth(to: selectedDate)
        }
    }

    /// Pas par numéro de jour du mois affiché. Clé = numéro du jour (1…31).
    @Published var stepsByDay: [Int: Int] = [:]

    /// Décalage en mois depuis le mois courant (0 = mois en cours, 1 = mois précédent, …).
    /// Chaque changement déclenche un fetch du calendrier mensuel.
    @Published var selectedMonthOffset: Int = 0 {
        didSet { fetchMonthSteps() }
    }

    /// Pas des 7 derniers jours. Index 0 = il y a 6 jours, index 6 = aujourd'hui.
    @Published var currentWeekSteps: [Int] = Array(repeating: 0, count: 7)

    /// Pas des 7 jours précédant la semaine en cours. Index 0 = il y a 13 jours, index 6 = il y a 7 jours.
    @Published var previousWeekSteps: [Int] = Array(repeating: 0, count: 7)

    /// Premier jour du mois affiché, calculé depuis `selectedMonthOffset`.
    var displayedMonth: Date {
        Calendar.current.date(byAdding: .month, value: -selectedMonthOffset, to: Date()) ?? Date()
    }

    /// Progression vers l'objectif du jour, entre 0.0 et 1.0.
    var progress: Double {
        min(Double(stepCount) / Double(goal), 1.0)
    }

    /// Date correspondant à `selectedDayOffset` jours avant aujourd'hui.
    var selectedDate: Date {
        Calendar.current.date(byAdding: .day, value: -selectedDayOffset, to: Date()) ?? Date()
    }

    /// Libellé lisible du jour sélectionné ("Aujourd'hui", "Hier", ou date courte fr_FR).
    var selectedDateLabel: String {
        switch selectedDayOffset {
        case 0: return "Aujourd'hui"
        case 1: return "Hier"
        default:
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "fr_FR")
            formatter.setLocalizedDateFormatFromTemplate("EEEdMMMM")
            return formatter.string(from: selectedDate)
        }
    }

    private let healthStore = HKHealthStore()
    private var observerQuery: HKObserverQuery?

    /// Demande l'autorisation HealthKit en lecture pour les pas, puis lance les fetches initiaux et l'observeur live.
    /// Sur simulateur, injecte des données fictives sans passer par HealthKit.
    func requestAuthorizationAndFetch() {
        #if targetEnvironment(simulator)
        loadMockData()
        #else
        guard HKHealthStore.isHealthDataAvailable() else { return }
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount),
              let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)
        else { return }

        healthStore.requestAuthorization(toShare: [], read: [stepType, distanceType]) { [weak self] success, _ in
            guard success else { return }
            Task { @MainActor in
                self?.isAuthorized = true
                self?.requestNotificationPermission()
                self?.fetchSteps(for: self?.selectedDate ?? Date())
                self?.fetchMonthSteps()
                self?.fetchWeeklyComparison()
                self?.fetchMilestoneCounts()
                self?.computeStreak()
                self?.startObserving()
            }
        }
        #endif
    }

    /// Injecte des données fictives réalistes pour tester l'interface sur simulateur.
    /// Couvre : pas du jour, calendrier mensuel complet, comparaison hebdomadaire.
    private func loadMockData() {
        isAuthorized = true
        fetchMilestoneCounts()
        computeStreak()

        // Pas du jour sélectionné
        stepCount = selectedDayOffset == 0 ? 7_430 : [4_200, 11_350, 8_900, 3_100, 12_600, 9_870, 6_540][selectedDayOffset % 7]

        // Calendrier mensuel : données pour les 28 premiers jours
        let calendar = Calendar.current
        let today = Date()
        guard let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) else { return }
        let currentDay = calendar.component(.day, from: today)

        let mockDailySteps: [Int] = [
            8_200, 11_500, 3_000, 9_400, 12_000, 6_700, 10_100,
            4_400, 10_000, 7_200, 13_500, 5_800, 9_600, 15_600,
            2_100, 8_800, 10_300, 7_600, 11_200, 4_900, 9_100,
            6_300, 12_400, 8_700, 10_500, 3_700, 11_000, 7_900
        ]

        var days: [Int: Int] = [:]
        for day in 1...currentDay {
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) else { continue }
            if calendar.startOfDay(for: date) <= calendar.startOfDay(for: today) {
                days[day] = mockDailySteps[(day - 1) % mockDailySteps.count]
            }
        }
        stepsByDay = days

        // Comparaison hebdomadaire
        currentWeekSteps  = [4_300, 9_800, 11_200, 7_600, 3_900, 10_500, 7_430]
        previousWeekSteps = [6_100, 8_300,  9_900, 5_200, 7_800, 12_100, 8_650]
    }

    /// Traduit une date calendaire en `selectedDayOffset` et met à jour la sélection.
    /// Les dates futures sont ignorées.
    func selectDate(_ date: Date) {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfTarget = calendar.startOfDay(for: date)
        guard let days = calendar.dateComponents([.day], from: startOfTarget, to: startOfToday).day, days >= 0 else { return }
        selectedDayOffset = days
    }

    /// Synchronise `selectedMonthOffset` avec le mois de `date`.
    /// Appelée à chaque changement de `selectedDayOffset` pour garder le calendrier aligné sur la date sélectionnée.
    private func syncSelectedMonth(to date: Date) {
        let calendar = Calendar.current
        guard let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: Date())),
              let targetMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date)),
              let monthsDiff = calendar.dateComponents([.month], from: targetMonthStart, to: currentMonthStart).month
        else { return }

        if selectedMonthOffset != monthsDiff {
            selectedMonthOffset = monthsDiff
        }
    }

    /// Récupère les pas jour par jour pour `displayedMonth` via `HKStatisticsCollectionQuery`.
    /// Le résultat est stocké dans `stepsByDay` (clé = numéro de jour).
    func fetchMonthSteps() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }

        let calendar = Calendar.current
        let now = Date()
        let month = displayedMonth
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else { return }
        guard let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else { return }
        let endOfRange = min(startOfNextMonth, now)

        let intervalComponents = DateComponents(day: 1)
        let predicate = HKQuery.predicateForSamples(withStart: startOfMonth, end: endOfRange, options: .strictStartDate)

        let query = HKStatisticsCollectionQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: startOfMonth,
            intervalComponents: intervalComponents
        )

        query.initialResultsHandler = { [weak self] _, results, _ in
            guard let results else { return }
            var dayToSteps: [Int: Int] = [:]

            results.enumerateStatistics(from: startOfMonth, to: endOfRange) { statistics, _ in
                let day = calendar.component(.day, from: statistics.startDate)
                let steps = statistics.sumQuantity()?.doubleValue(for: .count()) ?? 0
                dayToSteps[day] = Int(steps)
            }

            Task { @MainActor in
                self?.stepsByDay = dayToSteps
            }
        }

        healthStore.execute(query)
    }

    /// Récupère les pas sur une fenêtre de 14 jours pour alimenter le graphe de comparaison hebdomadaire.
    /// Surcharge le slot d'aujourd'hui avec `stepCount` live pour éviter le décalage du bucket HK.
    func fetchWeeklyComparison() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }

        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)

        guard let startOfRange = calendar.date(byAdding: .day, value: -13, to: startOfToday) else { return }
        guard let endOfRange = calendar.date(byAdding: .day, value: 1, to: startOfToday) else { return }

        let intervalComponents = DateComponents(day: 1)
        let predicate = HKQuery.predicateForSamples(withStart: startOfRange, end: endOfRange, options: .strictStartDate)

        let query = HKStatisticsCollectionQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: startOfRange,
            intervalComponents: intervalComponents
        )

        query.initialResultsHandler = { [weak self] _, results, _ in
            guard let results else { return }
            var stepsByOffset: [Int: Int] = [:]

            results.enumerateStatistics(from: startOfRange, to: endOfRange) { statistics, _ in
                guard let offset = calendar.dateComponents([.day], from: startOfRange, to: statistics.startDate).day else { return }
                let steps = statistics.sumQuantity()?.doubleValue(for: .count()) ?? 0
                stepsByOffset[offset] = Int(steps)
            }

            let previousWeek = (0...6).map { stepsByOffset[$0] ?? 0 }
            let currentWeek = (7...13).map { stepsByOffset[$0] ?? 0 }

            Task { @MainActor in
                guard let self else { return }
                self.previousWeekSteps = previousWeek
                self.currentWeekSteps = currentWeek
                // Le bucket HK du jour peut être en retard sur le total live — on force le remplacement.
                self.currentWeekSteps[6] = self.stepCount
            }
        }

        healthStore.execute(query)
    }

    /// Récupère le total de pas pour un jour donné via `HKStatisticsQuery` et met à jour `stepCount`.
    func fetchSteps(for date: Date) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }

        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
            let steps = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
            Task { @MainActor in
                withAnimation(.easeInOut(duration: 0.6)) {
                    self?.stepCount = Int(steps)
                }
            }
        }

        healthStore.execute(query)
    }

    /// Installe un `HKObserverQuery` pour recevoir les mises à jour live des pas.
    /// Ne rafraîchit `stepCount` que si l'utilisateur est sur la vue d'aujourd'hui.
    private func startObserving() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }

        observerQuery = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, _, _ in
            Task { @MainActor in
                guard let self else { return }
                if self.selectedDayOffset == 0 {
                    self.fetchSteps(for: self.selectedDate)
                }
            }
        }

        if let query = observerQuery {
            healthStore.execute(query)
        }
    }

    deinit {
        if let query = observerQuery {
            healthStore.stop(query)
        }
    }
}
