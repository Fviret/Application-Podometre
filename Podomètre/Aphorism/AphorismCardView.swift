import SwiftUI
import UIKit

/// Carte présentant un aphorisme : texte en italique, auteur et catégorie.
///
/// Un appui copie l'aphorisme dans le presse-papiers et affiche un bref toast « Copié ! ».
/// Réutilisée par la popup matinale et la section Paramètres.
struct AphorismCardView: View {
    let aphorism: Aphorism
    /// Autorise la copie au tap (désactivée dans la popup où le focus est le bouton principal).
    var allowsCopy: Bool = true

    @State private var showCopiedToast = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("« \(aphorism.text) »")
                .font(.system(.body, design: .serif))
                .italic()
                .foregroundStyle(Color.primary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                Text("— \(aphorism.author)")
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
                Spacer()
                Text(aphorism.category.capitalized)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Color.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.secondary.opacity(0.12), in: Capsule())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
        .overlay(alignment: .top) {
            if showCopiedToast {
                Text("Copié !")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.8), in: Capsule())
                    .padding(.top, 8)
                    .transition(.opacity)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { if allowsCopy { copyToClipboard() } }
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier("aphorism_card")
        .accessibilityLabel("Pensée du jour. \(aphorism.text). \(aphorism.author). Catégorie \(aphorism.category).")
        .accessibilityAddTraits(allowsCopy ? .isButton : [])
        .accessibilityHint(allowsCopy ? "Appuyez deux fois pour copier la citation" : "")
        // Action explicite : `onTapGesture` n'est pas activable de façon fiable par le
        // Contrôle de sélection, le Contrôle vocal ou l'accès clavier.
        .accessibilityAction { if allowsCopy { copyToClipboard() } }
    }

    /// Copie le texte de l'aphorisme et affiche un toast éphémère.
    private func copyToClipboard() {
        UIPasteboard.general.string = "« \(aphorism.text) » — \(aphorism.author)"
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIAccessibility.post(notification: .announcement, argument: "Citation copiée")
        withAnimation { showCopiedToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation { showCopiedToast = false }
        }
    }
}

#Preview {
    AphorismCardView(
        aphorism: Aphorism(
            id: 1,
            text: "La vie est trop courte pour boire du mauvais vin.",
            author: "Johann Wolfgang von Goethe",
            category: "vie"
        )
    )
    .padding()
}
