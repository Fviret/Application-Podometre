import SwiftUI

struct MonthCalendarView: View {
    @ObservedObject var viewModel: StepCountViewModel

    private let circleDiameter: CGFloat = 28
    private let goal = 10_000
    private let weekdayInitials = ["L", "M", "M", "J", "V", "S", "D"]

    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday
        return calendar
    }

    private var today: Date { Date() }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.setLocalizedDateFormatFromTemplate("MMMMyyyy")
        return formatter.string(from: today).capitalized
    }

    /// Day-of-month -> Date for every day in the current month.
    private var daysInMonth: [Int] {
        guard let range = calendar.range(of: .day, in: .month, for: today) else { return [] }
        return Array(range)
    }

    /// Number of empty leading cells before day 1, so the grid aligns to the correct weekday column.
    private var leadingEmptyCells: Int {
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) else { return 0 }
        let weekday = calendar.component(.weekday, from: startOfMonth) // 1 = Sunday ... 7 = Saturday
        // Convert to Monday-first index: Monday = 0 ... Sunday = 6
        return (weekday + 5) % 7
    }

    private func date(forDay day: Int) -> Date {
        var components = calendar.dateComponents([.year, .month], from: today)
        components.day = day
        return calendar.date(from: components) ?? today
    }

    private func isFuture(_ date: Date) -> Bool {
        calendar.startOfDay(for: date) > calendar.startOfDay(for: today)
    }

    private func isSelected(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: viewModel.selectedDate, toGranularity: .day)
    }

    private var monthlyTotal: Int {
        viewModel.stepsByDay.values.reduce(0, +)
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(monthTitle)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(Color.primary)

            HStack(spacing: 0) {
                ForEach(weekdayInitials.indices, id: \.self) { index in
                    Text(weekdayInitials[index])
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                ForEach(0..<leadingEmptyCells, id: \.self) { _ in
                    Color.clear
                        .frame(height: circleDiameter + 24)
                }

                ForEach(daysInMonth, id: \.self) { day in
                    dayCell(for: day)
                }
            }

            Text("Total du mois : \(monthlyTotal.formatted()) pas")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
        }
    }

    @ViewBuilder
    private func dayCell(for day: Int) -> some View {
        let cellDate = date(forDay: day)
        let future = isFuture(cellDate)
        let selected = isSelected(cellDate)
        let steps = viewModel.stepsByDay[day] ?? 0
        let progress = min(Double(steps) / Double(goal), 1.0)

        VStack(spacing: 4) {
            Text("\(day)")
                .font(.caption)
                .fontWeight(selected ? .bold : .regular)
                .foregroundStyle(selected ? Color.green : Color.primary)

            ZStack {
                Circle()
                    .stroke(Color.secondary, lineWidth: 2)
                    .frame(width: circleDiameter, height: circleDiameter)

                if !future {
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [Color.teal, Color.green],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round)
                        )
                        .frame(width: circleDiameter, height: circleDiameter)
                        .rotationEffect(.degrees(-90))
                }
            }
        }
        .opacity(future ? 0.3 : 1.0)
        .contentShape(Rectangle())
        .onTapGesture {
            guard !future else { return }
            viewModel.selectDate(cellDate)
        }
    }
}

#Preview {
    let viewModel = StepCountViewModel()
    viewModel.stepsByDay = [
        1: 8200, 2: 10500, 3: 3000, 4: 0, 5: 12000,
        6: 6700, 7: 9100, 8: 4400, 9: 10000, 10: 2100,
        11: 7600, 12: 8800, 13: 0, 14: 15600
    ]
    return MonthCalendarView(viewModel: viewModel)
        .padding()
}
