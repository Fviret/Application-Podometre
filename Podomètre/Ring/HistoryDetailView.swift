import SwiftUI

/// Écran d'historique complet : tendance multi-semaines, totaux mensuels, taux de réussite
/// de l'objectif et records personnels. Ouvert au tap sur le graphe hebdomadaire de l'écran Activité.
struct HistoryDetailView: View {
    @ObservedObject var viewModel: StepCountViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if let stats = viewModel.historyStats {
                        WeeklyTrendSection(weeklyAverages: stats.weeklyAverages, ringColor: viewModel.ringColor)
                        monthlyTotalsSection(stats)
                        goalSuccessSection(stats)
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

    // MARK: - Totaux mensuels

    private func monthlyTotalsSection(_ stats: HistoryStats) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Totaux mensuels")

            let maxValue = max(stats.monthlyTotals.map(\.total).max() ?? 1, 1)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .bottom, spacing: 10) {
                    ForEach(stats.monthlyTotals) { month in
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(viewModel.ringColor.opacity(0.7))
                                .frame(width: 20, height: max(4, CGFloat(month.total) / CGFloat(maxValue) * 100))
                            Text(month.label)
                                .font(.caption2)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                }
                .frame(height: 124, alignment: .bottom)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Totaux mensuels : "
            + stats.monthlyTotals.map { "\($0.label), \($0.total.formatted()) pas" }.joined(separator: ", "))
    }

    // MARK: - Taux de réussite de l'objectif

    private func goalSuccessSection(_ stats: HistoryStats) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Objectif atteint")

            HStack(spacing: 12) {
                successTile(label: "30 jours", rate: stats.goalSuccessRate30)
                successTile(label: "90 jours", rate: stats.goalSuccessRate90)
                successTile(label: "365 jours", rate: stats.goalSuccessRate365)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private func successTile(label: String, rate: Double) -> some View {
        VStack(spacing: 4) {
            Text("\(Int((rate * 100).rounded())) %")
                .font(.system(.title3, design: .rounded).weight(.bold))
                .foregroundStyle(viewModel.ringColor)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Objectif atteint \(Int((rate * 100).rounded())) % des jours sur \(label)")
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
                icon: "flame.fill",
                title: "Plus longue série",
                value: "\(stats.longestStreakEver) jour\(stats.longestStreakEver > 1 ? "s" : "")",
                subtitle: nil
            )
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
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
            }
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Cumul total

    private func allTimeSection(_ stats: HistoryStats) -> some View {
        VStack(spacing: 6) {
            Text(stats.allTimeTotalSteps.formatted())
                .font(.system(.largeTitle, design: .rounded).weight(.bold))
                .foregroundStyle(viewModel.ringColor)
            Text("pas cumulés depuis le début du suivi")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
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
                    Text("\(selectedWeek.average.formatted()) pas/jour en moyenne")
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(ringColor)
                }
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
