import SwiftUI

/// Tracé horizontal du segment courant d'un trajet : du dernier jalon franchi au prochain,
/// avec un marqueur « tu es ici » positionné selon la progression dans le segment.
///
/// Partagé par la card du trajet en cours (`ActiveJourneyCardView`) et le détail
/// (`JourneyDetailView`) pour une représentation cohérente.
struct JourneySegmentTrackView: View {
    let journey: Journey
    let progress: JourneyProgress
    let tint: Color

    /// Dernier jalon franchi (borne gauche), `nil` avant le premier → « Départ ».
    private var lastMilestone: Milestone? {
        journey.sortedMilestones
            .filter { progress.unlockedMilestoneIds.contains($0.id) }
            .last
    }

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
    var kmToNext: Double { max(rightKm - progress.totalKm, 0) }

    var body: some View {
        VStack(spacing: 6) {
            GeometryReader { geo in
                let width = geo.size.width
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.15))
                        .frame(height: 5)

                    Capsule()
                        .fill(tint)
                        .frame(width: width * segmentProgress, height: 5)

                    Circle()
                        .fill(tint)
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Segment en cours : de \(leftLabel) à \(rightLabel), prochaine étape dans \(kmToNext.formatted(.number.precision(.fractionLength(1)))) km")
    }
}
