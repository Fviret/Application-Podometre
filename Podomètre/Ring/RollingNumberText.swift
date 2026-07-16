import SwiftUI

/// Affiche un entier qui **s'incrémente en douceur** (compteur qui monte) quand sa valeur change,
/// au lieu de sauter directement à la valeur finale.
///
/// Conforme à `Animatable` : SwiftUI interpole `value` image par image sous une transaction
/// animée et réévalue le corps à chaque étape → l'entier affiché grimpe progressivement.
/// Utilise `monospacedDigit()` pour éviter les sauts de largeur pendant le défilement.
struct RollingNumberText: View, Animatable {
    /// Valeur courante (interpolée pendant l'animation).
    var value: Double
    var font: Font = .system(.largeTitle, design: .rounded).weight(.bold)
    var color: Color = .primary

    var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    var body: some View {
        Text(Int(value.rounded()).formatted())
            .font(font)
            .foregroundStyle(color)
            .monospacedDigit()
    }
}

#Preview {
    struct DemoView: View {
        @State private var steps = 0
        var body: some View {
            VStack(spacing: 24) {
                RollingNumberText(value: Double(steps))
                    .animation(.easeOut(duration: 0.8), value: steps)
                Button("Ajouter des pas") { steps += Int.random(in: 40...400) }
            }
            .padding()
        }
    }
    return DemoView()
}
