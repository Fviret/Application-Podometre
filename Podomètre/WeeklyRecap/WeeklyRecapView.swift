import SwiftUI

/// Sheet récapitulative affichée le lundi à la première ouverture de la semaine : bilan de la
/// semaine écoulée (pas, calories, distance, temps d'activité) avec comparaison à la semaine
/// précédente, dans la thématique visuelle du suivi (anneau, badges, flamme).
struct WeeklyRecapView: View {
    let recap: WeeklyRecapData
    let ringColor: Color

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    header

                    VStack(spacing: 12) {
                        statRow(
                            icon: "figure.walk",
                            label: "Pas",
                            value: recap.totalSteps.formatted(),
                            trend: WeeklyRecapTrend(current: Double(recap.totalSteps), previous: Double(recap.previousTotalSteps))
                        )
                        statRow(
                            icon: "flame.fill",
                            label: "Calories",
                            value: "\(recap.totalCalories) kcal",
                            trend: WeeklyRecapTrend(current: Double(recap.totalCalories), previous: Double(recap.previousTotalCalories))
                        )
                        statRow(
                            icon: "map.fill",
                            label: "Distance",
                            value: distanceText,
                            trend: WeeklyRecapTrend(current: recap.totalDistanceKm, previous: recap.previousTotalDistanceKm)
                        )
                        statRow(
                            icon: "clock.fill",
                            label: "Temps d'activité",
                            value: activeTimeText,
                            trend: WeeklyRecapTrend(current: Double(recap.totalActiveMinutes), previous: Double(recap.previousTotalActiveMinutes))
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 28)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
    }

    // MARK: - En-tête

    private var header: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(ringColor.opacity(0.15))
                    .frame(width: 72, height: 72)
                Image(systemName: "calendar.badge.checkmark")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(ringColor)
            }
            .accessibilityHidden(true)

            Text("Rapport hebdomadaire")
                .font(.system(.title2, design: .rounded).weight(.bold))
                .foregroundStyle(Color.primary)

            Text(String(format: String(localized: "Vous avez atteint votre objectif %@ fois cette semaine"), "\(recap.goalReachedCount)"))
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Lignes de statistiques

    private func statRow(icon: String, label: String, value: String, trend: WeeklyRecapTrend) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(ringColor)
                .frame(width: 32)
                .accessibilityHidden(true)

            Text(label)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Color.primary)

            Spacer()

            Text(value)
                .font(.system(.headline, design: .rounded).weight(.semibold))
                .foregroundStyle(Color.primary)
                .monospacedDigit()

            trendBadge(trend)
        }
        .padding(14)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label) : \(value), \(trendAccessibilityText(trend))")
    }

    private func trendBadge(_ trend: WeeklyRecapTrend) -> some View {
        Image(systemName: trendSystemImage(trend))
            .font(.caption.weight(.bold))
            .foregroundStyle(trendColor(trend))
            .frame(width: 22, height: 22)
            .background(trendColor(trend).opacity(0.15), in: Circle())
            .accessibilityHidden(true)
    }

    private func trendColor(_ trend: WeeklyRecapTrend) -> Color {
        switch trend {
        case .down: return .red
        case .flat: return .secondary
        case .up: return ringColor
        }
    }

    private func trendSystemImage(_ trend: WeeklyRecapTrend) -> String {
        switch trend {
        case .down: return "arrow.down"
        case .flat: return "minus"
        case .up: return "arrow.up"
        }
    }

    private func trendAccessibilityText(_ trend: WeeklyRecapTrend) -> String {
        switch trend {
        case .down: return "en baisse par rapport à la semaine précédente"
        case .flat: return "stable par rapport à la semaine précédente"
        case .up: return "en hausse par rapport à la semaine précédente"
        }
    }

    // MARK: - Formatage

    private var distanceText: String {
        recap.totalDistanceKm.formatted(.number.precision(.fractionLength(1))) + " km"
    }

    private var activeTimeText: String {
        let total = recap.totalActiveMinutes
        guard total >= 60 else { return "\(total) min" }
        let hours = total / 60
        let minutes = total % 60
        return minutes == 0 ? "\(hours) h" : "\(hours) h \(minutes) min"
    }
}

#Preview {
    WeeklyRecapView(
        recap: WeeklyRecapData(
            weekStart: Date(),
            goalReachedCount: 5,
            totalSteps: 62_400,
            previousTotalSteps: 54_100,
            totalDistanceKm: 44.8,
            previousTotalDistanceKm: 39.2,
            totalCalories: 3_120,
            previousTotalCalories: 3_260,
            totalActiveMinutes: 260,
            previousTotalActiveMinutes: 240
        ),
        ringColor: .green
    )
}
