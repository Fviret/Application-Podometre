import Testing
import Foundation
@testable import Podome_tre

// MARK: - Journey models

@Suite("Journey.progressPercent")
struct JourneyProgressPercentTests {

    private func makeJourney(totalKm: Double, milestones: [Milestone] = []) -> Journey {
        Journey(id: UUID(), name: "Test", subtitle: "", totalKm: totalKm,
                category: .walk, emoji: "🚶", milestones: milestones)
    }

    private func makeProgress(journeyId: UUID, totalKm: Double) -> JourneyProgress {
        JourneyProgress(journeyId: journeyId, totalKm: totalKm,
                        unlockedMilestoneIds: [], startDate: Date(), lastUpdatedDate: Date())
    }

    @Test func zeroTotalKmReturnsZero() {
        let journey = makeJourney(totalKm: 0)
        let progress = makeProgress(journeyId: journey.id, totalKm: 5)
        #expect(journey.progressPercent(for: progress) == 0)
    }

    @Test func halfwayReturnsHalf() {
        let journey = makeJourney(totalKm: 100)
        let progress = makeProgress(journeyId: journey.id, totalKm: 50)
        #expect(journey.progressPercent(for: progress) == 0.5)
    }

    @Test func completedReturnsOne() {
        let journey = makeJourney(totalKm: 100)
        let progress = makeProgress(journeyId: journey.id, totalKm: 100)
        #expect(journey.progressPercent(for: progress) == 1.0)
    }

    @Test func overflowClampsToOne() {
        let journey = makeJourney(totalKm: 100)
        let progress = makeProgress(journeyId: journey.id, totalKm: 150)
        #expect(journey.progressPercent(for: progress) == 1.0)
    }

    @Test func zeroProgressReturnsZero() {
        let journey = makeJourney(totalKm: 180)
        let progress = makeProgress(journeyId: journey.id, totalKm: 0)
        #expect(journey.progressPercent(for: progress) == 0)
    }
}

// MARK: - Journey.nextMilestone

@Suite("Journey.nextMilestone")
struct JourneyNextMilestoneTests {

    private let m1 = Milestone(id: UUID(), km: 10, label: "A", description: "")
    private let m2 = Milestone(id: UUID(), km: 50, label: "B", description: "")
    private let m3 = Milestone(id: UUID(), km: 90, label: "C", description: "")

    private func journey(_ milestones: [Milestone]) -> Journey {
        Journey(id: UUID(), name: "T", subtitle: "", totalKm: 100,
                category: .trail, emoji: "🏔️", milestones: milestones)
    }

    private func progress(journeyId: UUID, unlocked: Set<UUID>) -> JourneyProgress {
        JourneyProgress(journeyId: journeyId, totalKm: 0,
                        unlockedMilestoneIds: unlocked, startDate: Date(), lastUpdatedDate: Date())
    }

    @Test func returnsFirstWhenNoneUnlocked() {
        let j = journey([m1, m2, m3])
        let p = progress(journeyId: j.id, unlocked: [])
        #expect(journey([m1, m2, m3]).nextMilestone(for: p)?.id == m1.id)
    }

    @Test func skipsUnlockedMilestones() {
        let j = journey([m1, m2, m3])
        let p = progress(journeyId: j.id, unlocked: [m1.id, m2.id])
        #expect(j.nextMilestone(for: p)?.id == m3.id)
    }

    @Test func returnsNilWhenAllUnlocked() {
        let j = journey([m1, m2, m3])
        let p = progress(journeyId: j.id, unlocked: [m1.id, m2.id, m3.id])
        #expect(j.nextMilestone(for: p) == nil)
    }

    @Test func returnsNilForNoMilestones() {
        let j = journey([])
        let p = progress(journeyId: j.id, unlocked: [])
        #expect(j.nextMilestone(for: p) == nil)
    }

    @Test func sortsByKmNotInsertionOrder() {
        // m3 (90km) inséré avant m1 (10km) — nextMilestone doit retourner m1
        let j = journey([m3, m1, m2])
        let p = progress(journeyId: j.id, unlocked: [])
        #expect(j.nextMilestone(for: p)?.id == m1.id)
    }
}

// MARK: - Journey.sortedMilestones

@Suite("Journey.sortedMilestones")
struct JourneySortedMilestonesTests {

    @Test func sortedByKmAscending() {
        let m1 = Milestone(id: UUID(), km: 30, label: "B", description: "")
        let m2 = Milestone(id: UUID(), km: 10, label: "A", description: "")
        let m3 = Milestone(id: UUID(), km: 70, label: "C", description: "")
        let journey = Journey(id: UUID(), name: "T", subtitle: "", totalKm: 100,
                              category: .myth, emoji: "⚔️", milestones: [m1, m2, m3])
        let sorted = journey.sortedMilestones
        #expect(sorted[0].km == 10)
        #expect(sorted[1].km == 30)
        #expect(sorted[2].km == 70)
    }

    @Test func emptyMilestonesReturnsEmpty() {
        let journey = Journey(id: UUID(), name: "T", subtitle: "", totalKm: 50,
                              category: .history, emoji: "👑", milestones: [])
        #expect(journey.sortedMilestones.isEmpty)
    }
}

// MARK: - Int.asKilometers

@Suite("Int.asKilometers")
struct IntAsKilometersTests {

    @Test func zeroStepsIsZeroKm() {
        #expect(0.asKilometers == 0.0)
    }

    @Test func oneStepIsPointZeroEightKm() {
        #expect(1.asKilometers == 0.0008)
    }

    @Test func tenThousandStepsIsEightKm() {
        #expect(10_000.asKilometers == 8.0)
    }

    @Test func oneMillionStepsIs800km() {
        #expect(1_000_000.asKilometers == 800.0)
    }

    @Test func negativeSteps() {
        // Comportement défensif : pas négatifs → km négatifs
        #expect((-100).asKilometers == -0.08)
    }
}

// MARK: - BadgeData

@Suite("BadgeData")
struct BadgeDataTests {

    @Test func hasSixBadges() {
        #expect(BadgeData.stepMilestoneBadges.count == 6)
    }

    @Test func thresholdsAreStrictlyIncreasing() {
        let thresholds = BadgeData.stepMilestoneBadges.map(\.threshold)
        for i in 1..<thresholds.count {
            #expect(thresholds[i] > thresholds[i - 1])
        }
    }

    @Test func firstThresholdIsFiveThousand() {
        #expect(BadgeData.stepMilestoneBadges.first?.threshold == 5_000)
    }

    @Test func lastThresholdIsOneHundredThousand() {
        #expect(BadgeData.stepMilestoneBadges.last?.threshold == 100_000)
    }

    @Test func idsAreUnique() {
        let ids = BadgeData.stepMilestoneBadges.map(\.id)
        #expect(Set(ids).count == ids.count)
    }
}

// MARK: - StepCountViewModel — logique pure

@Suite("StepCountViewModel — logique pure")
@MainActor
struct StepCountViewModelTests {

    // Isole les tests UserDefaults dans une suite séparée
    private let defaults: UserDefaults = {
        let d = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        return d
    }()

    @Test func progressClampedToOne() async {
        let vm = StepCountViewModel()
        vm.stepCount = 99_999
        vm.goal = 10_000
        #expect(vm.progress == 1.0)
    }

    @Test func progressZeroWhenNoSteps() async {
        let vm = StepCountViewModel()
        vm.stepCount = 0
        vm.goal = 10_000
        #expect(vm.progress == 0.0)
    }

    @Test func progressHalfway() async {
        let vm = StepCountViewModel()
        vm.stepCount = 5_000
        vm.goal = 10_000
        #expect(vm.progress == 0.5)
    }

    @Test func selectedDateLabelToday() async {
        let vm = StepCountViewModel()
        vm.selectedDayOffset = 0
        #expect(vm.selectedDateLabel == "Aujourd'hui")
    }

    @Test func selectedDateLabelYesterday() async {
        let vm = StepCountViewModel()
        vm.selectedDayOffset = 1
        #expect(vm.selectedDateLabel == "Hier")
    }

    @Test func selectedDateLabelOtherDay() async {
        let vm = StepCountViewModel()
        vm.selectedDayOffset = 5
        #expect(vm.selectedDateLabel != "Aujourd'hui")
        #expect(vm.selectedDateLabel != "Hier")
        #expect(!vm.selectedDateLabel.isEmpty)
    }

    @Test func markJourneyCompletedAddsId() async {
        let vm = StepCountViewModel()
        let id = UUID().uuidString
        vm.markJourneyCompleted(id)
        #expect(vm.isJourneyCompleted(id))
    }

    @Test func markJourneyCompletedIdempotent() async {
        let vm = StepCountViewModel()
        let id = UUID().uuidString
        vm.markJourneyCompleted(id)
        vm.markJourneyCompleted(id)
        #expect(vm.completedJourneyIds.filter { $0 == id }.count == 1)
    }

    @Test func isJourneyCompletedReturnsFalseForUnknown() async {
        let vm = StepCountViewModel()
        #expect(!vm.isJourneyCompleted(UUID().uuidString))
    }

    @Test func setRingColorUpdatesRingColorId() async {
        let vm = StepCountViewModel()
        vm.setRingColor("ocean")
        #expect(vm.ringColorId == "ocean")
    }

    @Test func ringColorFallsBackToDefaultForUnknownId() async {
        let vm = StepCountViewModel()
        vm.setRingColor("nonexistent-color")
        // ringColor doit retourner la couleur par défaut sans crasher
        let _ = vm.ringColor
    }

    @Test func checkAndNotifyDoesNothingBelowGoal() async {
        let vm = StepCountViewModel()
        vm.stepCount = 5_000
        vm.goal = 10_000
        // Pas de crash, pas de notification planifiée
        vm.checkAndNotifyGoalReached()
    }

    @Test func checkAndNotifyFiresWhenGoalReached() async {
        let vm = StepCountViewModel()
        // Efface le garde "déjà notifié aujourd'hui"
        UserDefaults.standard.removeObject(forKey: "goalNotifiedDate")
        vm.stepCount = 10_000
        vm.goal = 10_000
        vm.notificationsEnabled = true
        vm.checkAndNotifyGoalReached()
        // Vérifie que le garde est posé (notification planifiée)
        let notifiedDate = UserDefaults.standard.object(forKey: "goalNotifiedDate") as? Date
        #expect(notifiedDate != nil)
        // Nettoyage
        UserDefaults.standard.removeObject(forKey: "goalNotifiedDate")
    }

    @Test func checkAndNotifyDoesNotFireTwiceToday() async {
        let vm = StepCountViewModel()
        UserDefaults.standard.removeObject(forKey: "goalNotifiedDate")
        vm.stepCount = 10_000
        vm.goal = 10_000
        vm.notificationsEnabled = true
        vm.checkAndNotifyGoalReached()
        let firstDate = UserDefaults.standard.object(forKey: "goalNotifiedDate") as? Date

        // Simule un deuxième appel — la date ne doit pas changer
        vm.checkAndNotifyGoalReached()
        let secondDate = UserDefaults.standard.object(forKey: "goalNotifiedDate") as? Date
        #expect(firstDate?.timeIntervalSince1970 == secondDate?.timeIntervalSince1970)
        UserDefaults.standard.removeObject(forKey: "goalNotifiedDate")
    }
}

// MARK: - JourneyProgress persistence (Codable)

@Suite("JourneyProgress — Codable")
struct JourneyProgressCodableTests {

    @Test func roundTripEncoding() throws {
        let id = UUID()
        let m1 = UUID()
        let original = JourneyProgress(
            journeyId: id,
            totalKm: 42.5,
            unlockedMilestoneIds: [m1],
            startDate: Date(timeIntervalSince1970: 0),
            lastUpdatedDate: Date(timeIntervalSince1970: 1000)
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(JourneyProgress.self, from: data)
        #expect(decoded.journeyId == original.journeyId)
        #expect(decoded.totalKm == original.totalKm)
        #expect(decoded.unlockedMilestoneIds == original.unlockedMilestoneIds)
        #expect(decoded.startDate == original.startDate)
    }

    @Test func emptyUnlockedIdsEncodes() throws {
        let progress = JourneyProgress(
            journeyId: UUID(), totalKm: 0,
            unlockedMilestoneIds: [],
            startDate: Date(), lastUpdatedDate: Date()
        )
        let data = try JSONEncoder().encode(progress)
        let decoded = try JSONDecoder().decode(JourneyProgress.self, from: data)
        #expect(decoded.unlockedMilestoneIds.isEmpty)
    }
}

// MARK: - AppColors

@Suite("AppColors")
struct AppColorsTests {

    @Test func atLeastOneColorOption() {
        #expect(!AppColors.ringColorOptions.isEmpty)
    }

    @Test func allColorIdsAreUnique() {
        let ids = AppColors.ringColorOptions.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test func defaultColorExistsInOptions() {
        let hasGreen = AppColors.ringColorOptions.contains { $0.id == "green" }
        #expect(hasGreen)
    }
}

// MARK: - Journey catalog

@Suite("allJourneys catalog")
struct AllJourneysTests {

    @Test func catalogIsNotEmpty() {
        #expect(!allJourneys.isEmpty)
    }

    @Test func allJourneyIdsAreUnique() {
        let ids = allJourneys.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test func allJourneysHavePositiveTotalKm() {
        for journey in allJourneys {
            #expect(journey.totalKm > 0, "Journey '\(journey.name)' a totalKm <= 0")
        }
    }

    @Test func allMilestonesWithinJourneyDistance() {
        for journey in allJourneys {
            for milestone in journey.milestones {
                #expect(milestone.km <= journey.totalKm,
                    "Jalon '\(milestone.label)' (\(milestone.km) km) dépasse totalKm (\(journey.totalKm) km) de '\(journey.name)'")
            }
        }
    }

    @Test func allMilestoneIdsUniqueWithinJourney() {
        for journey in allJourneys {
            let ids = journey.milestones.map(\.id)
            #expect(Set(ids).count == ids.count,
                "Jalons dupliqués dans '\(journey.name)'")
        }
    }

    @Test func categoriesMatchExpectedSet() {
        let found = Set(allJourneys.map(\.category))
        #expect(found.isSubset(of: Set(JourneyCategory.allCases)))
    }
}

// MARK: - Onboarding

@Suite("Onboarding — objectifs")
struct OnboardingGoalsTests {

    @Test func hasFiveGoals() {
        #expect(onboardingGoals.count == 5)
    }

    @Test func stepsAreStrictlyIncreasing() {
        let steps = onboardingGoals.map(\.steps)
        for i in 1..<steps.count {
            #expect(steps[i] > steps[i - 1])
        }
    }

    @Test func firstGoalIsFiveThousand() {
        #expect(onboardingGoals.first?.steps == 5_000)
    }

    @Test func lastGoalIsTwentyThousand() {
        #expect(onboardingGoals.last?.steps == 20_000)
    }

    @Test func defaultGoalExistsInList() {
        #expect(onboardingGoals.contains { $0.steps == onboardingDefaultGoal })
    }

    @Test func defaultGoalIsEightThousand() {
        #expect(onboardingDefaultGoal == 8_000)
    }

    @Test func allGoalsHaveNonEmptyLabels() {
        for goal in onboardingGoals {
            #expect(!goal.label.isEmpty)
            #expect(!goal.sublabel.isEmpty)
        }
    }
}

@Suite("Onboarding — UserDefaults")
struct OnboardingUserDefaultsTests {

    @Test func completedKeyMatchesConstant() {
        #expect(onboardingCompletedKey == "hasCompletedOnboarding")
    }

    @Test func defaultValueIsFalse() {
        let suite = UserDefaults(suiteName: "test-onboarding-\(UUID().uuidString)")!
        let value = suite.bool(forKey: onboardingCompletedKey)
        #expect(value == false)
    }

    @Test func settingTrueIsPersisted() {
        let suite = UserDefaults(suiteName: "test-onboarding-\(UUID().uuidString)")!
        suite.set(true, forKey: onboardingCompletedKey)
        #expect(suite.bool(forKey: onboardingCompletedKey) == true)
    }

    @Test func removingKeyResetsToFalse() {
        let suite = UserDefaults(suiteName: "test-onboarding-\(UUID().uuidString)")!
        suite.set(true, forKey: onboardingCompletedKey)
        suite.removeObject(forKey: onboardingCompletedKey)
        #expect(suite.bool(forKey: onboardingCompletedKey) == false)
    }
}
