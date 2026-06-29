import Foundation

/// Choix d'objectifs proposés à l'onboarding.
struct OnboardingGoal {
    let steps: Int
    let label: String
    let sublabel: String
}

/// Catalogue statique des objectifs proposés lors de l'onboarding.
let onboardingGoals: [OnboardingGoal] = [
    OnboardingGoal(steps: 5_000,  label: "5 000 pas",  sublabel: "Idéal pour commencer"),
    OnboardingGoal(steps: 8_000,  label: "8 000 pas",  sublabel: "Recommandé par l'OMS"),
    OnboardingGoal(steps: 10_000, label: "10 000 pas", sublabel: "Objectif classique"),
    OnboardingGoal(steps: 15_000, label: "15 000 pas", sublabel: "Objectif sportif"),
    OnboardingGoal(steps: 20_000, label: "20 000 pas", sublabel: "Je marche beaucoup"),
]

/// Objectif sélectionné par défaut à l'onboarding.
let onboardingDefaultGoal: Int = 8_000

/// Clé UserDefaults indiquant si l'onboarding a été complété.
let onboardingCompletedKey = "hasCompletedOnboarding"
