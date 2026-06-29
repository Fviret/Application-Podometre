import SwiftUI

/// Quatrième slide d'onboarding — sélection de l'objectif quotidien.
struct OnboardingSlide4View<Dots: View>: View {

    @ObservedObject var viewModel: StepCountViewModel
    @Binding var currentStep: Int
    let dotsView: Dots

    @State private var selectedGoal: Int = 8000
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    private let choices: [(steps: Int, label: String, sublabel: String)] = [
        (5000,  "5 000 pas",  "Idéal pour commencer"),
        (8000,  "8 000 pas",  "Recommandé par l'OMS"),
        (10000, "10 000 pas", "Objectif classique"),
    ]

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
                Text("Quel est votre objectif quotidien ?")
                    .font(.system(.title3, design: .rounded)).fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Text("Modifiable à tout moment dans les Paramètres.")
                    .font(.system(.subheadline))
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)

                VStack(spacing: 10) {
                    ForEach(choices, id: \.steps) { choice in
                        goalButton(choice: choice)
                    }
                }

                dotsView

                Button {
                    viewModel.goal = selectedGoal
                    hasCompletedOnboarding = true
                } label: {
                    Text("Lancer l'app")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(viewModel.ringColor))
                }

                Button("Choisir plus tard") {
                    hasCompletedOnboarding = true
                }
                .buttonStyle(.plain)
                .font(.system(.subheadline))
                .foregroundStyle(Color.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 40)
        }
    }

    /// Bouton de sélection d'objectif avec état sélectionné/non sélectionné.
    private func goalButton(choice: (steps: Int, label: String, sublabel: String)) -> some View {
        let isSelected = selectedGoal == choice.steps

        return Button {
            selectedGoal = choice.steps
        } label: {
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? viewModel.ringColor.opacity(0.08) : Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isSelected ? viewModel.ringColor : Color(.systemGray4),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
                .overlay(
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(choice.label)
                                .font(.system(.subheadline, design: .rounded)).fontWeight(.medium)
                                .foregroundStyle(Color.primary)
                            Text(choice.sublabel)
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                        }

                        Spacer()

                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(viewModel.ringColor)
                                .accessibilityHidden(true)
                        } else {
                            Circle()
                                .stroke(Color(.systemGray4), lineWidth: 1.5)
                                .frame(width: 18, height: 18)
                                .accessibilityHidden(true)
                        }
                    }
                    .padding(12)
                )
                .frame(height: 60)
        }
        .accessibilityValue(isSelected ? "Sélectionné" : "")
    }
}
