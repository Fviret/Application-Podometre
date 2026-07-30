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

// MARK: - StepCountViewModel — navigation par jour (non-régression)

/// Couvre les zones qui ont produit des régressions : halo et notification « fantômes »
/// au changement de jour, et sélection de date depuis le calendrier.
@Suite("StepCountViewModel — navigation par jour")
@MainActor
struct StepCountViewModelDayNavigationTests {

    /// Garde-fou principal : changer de jour doit invalider le compteur affiché.
    /// Sans ça, la valeur (élevée) de la veille subsiste en revenant sur aujourd'hui,
    /// ce qui rallume le halo et peut déclencher une notification d'objectif.
    @Test func changingDayResetsStepCount() async {
        let vm = StepCountViewModel()
        vm.stepCount = 12_000
        vm.selectedDayOffset = 1
        #expect(vm.stepCount == 0)
    }

    @Test func returningToTodayAlsoResetsStepCount() async {
        let vm = StepCountViewModel()
        vm.selectedDayOffset = 1
        vm.stepCount = 12_000        // valeur du jour passé
        vm.selectedDayOffset = 0     // retour sur aujourd'hui
        #expect(vm.stepCount == 0)
    }

    @Test func selectedDateMatchesOffset() async {
        let vm = StepCountViewModel()
        vm.selectedDayOffset = 3
        let expected = Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date()
        #expect(Calendar.current.isDate(vm.selectedDate, inSameDayAs: expected))
    }

    @Test func selectDateSetsMatchingOffset() async {
        let vm = StepCountViewModel()
        let target = Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date()
        vm.selectDate(target)
        #expect(vm.selectedDayOffset == 5)
    }

    @Test func selectDateIgnoresFutureDates() async {
        let vm = StepCountViewModel()
        vm.selectedDayOffset = 2
        let future = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
        vm.selectDate(future)
        #expect(vm.selectedDayOffset == 2, "Une date future ne doit pas changer la sélection")
    }

    @Test func selectDateOnTodayReturnsToZero() async {
        let vm = StepCountViewModel()
        vm.selectedDayOffset = 4
        vm.selectDate(Date())
        #expect(vm.selectedDayOffset == 0)
    }

    @Test func displayedMonthFollowsMonthOffset() async {
        let vm = StepCountViewModel()
        vm.selectedMonthOffset = 2
        let expected = Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date()
        let calendar = Calendar.current
        #expect(calendar.component(.month, from: vm.displayedMonth) == calendar.component(.month, from: expected))
        #expect(calendar.component(.year, from: vm.displayedMonth) == calendar.component(.year, from: expected))
    }
}

// MARK: - StepCountViewModel — série (non-régression)

/// La série ne doit dépendre que d'aujourd'hui, jamais du jour affiché.
@Suite("StepCountViewModel — série")
@MainActor
struct StepCountViewModelStreakTests {

    /// Consulter un jour passé où l'objectif était atteint ne doit pas modifier la série.
    @Test func streakUnaffectedByBrowsingPastDays() async {
        let vm = StepCountViewModel()
        vm.goal = 10_000
        vm.computeStreak()
        try? await Task.sleep(nanoseconds: 100_000_000)
        let baseline = vm.currentStreak

        vm.selectedDayOffset = 1
        vm.stepCount = 20_000        // jour passé largement au-dessus de l'objectif
        vm.computeStreak()
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(vm.currentStreak == baseline,
                "La série ne doit pas varier selon le jour consulté")
    }

    @Test func streakIsNeverNegative() async {
        let vm = StepCountViewModel()
        vm.computeStreak()
        try? await Task.sleep(nanoseconds: 100_000_000)
        #expect(vm.currentStreak >= 0)
    }
}

// MARK: - StepCountViewModel — progression et objectif

@Suite("StepCountViewModel — progression")
@MainActor
struct StepCountViewModelProgressTests {

    @Test func progressExactlyAtGoalIsOne() async {
        let vm = StepCountViewModel()
        vm.stepCount = 10_000
        vm.goal = 10_000
        #expect(vm.progress == 1.0)
    }

    @Test func progressQuarter() async {
        let vm = StepCountViewModel()
        vm.stepCount = 2_500
        vm.goal = 10_000
        #expect(vm.progress == 0.25)
    }

    @Test func goalIsPersistedOnChange() async {
        let vm = StepCountViewModel()
        vm.goal = 12_500
        #expect(Preferences.shared.integer(.dailyStepGoal) == 12_500)
    }

    @Test func ringColorIdIsPersistedOnChange() async {
        let vm = StepCountViewModel()
        let previous = vm.ringColorId
        vm.setRingColor("blue")
        #expect(Preferences.shared.string(.ringColorId) == "blue")
        vm.setRingColor(previous)   // restaure l'état initial
    }

    @Test func unknownRingColorFallsBackToFirstOption() async {
        let vm = StepCountViewModel()
        let previous = vm.ringColorId
        vm.setRingColor("couleur-inexistante")
        #expect(vm.ringColor == AppColors.ringColorOptions[0].color)
        vm.setRingColor(previous)
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
        #expect(PreferenceKey.hasCompletedOnboarding.rawValue == "hasCompletedOnboarding")
    }

    @Test func defaultValueIsFalse() {
        let suite = UserDefaults(suiteName: "test-onboarding-\(UUID().uuidString)")!
        let value = suite.bool(forKey: PreferenceKey.hasCompletedOnboarding.rawValue)
        #expect(value == false)
    }

    @Test func settingTrueIsPersisted() {
        let suite = UserDefaults(suiteName: "test-onboarding-\(UUID().uuidString)")!
        suite.set(true, forKey: PreferenceKey.hasCompletedOnboarding.rawValue)
        #expect(suite.bool(forKey: PreferenceKey.hasCompletedOnboarding.rawValue) == true)
    }

    @Test func removingKeyResetsToFalse() {
        let suite = UserDefaults(suiteName: "test-onboarding-\(UUID().uuidString)")!
        suite.set(true, forKey: PreferenceKey.hasCompletedOnboarding.rawValue)
        suite.removeObject(forKey: PreferenceKey.hasCompletedOnboarding.rawValue)
        #expect(suite.bool(forKey: PreferenceKey.hasCompletedOnboarding.rawValue) == false)
    }
}

// MARK: - Aphorism : décodage

@Suite("Aphorism decoding")
struct AphorismDecodingTests {

    @Test func decodesRequiredFields() throws {
        let json = """
        {
          "metadata": { "total_count": 1, "language": "fr", "license": "CC0" },
          "aphorisms": [
            { "id": 7, "text": "Le doute est inconfortable.", "author": "Voltaire", "category": "philosophie" }
          ]
        }
        """.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(AphorismData.self, from: json)
        #expect(decoded.aphorisms.count == 1)
        #expect(decoded.aphorisms[0].id == 7)
        #expect(decoded.aphorisms[0].author == "Voltaire")
    }

    @Test func ignoresExtraLegacyFields() throws {
        // Les anciennes versions du recueil contenaient tone/year/source : ils doivent être ignorés.
        let json = """
        { "metadata": { "total_count": 1, "language": "fr", "license": "CC0" },
          "aphorisms": [
            { "id": 1, "text": "T", "author": "A", "category": "vie",
              "tone": "drôle", "year": 1890, "source": "Aphorisme" }
          ] }
        """.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(AphorismData.self, from: json)
        #expect(decoded.aphorisms.first?.text == "T")
    }
}

// MARK: - Aphorism : sélection déterministe

@Suite("AphorismManager.aphorism(forDayOfYear:)")
struct AphorismSelectionTests {

    private func makeAphorisms(_ n: Int) -> [Aphorism] {
        (0..<n).map { Aphorism(id: $0, text: "T\($0)", author: "A", category: "c") }
    }

    @Test func emptyRecueilReturnsNil() {
        let manager = AphorismManager(aphorisms: [], preferences: Preferences(defaults: freshDefaults()))
        #expect(manager.aphorism(forDayOfYear: 1) == nil)
        #expect(manager.todayAphorism == nil)
    }

    @Test func firstDayReturnsFirst() {
        let manager = AphorismManager(aphorisms: makeAphorisms(400), preferences: Preferences(defaults: freshDefaults()))
        #expect(manager.aphorism(forDayOfYear: 1)?.id == 0)
    }

    @Test func lastIndexMapsToLast() {
        let manager = AphorismManager(aphorisms: makeAphorisms(400), preferences: Preferences(defaults: freshDefaults()))
        #expect(manager.aphorism(forDayOfYear: 400)?.id == 399)
    }

    @Test func wrapsAroundAfterCount() {
        // Année de 400+ jours impossible, mais le modulo doit rester sûr (366 > count possible).
        let manager = AphorismManager(aphorisms: makeAphorisms(365), preferences: Preferences(defaults: freshDefaults()))
        #expect(manager.aphorism(forDayOfYear: 366)?.id == 0)
    }

    @Test func isStableForSameDay() {
        let manager = AphorismManager(aphorisms: makeAphorisms(400), preferences: Preferences(defaults: freshDefaults()))
        #expect(manager.aphorism(forDayOfYear: 123)?.id == manager.aphorism(forDayOfYear: 123)?.id)
    }
}

// MARK: - Aphorism : logique d'affichage popup

@Suite("AphorismManager.shouldShowPopup")
struct AphorismPopupLogicTests {

    private func makeManager(defaults: UserDefaults) -> AphorismManager {
        AphorismManager(aphorisms: [Aphorism(id: 1, text: "T", author: "A", category: "c")],
                        preferences: Preferences(defaults: defaults))
    }

    @Test func enabledByDefaultWhenUnset() {
        let manager = makeManager(defaults: freshDefaults())
        #expect(manager.isEnabled == true)
    }

    @Test func showsWhenNeverDisplayed() {
        let manager = makeManager(defaults: freshDefaults())
        #expect(manager.shouldShowPopup() == true)
    }

    @Test func hiddenWhenDisabled() {
        let defaults = freshDefaults()
        defaults.set(false, forKey: PreferenceKey.aphorismPopupEnabled.rawValue)
        let manager = makeManager(defaults: defaults)
        #expect(manager.shouldShowPopup() == false)
    }

    @Test func hiddenWhenDisplayedToday() {
        let defaults = freshDefaults()
        defaults.set(Date(), forKey: PreferenceKey.lastAphorismDisplayDate.rawValue)
        let manager = makeManager(defaults: defaults)
        #expect(manager.shouldShowPopup() == false)
    }

    @Test func showsWhenDisplayedYesterday() {
        let defaults = freshDefaults()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        defaults.set(yesterday, forKey: PreferenceKey.lastAphorismDisplayDate.rawValue)
        let manager = makeManager(defaults: defaults)
        #expect(manager.shouldShowPopup() == true)
    }

    @Test func emptyRecueilNeverShows() {
        let manager = AphorismManager(aphorisms: [], preferences: Preferences(defaults: freshDefaults()))
        #expect(manager.shouldShowPopup() == false)
    }

    @Test func markDisplayedPreventsSecondShow() {
        let manager = makeManager(defaults: freshDefaults())
        #expect(manager.shouldShowPopup() == true)
        manager.markAphorismDisplayed()
        #expect(manager.shouldShowPopup() == false)
    }

    @Test func resetDailyGuardAllowsShowAgain() {
        let manager = makeManager(defaults: freshDefaults())
        manager.markAphorismDisplayed()
        #expect(manager.shouldShowPopup() == false)
        manager.resetDailyGuard()
        #expect(manager.shouldShowPopup() == true)
    }
}

/// Store UserDefaults isolé et vide pour chaque test.
private func freshDefaults() -> UserDefaults {
    let name = "test-aphorism-\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    defaults.removePersistentDomain(forName: name)
    return defaults
}

// MARK: - Preferences

@Suite("Preferences")
struct PreferencesTests {

    @Test func rawValuesMatchHistoricalKeys() {
        // Garde-fou anti-régression : renommer un case casserait les données existantes.
        #expect(PreferenceKey.dailyStepGoal.rawValue == "dailyStepGoal")
        #expect(PreferenceKey.isDarkMode.rawValue == "isDarkMode")
        #expect(PreferenceKey.aphorismPopupEnabled.rawValue == "aphorismPopupEnabled")
        #expect(PreferenceKey.hasCompletedOnboarding.rawValue == "hasCompletedOnboarding")
        #expect(PreferenceKey.showTodayMetrics.rawValue == "showTodayMetrics")
    }

    @Test func allKeysAreUnique() {
        let raws = PreferenceKey.allCases.map(\.rawValue)
        #expect(Set(raws).count == raws.count)
    }

    @Test func roundTripsTypedValues() {
        let prefs = Preferences(defaults: freshDefaults())
        prefs.set(12_345, for: .dailyStepGoal)
        prefs.set(true, for: .isDarkMode)
        prefs.set("blue", for: .ringColorId)
        #expect(prefs.integer(.dailyStepGoal) == 12_345)
        #expect(prefs.bool(.isDarkMode) == true)
        #expect(prefs.string(.ringColorId) == "blue")
    }

    @Test func hasValueDistinguishesUnsetFromFalse() {
        let prefs = Preferences(defaults: freshDefaults())
        #expect(prefs.hasValue(.aphorismPopupEnabled) == false)
        prefs.set(false, for: .aphorismPopupEnabled)
        #expect(prefs.hasValue(.aphorismPopupEnabled) == true)
    }

    @Test func removeObjectClearsValue() {
        let prefs = Preferences(defaults: freshDefaults())
        prefs.set(Date(), for: .lastAphorismDisplayDate)
        #expect(prefs.date(.lastAphorismDisplayDate) != nil)
        prefs.removeObject(.lastAphorismDisplayDate)
        #expect(prefs.date(.lastAphorismDisplayDate) == nil)
    }
}

// MARK: - WeatherCode (mapping WMO → emoji / description / libellé)

@Suite("WeatherCode")
struct WeatherCodeTests {

    @Test func clearSkyMapsToSun() {
        #expect(weatherEmoji(for: 0) == "☀️")
        #expect(weatherDescription(for: 0) == "ciel dégagé")
    }

    @Test func overcastMapsToCloud() {
        #expect(weatherEmoji(for: 3) == "☁️")
        #expect(weatherDescription(for: 3) == "couvert")
    }

    @Test func rainCodesMapToRain() {
        // Pluie (61,63,65) et averses (80,81,82) partagent le même emoji.
        #expect(weatherEmoji(for: 61) == "🌧️")
        #expect(weatherEmoji(for: 82) == "🌧️")
        #expect(weatherDescription(for: 65) == "pluie")
        #expect(weatherDescription(for: 80) == "averses")
    }

    @Test func thunderstormMapsToStorm() {
        #expect(weatherEmoji(for: 95) == "⛈️")
        #expect(weatherEmoji(for: 99) == "⛈️")
        #expect(weatherDescription(for: 95) == "orages")
    }

    @Test func snowMapsToSnow() {
        #expect(weatherEmoji(for: 71) == "❄️")
        #expect(weatherDescription(for: 75) == "neige")
    }

    @Test func drizzleRangeMapsToDrizzle() {
        // 51...57 est un intervalle : vérifie les bornes.
        #expect(weatherDescription(for: 51) == "bruine")
        #expect(weatherDescription(for: 57) == "bruine")
    }

    @Test func unknownCodeFallsBack() {
        #expect(weatherEmoji(for: 999) == "🌡️")
        #expect(weatherDescription(for: 999) == "conditions variables")
    }

    @Test func labelCapitalisesFirstLetter() {
        #expect(weatherLabel(for: 0) == "Ciel dégagé")
        #expect(weatherLabel(for: 3) == "Couvert")
    }

    @Test func labelMatchesDescriptionContent() {
        // Le libellé ne doit différer de la description que par la casse initiale.
        for code in [0, 2, 45, 61, 71, 95, 999] {
            #expect(weatherLabel(for: code).lowercased() == weatherDescription(for: code))
        }
    }
}

// MARK: - HistoryStats.compute (écran d'historique)

@Suite("HistoryStats.compute")
struct HistoryStatsComputeTests {

    private let calendar = Calendar.current

    /// Début du jour, `n` jours avant aujourd'hui.
    private func daysAgo(_ n: Int) -> Date {
        calendar.date(byAdding: .day, value: -n, to: calendar.startOfDay(for: Date()))!
    }

    private func weekdayFrenchName(_ weekday: Int) -> String {
        ["Dimanche", "Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi"][weekday - 1]
    }

    @Test func emptyDailyStepsReturnsDefaultStats() {
        let stats = HistoryStats.compute(dailySteps: [:], goal: 10_000, calendar: calendar)
        #expect(stats.weeklyAverages.isEmpty)
        #expect(stats.yearlyTotals.isEmpty)
        #expect(stats.bestDaySteps == 0)
        #expect(stats.allTimeTotalSteps == 0)
    }

    @Test func weeklyAveragesHasExpectedCountAndOrder() {
        let daily: [Date: Int] = [daysAgo(0): 8_000, daysAgo(1): 6_000]
        let stats = HistoryStats.compute(dailySteps: daily, goal: 10_000, calendar: calendar)

        #expect(stats.weeklyAverages.count == HistoryStats.weekCount)
        // La semaine la plus récente (0...6 jours) est en dernier, et se termine aujourd'hui.
        let mostRecent = stats.weeklyAverages.last
        #expect(mostRecent?.endDate == calendar.startOfDay(for: Date()))
        #expect(mostRecent?.average == 7_000) // (8 000 + 6 000) / 2
    }

    @Test func bestDayPicksMaximum() {
        let daily: [Date: Int] = [daysAgo(0): 5_000, daysAgo(3): 24_000, daysAgo(10): 9_000]
        let stats = HistoryStats.compute(dailySteps: daily, goal: 10_000, calendar: calendar)
        #expect(stats.bestDaySteps == 24_000)
        #expect(stats.bestDayDate == daysAgo(3))
    }

    @Test func bestWeekPicksHighestTotalBlock() {
        var daily: [Date: Int] = [:]
        // Semaine en cours (0...6 jours) : total modeste.
        for offset in 0...6 { daily[daysAgo(offset)] = 1_000 }
        // Semaine précédente (7...13 jours) : total bien plus élevé.
        for offset in 7...13 { daily[daysAgo(offset)] = 9_000 }

        let stats = HistoryStats.compute(dailySteps: daily, goal: 10_000, calendar: calendar)
        #expect(stats.bestWeekTotal == 9_000 * 7)
        #expect(stats.bestWeekStartDate == daysAgo(13))
        #expect(stats.bestWeekEndDate == daysAgo(7))
    }

    @Test func perfectWeekCountsOnlyFullyReachedWeeks() {
        var daily: [Date: Int] = [:]
        // Semaine précédente (7...13) : parfaite, chaque jour atteint l'objectif.
        for offset in 7...13 { daily[daysAgo(offset)] = 10_000 }
        // Semaine en cours (0...6) : un jour sous l'objectif -> pas parfaite.
        for offset in 0...6 { daily[daysAgo(offset)] = offset == 0 ? 5_000 : 10_000 }

        let stats = HistoryStats.compute(dailySteps: daily, goal: 10_000, calendar: calendar)
        #expect(stats.perfectWeekCount == 1)
    }

    @Test func longestStreakEverFindsMaxConsecutiveRun() {
        var daily: [Date: Int] = [:]
        // Série de 5 jours (10...14), coupure (jour 9 absent), puis série de 3 jours (0...2).
        for offset in 10...14 { daily[daysAgo(offset)] = 10_000 }
        for offset in 0...2 { daily[daysAgo(offset)] = 10_000 }

        let stats = HistoryStats.compute(dailySteps: daily, goal: 10_000, calendar: calendar)
        #expect(stats.longestStreakEver == 5)
    }

    @Test func perfectMonthCountsFullyReachedPastMonth() throws {
        let today = calendar.startOfDay(for: Date())
        let lastMonthDate = try #require(calendar.date(byAdding: .month, value: -1, to: today))
        let components = calendar.dateComponents([.year, .month], from: lastMonthDate)
        let firstOfLastMonth = try #require(calendar.date(from: components))
        let range = try #require(calendar.range(of: .day, in: .month, for: firstOfLastMonth))

        var daily: [Date: Int] = [:]
        for day in range {
            var dayComponents = components
            dayComponents.day = day
            if let date = calendar.date(from: dayComponents) {
                daily[calendar.startOfDay(for: date)] = 10_000
            }
        }

        let stats = HistoryStats.compute(dailySteps: daily, goal: 10_000, calendar: calendar)
        #expect(stats.perfectMonthCount == 1)
    }

    @Test func allTimeTotalStepsSumsEveryDay() {
        let daily: [Date: Int] = [daysAgo(0): 1_000, daysAgo(1): 2_000, daysAgo(2): 3_000]
        let stats = HistoryStats.compute(dailySteps: daily, goal: 10_000, calendar: calendar)
        #expect(stats.allTimeTotalSteps == 6_000)
    }

    @Test func totalGoalReachedDaysCountsIndependentlyOfStreaks() {
        let daily: [Date: Int] = [
            daysAgo(0): 12_000,  // atteint
            daysAgo(1): 4_000,   // pas atteint
            daysAgo(5): 11_000,  // atteint, isolé (hors série)
        ]
        let stats = HistoryStats.compute(dailySteps: daily, goal: 10_000, calendar: calendar)
        #expect(stats.totalGoalReachedDays == 2)
    }

    @Test func currentYearFutureMonthsAreFlaggedAndExcludedFromTotal() throws {
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        let daily: [Date: Int] = [daysAgo(0): 5_000]
        let stats = HistoryStats.compute(dailySteps: daily, goal: 10_000, calendar: calendar)

        let yearEntry = try #require(stats.yearlyTotals.first { $0.year == currentYear })
        for (index, month) in yearEntry.months.enumerated() {
            let monthNumber = index + 1
            if monthNumber > currentMonth {
                #expect(month.isFuture, "Le mois \(monthNumber) devrait être futur")
                #expect(month.total == 0)
            } else {
                #expect(!month.isFuture, "Le mois \(monthNumber) ne devrait pas être futur")
            }
        }
    }

    @Test func bestMonthLabelIncludesYear() {
        // Total énorme sur aujourd'hui pour garantir que son mois devient le meilleur.
        let daily: [Date: Int] = [daysAgo(0): 500_000]
        let stats = HistoryStats.compute(dailySteps: daily, goal: 10_000, calendar: calendar)
        let currentYear = calendar.component(.year, from: Date())
        #expect(stats.bestMonthTotal == 500_000)
        #expect(stats.bestMonthLabel?.contains("\(currentYear)") == true)
    }

    @Test func bestYearPicksHighestYearTotal() throws {
        let oneYearAgo = try #require(calendar.date(byAdding: .year, value: -1, to: Date()))
        let lastYear = calendar.component(.year, from: oneYearAgo)
        let daily: [Date: Int] = [
            daysAgo(0): 5_000,                                    // année en cours, petit total
            calendar.startOfDay(for: oneYearAgo): 900_000,        // année précédente, total énorme
        ]

        let stats = HistoryStats.compute(dailySteps: daily, goal: 10_000, calendar: calendar)
        #expect(stats.bestYear == lastYear)
        #expect(stats.bestYearTotal == 900_000)
    }

    @Test func mostActiveWeekdayPicksHighestAverage() {
        var daily: [Date: Int] = [:]
        for offset in 0..<28 {
            daily[daysAgo(offset)] = 5_000
        }
        // Ces décalages (multiples de 7) tombent tous sur le même jour de semaine qu'aujourd'hui.
        daily[daysAgo(0)] = 30_000
        daily[daysAgo(7)] = 30_000
        daily[daysAgo(14)] = 30_000
        daily[daysAgo(21)] = 30_000

        let stats = HistoryStats.compute(dailySteps: daily, goal: 10_000, calendar: calendar)
        let todayWeekday = calendar.component(.weekday, from: Date())
        #expect(stats.mostActiveWeekdayName == weekdayFrenchName(todayWeekday))
    }
}
