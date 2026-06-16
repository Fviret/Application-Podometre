import Foundation
import HealthKit
import SwiftUI
import Combine

@MainActor
class StepCountViewModel: ObservableObject {
    @Published var stepCount: Int = 0
    @Published var isAuthorized: Bool = false
    @Published var selectedDayOffset: Int = 0 {
        didSet { fetchSteps(for: selectedDate) }
    }
    @Published var stepsByDay: [Int: Int] = [:]

    var progress: Double {
        min(Double(stepCount) / 10_000.0, 1.0)
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

    func fetchMonthSteps() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }

        let calendar = Calendar.current
        let now = Date()
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else { return }

        let intervalComponents = DateComponents(day: 1)
        let predicate = HKQuery.predicateForSamples(withStart: startOfMonth, end: now, options: .strictStartDate)

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

            results.enumerateStatistics(from: startOfMonth, to: now) { statistics, _ in
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
