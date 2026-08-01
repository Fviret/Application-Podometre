import SwiftUI

/// Card épinglée en haut de l'écran Trajets pour le trajet en cours.
///
/// Trois niveaux de lecture : le pourcentage global (vue d'ensemble), un tracé du segment
/// entre le dernier jalon franchi et le prochain avec un marqueur « tu es ici » (objectif proche),
/// et la distance restante jusqu'à la prochaine étape. Affiche aussi une date d'arrivée estimée
/// quand une cadence de marche est connue. Un tap ouvre le détail du trajet.
struct ActiveJourneyCardView: View {
    let journey: Journey
    let progress: JourneyProgress
    let ringColor: Color
    /// Moyenne de pas quotidiens, pour l'estimation d'arrivée. `nil` = pas d'estimation.
    var averageDailySteps: Int? = nil
    let onTap: () -> Void

    // MARK: - Calculs

    /// Progression globale du trajet (0…1).
    private var overallPercent: Double { journey.progressPercent(for: progress) }

    /// Prochain jalon à atteindre (pour le libellé et la distance restante).
    private var nextMilestone: Milestone? { journey.nextMilestone(for: progress) }
    private var rightLabel: String { nextMilestone?.label ?? "Arrivée" }
    private var rightKm: Double { nextMilestone?.km ?? journey.totalKm }

    /// Distance restante jusqu'au prochain jalon, en km (jamais négative).
    private var kmToNext: Double { max(rightKm - progress.totalKm, 0) }

    /// Date d'arrivée estimée « à ton rythme », ou `nil` si aucune cadence connue.
    private var estimatedArrival: Date? {
        guard let avg = averageDailySteps, avg > 0 else { return nil }
        let remainingKm = max(journey.totalKm - progress.totalKm, 0)
        let kmPerDay = avg.asKilometers
        guard kmPerDay > 0 else { return nil }
        let days = Int((remainingKm / kmPerDay).rounded(.up))
        return Calendar.current.date(byAdding: .day, value: days, to: Date())
    }

    private var arrivalText: String? {
        guard let date = estimatedArrival else { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale.autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("d MMMM")
        return formatter.string(from: date)
    }

    // MARK: - Vue

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 14) {

                // En-tête : emoji + nom + % global
                HStack(spacing: 12) {
                    Text(journey.emoji)
                        .font(.title2)
                        .frame(width: 40, height: 40)
                        .background(ringColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 1) {
                        Text("Trajet en cours")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Color.secondary)
                            .textCase(.uppercase)
                        Text(LocalizedStringKey(journey.name))
                            .font(.system(.headline, design: .rounded))
                            .foregroundStyle(Color.primary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Text("\(Int((overallPercent * 100).rounded())) %")
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundStyle(ringColor)

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.secondary)
                        .accessibilityHidden(true)
                }

                // Tracé du segment étape → étape avec marqueur « tu es ici »
                JourneySegmentTrackView(journey: journey, progress: progress, tint: ringColor)

                // Étape suivante + arrivée estimée
                HStack {
                    Text(String(format: String(localized: "Prochaine étape dans %@ km"), kmToNext.formatted(.number.precision(.fractionLength(kmToNext < 10 ? 1 : 0)))))
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                    Spacer()
                    if let arrivalText {
                        Label(String(format: String(localized: "Arrivée ~%@"), arrivalText), systemImage: "flag.checkered")
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                            .labelStyle(.titleAndIcon)
                    }
                }
            }
            .padding(16)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySummary)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Ouvre le détail du trajet")
    }

    private var accessibilitySummary: String {
        var s = "Trajet en cours : \(journey.name), \(Int((overallPercent * 100).rounded())) %. "
        s += "Prochaine étape : \(rightLabel), dans \(kmToNext.formatted(.number.precision(.fractionLength(1)))) km."
        if let arrivalText { s += " Arrivée estimée vers le \(arrivalText)." }
        return s
    }
}

// MARK: - Preview

/// Construit une progression fictive sur un trajet donné (km parcourus + jalons franchis déduits).
private func previewProgress(_ journey: Journey, km: Double) -> JourneyProgress {
    let unlocked = journey.sortedMilestones.filter { $0.km <= km }.map(\.id)
    return JourneyProgress(
        journeyId: journey.id,
        totalKm: km,
        unlockedMilestoneIds: Set(unlocked),
        startDate: Date().addingTimeInterval(-14 * 86400),
        lastUpdatedDate: Date()
    )
}

private let previewGR20 = allJourneys.first { $0.name.contains("GR20") } ?? allJourneys[5]

#Preview("États de la card") {
    let color = AppColors.ringColorOptions[0].color
    return ScrollView {
        VStack(spacing: 16) {
            // Milieu de parcours, avec estimation d'arrivée
            ActiveJourneyCardView(journey: previewGR20,
                                  progress: previewProgress(previewGR20, km: 68),
                                  ringColor: color, averageDailySteps: 9_500, onTap: {})

            // Tout début (avant le 1er jalon → « Départ »)
            ActiveJourneyCardView(journey: previewGR20,
                                  progress: previewProgress(previewGR20, km: 4),
                                  ringColor: color, averageDailySteps: 6_200, onTap: {})

            // Proche de l'arrivée
            ActiveJourneyCardView(journey: previewGR20,
                                  progress: previewProgress(previewGR20, km: 172),
                                  ringColor: color, averageDailySteps: 12_000, onTap: {})

            // Sans historique de pas → pas d'ETA
            ActiveJourneyCardView(journey: previewGR20,
                                  progress: previewProgress(previewGR20, km: 90),
                                  ringColor: color, averageDailySteps: nil, onTap: {})
        }
        .padding()
    }
}
