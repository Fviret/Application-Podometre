import SwiftUI

/// Écran d'historique complet : tendance multi-semaines, totaux mensuels et records personnels.
/// Ouvert au tap sur le graphe hebdomadaire de l'écran Activité.
struct HistoryDetailView: View {
    @ObservedObject var viewModel: StepCountViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if let stats = viewModel.historyStats {
                        WeeklyTrendSection(weeklyAverages: stats.weeklyAverages, ringColor: viewModel.ringColor)
                        YearlyTotalsSection(yearlyTotals: stats.yearlyTotals, ringColor: viewModel.ringColor)
                        longestStreakSection(stats)
                        recordsSection(stats)
                        allTimeSection(stats)
                    } else {
                        ProgressView("Chargement de l'historique…")
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .navigationTitle("Historique")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
            .task {
                guard viewModel.historyStats == nil else { return }
                viewModel.fetchHistoryStats()
            }
        }
    }


    // MARK: - Plus longue série (mise en avant)

    /// Met en avant la plus longue série jamais réalisée avec la flamme animée, séparément
    /// des autres records — c'est la récompense la plus symbolique de l'app.
    private func longestStreakSection(_ stats: HistoryStats) -> some View {
        VStack(spacing: 10) {
            FlameStreakView(streak: stats.longestStreakEver, size: 100)

            Text("\(stats.longestStreakEver) jour\(stats.longestStreakEver > 1 ? "s" : "")")
                .font(.system(.title, design: .rounded).weight(.bold))
                .foregroundStyle(Color.primary)

            Text("Plus longue série jamais réalisée")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Plus longue série jamais réalisée : \(stats.longestStreakEver) jour\(stats.longestStreakEver > 1 ? "s" : "")")
    }

    // MARK: - Records personnels

    private func recordsSection(_ stats: HistoryStats) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Records personnels")

            recordRow(
                icon: "trophy.fill",
                title: "Meilleur jour",
                value: "\(stats.bestDaySteps.formatted()) pas",
                subtitle: stats.bestDayDate.map(dateLabel)
            )

            recordRow(
                icon: "calendar",
                title: "Meilleure semaine",
                value: "\(stats.bestWeekTotal.formatted()) pas",
                subtitle: weekRangeLabel(start: stats.bestWeekStartDate, end: stats.bestWeekEndDate)
            )

            recordRow(
                icon: "calendar.circle.fill",
                title: "Meilleur mois",
                value: "\(stats.bestMonthTotal.formatted()) pas",
                subtitle: stats.bestMonthLabel
            )

            recordRow(
                icon: "star.fill",
                title: "Meilleure année",
                value: "\(stats.bestYearTotal.formatted()) pas",
                subtitle: stats.bestYear.map(String.init)
            )

            if let mostActiveWeekdayName = stats.mostActiveWeekdayName {
                recordRow(
                    icon: "figure.walk",
                    title: "Jour le plus actif",
                    value: mostActiveWeekdayName,
                    subtitle: "\(stats.mostActiveWeekdayAverage.formatted()) pas/jour en moyenne"
                )
            }

            recordRow(
                icon: "checkmark.circle.fill",
                title: "Jours objectif atteint",
                value: "\(stats.totalGoalReachedDays.formatted())",
                subtitle: nil
            )

            if stats.perfectWeekCount > 0 {
                recordRow(
                    icon: "checkmark.seal.fill",
                    title: "Semaines parfaites",
                    value: "\(stats.perfectWeekCount) semaine\(stats.perfectWeekCount > 1 ? "s" : "")",
                    subtitle: nil
                )
            }

            if stats.perfectMonthCount > 0 {
                recordRow(
                    icon: "checkmark.seal.fill",
                    title: "Mois parfaits",
                    value: "\(stats.perfectMonthCount) mois",
                    subtitle: nil
                )
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    /// Formate un intervalle de dates (ex. "1 juin – 7 juin"), `nil` si l'une des deux bornes manque.
    private func weekRangeLabel(start: Date?, end: Date?) -> String? {
        guard let start, let end else { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.setLocalizedDateFormatFromTemplate("d MMMM")
        return "\(formatter.string(from: start)) – \(formatter.string(from: end))"
    }

    private func recordRow(icon: String, title: String, value: String, subtitle: String?) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(viewModel.ringColor)
                .frame(width: 32)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
                Text(value)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Color.primary)
            }

            Spacer()

            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 120, alignment: .trailing)
            }
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Cumul total

    /// Circonférence de la Terre à l'équateur, en km — référence du « tour du monde ».
    private let earthCircumferenceKm: Double = 40_075

    private func allTimeSection(_ stats: HistoryStats) -> some View {
        // Progression exprimée comme un tour en cours (0...1), plutôt qu'une barre qui
        // resterait bloquée à 100 % une fois le premier tour du monde dépassé.
        let totalTours = stats.allTimeTotalDistanceKm / earthCircumferenceKm
        let completedTours = Int(totalTours)
        let currentTourProgress = totalTours - Double(completedTours)

        return VStack(spacing: 20) {
            VStack(spacing: 6) {
                Text(stats.allTimeTotalSteps.formatted())
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .foregroundStyle(viewModel.ringColor)
                Text("pas cumulés depuis le début du suivi")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
            }
            .accessibilityElement(children: .combine)

            VStack(spacing: 6) {
                Text("\(stats.allTimeTotalDistanceKm.formatted(.number.precision(.fractionLength(0)))) km")
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .foregroundStyle(viewModel.ringColor)
                Text("parcourus depuis le début du suivi")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
            }
            .accessibilityElement(children: .combine)

            VStack(spacing: 12) {
                // Piste + point de position, même principe que le tracé de segment des trajets :
                // le point marque où on en est dans le tour en cours, pas juste une barre pleine.
                GeometryReader { geo in
                    let width = geo.size.width
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.15))
                            .frame(height: 10)

                        Capsule()
                            .fill(viewModel.ringColor)
                            .frame(width: max(10, width * currentTourProgress), height: 10)

                        Circle()
                            .fill(viewModel.ringColor)
                            .frame(width: 22, height: 22)
                            .overlay(Circle().strokeBorder(Color(.secondarySystemBackground), lineWidth: 3))
                            .shadow(color: viewModel.ringColor.opacity(0.4), radius: 4, x: 0, y: 0)
                            .offset(x: width * currentTourProgress - 11)
                    }
                }
                .frame(height: 22)

                Text(worldTourLabel(completedTours: completedTours, currentTourProgress: currentTourProgress))
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color.primary)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(worldTourLabel(completedTours: completedTours, currentTourProgress: currentTourProgress))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    /// Libellé du tour du monde : distingue « en cours de premier tour » et « N tours + reste ».
    private func worldTourLabel(completedTours: Int, currentTourProgress: Double) -> String {
        let percent = Int((currentTourProgress * 100).rounded())
        if completedTours > 0 {
            return "\(completedTours) tour\(completedTours > 1 ? "s" : "") du monde + \(percent) % (40 075 km/tour)"
        }
        return "\(percent) % du tour du monde (40 075 km)"
    }

    // MARK: - Commun

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(.subheadline, design: .rounded).weight(.semibold))
            .foregroundStyle(Color.primary)
    }

    /// Formate une date en libellé court fr_FR (ex. "12 juillet").
    private func dateLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.setLocalizedDateFormatFromTemplate("d MMMM")
        return formatter.string(from: date)
    }
}

// MARK: - WeeklyTrendSection

/// Graphe de tendance sur `HistoryStats.weekCount` semaines. Chaque barre est tappable : la
/// sélection affiche en dessous l'intervalle de dates et la moyenne quotidienne de la semaine
/// choisie. La semaine la plus récente est sélectionnée par défaut.
private struct WeeklyTrendSection: View {
    let weeklyAverages: [HistoryStats.WeeklyAverage]
    let ringColor: Color

    @State private var selectedIndex: Int

    init(weeklyAverages: [HistoryStats.WeeklyAverage], ringColor: Color) {
        self.weeklyAverages = weeklyAverages
        self.ringColor = ringColor
        _selectedIndex = State(initialValue: max(0, weeklyAverages.count - 1))
    }

    private var selectedWeek: HistoryStats.WeeklyAverage? {
        weeklyAverages.indices.contains(selectedIndex) ? weeklyAverages[selectedIndex] : nil
    }

    private var previousWeek: HistoryStats.WeeklyAverage? {
        weeklyAverages.indices.contains(selectedIndex - 1) ? weeklyAverages[selectedIndex - 1] : nil
    }

    /// Écart (en pas) en deçà duquel les deux moyennes sont considérées équivalentes.
    private let trendNeutralThreshold = 500

    private enum WeekTrend { case down, flat, up }

    /// Tendance de la semaine sélectionnée par rapport à celle juste avant elle dans le graphe.
    /// `nil` si aucune semaine précédente n'est disponible (première semaine du graphe).
    private var trend: WeekTrend? {
        guard let selectedWeek, let previousWeek else { return nil }
        let diff = selectedWeek.average - previousWeek.average
        if abs(diff) <= trendNeutralThreshold { return .flat }
        return diff > 0 ? .up : .down
    }

    private var trendColor: Color {
        switch trend {
        case .down: return .red
        case .flat, .none: return .secondary
        case .up: return ringColor
        }
    }

    private var trendSystemImage: String {
        switch trend {
        case .down: return "arrow.down"
        case .flat, .none: return "minus"
        case .up: return "arrow.up"
        }
    }

    private var trendA11yText: String? {
        switch trend {
        case .down: return "en baisse par rapport à la semaine précédente"
        case .flat: return "stable par rapport à la semaine précédente"
        case .up: return "en hausse par rapport à la semaine précédente"
        case .none: return nil
        }
    }

    private func rangeLabel(_ week: HistoryStats.WeeklyAverage) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.setLocalizedDateFormatFromTemplate("d MMMM")
        return "\(formatter.string(from: week.startDate)) – \(formatter.string(from: week.endDate))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tendance sur \(HistoryStats.weekCount) semaines")
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(Color.primary)

            let maxValue = max(weeklyAverages.map(\.average).max() ?? 1, 1)
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(Array(weeklyAverages.enumerated()), id: \.offset) { index, week in
                    Button {
                        selectedIndex = index
                    } label: {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(index == selectedIndex ? ringColor : ringColor.opacity(0.3))
                            .frame(height: max(4, CGFloat(week.average) / CGFloat(maxValue) * 100))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Semaine du \(rangeLabel(week))")
                    .accessibilityValue("\(week.average.formatted()) pas par jour en moyenne")
                    .accessibilityAddTraits(.isButton)
                }
            }
            .frame(height: 100, alignment: .bottom)

            if let selectedWeek {
                VStack(alignment: .leading, spacing: 2) {
                    Text(rangeLabel(selectedWeek))
                        .font(.caption)
                        .foregroundStyle(Color.secondary)

                    HStack(spacing: 6) {
                        Text("\(selectedWeek.average.formatted()) pas/jour en moyenne")
                            .font(.system(.subheadline, design: .rounded).weight(.semibold))
                            .foregroundStyle(ringColor)

                        if trend != nil {
                            Image(systemName: trendSystemImage)
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(trendColor)
                                .frame(width: 18, height: 18)
                                .background(trendColor.opacity(0.15), in: Circle())
                        }
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(rangeLabel(selectedWeek)), \(selectedWeek.average.formatted()) pas par jour en moyenne"
                    + (trendA11yText.map { ", \($0)" } ?? ""))
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - YearlyTotalsSection

/// Totaux mensuels d'une année civile complète (janvier à décembre). Les mois pas encore
/// vécus sont grisés, à une hauteur de référence (moyenne des mois déjà vécus de l'année),
/// pour ne pas les afficher comme un « 0 » trompeur. Balayage horizontal pour changer d'année,
/// aussi loin que l'historique HealthKit disponible ; année en cours par défaut.
private struct YearlyTotalsSection: View {
    let yearlyTotals: [HistoryStats.YearlyTotals]
    let ringColor: Color

    @State private var selectedIndex: Int
    private let haptic = UIImpactFeedbackGenerator(style: .light)

    init(yearlyTotals: [HistoryStats.YearlyTotals], ringColor: Color) {
        self.yearlyTotals = yearlyTotals
        self.ringColor = ringColor
        _selectedIndex = State(initialValue: max(0, yearlyTotals.count - 1))
    }

    private var selectedYear: HistoryStats.YearlyTotals? {
        yearlyTotals.indices.contains(selectedIndex) ? yearlyTotals[selectedIndex] : nil
    }

    /// Moyenne des mois déjà vécus de l'année sélectionnée — sert de hauteur de référence
    /// pour les barres grisées des mois futurs (au lieu d'un « 0 » qui laisserait croire à une absence de données).
    private func averageOfLivedMonths(_ year: HistoryStats.YearlyTotals) -> Int {
        let lived = year.months.filter { !$0.isFuture }.map(\.total)
        guard !lived.isEmpty else { return 0 }
        return lived.reduce(0, +) / lived.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Totaux mensuels")
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color.primary)
                Spacer()
                if let selectedYear {
                    Text(String(selectedYear.year))
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(Color.secondary)
                }
            }

            if let selectedYear {
                let averageSoFar = averageOfLivedMonths(selectedYear)
                let maxValue = max(selectedYear.months.map(\.total).max() ?? 1, averageSoFar, 1)

                HStack(alignment: .bottom, spacing: 6) {
                    ForEach(selectedYear.months) { month in
                        VStack(spacing: 4) {
                            let value = month.isFuture ? averageSoFar : month.total
                            RoundedRectangle(cornerRadius: 3)
                                .fill(month.isFuture ? Color.secondary.opacity(0.15) : ringColor.opacity(0.7))
                                .frame(height: max(4, CGFloat(value) / CGFloat(maxValue) * 100))
                            // Lettre unique (au lieu de l'abréviation complète) : largeur fixe pour
                            // toutes les colonnes, sinon les libellés de largeur inégale ("Févr." vs
                            // "Mai") faussent la répartition de l'HStack et désalignent la grille.
                            Text(String(month.label.prefix(1)).uppercased())
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(month.isFuture ? Color.secondary.opacity(0.5) : Color.secondary)
                                .frame(width: 16)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 124, alignment: .bottom)
                .contentShape(Rectangle())
                // Balayage horizontal pour changer d'année, même convention que la navigation
                // par jour de l'anneau (seuil 44pt, dominance horizontale, haptique léger).
                .gesture(
                    DragGesture(minimumDistance: 24)
                        .onEnded { dragValue in
                            guard abs(dragValue.translation.width) > abs(dragValue.translation.height),
                                  abs(dragValue.translation.width) > 44 else { return }
                            if dragValue.translation.width > 0, selectedIndex > 0 {
                                haptic.impactOccurred()
                                selectedIndex -= 1
                            } else if dragValue.translation.width < 0, selectedIndex < yearlyTotals.count - 1 {
                                haptic.impactOccurred()
                                selectedIndex += 1
                            }
                        }
                )
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Totaux mensuels \(selectedYear.year) : "
                    + selectedYear.months.map { $0.isFuture ? "\($0.label), à venir" : "\($0.label), \($0.total.formatted()) pas" }.joined(separator: ", "))
                .accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment: if selectedIndex < yearlyTotals.count - 1 { selectedIndex += 1 }
                    case .decrement: if selectedIndex > 0 { selectedIndex -= 1 }
                    @unknown default: break
                    }
                }

                Text("Total \(selectedYear.year) : \(selectedYear.yearTotal.formatted()) pas")
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(ringColor)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 2)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Preview

#Preview {
    let viewModel = StepCountViewModel()
    viewModel.historyStats = .mock
    return HistoryDetailView(viewModel: viewModel)
}
