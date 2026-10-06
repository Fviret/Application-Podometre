import SwiftUI

/// Remplace temporairement le contenu par un squelette qui pulse, tant que les données Santé ne
/// sont pas arrivées : évite un écran « à 0 » qui ressemble à un bug, sans rien afficher de faux.
///
/// Les textes passent en blocs grisés (`.redacted`), l'ensemble pulse doucement (fixe si
/// « Réduire les animations » est actif) et n'est plus interactif ni lu par VoiceOver.
struct LoadingPlaceholderModifier: ViewModifier {
    let isLoading: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulse = false

    func body(content: Content) -> some View {
        content
            .redacted(reason: isLoading ? .placeholder : [])
            .opacity(isLoading && pulse ? 0.45 : 1)
            .allowsHitTesting(!isLoading)
            .accessibilityHidden(isLoading)
            .onAppear { startPulseIfNeeded() }
            .onChange(of: isLoading) { _, _ in startPulseIfNeeded() }
    }

    /// Lance l'oscillation d'opacité (aller-retour continu) quand le chargement commence.
    private func startPulseIfNeeded() {
        guard isLoading, !reduceMotion else {
            pulse = false
            return
        }
        withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
            pulse = true
        }
    }
}

extension View {
    /// Affiche un squelette pulsant à la place du contenu tant que `isLoading` est vrai.
    func loadingPlaceholder(isLoading: Bool) -> some View {
        modifier(LoadingPlaceholderModifier(isLoading: isLoading))
    }
}

#Preview {
    VStack(spacing: 24) {
        Text("7 454 pas").font(.largeTitle).loadingPlaceholder(isLoading: true)
        Text("7 454 pas").font(.largeTitle).loadingPlaceholder(isLoading: false)
    }
    .padding()
}
