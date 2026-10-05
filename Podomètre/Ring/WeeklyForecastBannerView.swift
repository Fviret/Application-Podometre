import SwiftUI

/// Bannière de prévisions météo sur 7 jours, affichée sous l'anneau de pas.
/// Invisible tant que la localisation n'est pas accordée.
struct WeeklyForecastBannerView: View {
    let forecasts: [DailyForecast]
    var walkingForecast: WalkingForecast? = nil
    /// Toutes les heures des 7 jours — filtrées par jour pour le détail.
    var allHourly: [HourlyWeather] = []
    var locationLabel: String? = nil

    /// Jour sélectionné au tap — présente la sheet de détail météo.
    @State private var selectedForecast: DailyForecast?

    var body: some View {
        if !forecasts.isEmpty {
            VStack(spacing: 2) {
                Text("Météo · 7 jours")
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .accessibilityAddTraits(.isHeader)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(forecasts.indices, id: \.self) { i in
                            Button {
                                selectedForecast = forecasts[i]
                            } label: {
                                DayForecastCell(forecast: forecasts[i], isToday: i == 0)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                }
                .accessibilityElement(children: .contain)

                if let label = locationLabel {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption)
                            .accessibilityHidden(true)
                        Text(label)
                            .font(.caption)
                    }
                    .foregroundStyle(Color.secondary.opacity(0.6))
                    .padding(.bottom, 4)
                    .accessibilityLabel("Localisation : \(label)")
                }
            }
            .sheet(item: $selectedForecast) { forecast in
                detailView(for: forecast)
            }
        }
    }

    /// Construit la sheet de détail pour un jour, avec l'horaire de ce jour (filtré depuis les 7 jours).
    private func detailView(for forecast: DailyForecast) -> WeatherDetailView {
        let calendar = Calendar.current
        let today = calendar.isDateInToday(forecast.date)
        var dayHours = allHourly.filter { calendar.isDate($0.hour, inSameDayAs: forecast.date) }
        if today {
            // Aujourd'hui : ne garder que les heures à venir (pas les heures passées).
            dayHours = dayHours.filter { $0.hour >= Date().addingTimeInterval(-3600) }
        }
        return WeatherDetailView(
            forecast: forecast,
            isToday: today,
            hourly: dayHours,
            nextRainHour: today ? walkingForecast?.nextRainHour : nil,
            locationLabel: locationLabel
        )
    }
}

/// Cellule d'un jour dans la bannière 7 jours.
private struct DayForecastCell: View {
    let forecast: DailyForecast
    let isToday: Bool

    private var dayLabel: String {
        if isToday { return "Auj." }
        let f = DateFormatter()
        f.locale = Locale.autoupdatingCurrent
        f.dateFormat = "EEE"
        return f.string(from: forecast.date).capitalized
    }

    private var fullDayLabel: String {
        if isToday { return "Aujourd'hui" }
        let f = DateFormatter()
        f.locale = Locale.autoupdatingCurrent
        f.setLocalizedDateFormatFromTemplate("EEEE d MMMM")
        return f.string(from: forecast.date).capitalized
    }

    private var a11yLabel: String {
        let precip = forecast.precipitationMm > 0.2
            ? ", \(Int(forecast.precipitationMm.rounded())) mm de pluie"
            : ""
        return "\(fullDayLabel), \(weatherDescription(for: forecast.weatherCode)), \(Int(forecast.tempMax.rounded()))° max, \(Int(forecast.tempMin.rounded()))° min\(precip)"
    }

    var body: some View {
        VStack(spacing: 6) {
            Text(dayLabel)
                .font(.system(.caption2, design: .rounded).weight(isToday ? .semibold : .regular))
                .foregroundStyle(isToday ? Color.primary : Color.secondary)

            Text(weatherEmoji(for: forecast.weatherCode))
                .font(.system(size: 22))
                .accessibilityHidden(true)

            VStack(spacing: 1) {
                Text("\(Int(forecast.tempMax.rounded()))°")
                    .font(.system(.footnote, design: .rounded).weight(.medium))
                    .foregroundStyle(Color.primary)
                Text("\(Int(forecast.tempMin.rounded()))°")
                    .font(.caption2)
                    .foregroundStyle(Color.secondary)
            }

            if forecast.precipitationMm > 0.2 {
                Text("\(Int(forecast.precipitationMm.rounded()))mm")
                    .font(.caption2)
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(Color.blue.opacity(0.8))
            } else {
                Text(" ")
                    .font(.caption2)
            }
        }
        .frame(width: 52)
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isToday ? Color(.systemGray5) : Color.clear)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(a11yLabel)
    }
}

#Preview {
    WeeklyForecastBannerView(forecasts: [
        DailyForecast(date: Date(), weatherCode: 1, tempMin: 14, tempMax: 22, precipitationMm: 0),
        DailyForecast(date: Date().addingTimeInterval(86400), weatherCode: 61, tempMin: 12, tempMax: 17, precipitationMm: 4.2),
        DailyForecast(date: Date().addingTimeInterval(86400 * 2), weatherCode: 3, tempMin: 13, tempMax: 19, precipitationMm: 0.1),
        DailyForecast(date: Date().addingTimeInterval(86400 * 3), weatherCode: 0, tempMin: 15, tempMax: 24, precipitationMm: 0),
        DailyForecast(date: Date().addingTimeInterval(86400 * 4), weatherCode: 80, tempMin: 11, tempMax: 16, precipitationMm: 8.0),
        DailyForecast(date: Date().addingTimeInterval(86400 * 5), weatherCode: 2, tempMin: 14, tempMax: 21, precipitationMm: 0),
        DailyForecast(date: Date().addingTimeInterval(86400 * 6), weatherCode: 0, tempMin: 16, tempMax: 25, precipitationMm: 0),
    ], locationLabel: "Paris, France")
    .padding()
}
