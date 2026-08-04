import Foundation

/// Données du récapitulatif hebdomadaire — semaine calendaire (lundi → dimanche) qui vient de
/// s'achever, comparée à la semaine précédente (mêmes bornes).
struct WeeklyRecapData: Identifiable, Equatable {
    /// Lundi de la semaine récapitulée — sert d'identifiant (`.sheet(item:)`) et de garde d'affichage.
    let weekStart: Date
    var id: Date { weekStart }

    /// Nombre de jours (sur 7) où l'objectif quotidien a été atteint durant la semaine.
    let goalReachedCount: Int

    let totalSteps: Int
    let previousTotalSteps: Int

    let totalDistanceKm: Double
    let previousTotalDistanceKm: Double

    let totalCalories: Int
    let previousTotalCalories: Int

    let totalActiveMinutes: Int
    let previousTotalActiveMinutes: Int
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
