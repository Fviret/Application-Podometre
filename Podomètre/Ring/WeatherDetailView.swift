import SwiftUI

/// Écran de détail météo pour un jour donné (présenté en sheet au tap sur un jour de la bannière).
/// N'affiche que les données disponibles : condition, max/min, précipitations, localisation,
/// et — pour aujourd'hui uniquement — l'horaire des prochaines heures + l'alerte pluie.
struct WeatherDetailView: View {
    let forecast: DailyForecast
    let isToday: Bool
    /// Prévisions horaires (prochaines heures) — pertinentes uniquement pour aujourd'hui.
    var hourly: [HourlyWeather] = []
    /// Première heure de pluie à venir (aujourd'hui) — pour l'alerte.
    var nextRainHour: Date? = nil
    var locationLabel: String? = nil

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    hero

                    HStack(spacing: 10) {
                        if forecast.precipitationMm > 0.2 {
                            infoPill(icon: "drop.fill",
                                     text: "\(forecast.precipitationMm.formatted(.number.precision(.fractionLength(1)))) mm attendus",
                                     neutral: false)
                        }
                        if let label = locationLabel {
                            infoPill(icon: "location.fill", text: label, neutral: true)
                        }
                    }

                    if isToday, let rain = nextRainHour {
                        infoPill(icon: "cloud.rain.fill",
                                 text: "Pluie prévue vers \(timeString(rain))",
                                 neutral: false)
                    }

                    if !hourly.isEmpty {
                        hourlyList
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .navigationTitle(dayTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
    }

    // MARK: - Sous-vues

    private var hero: some View {
        VStack(spacing: 4) {
            Text(weatherEmoji(for: forecast.weatherCode))
                .font(.system(size: 80))
                .accessibilityHidden(true)
            Text(weatherLabel(for: forecast.weatherCode))
                .font(.system(.title3, design: .rounded).weight(.semibold))
            Text("\(Int(forecast.tempMax.rounded()))°  /  \(Int(forecast.tempMin.rounded()))°")
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Color.secondary)
        }
        .padding(.top, 8)
        .accessibilityElement(children: .combine)
    }

    private var hourlyList: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Prochaines heures")
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(Color.secondary)
                .padding(.bottom, 8)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: 0) {
                ForEach(hourly.indices, id: \.self) { i in
                    let h = hourly[i]
                    let isNow = isToday && i == 0
                    HStack(spacing: 14) {
                        Text(isNow ? "Maintenant" : timeString(h.hour))
                            .font(.system(.subheadline, design: .rounded).weight(.medium))
                            .foregroundStyle(isNow ? Color.primary : Color.secondary)
                            .frame(width: 96, alignment: .leading)

                        Text(weatherEmoji(for: h.weatherCode))
                            .font(.system(size: 22))
                            .accessibilityHidden(true)

                        Spacer()

                        if h.precipitationMm > 0.1 {
                            Text("\(h.precipitationMm.formatted(.number.precision(.fractionLength(1)))) mm")
                                .font(.caption)
                                .foregroundStyle(Color.blue.opacity(0.85))
                        }

                        Text("\(Int(h.temperature.rounded()))°")
                            .font(.system(.body, design: .rounded).weight(.semibold))
                            .frame(width: 44, alignment: .trailing)
                    }
                    .padding(.vertical, 11)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(hourAccessibility(index: i, hour: h))

                    if i < hourly.count - 1 {
                        Divider()
                    }
                }
            }
            .padding(.horizontal, 16)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private func infoPill(icon: String, text: String, neutral: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon).font(.caption).accessibilityHidden(true)
            Text(text).font(.system(.subheadline, design: .rounded).weight(.medium))
        }
        .foregroundStyle(neutral ? Color.secondary : Color.blue)
        .padding(.horizontal, 13)
        .padding(.vertical, 7)
        .background(neutral ? Color(.secondarySystemBackground) : Color.blue.opacity(0.12),
                    in: Capsule())
    }

    // MARK: - Helpers

    /// Titre : « Aujourd'hui » ou le jour formaté (« Samedi 18 juillet »).
    private var dayTitle: String {
        if isToday { return "Aujourd'hui" }
        let f = DateFormatter()
        f.locale = Locale(identifier: "fr_FR")
        f.setLocalizedDateFormatFromTemplate("EEEE d MMMM")
        return f.string(from: forecast.date).capitalized
    }

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "fr_FR")
        f.dateFormat = "HH'h'"
        return f.string(from: date)
    }

    private func hourAccessibility(index: Int, hour: HourlyWeather) -> String {
        let when = (isToday && index == 0) ? "Maintenant" : timeString(hour.hour)
        let precip = hour.precipitationMm > 0.1
            ? ", \(hour.precipitationMm.formatted(.number.precision(.fractionLength(1)))) mm de pluie"
            : ""
        return "\(when), \(weatherDescription(for: hour.weatherCode)), \(Int(hour.temperature.rounded()))°\(precip)"
    }
}

#Preview {
    WeatherDetailView(
        forecast: DailyForecast(date: Date(), weatherCode: 80, tempMin: 13, tempMax: 19, precipitationMm: 4.2),
        isToday: true,
        hourly: [
            HourlyWeather(hour: Date(), precipitationMm: 0.8, temperature: 16, weatherCode: 80),
            HourlyWeather(hour: Date().addingTimeInterval(3600), precipitationMm: 1.2, temperature: 15, weatherCode: 61),
            HourlyWeather(hour: Date().addingTimeInterval(7200), precipitationMm: 0, temperature: 17, weatherCode: 2),
            HourlyWeather(hour: Date().addingTimeInterval(10800), precipitationMm: 0, temperature: 19, weatherCode: 0)
        ],
        nextRainHour: Date().addingTimeInterval(1800),
        locationLabel: "Paris, France"
    )
}
