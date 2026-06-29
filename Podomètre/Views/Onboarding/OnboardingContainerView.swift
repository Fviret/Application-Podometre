import SwiftUI

/// Conteneur de l'onboarding — gère la navigation entre les 4 slides.
struct OnboardingContainerView: View {

    @ObservedObject var viewModel: StepCountViewModel
    @State private var currentStep: Int = 0

    var body: some View {
        TabView(selection: $currentStep) {
            OnboardingSlide1View(currentStep: $currentStep) {
                dotsView
            } nextButton: {
                nextButton(label: "Suivant") { currentStep += 1 }
            }
            .tag(0)

            OnboardingSlide2View(currentStep: $currentStep) {
                dotsView
            } nextButton: {
                nextButton(label: "Suivant") { currentStep += 1 }
            }
            .tag(1)

            OnboardingSlide3View(viewModel: viewModel, currentStep: $currentStep) {
                dotsView
            }
            .tag(2)

            OnboardingSlide4View(viewModel: viewModel, currentStep: $currentStep) {
                dotsView
            }
            .tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut, value: currentStep)
        .interactiveDismissDisabled()
    }

    /// Indicateurs de progression (dots) injectés dans chaque slide.
    private var dotsView: some View {
        HStack(spacing: 8) {
            ForEach(0..<4, id: \.self) { index in
                Capsule()
                    .fill(index == currentStep ? Color.accentColor : Color(.systemGray4))
                    .frame(width: index == currentStep ? 20 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.25), value: currentStep)
            }
        }
        .padding(.top, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Étape \(currentStep + 1) sur 4")
    }

    /// Bouton "Suivant" standard utilisé sur les slides 1 et 2.
    private func nextButton(label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Capsule().fill(Color.accentColor))
        }
        .accessibilityLabel("Passer à l'étape suivante")
    }
}
