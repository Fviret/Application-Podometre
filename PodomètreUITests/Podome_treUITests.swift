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

    /// Navigue jusqu'à la slide 3 : le bouton principal reste « Suivant ».
    @MainActor
    func testOnboardingSlide3ShowsNextButton() throws {
        let app = XCUIApplication()
        app.launchFresh()

        let nextButton = app.buttons["onboarding_primary_button"]
        XCTAssertTrue(nextButton.waitForExistence(timeout: 5))
        nextButton.tap()
        nextButton.tap()

        XCTAssertTrue(nextButton.waitForExistence(timeout: 3))
        XCTAssertEqual(nextButton.label, "Suivant")
    }

    /// Navigue jusqu'à la slide 4 (3 taps) et vérifie le bouton final « Lancer l'app ».
    @MainActor
    func testOnboardingSlide4ShowsLaunchButton() throws {
        let app = XCUIApplication()
        app.launchFresh()

        let nextButton = app.buttons["onboarding_primary_button"]
        XCTAssertTrue(nextButton.waitForExistence(timeout: 5))
        nextButton.tap()
        nextButton.tap()
        nextButton.tap()

        let launchButton = app.buttons["onboarding_primary_button"]
        XCTAssertTrue(launchButton.waitForExistence(timeout: 3))
        XCTAssertEqual(launchButton.label, "Lancer l'app")
    }

    /// Complète l'onboarding (3 taps + lancement) et vérifie qu'on arrive sur l'app principale.
    @MainActor
    func testOnboardingCompletionLandsOnMainApp() throws {
        let app = XCUIApplication()
        app.launchFresh()

        let nextButton = app.buttons["onboarding_primary_button"]
        XCTAssertTrue(nextButton.waitForExistence(timeout: 5))
        nextButton.tap()
        nextButton.tap()
        nextButton.tap()

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
        // Sur « Aujourd'hui », le chevron droit est à opacity(0) : absent de l'arbre d'accessibilité.
        XCTAssertFalse(app.buttons["Jour suivant"].exists)
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

// MARK: - Helpers pensée du jour


extension XCUIApplication {
    /// Lance l'app en sautant l'onboarding, avec un état « pensée du jour » contrôlé.
    /// - Parameters:
    ///   - resetAphorism: force l'affichage de la popup (état réinitialisé).
    ///   - disableAphorism: désactive complètement la pensée du jour.
    func launchMainApp(resetAphorism: Bool = false, disableAphorism: Bool = false) {
        launchArguments = ["UI_TESTING"]
        launchEnvironment["SKIP_ONBOARDING"] = "1"
        if resetAphorism { launchEnvironment["RESET_APHORISM"] = "1" }
        if disableAphorism { launchEnvironment["DISABLE_APHORISM"] = "1" }
        launch()
    }
}

// MARK: - Pensée du jour : popup


final class AphorismPopupUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// La popup « pensée du jour » s'affiche à la première ouverture du jour.
    @MainActor
    func testPopupAppearsOnFirstLaunch() throws {
        let app = XCUIApplication()
        app.launchMainApp(resetAphorism: true)

        let button = app.buttons["aphorism_make_my_day"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
    }

    /// « Make my day » referme la popup.
    @MainActor
    func testMakeMyDayDismissesPopup() throws {
        let app = XCUIApplication()
        app.launchMainApp(resetAphorism: true)

        let button = app.buttons["aphorism_make_my_day"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        button.tap()

        XCTAssertFalse(button.waitForExistence(timeout: 2))
    }

    /// Quand la pensée du jour est désactivée, la popup ne s'affiche jamais.
    @MainActor
    func testPopupHiddenWhenDisabled() throws {
        let app = XCUIApplication()
        app.launchMainApp(disableAphorism: true)

        // Attendre que l'app soit chargée (onglets présents) avant de vérifier l'absence.
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["aphorism_make_my_day"].exists)
    }
}

// MARK: - Pensée du jour : Paramètres

final class AphorismSettingsUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// La section Paramètres affiche le toggle de la pensée du jour.
    @MainActor
    func testSettingsShowsToggle() throws {
        let app = XCUIApplication()
        // Désactivé pour éviter que la popup ne masque l'écran au démarrage.
        app.launchMainApp(disableAphorism: true)

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5))
        app.tabBars.firstMatch.buttons["Paramètres"].tap()

        let toggle = app.switches["aphorism_toggle"]
        var attempts = 0
        while !toggle.exists && attempts < 6 {
            app.swipeUp()
            attempts += 1
        }
        XCTAssertTrue(toggle.waitForExistence(timeout: 3))
    }

    /// La carte de l'aphorisme du jour est présente dans les Paramètres (pensée du jour active).
    @MainActor
    func testSettingsShowsCard() throws {
        let app = XCUIApplication()
        app.launchMainApp()

        // Fermer la popup éventuelle du jour.
        let popupButton = app.buttons["aphorism_make_my_day"]
        if popupButton.waitForExistence(timeout: 3) { popupButton.tap() }

        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5))
        app.tabBars.firstMatch.buttons["Paramètres"].tap()

        // La carte dans les Paramètres autorise la copie → trait bouton (type .button).
        let card = app.buttons["aphorism_card"]
        var attempts = 0
        while !card.exists && attempts < 6 {
            app.swipeUp()
            attempts += 1
        }
        XCTAssertTrue(card.exists)
    }
}
