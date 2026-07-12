//
//  Podome_treUITests.swift
//  PodomètreUITests
//

import XCTest

// MARK: - Helpers

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
