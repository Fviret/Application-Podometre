import Foundation
import HealthKit
import CoreMotion
import SwiftUI
import Combine
import UserNotifications

/// ViewModel principal de l'anneau de pas.
/// Centralise les données HealthKit, la navigation par jour/mois et l'objectif quotidien.
@MainActor
class StepCountViewModel: ObservableObject {

    /// Identifiant de la couleur sélectionnée pour l'anneau. Persisté dans UserDefaults ; défaut "green".
    @Published var ringColorId: String = Preferences.shared.string(.ringColorId) ?? "green"

    /// Couleur effective de l'anneau, dérivée de `ringColorId`.
    var ringColor: Color {
        AppColors.ringColorOptions.first { $0.id == ringColorId }?.color
            ?? AppColors.ringColorOptions[0].color
    }

    /// Met à jour la couleur de l'anneau et la persiste dans UserDefaults.
    func setRingColor(_ id: String) {
        ringColorId = id
        Preferences.shared.set(id, for: .ringColorId)
    }

    /// Active ou désactive les notifications de l'objectif journalier. Persisté dans UserDefaults.
    @Published var notificationsEnabled: Bool = Preferences.shared.bool(.notificationsEnabled) {
        didSet { Preferences.shared.set(notificationsEnabled, for: .notificationsEnabled) }
    }

    /// Nombre de jours consécutifs où l'objectif quotidien a été atteint, en remontant depuis aujourd'hui.
    @Published var currentStreak: Int = 0

    /// Nombre de jours où chaque seuil de pas a été atteint. Clé = StepMilestoneBadge.id.
    @Published var milestoneCounts: [String: Int] = [:]

    /// Distance marche+course du jour, en km (HealthKit `distanceWalkingRunning`).
    @Published var todayDistanceKm: Double = 0
    /// Minutes actives du jour (marche/course/vélo), calculées via Core Motion — fonctionne sans Apple Watch.
    @Published var todayActiveMinutes: Int = 0
    /// Calories actives du jour, en kcal (HealthKit `activeEnergyBurned`). Souvent 0 sans Apple Watch.
    @Published var todayActiveCalories: Int = 0

    /// Identifiants (UUID string) des trajets entièrement complétés. Persisté dans UserDefaults.
    @Published var completedJourneyIds: [String] = Preferences.shared.stringArray(.completedJourneyIds) ?? []

    /// Marque un trajet comme complété si ce n'est pas déjà le cas.
    func markJourneyCompleted(_ id: String) {
        guard !completedJourneyIds.contains(id) else { return }
        completedJourneyIds.append(id)
        Preferences.shared.set(completedJourneyIds, for: .completedJourneyIds)
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
            guard let saved = Preferences.shared.date(.goalNotifiedDate) else { return false }
            return Calendar.current.isDateInToday(saved)
        }
        set {
            if newValue { Preferences.shared.set(Date(), for: .goalNotifiedDate) }
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
    /// Ne dépend QUE d'aujourd'hui et de l'historique HealthKit — jamais du jour affiché (`stepCount`) :
    /// naviguer sur un jour passé ne modifie pas la série. Plafond à 365 jours.
    func computeStreak() {
        Task {
            let result = await computeStreakAsync()
            currentStreak = result
        }
    }

    private func computeStreakAsync() async -> Int {
        #if targetEnvironment(simulator)
        // Valeur fictive fixe : indépendante du jour affiché.
        return 4
        #else
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return 0 }
        let calendar = Calendar.current
        var streak = 0
        var offset = 0

        // On part d'aujourd'hui (offset 0) et on remonte tant que l'objectif est atteint.
        // Chaque jour est lu depuis HealthKit : le calcul ne dépend pas de `stepCount` (jour affiché).
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
        let stored = Preferences.shared.integer(.dailyStepGoal)
        return stored > 0 ? stored : 10_000
    }() {
        didSet { Preferences.shared.set(goal, for: .dailyStepGoal) }
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

    /// `true` quand l'app ne reçoit aucune donnée de pas alors que le prompt HealthKit a déjà
    /// été présenté — signe d'un accès en lecture refusé. HealthKit ne révèle jamais directement
    /// un refus de lecture : on l'infère de l'absence totale de pas sur une large fenêtre.
    /// Pilote la bannière d'invitation à ouvrir les Réglages sur l'écran Activité.
    @Published var healthAccessDenied: Bool = false

    /// Décalage en jours depuis aujourd'hui (0 = aujourd'hui, 1 = hier, …).
    /// Chaque changement déclenche un fetch du jour et une synchro du mois affiché.
    @Published var selectedDayOffset: Int = 0 {
        didSet {
            // Invalide la valeur du jour précédent avant de charger le nouveau jour.
            // Sans ça, en revenant sur aujourd'hui, `stepCount` garde la valeur (élevée) de la veille :
            // le halo « objectif atteint » clignote et une notification fantôme peut partir.
            stepCount = 0
            fetchSteps(for: selectedDate)
            fetchMetrics(for: selectedDate)
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

    /// Moyenne de pas par jour sur les 6 jours pleins précédents (aujourd'hui exclu car partiel).
    /// Sert à estimer une cadence de marche (ex. date d'arrivée sur un trajet). `nil` si l'historique
    /// est vide/insuffisant (aucune estimation fiable possible).
    var averageDailySteps: Int? {
        guard currentWeekSteps.count == 7 else { return nil }
        let fullDays = Array(currentWeekSteps.prefix(6)) // index 6 = aujourd'hui, écarté
        let total = fullDays.reduce(0, +)
        guard total > 0 else { return nil }
        return total / fullDays.count
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
    private var observerQueryRegistered = false

    /// Podomètre Core Motion pour l'affichage quasi temps réel des pas du jour au premier plan.
    private let pedometer = CMPedometer()
    /// Historique d'activité (marche/course/vélo) pour calculer le temps actif sans Apple Watch.
    private let activityManager = CMMotionActivityManager()
    private var isLiveUpdating = false
    #if targetEnvironment(simulator)
    private var mockLiveTimer: Timer?
    #endif

    /// Détermine si l'accès en lecture aux pas semble refusé et met à jour `healthAccessDenied`.
    ///
    /// HealthKit ne signale jamais un refus de lecture : `requestAuthorization` réussit même en cas
    /// de refus, et `authorizationStatus` ne concerne que l'écriture. On croise donc deux signaux :
    /// le prompt a déjà été présenté (`getRequestStatusForAuthorization == .unnecessary`) **et**
    /// aucun pas n'existe sur les 30 derniers jours. Sur simulateur, toujours `false` (données mock).
    func checkHealthAccess() {
        #if targetEnvironment(simulator)
        healthAccessDenied = false
        #else
        guard HKHealthStore.isHealthDataAvailable(),
              let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount),
              let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning),
              let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)
        else { healthAccessDenied = false; return }

        healthStore.getRequestStatusForAuthorization(toShare: [], read: [stepType, distanceType, energyType]) { [weak self] status, _ in
            // `.shouldRequest` : le prompt n'a pas encore été montré → ce n'est pas un refus.
            guard status == .unnecessary else {
                Task { @MainActor in self?.healthAccessDenied = false }
                return
            }
            let end = Date()
            let start = Calendar.current.date(byAdding: .day, value: -30, to: end) ?? end
            let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
            let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
                let steps = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                Task { @MainActor in
                    // Aucun pas sur 30 jours alors que le prompt a été montré : accès très probablement refusé.
                    self?.healthAccessDenied = steps == 0
                }
            }
            self?.healthStore.execute(query)
        }
        #endif
    }

    /// Demande l'autorisation HealthKit en lecture pour les pas, puis lance les fetches initiaux et l'observeur live.
    /// Sur simulateur, injecte des données fictives sans passer par HealthKit.
    func requestAuthorizationAndFetch() {
        #if targetEnvironment(simulator)
        loadMockData()
        #else
        guard HKHealthStore.isHealthDataAvailable() else { return }
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount),
              let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning),
              let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)
        else { return }

        healthStore.requestAuthorization(toShare: [], read: [stepType, distanceType, energyType]) { [weak self] success, _ in
            guard success else { return }
            Task { @MainActor in
                self?.isAuthorized = true
                self?.requestNotificationPermission()
                self?.enableBackgroundDelivery()
                self?.setupStepObserverQuery()
                self?.fetchSteps(for: self?.selectedDate ?? Date())
                self?.fetchMonthSteps()
                self?.fetchWeeklyComparison()
                self?.fetchMilestoneCounts()
                self?.fetchMetrics(for: self?.selectedDate ?? Date())
                self?.computeStreak()
                self?.checkHealthAccess()
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

        // Métriques du jour sélectionné (mock simulateur)
        fetchMetrics(for: selectedDate)

        // Pas du jour sélectionné (previewStepsOverride force une valeur pour les previews Xcode).
        stepCount = selectedDayOffset == 0 ? (previewStepsOverride ?? 7_430) : [4_200, 11_350, 8_900, 3_100, 12_600, 9_870, 6_540][selectedDayOffset % 7]

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
                guard let self else { return }
                // Ignore un résultat obsolète : si l'utilisateur a changé de jour entre-temps,
                // une requête lancée pour un autre jour ne doit pas écraser `stepCount`
                // (sinon halo/notification « fantômes » sur le jour désormais affiché).
                guard Calendar.current.isDate(date, inSameDayAs: self.selectedDate) else { return }
                // L'animation est déclarée dans StepRingView (avec sa garde reduceMotion) :
                // le ViewModel ne fait qu'assigner la donnée.
                self.stepCount = Int(steps)
            }
        }

        healthStore.execute(query)
    }

    /// Active la livraison HealthKit en arrière-plan (fréquence horaire) pour les pas.
    /// Permet à l'OS de réveiller l'app même quand elle est fermée.
    func enableBackgroundDelivery() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        healthStore.enableBackgroundDelivery(
            for: HKQuantityType(.stepCount),
            frequency: .hourly
        ) { _, error in
            if let error { print("Background delivery error: \(error)") }
        }
    }

    /// Installe un `HKObserverQuery` pour recevoir les mises à jour de pas, en foreground et en background.
    /// Le `completionHandler` fourni par HealthKit doit toujours être appelé pour signaler la fin du traitement.
    func setupStepObserverQuery() {
        guard !observerQueryRegistered else { return }
        observerQueryRegistered = true
        let stepType = HKQuantityType(.stepCount)

        observerQuery = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, completionHandler, error in
            guard error == nil else { completionHandler(); return }
            self?.fetchStepsForBackground {
                completionHandler()
            }
        }

        if let query = observerQuery {
            healthStore.execute(query)
        }
    }

    /// Fetch des pas du jour en arrière-plan — met à jour `stepCount`, vérifie l'objectif et recalcule le streak.
    /// `completion` doit impérativement être appelé pour libérer le token background de HealthKit.
    func fetchStepsForBackground(completion: @escaping () -> Void) {
        let start = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date())
        let query = HKStatisticsQuery(
            quantityType: HKQuantityType(.stepCount),
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] _, stats, _ in
            let steps = Int(stats?.sumQuantity()?.doubleValue(for: .count()) ?? 0)
            DispatchQueue.main.async {
                guard let self else { completion(); return }
                // N'agit que si aujourd'hui est affiché : ne pas écraser l'affichage d'un jour passé
                // ni notifier l'objectif sur la base d'une autre journée.
                guard self.selectedDayOffset == 0 else { completion(); return }
                self.stepCount = steps
                self.checkAndNotifyGoalReached()
                self.computeStreak()
                completion()
            }
        }
        healthStore.execute(query)
    }

    // MARK: - Métriques du jour (distance, temps actif, calories)

    /// Récupère les métriques (distance, minutes d'exercice, calories actives) pour le jour `date`.
    /// Sur simulateur, injecte des valeurs fictives variant selon le jour.
    func fetchMetrics(for date: Date) {
        #if targetEnvironment(simulator)
        let offset = max(0, Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0)
        let distances: [Double] = [5.6, 3.2, 8.9, 6.7, 2.4, 9.6, 5.0]
        let minutes = [42, 20, 65, 38, 15, 70, 33]
        let calories = [480, 260, 720, 410, 180, 810, 390]
        let i = offset % 7
        todayDistanceKm = distances[i]
        todayActiveMinutes = minutes[i]
        todayActiveCalories = calories[i]
        #else
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? date
        fetchDayQuantity(.distanceWalkingRunning, unit: .meterUnit(with: .kilo), start: start, end: end) { [weak self] value in
            self?.todayDistanceKm = value
        }
        fetchActiveMinutes(from: start, to: end)
        fetchDayQuantity(.activeEnergyBurned, unit: .kilocalorie(), start: start, end: end) { [weak self] value in
            self?.todayActiveCalories = Int(value)
        }
        #endif
    }

    /// Calcule le temps actif (min) sur `[start, end)` via Core Motion : somme des segments
    /// marche/course/vélo de l'historique d'activité. Fonctionne sur iPhone seul (pas d'Apple Watch requise).
    private func fetchActiveMinutes(from start: Date, to end: Date) {
        guard CMMotionActivityManager.isActivityAvailable() else { return }
        activityManager.queryActivityStarting(from: start, to: end, to: .main) { [weak self] activities, error in
            guard let activities, error == nil else { return }
            var activeSeconds: TimeInterval = 0
            for (index, activity) in activities.enumerated() {
                let isActive = (activity.walking || activity.running || activity.cycling) && activity.confidence != .low
                guard isActive else { continue }
                let segmentEnd = index + 1 < activities.count ? activities[index + 1].startDate : end
                activeSeconds += segmentEnd.timeIntervalSince(activity.startDate)
            }
            let minutes = Int(activeSeconds / 60)
            Task { @MainActor in self?.todayActiveMinutes = minutes }
        }
    }

    /// Somme cumulée d'un type de quantité HealthKit sur l'intervalle `[start, end)`, convertie dans `unit`.
    private func fetchDayQuantity(_ identifier: HKQuantityTypeIdentifier, unit: HKUnit, start: Date, end: Date, completion: @escaping (Double) -> Void) {
        guard let type = HKQuantityType.quantityType(forIdentifier: identifier) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            let value = result?.sumQuantity()?.doubleValue(for: unit) ?? 0
            Task { @MainActor in completion(value) }
        }
        healthStore.execute(query)
    }

    // MARK: - Mise à jour live (Core Motion)

    /// Démarre le suivi quasi temps réel des pas du jour via `CMPedometer`.
    /// Ne s'active qu'au premier plan et pour aujourd'hui ; HealthKit reste la source de vérité.
    func startLiveStepUpdates() {
        guard selectedDayOffset == 0, !isLiveUpdating else { return }
        isLiveUpdating = true

        #if targetEnvironment(simulator)
        // Simulateur : simule une marche (incréments réguliers) pour visualiser l'animation.
        mockLiveTimer?.invalidate()
        mockLiveTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.selectedDayOffset == 0 else { return }
                self.stepCount += Int.random(in: 8...25)
            }
        }
        #else
        guard CMPedometer.isStepCountingAvailable() else { isLiveUpdating = false; return }
        let startOfDay = Calendar.current.startOfDay(for: Date())
        pedometer.startUpdates(from: startOfDay) { [weak self] data, error in
            guard let data, error == nil else { return }
            let steps = data.numberOfSteps.intValue
            Task { @MainActor in
                guard let self, self.selectedDayOffset == 0 else { return }
                // `max` : la valeur ne recule jamais dans la journée (HealthKit peut inclure d'autres sources).
                self.stepCount = max(self.stepCount, steps)
            }
        }
        #endif
    }

    /// Arrête le suivi live (arrière-plan, ou navigation vers un jour passé) pour préserver la batterie.
    func stopLiveStepUpdates() {
        guard isLiveUpdating else { return }
        isLiveUpdating = false
        #if targetEnvironment(simulator)
        mockLiveTimer?.invalidate()
        mockLiveTimer = nil
        #else
        pedometer.stopUpdates()
        #endif
    }

    /// Pas du jour forcés pour les previews Xcode (objectif atteint). `nil` = mock standard.
    /// Utilisé uniquement par les `#Preview` pour visualiser l'écran en état « objectif atteint ».
    var previewStepsOverride: Int?

    deinit {
        if let query = observerQuery {
            healthStore.stop(query)
        }
    }
}

extension StepCountViewModel {
    /// Instance de preview : objectif du jour **atteint** + série active,
    /// pour visualiser la série 🔥 et l'anneau plein dans le canvas Xcode.
    static var previewGoalReached: StepCountViewModel {
        let vm = StepCountViewModel()
        vm.goal = 10_000
        vm.previewStepsOverride = 12_634
        vm.stepCount = 12_634
        vm.currentStreak = 5
        vm.todayDistanceKm = 9.8
        vm.todayActiveMinutes = 42
        vm.todayActiveCalories = 480
        return vm
    }
}
