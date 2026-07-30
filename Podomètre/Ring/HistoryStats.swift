import Foundation

/// Statistiques agrégées pour l'écran d'historique : tendance multi-semaines, totaux mensuels,
/// taux de réussite de l'objectif et records personnels. Calculées à la demande depuis tout
/// l'historique HealthKit disponible — jamais persistées.
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
    /// Taux de réussite de l'objectif *courant*, appliqué rétroactivement (0...1) — aucun
    /// historique d'objectif n'est conservé, seul l'objectif actuel est connu.
    var goalSuccessRate30: Double = 0
    var goalSuccessRate90: Double = 0
    var goalSuccessRate365: Double = 0
    /// Meilleur jour jamais enregistré.
    var bestDaySteps: Int = 0
    var bestDayDate: Date?
    /// Plus longue série de jours consécutifs avec objectif atteint, jamais réalisée
    /// (indépendante de `currentStreak`, qui ne reflète que la série en cours).
    var longestStreakEver: Int = 0
    /// Cumul de pas depuis la première donnée HealthKit disponible.
    var allTimeTotalSteps: Int = 0

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

        func successRate(overDays days: Int) -> Double {
            guard goal > 0 else { return 0 }
            var reached = 0
            for offset in 0..<days {
                guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
                if (dailySteps[date] ?? 0) >= goal { reached += 1 }
            }
            return Double(reached) / Double(days)
        }
        stats.goalSuccessRate30 = successRate(overDays: 30)
        stats.goalSuccessRate90 = successRate(overDays: 90)
        stats.goalSuccessRate365 = successRate(overDays: 365)

        if let best = dailySteps.max(by: { $0.value < $1.value }) {
            stats.bestDaySteps = best.value
            stats.bestDayDate = best.key
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
        stats.goalSuccessRate30 = 0.63
        stats.goalSuccessRate90 = 0.58
        stats.goalSuccessRate365 = 0.51
        stats.bestDaySteps = 24_680
        stats.bestDayDate = Calendar.current.date(byAdding: .day, value: -42, to: Date())
        stats.longestStreakEver = 11
        stats.allTimeTotalSteps = 2_845_320
        return stats
    }
}
