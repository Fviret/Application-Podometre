import SwiftUI

/// Vue du calendrier mensuel affichant un cercle par jour.
/// Cercle plein vert = objectif atteint, cercle vide vert = partiel, cercle gris = aucun pas.
struct MonthCalendarView: View {
    @ObservedObject var viewModel: StepCountViewModel

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let circleDiameter: CGFloat = 28
    private let weekdayInitials = ["L", "M", "M", "J", "V", "S", "D"]
    private let weekdayFullNames = ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"]
    private let haptic = UIImpactFeedbackGenerator(style: .light)

    /// Calendrier grégorien explicite pour éviter les variations de `firstWeekday` selon la locale.
    private var calendar: Calendar {
        Calendar(identifier: .gregorian)
    }

    /// Date du jour, capturée une fois à la construction de la vue.
    private let today: Date = Date()

    private var displayedMonth: Date { viewModel.displayedMonth }

    /// Titre du mois affiché, formaté en français capitalisé (ex. "Juin 2026").
    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.setLocalizedDateFormatFromTemplate("MMMMyyyy")
        return formatter.string(from: displayedMonth).capitalized
    }

    /// Retourne le tableau plat de numéros de jours pour la grille du mois.
    /// Les cellules `nil` sont des espaces vides avant le 1er ou en fin de grille pour compléter les rangées de 7.
    private func calendarDays(for month: Date) -> [Int?] {
        let components = calendar.dateComponents([.year, .month], from: month)
        guard let firstDay = calendar.date(from: components) else { return [] }

        let rawWeekday = calendar.component(.weekday, from: firstDay) // 1=Dim, 2=Lun … 7=Sam
        let offset = (rawWeekday + 5) % 7 // remappage lundi-first : 0=Lun … 6=Dim

        guard let range = calendar.range(of: .day, in: .month, for: firstDay) else { return [] }
        let daysInMonth = range.count

        var days: [Int?] = Array(repeating: nil, count: offset)
        days += (1...daysInMonth).map { Optional($0) }

        while days.count % 7 != 0 {
            days.append(nil)
        }

        return days
    }

    /// Construit la `Date` complète pour un numéro de jour dans le mois affiché.
    private func date(forDay day: Int) -> Date {
        var components = calendar.dateComponents([.year, .month], from: displayedMonth)
        components.day = day
        return calendar.date(from: components) ?? displayedMonth
    }

    /// Retourne `true` si `date` est strictement dans le futur (au-delà d'aujourd'hui).
    private func isFuture(_ date: Date) -> Bool {
        calendar.startOfDay(for: date) > calendar.startOfDay(for: today)
    }

    /// Total des pas sur tous les jours du mois affiché.
    private var monthlyTotal: Int {
        viewModel.stepsByDay.values.reduce(0, +)
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 0) {
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
                .accessibilityLabel("Mois précédent")
                .opacity(viewModel.selectedMonthOffset < 11 ? 1 : 0)
                .disabled(viewModel.selectedMonthOffset >= 11)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: viewModel.selectedMonthOffset)

                Spacer()

                Text(monthTitle)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Color.primary)

                Spacer()

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
                .accessibilityLabel("Mois suivant")
                .opacity(viewModel.selectedMonthOffset > 0 ? 1 : 0)
                .disabled(viewModel.selectedMonthOffset <= 0)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: viewModel.selectedMonthOffset)
            }

            HStack(spacing: 0) {
                ForEach(weekdayInitials.indices, id: \.self) { index in
                    Text(weekdayInitials[index])
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                        .frame(maxWidth: .infinity)
                        .accessibilityLabel(weekdayFullNames[index])
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                ForEach(Array(calendarDays(for: displayedMonth).enumerated()), id: \.offset) { _, day in
                    if let day {
                        dayCell(for: day)
                    } else {
                        Color.clear
                            .frame(width: circleDiameter, height: circleDiameter)
                            .accessibilityHidden(true)
                    }
                }
            }

            Text("Total : \(monthlyTotal.formatted()) pas")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
        }
    }

    /// Cellule d'un jour : cercle coloré selon l'atteinte de l'objectif, grisé si date future.
    @ViewBuilder
    private func dayCell(for day: Int) -> some View {
        let cellDate = date(forDay: day)
        let future = isFuture(cellDate)
        let steps = viewModel.stepsByDay[day] ?? 0
        let goal = viewModel.goal
        let goalReached = steps >= goal

        let a11yLabel: String = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "fr_FR")
            formatter.setLocalizedDateFormatFromTemplate("d MMMM")
            let dateStr = formatter.string(from: cellDate)
            if future { return "\(dateStr), à venir" }
            if steps == 0 { return "\(dateStr), aucun pas" }
            if goalReached { return "\(dateStr), \(steps.formatted()) pas, objectif atteint" }
            return "\(dateStr), \(steps.formatted()) pas"
        }()

        ZStack {
            if goalReached {
                Circle()
                    .fill(viewModel.ringColor)
            } else if steps > 0 {
                Circle()
                    .stroke(viewModel.ringColor, lineWidth: 1.5)
            } else {
                Circle()
                    .stroke(Color.gray, lineWidth: 1)
                    .opacity(0.4)
            }
            Text("\(day)")
                .font(.caption2)
                .fontWeight(goalReached ? .bold : .regular)
                .foregroundStyle(goalReached ? Color.white : Color.primary)
        }
        .frame(width: 28, height: 28)
        .opacity(future ? 0.3 : 1.0)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(a11yLabel)
        .accessibilityAddTraits(future || steps == 0 ? [] : .isButton)
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
