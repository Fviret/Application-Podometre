// TODO: Ajouter l'image "onboarding_activity" dans Assets.xcassets
// depuis les screenshots simulateur.
// Résolution recommandée : 390x844 @2x (iPhone standard).

import SwiftUI

/// Première slide d'onboarding — présente l'écran d'activité et l'anneau de progression.
struct OnboardingSlide1View<Dots: View, Next: View>: View {

    @Binding var currentStep: Int
    let dotsView: Dots
    let nextButton: Next

    init(
        currentStep: Binding<Int>,
        @ViewBuilder dotsView: () -> Dots,
        @ViewBuilder nextButton: () -> Next
    ) {
        _currentStep = currentStep
        self.dotsView = dotsView()
        self.nextButton = nextButton()
    }

    var body: some View {
        ZStack {
            Image("onboarding_activity")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .accessibilityHidden(true)

            VStack {
                Spacer()

                VStack(spacing: 8) {
                    Text("Vos pas du jour, en un coup d'œil")
                        .font(.system(.title3, design: .rounded)).fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.primary)
                        .accessibilityAddTraits(.isHeader)

                    Text("Suivez votre progression quotidienne et naviguez dans votre historique.")
                        .font(.system(.subheadline, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.secondary)
                        .padding(.horizontal, 8)

                    dotsView

                    nextButton
                        .accessibilityLabel("Passer à l'étape suivante")
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .padding(.top, 48)
                .background(
                    LinearGradient(
                        colors: [
                            Color(.systemBackground).opacity(0),
                            Color(.systemBackground).opacity(0.97)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
    }
}
