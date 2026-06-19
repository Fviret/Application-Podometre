import Foundation
import HealthKit
import SwiftUI
import Combine

@MainActor
class StepCountViewModel: ObservableObject {
    @Published var goal: Int = {
        let stored = UserDefaults.standard.integer(forKey: "dailyStepGoal")
        return stored > 0 ? stored : 10_000
    }() {
        didSet { UserDefaults.standard.set(goal, forKey: "dailyStepGoal") }
    }

    @Published var stepCount: Int = 0 {
        didSet {
            // stepCount tracks whichever day is selected; only mirror it into the
            // chart's "today" slot when it actually represents today.
            if selectedDayOffset == 0, currentWeekSteps.count == 7 {
                currentWeekSteps[6] = stepCount
            }
        }
    }
    @Published var isAuthorized: Bool = false
    @Published var selectedDayOffset: Int = 0 {
        didSet {
            fetchSteps(for: selectedDate)
            syncSelectedMonth(to: selectedDate)
        }
    }
    @Published var stepsByDay: [Int: Int] = [:]
    @Published var selectedMonthOffset: Int = 0 {
        didSet { fetchMonthSteps() }
    }
    /// Index 0 = 6 days ago, index 6 = today.
    @Published var currentWeekSteps: [Int] = Array(repeating: 0, count: 7)
    /// Index 0 = 13 days ago, index 6 = 7 days ago (the week before currentWeekSteps).
    @Published var previousWeekSteps: [Int] = Array(repeating: 0, count: 7)

    var displayedMonth: Date {
        Calendar.current.date(byAdding: .month, value: -selectedMonthOffset, to: Date()) ?? Date()
    }

    var progress: Double {
        min(Double(stepCount) / Double(goal), 1.0)
    }

    var selectedDate: Date {
        Calendar.current.date(byAdding: .day, value: -selectedDayOffset, to: Date()) ?? Date()
    }

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

    func requestAuthorizationAndFetch() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }

        healthStore.requestAuthorization(toShare: [], read: [stepType]) { [weak self] success, _ in
            guard success else { return }
            Task { @MainActor in
                self?.isAuthorized = true
                self?.fetchSteps(for: self?.selectedDate ?? Date())
                self?.fetchMonthSteps()
                self?.fetchWeeklyComparison()
                self?.startObserving()
            }
        }
    }

    /// Selects the given date by translating it into a day offset from today.
    func selectDate(_ date: Date) {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfTarget = calendar.startOfDay(for: date)
        guard let days = calendar.dateComponents([.day], from: startOfTarget, to: startOfToday).day, days >= 0 else { return }
        selectedDayOffset = days
    }

    /// Keeps the calendar's displayed month in sync with the ring's selected day,
    /// so navigating across a month boundary with the chevrons updates the calendar too.
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

            print("[StepCountViewModel] fetchMonthSteps: \(dayToSteps)")

            Task { @MainActor in
                self?.stepsByDay = dayToSteps
            }
        }

        healthStore.execute(query)
    }

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
            var stepsByOffset: [Int: Int] = [:] // offset = days since startOfRange (0...13)

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
                // The collection query's bucket for today can lag behind HealthKit's
                // live total, so the already-fetched live stepCount always wins.
                self.currentWeekSteps[6] = self.stepCount

                print("current:", self.currentWeekSteps)
                print("previous:", self.previousWeekSteps)
            }
        }

        healthStore.execute(query)
    }

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

    private func startObserving() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }

        observerQuery = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, _, _ in
            Task { @MainActor in
                guard let self else { return }
                // Only live-refresh when viewing today
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
