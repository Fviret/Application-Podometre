import SwiftUI

/// Troisième slide d'onboarding — demande les permissions HealthKit.
struct OnboardingSlide3View<Dots: View>: View {

    @ObservedObject var viewModel: StepCountViewModel
    @Binding var currentStep: Int
    let dotsView: Dots

    init(
        viewModel: StepCountViewModel,
        currentStep: Binding<Int>,
        @ViewBuilder dotsView: () -> Dots
    ) {
        self.viewModel = viewModel
        _currentStep = currentStep
        self.dotsView = dotsView()
    }

    var body: some View {
        Color(.systemGroupedBackground).ignoresSafeArea()

        ScrollView {
            VStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(.systemBackground))
                        .frame(width: 72, height: 72)
                        .shadow(color: .black.opacity(0.1), radius: 2)

                    Image(systemName: "heart.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.red)
                        .accessibilityHidden(true)
                }

                Text("Accès à vos données de santé")
                    .font(.system(.title3, design: .rounded)).fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Text("Pour suivre vos pas et calculer votre progression sur les trajets.")
                    .font(.system(.subheadline))
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                VStack(spacing: 8) {
                    infoBlock(
                        icon: "figure.walk",
                        title: "Nombre de pas",
                        subtitle: "Comptage en temps réel via HealthKit",
                        ringColor: viewModel.ringColor
                    )
                    infoBlock(
                        icon: "arrow.left.and.right",
                        title: "Distance parcourue",
                        subtitle: "Marche et course pour les trajets",
                        ringColor: viewModel.ringColor
                    )
                }

                Text("Ces données ne quittent jamais votre iPhone.")
                    .font(.caption)
                    .foregroundStyle(Color(UIColor.tertiaryLabel))
                    .multilineTextAlignment(.center)

                dotsView

                Button {
                    Task {
                        await viewModel.requestAuthorizationAndFetch()
                        currentStep += 1
                    }
                } label: {
                    Text("Autoriser l'accès")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(Color.accentColor))
                }
                .accessibilityLabel("Autoriser l'accès à HealthKit")

                Button("Plus tard") {
                    currentStep += 1
                }
                .buttonStyle(.plain)
                .font(.system(.subheadline))
                .foregroundStyle(Color.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 40)
        }
    }

    /// Bloc informatif avec icône SF Symbol et texte descriptif.
    private func infoBlock(icon: String, title: String, subtitle: String, ringColor: Color) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemBackground))
            .overlay(
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundStyle(ringColor)
                        .frame(width: 36)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(.subheadline, design: .rounded)).fontWeight(.medium)
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                    }

                    Spacer()
                }
                .padding(12)
            )
    }
}
