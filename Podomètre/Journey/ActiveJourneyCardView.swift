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

    /// Jalon franchi le plus avancé (borne gauche du segment), `nil` avant le premier.
    private var lastMilestone: Milestone? {
        journey.sortedMilestones
            .filter { progress.unlockedMilestoneIds.contains($0.id) }
            .last
    }

    /// Prochain jalon à atteindre (borne droite du segment).
    private var nextMilestone: Milestone? { journey.nextMilestone(for: progress) }

    private var leftKm: Double { lastMilestone?.km ?? 0 }
    private var rightKm: Double { nextMilestone?.km ?? journey.totalKm }
    private var leftLabel: String { lastMilestone?.label ?? "Départ" }
    private var rightLabel: String { nextMilestone?.label ?? "Arrivée" }

    /// Position du marqueur dans le segment courant (0…1).
    private var segmentProgress: Double {
        let span = rightKm - leftKm
        guard span > 0 else { return 1 }
        return min(max((progress.totalKm - leftKm) / span, 0), 1)
    }

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
        formatter.locale = Locale(identifier: "fr_FR")
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
                        Text(journey.name)
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
                segmentTrack

                // Étape suivante + arrivée estimée
                HStack {
                    Text("Prochaine étape dans \(kmToNext.formatted(.number.precision(.fractionLength(kmToNext < 10 ? 1 : 0)))) km")
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                    Spacer()
                    if let arrivalText {
                        Label("Arrivée ~\(arrivalText)", systemImage: "flag.checkered")
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

    /// Ligne horizontale : jalon gauche ●, marqueur ◉ « tu es ici », jalon droit ○, + libellés.
    private var segmentTrack: some View {
        VStack(spacing: 6) {
            GeometryReader { geo in
                let width = geo.size.width
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.15))
                        .frame(height: 5)

                    Capsule()
                        .fill(ringColor)
                        .frame(width: width * segmentProgress, height: 5)

                    Circle()
                        .fill(ringColor)
                        .frame(width: 13, height: 13)
                        .overlay(Circle().strokeBorder(Color(.secondarySystemBackground), lineWidth: 2))
                        .offset(x: width * segmentProgress - 6.5)
                }
            }
            .frame(height: 14)

            HStack {
                Text(leftLabel)
                    .font(.caption2)
                    .foregroundStyle(Color.secondary)
                    .lineLimit(1)
                Spacer(minLength: 12)
                Text(rightLabel)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)
            }
        }
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
