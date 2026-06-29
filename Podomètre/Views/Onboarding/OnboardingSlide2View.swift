// TODO: Ajouter l'image "onboarding_journeys" dans Assets.xcassets
// depuis les screenshots simulateur.
// Résolution recommandée : 390x844 @2x (iPhone standard).

import SwiftUI

/// Deuxième slide d'onboarding — présente le système de trajets et la progression réelle.
struct OnboardingSlide2View<Dots: View, Next: View>: View {

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
            Image("onboarding_journeys")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .accessibilityHidden(true)

            VStack {
                Spacer()

                VStack(spacing: 8) {
                    Text("Marchez vers des destinations légendaires")
                        .font(.system(.title3, design: .rounded)).fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.primary)
                        .accessibilityAddTraits(.isHeader)

                    Text("Vos kilomètres réels vous font avancer sur le GR20, Compostelle ou l'Odyssée d'Ulysse.")
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
