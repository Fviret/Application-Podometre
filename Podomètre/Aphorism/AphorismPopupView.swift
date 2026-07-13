import SwiftUI
import UIKit

/// Popup matinale « pensée du jour » : fond semi-transparent, carte de l'aphorisme
/// et bouton principal « Make my day » qui referme la vue.
///
/// Conçue pour être posée en overlay au-dessus de l'app ; anime son apparition/disparition.
struct AphorismPopupView: View {
    let aphorism: Aphorism
    /// Couleur d'accent du bouton principal (couleur de l'anneau de l'utilisateur).
    var accentColor: Color = .accentColor
    let onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }
                .accessibilityHidden(true)

            VStack(spacing: 20) {
                Text("Pensée du jour")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Color.secondary)
                    .accessibilityAddTraits(.isHeader)

                AphorismCardView(aphorism: aphorism, allowsCopy: false)

                Button(action: dismissWithHaptic) {
                    Text("Make my day")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(accentColor))
                }
                .accessibilityIdentifier("aphorism_make_my_day")
                .accessibilityLabel("Fermer la pensée du jour")
            }
            .padding(24)
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal, 28)
            .shadow(color: .black.opacity(0.15), radius: 20, y: 8)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("aphorism_popup")
            .accessibilityAddTraits(.isModal)
        }
        .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.95)))
    }

    /// Déclenche un retour haptique de confirmation avant de fermer la popup.
    private func dismissWithHaptic() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        onDismiss()
    }
}

#Preview {
    AphorismPopupView(
        aphorism: Aphorism(
            id: 1,
            text: "Le seul moyen de se débarrasser d'une tentation, c'est d'y céder.",
            author: "Oscar Wilde",
            category: "ironie"
        ),
        onDismiss: {}
    )
}
