import SwiftUI

/// Vue unique d'onboarding — carrousel 4 pages géré en interne.
struct OnboardingView: View {

    @ObservedObject var viewModel: StepCountViewModel
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var page: Int = 0
    @State private var selectedGoal: Int = 8000

    private let goals: [(steps: Int, label: String, sublabel: String)] = [
        (5000,  "5 000 pas",  "Idéal pour commencer"),
        (8000,  "8 000 pas",  "Recommandé par l'OMS"),
        (10000, "10 000 pas", "Objectif classique"),
        (15000, "15 000 pas", "Objectif sportif")
        (20000, "20 000 pas", "Je marche beaucoup")
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                // Carrousel
                TabView(selection: $page) {
                    slide1.tag(0)
                    slide2.tag(1)
                    slide3.tag(2)
                    slide4(geo: geo).tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: page)
                .ignoresSafeArea()

                // Overlay fixe en bas : dots + bouton
                VStack(spacing: 12) {
                    dots

                    switch page {
                    case 0, 1:
                        primaryButton(label: "Suivant") { page += 1 }
                    case 2:
                        primaryButton(label: "Autoriser l'accès", color: .accentColor) {
                            Task {
                                await viewModel.requestAuthorizationAndFetch()
                                page += 1
                            }
                        }
                        secondaryButton(label: "Plus tard") { page += 1 }
                    default:
                        primaryButton(label: "Lancer l'app", color: viewModel.ringColor) {
                            viewModel.goal = selectedGoal
                            hasCompletedOnboarding = true
                        }
                        secondaryButton(label: "Choisir plus tard") {
                            hasCompletedOnboarding = true
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, geo.safeAreaInsets.bottom + 16)
                .padding(.top, 20)
                .background(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea(edges: .bottom)
                )
            }
        }
        .interactiveDismissDisabled()
    }

    // MARK: - Slides

    /// Slide 1 — écran d'activité.
    private var slide1: some View {
        VStack(spacing: 0) {
            Image("onboarding_activity")
                .resizable()
                .scaledToFit()
                .accessibilityHidden(true)

            ZStack {
                LinearGradient(
                    colors: [
                        Color(.systemBackground).opacity(0),
                        Color(.systemBackground).opacity(0.98)
                    ],
                    startPoint: .top,
                    endPoint: .center
                )

                slideCaption(
                    title: "Vos pas du jour, en un coup d'œil",
                    subtitle: "Suivez votre progression quotidienne et naviguez dans votre historique."
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Spacer()
        }
        .background(Color(.systemBackground))
    }

    /// Slide 2 — écran des trajets.
    private var slide2: some View {
        ZStack(alignment: .top) {
            Image("onboarding_journeys")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .accessibilityHidden(true)

            LinearGradient(
                colors: [.clear, Color(.systemBackground).opacity(0.5)],
                startPoint: .center,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                Spacer()
                slideCaption(
                    title: "Marchez vers des destinations légendaires",
                    subtitle: "Vos kilomètres réels vous font avancer sur le GR20, Compostelle ou l'Odyssée d'Ulysse."
                )
            }
        }
    }

    /// Slide 3 — permissions HealthKit.
    private var slide3: some View {
        ScrollView {
            VStack(spacing: 16) {
                Spacer().frame(height: 60)

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
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                VStack(spacing: 8) {
                    infoBlock(icon: "figure.walk",
                              title: "Nombre de pas",
                              subtitle: "Comptage en temps réel via HealthKit")
                    infoBlock(icon: "arrow.left.and.right",
                              title: "Distance parcourue",
                              subtitle: "Marche et course pour les trajets")
                }

                Text("Ces données ne quittent jamais votre iPhone.")
                    .font(.caption)
                    .foregroundStyle(Color(UIColor.tertiaryLabel))
                    .multilineTextAlignment(.center)

                // Espace pour l'overlay fixe
                Spacer().frame(height: 160)
            }
            .padding(.horizontal, 24)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    /// Slide 4 — sélection de l'objectif.
    private func slide4(geo: GeometryProxy) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                Spacer().frame(height: 60)

                Text("Quel est votre objectif quotidien ?")
                    .font(.system(.title3, design: .rounded)).fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Text("Modifiable à tout moment dans les Paramètres.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                VStack(spacing: 10) {
                    ForEach(goals, id: \.steps) { choice in
                        goalButton(choice: choice)
                    }
                }

                // Espace pour l'overlay fixe
                Spacer().frame(height: 180)
            }
            .padding(.horizontal, 24)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    // MARK: - Composants réutilisables

    /// Texte de légende positionné en bas des slides photo.
    private func slideCaption(title: String, subtitle: String) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(.title3, design: .rounded)).fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            Text(subtitle)
                .font(.system(.subheadline))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 180)
    }

    /// Bloc informatif icône + texte pour la slide HealthKit.
    private func infoBlock(icon: String, title: String, subtitle: String) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemBackground))
            .overlay(
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundStyle(viewModel.ringColor)
                        .frame(width: 36)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(.subheadline, design: .rounded)).fontWeight(.medium)
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(12)
            )
    }

    /// Bouton de choix d'objectif (slide 4).
    private func goalButton(choice: (steps: Int, label: String, sublabel: String)) -> some View {
        let isSelected = selectedGoal == choice.steps
        return Button { selectedGoal = choice.steps } label: {
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? viewModel.ringColor.opacity(0.08) : Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? viewModel.ringColor : Color(.systemGray4),
                                lineWidth: isSelected ? 2 : 1)
                )
                .overlay(
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(choice.label)
                                .font(.system(.subheadline, design: .rounded)).fontWeight(.medium)
                                .foregroundStyle(Color.primary)
                            Text(choice.sublabel)
                                .font(.caption)
                                .foregroundStyle(.secondary)
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

    /// Indicateurs de page animés.
    private var dots: some View {
        HStack(spacing: 8) {
            ForEach(0..<4, id: \.self) { i in
                Capsule()
                    .fill(i == page ? Color.accentColor : Color(.systemGray4))
                    .frame(width: i == page ? 20 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.25), value: page)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Étape \(page + 1) sur 4")
    }

    /// Bouton principal pleine largeur.
    private func primaryButton(label: String, color: Color = .accentColor, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Capsule().fill(color))
        }
    }

    /// Bouton secondaire discret.
    private func secondaryButton(label: String, action: @escaping () -> Void) -> some View {
        Button(label, action: action)
            .buttonStyle(.plain)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
}
