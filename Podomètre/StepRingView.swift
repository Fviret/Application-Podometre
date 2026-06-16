import SwiftUI

struct StepRingView: View {
    @StateObject private var viewModel = StepCountViewModel()

    private let ringDiameter: CGFloat = 240
    private let strokeWidth: CGFloat = 20
    private let goal = 10_000
    private let haptic = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                HStack(spacing: 0) {
                    // Left chevron — go to previous day
                    Button {
                        haptic.impactOccurred()
                        viewModel.selectedDayOffset += 1
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundStyle(Color.secondary)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .opacity(viewModel.selectedDayOffset < 6 ? 1 : 0)
                    .disabled(viewModel.selectedDayOffset >= 6)
                    .animation(.easeInOut(duration: 0.15), value: viewModel.selectedDayOffset)

                    Spacer()

                    // Ring + date label
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .stroke(Color(.systemGray5), lineWidth: strokeWidth)
                                .frame(width: ringDiameter, height: ringDiameter)

                            Circle()
                                .trim(from: 0, to: viewModel.progress)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.teal, Color.green],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                                )
                                .frame(width: ringDiameter, height: ringDiameter)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 0.6), value: viewModel.progress)

                            VStack(spacing: 4) {
                                Text(viewModel.stepCount.formatted())
                                    .font(.system(size: 44, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.primary)
                                    .contentTransition(.numericText())
                                    .animation(.easeInOut(duration: 0.6), value: viewModel.stepCount)

                                Text("pas")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                            }
                        }

                        Text(viewModel.selectedDateLabel)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.primary)
                            .id(viewModel.selectedDayOffset)
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.2), value: viewModel.selectedDayOffset)
                    }

                    Spacer()

                    // Right chevron — go toward today
                    Button {
                        haptic.impactOccurred()
                        viewModel.selectedDayOffset -= 1
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                            .foregroundStyle(Color.secondary)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .opacity(viewModel.selectedDayOffset > 0 ? 1 : 0)
                    .disabled(viewModel.selectedDayOffset <= 0)
                    .animation(.easeInOut(duration: 0.15), value: viewModel.selectedDayOffset)
                }
                .padding(.horizontal, 8)

                Text("Objectif : \(goal.formatted()) pas")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.secondary)

                Divider()
                    .padding(.horizontal, 24)

                MonthCalendarView(viewModel: viewModel)
                    .padding(.horizontal, 24)
                }
                .padding(.vertical, 32)
            }
        }
        .onAppear {
            viewModel.requestAuthorizationAndFetch()
        }
    }
}

#Preview {
    StepRingPreview(stepCount: 4210, selectedDayOffset: 2)
}

private struct StepRingPreview: View {
    let stepCount: Int
    let selectedDayOffset: Int

    private let ringDiameter: CGFloat = 240
    private let strokeWidth: CGFloat = 20
    private let goal = 10_000

    private var progress: Double { min(Double(stepCount) / 10_000.0, 1.0) }

    private var dateLabel: String {
        switch selectedDayOffset {
        case 0: return "Aujourd'hui"
        case 1: return "Hier"
        default:
            let date = Calendar.current.date(byAdding: .day, value: -selectedDayOffset, to: Date()) ?? Date()
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "fr_FR")
            formatter.setLocalizedDateFormatFromTemplate("EEEdMMMM")
            return formatter.string(from: date)
        }
    }

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                HStack(spacing: 0) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundStyle(Color.secondary)
                        .frame(width: 44, height: 44)
                        .opacity(selectedDayOffset < 6 ? 1 : 0)

                    Spacer()

                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .stroke(Color(.systemGray5), lineWidth: strokeWidth)
                                .frame(width: ringDiameter, height: ringDiameter)

                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.teal, Color.green],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                                )
                                .frame(width: ringDiameter, height: ringDiameter)
                                .rotationEffect(.degrees(-90))

                            VStack(spacing: 4) {
                                Text(stepCount.formatted())
                                    .font(.system(size: 44, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.primary)

                                Text("pas")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                            }
                        }

                        Text(dateLabel)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.primary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundStyle(Color.secondary)
                        .frame(width: 44, height: 44)
                        .opacity(selectedDayOffset > 0 ? 1 : 0)
                }
                .padding(.horizontal, 8)

                Text("Objectif : \(goal.formatted()) pas")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.secondary)
            }
        }
    }
}
