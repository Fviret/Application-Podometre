import XCTest

// MARK: - Helpers

extension XCUIApplication {
    /// Lance l'app en réinitialisant l'état d'onboarding pour un test reproductible.
    func launchFresh() {
        launchArguments = ["UI_TESTING"]
        launchEnvironment["RESET_ONBOARDING"] = "1"
        launch()
    }

    /// Lance l'app en simulant que l'onboarding a déjà été complété.
    func launchWithOnboardingDone() {
        launchArguments = ["UI_TESTING"]
        launchEnvironment["SKIP_ONBOARDING"] = "1"
        launch()
    }
}

// MARK: - Onboarding

final class OnboardingUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Vérifie que le bouton "Suivant" est présent dès la slide 1.
    @MainActor
    func testOnboardingFirstSlideShowsNextButton() throws {
        let app = XCUIApplication()
        app.launchFresh()

        let nextButton = app.buttons["onboarding_primary_button"]
        XCTAssertTrue(nextButton.waitForExistence(timeout: 5))
        XCTAssertEqual(nextButton.label, "Suivant")
    }

    /// Vérifie que les indicateurs de page (dots) sont présents.
    @MainActor
    func testOnboardingDotsExist() throws {
        let app = XCUIApplication()
        app.launchFresh()

        let dots = app.otherElements["onboarding_dots"]
        XCTAssertTrue(dots.waitForExistence(timeout: 5))
    }

    /// Navigue jusqu'à la slide 2 via le bouton "Suivant".
    @MainActor
    func testOnboardingNextButtonAdvancesSlide() throws {
        let app = XCUIApplication()
        app.launchFresh()

        let nextButton = app.buttons["onboarding_primary_button"]
        XCTAssertTrue(nextButton.waitForExistence(timeout: 5))
        nextButton.tap()

        XCTAssertTrue(nextButton.waitForExistence(timeout: 3))
        XCTAssertEqual(nextButton.label, "Suivant")
    }

    /// Navigue jusqu'à la slide 3 et vérifie le bouton HealthKit.
    @MainActor
    func testOnboardingSlide3ShowsHealthKitButton() throws {
        let app = XCUIApplication()
        app.launchFresh()

        let nextButton = app.buttons["onboarding_primary_button"]
        XCTAssertTrue(nextButton.waitForExistence(timeout: 5))
        nextButton.tap()
        nextButton.tap()

        XCTAssertTrue(app.buttons["onboarding_primary_button"].waitForExistence(timeout: 3))
        XCTAssertEqual(app.buttons["onboarding_primary_button"].label, "Autoriser l'accès")
    }

    /// Navigue jusqu'à la slide 4 via "Plus tard" et vérifie le bouton final.
    @MainActor
    func testOnboardingSlide4ShowsLaunchButton() throws {
        let app = XCUIApplication()
        app.launchFresh()

        let nextButton = app.buttons["onboarding_primary_button"]
        XCTAssertTrue(nextButton.waitForExistence(timeout: 5))
        nextButton.tap()
        nextButton.tap()

        let skipButton = app.buttons["Plus tard"]
        XCTAssertTrue(skipButton.waitForExistence(timeout: 3))
        skipButton.tap()

        let launchButton = app.buttons["onboarding_primary_button"]
        XCTAssertTrue(launchButton.waitForExistence(timeout: 3))
        XCTAssertEqual(launchButton.label, "Lancer l'app")
    }

    /// Complète l'onboarding et vérifie qu'on arrive sur l'app principale.
    @MainActor
    func testOnboardingCompletionLandsOnMainApp() throws {
        let app = XCUIApplication()
        app.launchFresh()

        let nextButton = app.buttons["onboarding_primary_button"]
        XCTAssertTrue(nextButton.waitForExistence(timeout: 5))
        nextButton.tap()
        nextButton.tap()

        let skipButton = app.buttons["Plus tard"]
        XCTAssertTrue(skipButton.waitForExistence(timeout: 3))
        skipButton.tap()

        let launchButton = app.buttons["onboarding_primary_button"]
        XCTAssertTrue(launchButton.waitForExistence(timeout: 3))
        launchButton.tap()

        let ring = app.otherElements["step_ring"]
        XCTAssertTrue(ring.waitForExistence(timeout: 5))
    }

    /// Vérifie que l'onboarding ne peut pas être dismissé par swipe vers le bas.
    @MainActor
    func testOnboardingCannotBeDismissedBySwipe() throws {
        let app = XCUIApplication()
        app.launchFresh()

        let nextButton = app.buttons["onboarding_primary_button"]
        XCTAssertTrue(nextButton.waitForExistence(timeout: 5))

        app.swipeDown()

        XCTAssertTrue(nextButton.exists)
    }
}

// MARK: - Navigation TabBar

final class TabNavigationUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Vérifie que la TabBar contient 3 onglets.
    @MainActor
    func testTabBarHasThreeTabs() throws {
        let app = XCUIApplication()
        app.launchWithOnboardingDone()

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5))
        XCTAssertEqual(app.tabBars.firstMatch.buttons.count, 3)
    }

    /// Vérifie que l'onglet Activité est affiché par défaut (anneau visible).
    @MainActor
    func testDefaultTabIsActivity() throws {
        let app = XCUIApplication()
        app.launchWithOnboardingDone()

        let ring = app.otherElements["step_ring"]
        XCTAssertTrue(ring.waitForExistence(timeout: 5))
    }

    /// Navigue vers l'onglet Trajets et vérifie qu'il s'affiche.
    @MainActor
    func testNavigateToJourneysTab() throws {
        let app = XCUIApplication()
        app.launchWithOnboardingDone()

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5))
        app.tabBars.firstMatch.buttons["Trajets"].tap()

        XCTAssertTrue(app.staticTexts["Trajets"].waitForExistence(timeout: 3))
    }

    /// Navigue vers l'onglet Paramètres et vérifie qu'il s'affiche.
    @MainActor
    func testNavigateToSettingsTab() throws {
        let app = XCUIApplication()
        app.launchWithOnboardingDone()

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5))
        app.tabBars.firstMatch.buttons["Paramètres"].tap()

        XCTAssertTrue(app.staticTexts["Paramètres"].waitForExistence(timeout: 3))
    }

    /// Revient sur Activité après avoir navigué vers Paramètres.
    @MainActor
    func testCanReturnToActivityTab() throws {
        let app = XCUIApplication()
        app.launchWithOnboardingDone()

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5))
        app.tabBars.firstMatch.buttons["Paramètres"].tap()
        app.tabBars.firstMatch.buttons["Activité"].tap()

        XCTAssertTrue(app.otherElements["step_ring"].waitForExistence(timeout: 3))
    }
}

// MARK: - Écran Activité

final class ActivityUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Vérifie que l'anneau de progression est affiché.
    @MainActor
    func testStepRingIsVisible() throws {
        let app = XCUIApplication()
        app.launchWithOnboardingDone()

        XCTAssertTrue(app.otherElements["step_ring"].waitForExistence(timeout: 5))
    }

    /// Vérifie que le label de date affiche "Aujourd'hui" par défaut.
    @MainActor
    func testDateLabelShowsToday() throws {
        let app = XCUIApplication()
        app.launchWithOnboardingDone()

        let dateLabel = app.staticTexts["date_label"]
        XCTAssertTrue(dateLabel.waitForExistence(timeout: 5))
        XCTAssertEqual(dateLabel.label, "Aujourd'hui")
    }

    /// Le chevron gauche navigue vers le jour précédent ("Hier").
    @MainActor
    func testLeftChevronNavigatesToPreviousDay() throws {
        let app = XCUIApplication()
        app.launchWithOnboardingDone()

        let dateLabel = app.staticTexts["date_label"]
        XCTAssertTrue(dateLabel.waitForExistence(timeout: 5))

        app.buttons["Jour précédent"].tap()

        XCTAssertEqual(dateLabel.label, "Hier")
    }

    /// Le chevron droit est désactivé quand on est sur "Aujourd'hui".
    @MainActor
    func testRightChevronIsDisabledOnToday() throws {
        let app = XCUIApplication()
        app.launchWithOnboardingDone()

        XCTAssertTrue(app.otherElements["step_ring"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Jour suivant"].isEnabled)
    }

    /// Le chevron droit se réactive après avoir navigué vers un jour passé.
    @MainActor
    func testRightChevronEnabledAfterGoingBack() throws {
        let app = XCUIApplication()
        app.launchWithOnboardingDone()

        XCTAssertTrue(app.otherElements["step_ring"].waitForExistence(timeout: 5))
        app.buttons["Jour précédent"].tap()

        XCTAssertTrue(app.buttons["Jour suivant"].isEnabled)
    }
}
