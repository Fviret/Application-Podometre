import SwiftUI

/// Petite croix pour masquer une bannière ou carte d'autorisation sur l'écran Activité.
/// Cible tactile de 44 pt ; libellé VoiceOver « Masquer ».
struct DismissButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.secondary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Masquer")
        .accessibilityIdentifier("dismiss_permission_banner")
    }
}

#Preview {
    DismissButton {}
}
