import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: StepCountViewModel
    @State private var showPicker = false

    private let goalOptions = Array(stride(from: 5_000, through: 20_000, by: 500))

    var body: some View {
        NavigationStack {
            List {
                Section("Objectif quotidien") {
                    Button {
                        withAnimation { showPicker.toggle() }
                    } label: {
                        HStack {
                            Text("Pas par jour")
                                .foregroundStyle(Color.primary)
                            Spacer()
                            Text(viewModel.goal.formatted())
                                .foregroundStyle(Color.secondary)
                            Image(systemName: showPicker ? "chevron.up" : "chevron.down")
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                        }
                    }

                    if showPicker {
                        Picker("Pas par jour", selection: $viewModel.goal) {
                            ForEach(goalOptions, id: \.self) { value in
                                Text(value.formatted()).tag(value)
                            }
                        }
                        .pickerStyle(.wheel)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
            .navigationTitle("Paramètres")
        }
    }
}

#Preview {
    SettingsView(viewModel: StepCountViewModel())
}
