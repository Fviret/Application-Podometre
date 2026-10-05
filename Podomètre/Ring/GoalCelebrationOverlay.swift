import SwiftUI

/// Effet de célébration ponctuel affiché au moment précis où l'objectif du jour est franchi :
/// une pastille « Objectif atteint » et un éclat de particules dans la couleur de l'anneau, qui
/// se dissolvent après un court instant. `StepRingView` pilote l'apparition via `isPresented` —
/// cette vue ne se redéclenche jamais toute seule (pas d'effet à chaque réapparition de l'écran).
struct GoalCelebrationOverlay: View {
    let ringColor: Color
    @Binding var isPresented: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Pilote à la fois l'éclatement des particules et l'agrandissement de la pastille.
    @State private var animateIn = false
    /// Fondu de sortie de l'ensemble (particules + pastille), déclenché après le délai d'affichage.
    @State private var fadeOut = false

    private let particleCount = 12
    private let burstDistance: CGFloat = 90

    var body: some View {
        if isPresented {
            ZStack {
                if !reduceMotion {
                    ForEach(0..<particleCount, id: \.self) { index in
                        particle(at: index)
                    }
                }
                badge
            }
            .opacity(fadeOut ? 0 : 1)
            // Le franchissement de l'objectif est déjà porté par le halo de l'anneau et la valeur
            // d'accessibilité du compteur : cet effet est un bonus purement visuel/haptique.
            .accessibilityHidden(true)
            .onAppear(perform: animate)
        }
    }

    private var badge: some View {
        Text("Objectif atteint 🎉")
            .font(.system(.subheadline, design: .rounded).weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(ringColor, in: Capsule())
            .scaleEffect(animateIn ? 1 : 0.6)
    }

    private func particle(at index: Int) -> some View {
        let angle = Double(index) / Double(particleCount) * 2 * .pi
        let distance = animateIn ? burstDistance : 0
        return Circle()
            .fill(ringColor.opacity(0.85))
            .frame(width: 6, height: 6)
            .offset(x: cos(angle) * distance, y: sin(angle) * distance)
    }

    private func animate() {
        withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.45, dampingFraction: 0.65)) {
            animateIn = true
        }
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            withAnimation(.easeOut(duration: 0.4)) { fadeOut = true }
            try? await Task.sleep(for: .seconds(0.4))
            isPresented = false
        }
    }
}

#Preview {
    GoalCelebrationOverlay(ringColor: .green, isPresented: .constant(true))
        .frame(width: 240, height: 240)
}
