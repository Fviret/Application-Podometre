import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: StepCountViewModel

    var body: some View {
        NavigationStack {
            List {
                Section("Objectif quotidien") {
                    HStack {
                        Text("Pas par jour")
                        Spacer()
                        Text(viewModel.goal.formatted())
                            .foregroundStyle(Color.secondary)
                            .monospacedDigit()
                    }
                    Stepper(
                        value: $viewModel.goal,
                        in: 1_000...50_000,
                        step: 500
                    ) {
                        EmptyView()
                    }
                    .labelsHidden()
                }
            }
            .navigationTitle("Paramètres")
        }
    }
}

#Preview {
    SettingsView(viewModel: StepCountViewModel())
}
