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

                Section("Personnalisation des couleurs") {
                    HStack {
                        Circle()
                            .fill(viewModel.ringColor)
                            .frame(width: 24, height: 24)
                        Text(AppColors.ringColorOptions.first { $0.id == viewModel.ringColorId }?.name ?? "")
                            .foregroundStyle(Color.primary)
                        Spacer()
                    }

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(AppColors.ringColorOptions) { option in
                            ZStack {
                                Circle()
                                    .fill(option.color)
                                    .frame(width: 36, height: 36)
                                if option.id == viewModel.ringColorId {
                                    Circle()
                                        .stroke(Color.primary, lineWidth: 2)
                                        .frame(width: 42, height: 42)
                                }
                            }
                            .onTapGesture {
                                viewModel.setRingColor(option.id)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Paramètres")
        }
    }
}

#Preview {
    SettingsView(viewModel: StepCountViewModel())
}
