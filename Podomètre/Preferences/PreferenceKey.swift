import Foundation

/// Source unique de vérité pour les clés de persistance `UserDefaults`.
///
/// Les `rawValue` reproduisent **à l'identique** les chaînes historiquement utilisées :
/// ne jamais renommer un `case` sans migration, sous peine de perdre les données existantes.
enum PreferenceKey: String, CaseIterable {
    /// Objectif quotidien en pas (`Int`, défaut 10 000).
    case dailyStepGoal
    /// ID de la couleur de l'anneau (`String`).
    case ringColorId
    /// Toggle notification objectif (`Bool`).
    case notificationsEnabled
    /// Garde pour max 1 notif objectif/jour (`Date`).
    case goalNotifiedDate
    /// Toggle mode sombre (`Bool`).
    case isDarkMode
    /// UUIDs des trajets terminés (`[String]`).
    case completedJourneyIds
    /// `[String: Date]` encodé (`Data` JSON) — date de complétion par UUID de trajet.
    case journeyCompletionDates
    /// `[UUID: JourneyProgress]` encodé (`Data` JSON).
    case journeyProgressMap
    /// Toggle pensée du jour (`Bool`, défaut activé).
    case aphorismPopupEnabled
    /// Garde pour max 1 popup pensée du jour/jour (`Date`).
    case lastAphorismDisplayDate
    /// Indique si l'onboarding a été complété (`Bool`).
    case hasCompletedOnboarding
    /// Toggle notifications de progression des trajets (`Bool`).
    case journeyNotificationsEnabled
    /// Affiche la météo sur l'écran principal (`Bool`).
    case showWeatherForecast
    /// Affiche le calendrier mensuel (`Bool`).
    case showMonthCalendar
    /// Affiche le graphe hebdomadaire (`Bool`).
    case showWeeklyChart
    /// Affiche la rangée de métriques du jour (distance, temps actif, calories) (`Bool`).
    case showTodayMetrics
    /// `[MainScreenSection]` encodé (`Data` JSON) — ordre d'affichage des sections sous l'anneau.
    case mainScreenSectionOrder
}
