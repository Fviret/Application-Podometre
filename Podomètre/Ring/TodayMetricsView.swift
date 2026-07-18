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
                value: activeTimeText,
                label: "Temps actif",
                a11y: "Temps actif : \(activeTimeAccessibility)"
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

    /// Temps actif formaté : « 45 min » sous 1 h, sinon « 1 h 14 min » (ou « 2 h » si pile).
    private var activeTimeText: String {
        let total = viewModel.todayActiveMinutes
        guard total >= 60 else { return "\(total) min" }
        let hours = total / 60
        let minutes = total % 60
        return minutes == 0 ? "\(hours) h" : "\(hours) h \(minutes) min"
    }

    /// Formulation accessible du temps actif (VoiceOver).
    private var activeTimeAccessibility: String {
        let total = viewModel.todayActiveMinutes
        guard total >= 60 else { return "\(total) minutes" }
        let hours = total / 60
        let minutes = total % 60
        let heure = hours > 1 ? "heures" : "heure"
        return minutes == 0 ? "\(hours) \(heure)" : "\(hours) \(heure) \(minutes) minutes"
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
