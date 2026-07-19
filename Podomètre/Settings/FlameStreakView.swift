import SwiftUI

/// Flamme animée de la série (streak), recréée nativement en SwiftUI.
/// Le nombre de couches et les couleurs évoluent selon le nombre de jours consécutifs :
/// - 0-1 jour : 1 couche · 2 jours : 2 couches · 3+ jours : 3 couches (cœur)
/// - paliers de couleur : braise grise (0) → orange (1-6) → rouge (7-13) → vert (14-20) → bleu (21+)
/// Respecte « Réduire les animations » (flamme figée) et est décorative pour VoiceOver.
struct FlameStreakView: View {
    let streak: Int
    /// Hauteur de référence de la flamme (les proportions internes s'y adaptent).
    var size: CGFloat = 84

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animate = false

    private var tier: FlameTier { FlameTier(streak: streak) }

    /// Nombre de couches visibles selon la série.
    private var layerCount: Int {
        if streak < 2 { return 1 }
        if streak < 3 { return 2 }
        return 3
    }

    var body: some View {
        let unit = size / 84

        ZStack(alignment: .bottom) {
            // Halo pulsant
            Circle()
                .fill(
                    RadialGradient(
                        colors: [tier.glow, tier.glow.opacity(0)],
                        center: .center, startRadius: 0, endRadius: 30 * unit
                    )
                )
                .frame(width: 58 * unit, height: 58 * unit)
                .blur(radius: 4 * unit)
                .scaleEffect(animate ? 1.12 : 1)
                .opacity(animate ? 0.85 : 0.55)
                .offset(y: -8 * unit)
                .animation(motion(2.6), value: animate)

            // Couche externe (toujours présente)
            flameLayer(width: 40 * unit, height: 54 * unit,
                       colors: tier.outerColors, glow: tier.outerShadow,
                       yOffset: -8 * unit, duration: 2.4, rotate: 4, scaleAmt: 0.03)

            // Couche médiane (≥ 2 jours)
            if layerCount >= 2 {
                flameLayer(width: 26 * unit, height: 36 * unit,
                           colors: tier.midColors, glow: .clear,
                           yOffset: -11 * unit, duration: 1.9, rotate: 5, scaleAmt: 0.05)
                    .transition(.scale(scale: 0.4).combined(with: .opacity))
            }

            // Cœur (≥ 3 jours)
            if layerCount >= 3 {
                flameLayer(width: 13 * unit, height: 20 * unit,
                           colors: tier.innerColors, glow: .clear,
                           yOffset: -14 * unit, duration: 1.3, rotate: 6, scaleAmt: 0.08)
                    .transition(.scale(scale: 0.4).combined(with: .opacity))
            }
        }
        .frame(width: size * 0.83, height: size)
        .animation(.easeInOut(duration: 0.3), value: layerCount)
        .animation(.easeInOut(duration: 0.4), value: tier)
        .accessibilityHidden(true)
        .onAppear {
            guard !reduceMotion else { return }
            animate = true
        }
    }

    /// Une couche de flamme, avec son flicker propre (rotation + étirement oscillants).
    private func flameLayer(width: CGFloat, height: CGFloat,
                            colors: [Color], glow: Color,
                            yOffset: CGFloat, duration: Double,
                            rotate: Double, scaleAmt: CGFloat) -> some View {
        FlameShape()
            .fill(LinearGradient(colors: colors, startPoint: .bottom, endPoint: .top))
            .frame(width: width, height: height)
            .shadow(color: glow, radius: 6, x: 0, y: 0)
            .rotationEffect(.degrees(animate ? rotate : 0), anchor: .bottom)
            .scaleEffect(x: animate ? 1 - scaleAmt : 1,
                         y: animate ? 1 + scaleAmt : 1, anchor: .bottom)
            .offset(y: yOffset)
            .animation(motion(duration), value: animate)
    }

    /// Animation de flicker en boucle, désactivée si « Réduire les animations ».
    private func motion(_ duration: Double) -> Animation? {
        reduceMotion ? nil : .easeInOut(duration: duration).repeatForever(autoreverses: true)
    }
}

// MARK: - Forme de flamme

/// Silhouette de flamme (pointe en haut, base arrondie), dessinée dans son rectangle.
private struct FlameShape: Shape {
    func path(in rect: CGRect) -> Path {
        // Coordonnées d'une flamme de référence (boîte 100×110) mises à l'échelle du rect.
        let sx = rect.width / 100
        let sy = rect.height / 110
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * sx, y: rect.minY + y * sy)
        }
        var path = Path()
        path.move(to: p(50, 20))
        path.addCurve(to: p(35, 78), control1: p(30, 40), control2: p(25, 60))
        path.addCurve(to: p(65, 78), control1: p(40, 88), control2: p(60, 88))
        path.addCurve(to: p(50, 20), control1: p(75, 60), control2: p(70, 40))
        path.closeSubpath()
        return path
    }
}

// MARK: - Paliers de couleur

/// Palier de couleur de la flamme selon la longueur de la série.
private enum FlameTier: Equatable {
    case spark   // 0 jour — braise grise
    case orange  // 1-6 jours
    case red     // 7-13 jours
    case green   // 14-20 jours
    case blue    // 21+ jours

    init(streak: Int) {
        switch streak {
        case ..<1:    self = .spark
        case 1..<7:   self = .orange
        case 7..<14:  self = .red
        case 14..<21: self = .green
        default:      self = .blue
        }
    }

    var glow: Color {
        switch self {
        case .spark:  return Color(hex: 0x969696).opacity(0.35)
        case .orange: return Color(hex: 0xff9f1c).opacity(0.45)
        case .red:    return Color(hex: 0xff3d1a).opacity(0.50)
        case .green:  return Color(hex: 0x30d158).opacity(0.45)
        case .blue:   return Color(hex: 0x0a84ff).opacity(0.50)
        }
    }

    var outerColors: [Color] {
        switch self {
        case .spark:  return [Color(hex: 0x5a5a5a), Color(hex: 0x6e6e6e), Color(hex: 0x8a8a8a)]
        case .orange: return [Color(hex: 0xffb648), Color(hex: 0xff9f1c), Color(hex: 0xff7a1a)]
        case .red:    return [Color(hex: 0xff9500), Color(hex: 0xff7a00), Color(hex: 0xff3d1a)]
        case .green:  return [Color(hex: 0x63e685), Color(hex: 0x30d158), Color(hex: 0x1a8a3d)]
        case .blue:   return [Color(hex: 0x5ac8fa), Color(hex: 0x3ea6ff), Color(hex: 0x0a84ff)]
        }
    }

    var midColors: [Color] {
        switch self {
        case .spark:  return [Color(hex: 0x8a8a8a), Color(hex: 0x6e6e6e)]
        case .orange: return [Color(hex: 0xffcf3d), Color(hex: 0xffb015)]
        case .red:    return [Color(hex: 0xffcc00), Color(hex: 0xff9500)]
        case .green:  return [Color(hex: 0xa6f5bd), Color(hex: 0x4de07a)]
        case .blue:   return [Color(hex: 0x9fe3ff), Color(hex: 0x5ac8fa)]
        }
    }

    var innerColors: [Color] {
        switch self {
        case .spark:  return [Color(hex: 0xbdbdbd)]
        case .orange: return [Color(hex: 0xfff4cf)]
        case .red:    return [Color(hex: 0xffe9a8)]
        case .green:  return [Color(hex: 0xe9fff0)]
        case .blue:   return [Color(hex: 0xffffff)]
        }
    }

    var outerShadow: Color {
        switch self {
        case .spark:  return .clear
        case .orange: return Color(hex: 0xff7a1a).opacity(0.5)
        case .red:    return Color(hex: 0xff3d1a).opacity(0.6)
        case .green:  return Color(hex: 0x30d158).opacity(0.55)
        case .blue:   return Color(hex: 0x0a84ff).opacity(0.65)
        }
    }
}

private extension Color {
    /// Construit une couleur depuis un entier hexadécimal RRGGBB.
    init(hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255
        )
    }
}

// MARK: - Preview

#Preview("Paliers de flamme") {
    HStack(spacing: 24) {
        ForEach([1, 5, 10, 17, 25], id: \.self) { days in
            VStack {
                FlameStreakView(streak: days, size: 72)
                Text("\(days) j").font(.caption2).foregroundStyle(.secondary)
            }
        }
    }
    .padding(40)
}
