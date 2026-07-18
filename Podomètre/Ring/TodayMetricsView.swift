import SwiftUI

/// Rangée de métriques du jour affichée sous l'anneau : distance, temps actif, calories.
/// Les données proviennent de HealthKit (`StepCountViewModel`). Temps actif et calories
/// peuvent rester à 0 sans Apple Watch — les tuiles restent affichées.
struct TodayMetricsView: View {
    @ObservedObject var viewModel: StepCountViewModel

    var body: some View {
        HStack(spacing: 12) {
            metricTile(
                icon: "figure.walk",
                value: distanceText,
                label: "Distance",
                a11y: "Distance parcourue : \(distanceText)"
            )
            metricTile(
                icon: "clock.fill",
                value: "\(viewModel.todayActiveMinutes) min",
                label: "Temps actif",
                a11y: "Temps actif : \(viewModel.todayActiveMinutes) minutes"
            )
            metricTile(
                icon: "flame.fill",
                value: "\(viewModel.todayActiveCalories) kcal",
                label: "Calories",
                a11y: "Calories actives : \(viewModel.todayActiveCalories) kilocalories"
            )
        }
    }

    /// Distance formatée avec une décimale (unité km), séparateur localisé.
    private var distanceText: String {
        viewModel.todayDistanceKm.formatted(.number.precision(.fractionLength(1))) + " km"
    }

    /// Tuile individuelle : icône teintée + valeur + libellé.
    private func metricTile(icon: String, value: String, label: String, a11y: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(viewModel.ringColor)
                .accessibilityHidden(true)

            Text(value)
                .font(.system(.headline, design: .rounded).weight(.semibold))
                .foregroundStyle(Color.primary)
                .contentTransition(.numericText())

            Text(label)
                .font(.caption)
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(a11y)
    }
}

#Preview {
    TodayMetricsView(viewModel: .previewGoalReached)
        .padding()
}
