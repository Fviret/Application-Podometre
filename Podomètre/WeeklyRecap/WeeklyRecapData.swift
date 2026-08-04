import Foundation

/// Données du récapitulatif hebdomadaire — semaine calendaire (lundi → dimanche) qui vient de
/// s'achever, comparée à la semaine précédente (mêmes bornes).
struct WeeklyRecapData: Identifiable, Equatable {
    /// Lundi de la semaine récapitulée — sert d'identifiant (`.sheet(item:)`) et de garde d'affichage.
    let weekStart: Date
    var id: Date { weekStart }

    /// Objectif atteint ou non pour chacun des 7 jours de la semaine, lundi en premier.
    let dailyGoalReached: [Bool]

    /// Nombre de jours (sur 7) où l'objectif quotidien a été atteint durant la semaine.
    var goalReachedCount: Int { dailyGoalReached.filter { $0 }.count }

    let totalSteps: Int
    let previousTotalSteps: Int

    let totalDistanceKm: Double
    let previousTotalDistanceKm: Double

    let totalCalories: Int
    let previousTotalCalories: Int

    let totalActiveMinutes: Int
    let previousTotalActiveMinutes: Int

    /// Trajet en cours à mettre en avant (le même que la card épinglée du catalogue), et sa
    /// progression — ancre le récap dans la fonctionnalité différenciante de l'app plutôt que
    /// d'en faire un simple résumé de métriques génériques. Renseigné par `ContentView` (qui a
    /// accès à `JourneyProgressService`, contrairement à `StepCountViewModel`) une fois les
    /// métriques HealthKit récupérées ; `nil` si aucun trajet n'est en cours.
    var activeJourneyName: String? = nil
    var activeJourneyProgressKm: Double? = nil
    var activeJourneyTargetKm: Double? = nil
}

/// Sens de variation d'une métrique par rapport à la semaine précédente.
enum WeeklyRecapTrend {
    case down, flat, up

    init(current: Double, previous: Double) {
        if current > previous { self = .up }
        else if current < previous { self = .down }
        else { self = .flat }
    }
}
