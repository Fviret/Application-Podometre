import Foundation

/// Choix d'objectifs proposés à l'onboarding et dans les Paramètres.
struct OnboardingGoal {
    let steps: Int
    let label: String
    let sublabel: String
    /// Niveau d'effort associé (ex. « Léger », « Ambitieux »), affiché dans le menu des Paramètres.
    let effort: String
}

/// Catalogue statique des objectifs proposés (onboarding + sélecteur des Paramètres).
let onboardingGoals: [OnboardingGoal] = [
    OnboardingGoal(steps: 5_000,  label: "5 000 pas",  sublabel: "Idéal pour commencer", effort: "Léger"),
    OnboardingGoal(steps: 8_000,  label: "8 000 pas",  sublabel: "Recommandé par l'OMS", effort: "Régulier"),
    OnboardingGoal(steps: 10_000, label: "10 000 pas", sublabel: "Objectif classique",   effort: "Ambitieux"),
    OnboardingGoal(steps: 15_000, label: "15 000 pas", sublabel: "Objectif sportif",     effort: "Sportif"),
    OnboardingGoal(steps: 20_000, label: "20 000 pas", sublabel: "Je marche beaucoup",   effort: "Titan"),
]

/// Retourne le niveau d'effort correspondant à un objectif, si présent au catalogue.
func effortLabel(forGoal steps: Int) -> String? {
    onboardingGoals.first { $0.steps == steps }?.effort
}

/// Objectif sélectionné par défaut à l'onboarding.
let onboardingDefaultGoal: Int = 8_000
