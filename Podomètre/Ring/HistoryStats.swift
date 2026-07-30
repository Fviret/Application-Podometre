import Foundation

/// Statistiques agrégées pour l'écran d'historique : tendance multi-semaines, totaux mensuels
/// et records personnels. Calculées à la demande depuis tout l'historique HealthKit disponible
/// — jamais persistées.
struct HistoryStats {
    /// Un mois affiché dans le graphe des totaux mensuels.
    struct MonthlyTotal: Identifiable {
        let id = UUID()
        let label: String
        let total: Int
        /// `true` si ce mois n'est pas encore vécu (postérieur au mois courant, dans l'année courante).
        let isFuture: Bool
    }

    /// Les 12 mois d'une année civile, du plus ancien historique disponible à l'année en cours.
    struct YearlyTotals: Identifiable {
        let id = UUID()
        let year: Int
        /// Janvier à décembre, dans l'ordre.
        let months: [MonthlyTotal]
        /// Somme des mois déjà vécus (les mois futurs comptent pour 0).
        let yearTotal: Int
    }

    /// Une semaine affichée dans le graphe de tendance, avec ses bornes de dates.
    struct WeeklyAverage: Identifiable {
        let id = UUID()
        /// Moyenne de pas/jour sur les jours de la semaine ayant au moins un pas enregistré.
        let average: Int
        /// Premier jour de la semaine (le plus ancien).
        let startDate: Date
        /// Dernier jour de la semaine (le plus récent — aujourd'hui pour la semaine en cours).
        let endDate: Date
    }

    /// Moyenne de pas par semaine sur les dernières semaines, la plus ancienne en premier.
    var weeklyAverages: [WeeklyAverage] = []
    /// Totaux mensuels par année civile, de la plus ancienne (historique disponible) à l'année en cours.
    var yearlyTotals: [YearlyTotals] = []
    /// Meilleur jour jamais enregistré.
    var bestDaySteps: Int = 0
    var bestDayDate: Date?
    /// Meilleure semaine jamais enregistrée (même découpage que `weeklyAverages` : blocs de
    /// 7 jours ancrés sur aujourd'hui, étendus à tout l'historique disponible).
    var bestWeekTotal: Int = 0
    var bestWeekStartDate: Date?
    var bestWeekEndDate: Date?
    /// Année civile avec le plus grand total de pas (parmi `yearlyTotals`).
    var bestYearTotal: Int = 0
    var bestYear: Int?
    /// Meilleur mois jamais enregistré (parmi tous les mois vécus de `yearlyTotals`), ex. "Juin 2026".
    var bestMonthTotal: Int = 0
    var bestMonthLabel: String?
    /// Jour de la semaine où la moyenne de pas est la plus élevée sur tout l'historique.
    var mostActiveWeekdayName: String?
    var mostActiveWeekdayAverage: Int = 0
    /// Nombre total de jours (non consécutifs) où l'objectif a été atteint, sur tout l'historique.
    var totalGoalReachedDays: Int = 0
    /// Nombre de semaines (mêmes blocs de 7 jours) où l'objectif a été atteint tous les jours.
    var perfectWeekCount: Int = 0
    /// Nombre de mois civils où l'objectif a été atteint tous les jours du mois.
    var perfectMonthCount: Int = 0
    /// Plus longue série de jours consécutifs avec objectif atteint, jamais réalisée
    /// (indépendante de `currentStreak`, qui ne reflète que la série en cours).
    var longestStreakEver: Int = 0
    /// Cumul de pas depuis la première donnée HealthKit disponible.
    var allTimeTotalSteps: Int = 0
    /// Cumul de distance marche+course (km) depuis la première donnée disponible. Récupéré
    /// séparément des pas (requête `distanceWalkingRunning` dédiée) — pas dérivé de `dailySteps`.
    var allTimeTotalDistanceKm: Double = 0

    /// Nombre de semaines couvertes par le graphe de tendance.
    static let weekCount = 10

    /// Calcule les statistiques à partir d'un dictionnaire jour → pas (les jours à 0 pas sont
    /// absents du dictionnaire ; la logique de série ci-dessous en tient compte).
    static func compute(dailySteps: [Date: Int], goal: Int, calendar: Calendar) -> HistoryStats {
        var stats = HistoryStats()
        guard !dailySteps.isEmpty else { return stats }

        let today = calendar.startOfDay(for: Date())

        stats.weeklyAverages = (0..<weekCount).reversed().compactMap { weekIndex -> WeeklyAverage? in
            var total = 0
            var count = 0
            for dayOffset in 0..<7 {
                let offset = weekIndex * 7 + dayOffset
                guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
                if let steps = dailySteps[date] {
                    total += steps
                    count += 1
                }
            }
            guard let endDate = calendar.date(byAdding: .day, value: -(weekIndex * 7), to: today),
                  let startDate = calendar.date(byAdding: .day, value: -(weekIndex * 7 + 6), to: today)
            else { return nil }
            return WeeklyAverage(average: count > 0 ? total / count : 0, startDate: startDate, endDate: endDate)
        }

        let monthFormatter = DateFormatter()
        monthFormatter.locale = Locale(identifier: "fr_FR")
        monthFormatter.setLocalizedDateFormatFromTemplate("MMM")

        // Une entrée par année civile complète, de la plus ancienne donnée disponible à l'année en cours.
        let currentYear = calendar.component(.year, from: today)
        let currentMonth = calendar.component(.month, from: today)
        let earliestYear = dailySteps.keys.map { calendar.component(.year, from: $0) }.min() ?? currentYear

        stats.yearlyTotals = (earliestYear...currentYear).map { year in
            var yearTotal = 0
            let months: [MonthlyTotal] = (1...12).map { monthNumber in
                let isFuture = year == currentYear && monthNumber > currentMonth
                let total = isFuture ? 0 : dailySteps.filter {
                    let components = calendar.dateComponents([.year, .month], from: $0.key)
                    return components.year == year && components.month == monthNumber
                }.values.reduce(0, +)
                yearTotal += total

                var labelComponents = DateComponents()
                labelComponents.year = year
                labelComponents.month = monthNumber
                labelComponents.day = 1
                let label = calendar.date(from: labelComponents).map { monthFormatter.string(from: $0).capitalized } ?? "\(monthNumber)"

                return MonthlyTotal(label: label, total: total, isFuture: isFuture)
            }
            return YearlyTotals(year: year, months: months, yearTotal: yearTotal)
        }

        if let best = dailySteps.max(by: { $0.value < $1.value }) {
            stats.bestDaySteps = best.value
            stats.bestDayDate = best.key
        }

        if let bestYearEntry = stats.yearlyTotals.max(by: { $0.yearTotal < $1.yearTotal }) {
            stats.bestYearTotal = bestYearEntry.yearTotal
            stats.bestYear = bestYearEntry.year
        }

        // Meilleur mois : parcourt tous les mois déjà vécus de toutes les années (yearlyTotals
        // les a déjà calculés), pas de requête supplémentaire.
        var bestMonthTotal = -1
        var bestMonthLabel: String?
        for yearEntry in stats.yearlyTotals {
            for month in yearEntry.months where !month.isFuture && month.total > bestMonthTotal {
                bestMonthTotal = month.total
                bestMonthLabel = "\(month.label) \(yearEntry.year)"
            }
        }
        stats.bestMonthTotal = max(bestMonthTotal, 0)
        stats.bestMonthLabel = bestMonthLabel

        // Jour de la semaine le plus actif : moyenne de pas par jour de semaine sur tout l'historique.
        var weekdayTotals: [Int: Int] = [:]
        var weekdayCounts: [Int: Int] = [:]
        for (date, steps) in dailySteps {
            let weekday = calendar.component(.weekday, from: date)
            weekdayTotals[weekday, default: 0] += steps
            weekdayCounts[weekday, default: 0] += 1
        }
        let weekdayAverages = weekdayTotals.compactMap { weekday, total -> (weekday: Int, average: Int)? in
            guard let count = weekdayCounts[weekday], count > 0 else { return nil }
            return (weekday, total / count)
        }
        if let bestWeekday = weekdayAverages.max(by: { $0.average < $1.average }) {
            stats.mostActiveWeekdayName = weekdayName(bestWeekday.weekday)
            stats.mostActiveWeekdayAverage = bestWeekday.average
        }

        // Nombre total de jours (non consécutifs) où l'objectif a été atteint.
        if goal > 0 {
            stats.totalGoalReachedDays = dailySteps.values.filter { $0 >= goal }.count
        }

        // Meilleure semaine + semaines parfaites : mêmes blocs de 7 jours ancrés sur aujourd'hui
        // que `weeklyAverages`, mais étendus à tout l'historique disponible (pas seulement `weekCount`).
        if let earliestDate = dailySteps.keys.min() {
            let totalWeeks = max(0, (calendar.dateComponents([.day], from: earliestDate, to: today).day ?? 0) / 7 + 1)
            var bestWeekTotal = -1
            var bestWeekStart: Date?
            var bestWeekEnd: Date?
            var perfectWeeks = 0

            for weekIndex in 0..<totalWeeks {
                guard let endDate = calendar.date(byAdding: .day, value: -(weekIndex * 7), to: today),
                      let startDate = calendar.date(byAdding: .day, value: -(weekIndex * 7 + 6), to: today)
                else { continue }

                var weekTotal = 0
                var allReachGoal = goal > 0
                for dayOffset in 0..<7 {
                    guard let date = calendar.date(byAdding: .day, value: -(weekIndex * 7 + dayOffset), to: today) else {
                        allReachGoal = false
                        continue
                    }
                    let steps = dailySteps[date] ?? 0
                    weekTotal += steps
                    if steps < goal { allReachGoal = false }
                }

                if weekTotal > bestWeekTotal {
                    bestWeekTotal = weekTotal
                    bestWeekStart = startDate
                    bestWeekEnd = endDate
                }
                if allReachGoal { perfectWeeks += 1 }
            }

            stats.bestWeekTotal = max(bestWeekTotal, 0)
            stats.bestWeekStartDate = bestWeekStart
            stats.bestWeekEndDate = bestWeekEnd
            stats.perfectWeekCount = perfectWeeks
        }

        // Mois parfaits : chaque jour du mois civil (calendrier, pas les blocs de 7 jours
        // ci-dessus) a atteint l'objectif. Parcourt les mois du plus ancien à l'actuel via un
        // index entier (année × 12 + mois) pour éviter une boucle de dates fragile.
        if goal > 0, let earliestDate = dailySteps.keys.min() {
            let startComponents = calendar.dateComponents([.year, .month], from: earliestDate)
            let startIndex = (startComponents.year ?? currentYear) * 12 + ((startComponents.month ?? 1) - 1)
            let endIndex = currentYear * 12 + (currentMonth - 1)

            var perfectMonths = 0
            if startIndex <= endIndex {
                for index in startIndex...endIndex {
                    let year = index / 12
                    let month = index % 12 + 1

                    var monthStart = DateComponents()
                    monthStart.year = year
                    monthStart.month = month
                    monthStart.day = 1
                    guard let monthDate = calendar.date(from: monthStart),
                          let range = calendar.range(of: .day, in: .month, for: monthDate)
                    else { continue }

                    let allReachGoal = range.allSatisfy { day -> Bool in
                        var dayComponents = monthStart
                        dayComponents.day = day
                        guard let date = calendar.date(from: dayComponents) else { return false }
                        return (dailySteps[calendar.startOfDay(for: date)] ?? 0) >= goal
                    }
                    if allReachGoal { perfectMonths += 1 }
                }
            }
            stats.perfectMonthCount = perfectMonths
        }

        // Série la plus longue : ne parcourt que les jours présents (pas > 0). Un jour manquant
        // (0 pas) casse naturellement la continuité, la vérification d'adjacence (J+1) suffit —
        // pas besoin d'itérer explicitement les jours à 0.
        var longest = 0
        var current = 0
        var previousDay: Date?
        for day in dailySteps.keys.sorted() {
            guard dailySteps[day] ?? 0 >= goal else {
                current = 0
                previousDay = day
                continue
            }
            if let previousDay, calendar.date(byAdding: .day, value: 1, to: previousDay) == day {
                current += 1
            } else {
                current = 1
            }
            longest = max(longest, current)
            previousDay = day
        }
        stats.longestStreakEver = longest

        stats.allTimeTotalSteps = dailySteps.values.reduce(0, +)

        return stats
    }

    /// Nom du jour de semaine en fr_FR depuis le composant `.weekday` de `Calendar`
    /// (1 = dimanche … 7 = samedi, indépendant de `firstWeekday`).
    private static func weekdayName(_ weekday: Int) -> String {
        let names = ["Dimanche", "Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi"]
        guard (1...7).contains(weekday) else { return "" }
        return names[weekday - 1]
    }
}

extension HistoryStats {
    /// Instance de prévisualisation avec des valeurs réalistes (utilisée aussi sur simulateur).
    static var mock: HistoryStats {
        var stats = HistoryStats()
        let today = Calendar.current.startOfDay(for: Date())
        let rawAverages = [6_200, 7_100, 8_300, 7_600, 9_100, 8_800, 9_400, 8_700, 9_900, 9_300]
        stats.weeklyAverages = rawAverages.enumerated().map { index, average in
            let weekIndex = rawAverages.count - 1 - index
            let endDate = Calendar.current.date(byAdding: .day, value: -(weekIndex * 7), to: today) ?? today
            let startDate = Calendar.current.date(byAdding: .day, value: -(weekIndex * 7 + 6), to: today) ?? today
            return WeeklyAverage(average: average, startDate: startDate, endDate: endDate)
        }
        let currentYear = Calendar.current.component(.year, from: today)
        let currentMonth = Calendar.current.component(.month, from: today)
        let monthLabels = ["Janv.", "Févr.", "Mars", "Avr.", "Mai", "Juin", "Juil.", "Août", "Sept.", "Oct.", "Nov.", "Déc."]

        // Année en cours : mois vécus avec des totaux réalistes, le reste grisé (futur).
        let thisYearTotals = [26_500, 24_800, 28_900, 27_100, 30_200, 29_400, 25_100, 27_800, 28_600, 26_900, 24_300, 27_200]
        let thisYearMonths = (1...12).map { month -> MonthlyTotal in
            let isFuture = month > currentMonth
            return MonthlyTotal(label: monthLabels[month - 1], total: isFuture ? 0 : thisYearTotals[month - 1], isFuture: isFuture)
        }

        // Année précédente : complète, tous les mois vécus.
        let lastYearTotals = [23_400, 22_100, 25_600, 24_800, 27_300, 26_700, 22_900, 25_400, 26_100, 24_600, 22_800, 24_900]
        let lastYearMonths = (1...12).map { month in
            MonthlyTotal(label: monthLabels[month - 1], total: lastYearTotals[month - 1], isFuture: false)
        }

        stats.yearlyTotals = [
            YearlyTotals(year: currentYear - 1, months: lastYearMonths, yearTotal: lastYearTotals.reduce(0, +)),
            YearlyTotals(year: currentYear, months: thisYearMonths, yearTotal: thisYearMonths.map(\.total).reduce(0, +))
        ]
        stats.bestDaySteps = 24_680
        stats.bestDayDate = Calendar.current.date(byAdding: .day, value: -42, to: Date())
        stats.bestWeekTotal = 68_400
        stats.bestWeekEndDate = Calendar.current.date(byAdding: .day, value: -21, to: today)
        stats.bestWeekStartDate = Calendar.current.date(byAdding: .day, value: -27, to: today)
        stats.bestYearTotal = lastYearTotals.reduce(0, +)
        stats.bestYear = currentYear - 1
        stats.bestMonthTotal = 30_200
        stats.bestMonthLabel = "Mai \(currentYear)"
        stats.mostActiveWeekdayName = "Samedi"
        stats.mostActiveWeekdayAverage = 10_400
        stats.totalGoalReachedDays = 187
        stats.perfectWeekCount = 2
        stats.perfectMonthCount = 0
        stats.longestStreakEver = 11
        stats.allTimeTotalSteps = 2_845_320
        stats.allTimeTotalDistanceKm = 2_050
        return stats
    }
}
