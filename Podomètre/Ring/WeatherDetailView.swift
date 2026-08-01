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

                    if !slots.isEmpty {
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
            Text(LocalizedStringKey(weatherLabel(for: forecast.weatherCode)))
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
            Text("Prévisions du jour")
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(Color.secondary)
                .padding(.bottom, 8)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: 0) {
                ForEach(slots.indices, id: \.self) { i in
                    let slot = slots[i]
                    let h = slot.forecast
                    HStack(spacing: 14) {
                        Text(slot.label)
                            .font(.system(.body, design: .rounded).weight(.medium))
                            .foregroundStyle(Color.primary)
                            .frame(width: 124, alignment: .leading)

                        Text(weatherEmoji(for: h.weatherCode))
                            .font(.system(size: 28))
                            .accessibilityHidden(true)

                        Spacer()

                        Text("\(Int(h.temperature.rounded()))°")
                            .font(.system(.title3, design: .rounded).weight(.semibold))
                            .frame(width: 48, alignment: .trailing)
                    }
                    .padding(.vertical, 15)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(slotAccessibility(slot))

                    if i < slots.count - 1 {
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

    // MARK: - Créneaux horaires compacts

    /// Un créneau : un libellé (heure ou tranche) et la prévision représentative.
    private struct WeatherSlot {
        let label: String
        let forecast: HourlyWeather
    }

    /// Créneaux compacts de la journée (nuit regroupée, puis toutes les ~3 h),
    /// construits à partir des heures disponibles pour le jour affiché.
    private var slots: [WeatherSlot] {
        let targets: [(hour: Int, label: String)] = [
            (0, "00 h – 02 h"),
            (2, "02 h – 05 h"),
            (5, "05 h – 08 h"),
            (8, "08 h – 11 h"),
            (11, "11 h – 14 h"),
            (14, "14 h – 17 h"),
            (17, "17 h – 20 h"),
            (20, "20 h – 22 h"),
            (22, "22 h – 00 h")
        ]
        let calendar = Calendar.current
        return targets.compactMap { target in
            guard let match = hourly.first(where: { calendar.component(.hour, from: $0.hour) == target.hour }) else { return nil }
            return WeatherSlot(label: target.label, forecast: match)
        }
    }

    private func slotAccessibility(_ slot: WeatherSlot) -> String {
        "\(slot.label), \(weatherDescription(for: slot.forecast.weatherCode)), \(Int(slot.forecast.temperature.rounded()))°"
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
