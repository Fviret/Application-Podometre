import SwiftUI

/// Bannière affichant la série de jours consécutifs où l'objectif a été atteint.
struct StreakBannerView: View {
    let streak: Int
    @ObservedObject var viewModel: StepCountViewModel

    var body: some View {
        VStack(spacing: 6) {
            Section("Série en cours") {
                FlameStreakView(streak: streak, size: 76)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(streak)")
                        .font(.system(.largeTitle, design: .rounded).weight(.bold))
                        .foregroundStyle(viewModel.ringColor)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(format: String(localized: streak > 1 ? "Série en cours : %@ jours consécutifs" : "Série en cours : %@ jour consécutif"), "\(streak)"))
    }
}

#Preview {
    let viewModel = StepCountViewModel()
    return List {
        Section {
            StreakBannerView(streak: 7, viewModel: viewModel)
        }
    }
}
