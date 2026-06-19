import SwiftUI

struct MonthCalendarView: View {
    @ObservedObject var viewModel: StepCountViewModel

    private let circleDiameter: CGFloat = 28
    private let weekdayInitials = ["L", "M", "M", "J", "V", "S", "D"]
    private let haptic = UIImpactFeedbackGenerator(style: .light)

    private var calendar: Calendar {
        Calendar(identifier: .gregorian)
    }

    private var today: Date { Date() }

    private var displayedMonth: Date { viewModel.displayedMonth }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.setLocalizedDateFormatFromTemplate("MMMMyyyy")
        return formatter.string(from: displayedMonth).capitalized
    }

    /// Flat, row-major grid of day numbers for `month`. `nil` entries are empty
    /// placeholder cells (leading days before the 1st, or trailing padding so
    /// the grid always has complete rows of 7).
    private func calendarDays(for month: Date) -> [Int?] {
        let calendar = Calendar(identifier: .gregorian)

        let components = calendar.dateComponents([.year, .month], from: month)
        guard let firstDay = calendar.date(from: components) else { return [] }

        let rawWeekday = calendar.component(.weekday, from: firstDay) // 1=Sun, 2=Mon ... 7=Sat
        let offset = (rawWeekday + 5) % 7 // remapped: 0=Mon, 1=Tue ... 6=Sun

        guard let range = calendar.range(of: .day, in: .month, for: firstDay) else { return [] }
        let daysInMonth = range.count

        var days: [Int?] = Array(repeating: nil, count: offset)
        days += (1...daysInMonth).map { Optional($0) }

        while days.count % 7 != 0 {
            days.append(nil)
        }

        return days
    }

    private func date(forDay day: Int) -> Date {
        var components = calendar.dateComponents([.year, .month], from: displayedMonth)
        components.day = day
        return calendar.date(from: components) ?? displayedMonth
    }

    private func isFuture(_ date: Date) -> Bool {
        calendar.startOfDay(for: date) > calendar.startOfDay(for: today)
    }

    private var monthlyTotal: Int {
        viewModel.stepsByDay.values.reduce(0, +)
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 0) {
                // Left chevron — go to previous month
                Button {
                    haptic.impactOccurred()
                    viewModel.selectedMonthOffset += 1
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .opacity(viewModel.selectedMonthOffset < 11 ? 1 : 0)
                .disabled(viewModel.selectedMonthOffset >= 11)
                .animation(.easeInOut(duration: 0.15), value: viewModel.selectedMonthOffset)

                Spacer()

                Text(monthTitle)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.primary)

                Spacer()

                // Right chevron — go toward current month
                Button {
                    haptic.impactOccurred()
                    viewModel.selectedMonthOffset -= 1
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .opacity(viewModel.selectedMonthOffset > 0 ? 1 : 0)
                .disabled(viewModel.selectedMonthOffset <= 0)
                .animation(.easeInOut(duration: 0.15), value: viewModel.selectedMonthOffset)
            }

            HStack(spacing: 0) {
                ForEach(weekdayInitials.indices, id: \.self) { index in
                    Text(weekdayInitials[index])
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                ForEach(Array(calendarDays(for: displayedMonth).enumerated()), id: \.offset) { _, day in
                    if let day {
                        dayCell(for: day)
                    } else {
                        Color.clear
                            .frame(height: circleDiameter + 24)
                    }
                }
            }

            Text("Total : \(monthlyTotal.formatted()) pas")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
        }
    }

    @ViewBuilder
    private func dayCell(for day: Int) -> some View {
        let cellDate = date(forDay: day)
        let future = isFuture(cellDate)
        let steps = viewModel.stepsByDay[day] ?? 0

        let _ = print("[MonthCalendarView] day \(day): steps = \(steps)")

        let goal = viewModel.goal
        ZStack {
            if steps >= goal {
                Circle()
                    .fill(Color.green)
            } else if steps > 0 {
                Circle()
                    .stroke(Color.green, lineWidth: 1.5)
            } else {
                Circle()
                    .stroke(Color.gray, lineWidth: 1)
                    .opacity(0.4)
            }
            Text("\(day)")
                .font(.caption2)
                .fontWeight(steps >= goal ? .bold : .regular)
                .foregroundStyle(steps >= goal ? Color.white : Color.primary)
        }
        .frame(width: 28, height: 28)
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
