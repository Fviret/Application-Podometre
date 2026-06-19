import SwiftUI

struct WeeklyBarChartView: View {
    @ObservedObject var viewModel: StepCountViewModel

    private let chartHeight: CGFloat = 140
    private let yAxisWidth: CGFloat = 32
    private let labelRowHeight: CGFloat = 20
    private let labelRowGap: CGFloat = 8

    private var weekdayShortLabels: [String] {
        // index 0 = 6 days ago ... index 6 = today
        (0..<7).map { offset in
            let date = Calendar.current.date(byAdding: .day, value: -(6 - offset), to: Date()) ?? Date()
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "fr_FR")
            formatter.setLocalizedDateFormatFromTemplate("EEE")
            let symbol = formatter.string(from: date)
            return String(symbol.prefix(2)).capitalized
        }
    }

    private func compactSteps(_ n: Int) -> String {
        if n == 0 { return "0" }
        if n >= 1000 {
            return String(format: "%.1fk", Double(n) / 1000).replacingOccurrences(of: ".0k", with: "k")
        }
        return "\(n)"
    }

    private var yMax: Int {
        let maxValue = max(1, (viewModel.currentWeekSteps + viewModel.previousWeekSteps).max() ?? 1)
        let raw = maxValue + 5000
        return Int(ceil(Double(raw) / 5000.0)) * 5000
    }

    private var ticks: [Int] {
        let raw = [0, yMax / 3, 2 * yMax / 3, yMax]
        return raw.map { Int((Double($0) / 100.0).rounded()) * 100 }
    }

    private func xPos(_ index: Int, chartWidth: CGFloat) -> CGFloat {
        yAxisWidth + CGFloat(index) / 6.0 * chartWidth
    }

    private func yPos(_ steps: Int) -> CGFloat {
        chartHeight - CGFloat(steps) / CGFloat(yMax) * chartHeight
    }

    private func linePath(values: [Int], chartWidth: CGFloat) -> Path {
        var path = Path()
        var started = false

        for index in 0..<7 {
            let value = values[index]
            guard value > 0 else {
                started = false
                continue
            }

            let point = CGPoint(x: xPos(index, chartWidth: chartWidth), y: yPos(value))
            if started {
                path.addLine(to: point)
            } else {
                path.move(to: point)
                started = true
            }
        }

        return path
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("7 derniers jours")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.primary)

                Spacer()

                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 4, height: 4)

                    Text("— semaine précédente")
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                }
            }

            GeometryReader { geo in
                let chartWidth = max(0, geo.size.width - yAxisWidth)

                ZStack(alignment: .topLeading) {
                    // Y-axis grid lines + labels
                    ForEach(ticks, id: \.self) { tick in
                        let y = yPos(tick)

                        Path { path in
                            path.move(to: CGPoint(x: yAxisWidth, y: y))
                            path.addLine(to: CGPoint(x: yAxisWidth + chartWidth, y: y))
                        }
                        .stroke(Color.secondary.opacity(0.2), style: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))

                        Text(compactSteps(tick))
                            .font(.system(size: 9))
                            .foregroundStyle(Color.secondary)
                            .frame(width: 28, alignment: .trailing)
                            .position(x: 14, y: y)
                    }

                    // Previous week line (behind)
                    linePath(values: viewModel.previousWeekSteps, chartWidth: chartWidth)
                        .stroke(Color.secondary.opacity(0.4), style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))

                    // Current week line (front)
                    linePath(values: viewModel.currentWeekSteps, chartWidth: chartWidth)
                        .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

                    // Previous week dots
                    ForEach(0..<7, id: \.self) { index in
                        let steps = viewModel.previousWeekSteps[index]
                        if steps > 0 {
                            Circle()
                                .fill(Color.secondary.opacity(0.5))
                                .frame(width: 5, height: 5)
                                .position(x: xPos(index, chartWidth: chartWidth), y: yPos(steps))
                        }
                    }

                    // Current week dots
                    ForEach(0..<7, id: \.self) { index in
                        let steps = viewModel.currentWeekSteps[index]
                        if steps > 0 {
                            Circle()
                                .fill(Color.accentColor)
                                .overlay(Circle().stroke(Color.white, lineWidth: 1))
                                .frame(width: 5, height: 5)
                                .position(x: xPos(index, chartWidth: chartWidth), y: yPos(steps))
                        }
                    }

                    // Day labels row
                    ForEach(0..<7, id: \.self) { index in
                        let isToday = index == 6
                        Text(weekdayShortLabels[index])
                            .font(.caption2)
                            .fontWeight(isToday ? .bold : .regular)
                            .foregroundStyle(isToday ? Color.accentColor : Color.secondary)
                            .position(x: xPos(index, chartWidth: chartWidth), y: chartHeight + labelRowGap + labelRowHeight / 2)
                    }
                }
            }
            .frame(height: chartHeight + labelRowGap + labelRowHeight)
        }
    }
}

#Preview {
    let viewModel = StepCountViewModel()
    viewModel.currentWeekSteps = [3200, 7800, 10500, 9100, 4300, 11200, 6400]
    viewModel.previousWeekSteps = [5000, 6200, 8900, 7700, 3100, 9800, 10100]
    return WeeklyBarChartView(viewModel: viewModel)
        .padding()
}
