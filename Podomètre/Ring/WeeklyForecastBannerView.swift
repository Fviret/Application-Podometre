import SwiftUI

/// Bannière de prévisions météo sur 7 jours, affichée sous l'anneau de pas.
/// Invisible tant que la localisation n'est pas accordée.
struct WeeklyForecastBannerView: View {
    let forecasts: [DailyForecast]
    var locationLabel: String? = nil

    var body: some View {
        if !forecasts.isEmpty {
            VStack(spacing: 2) {
                Divider()
                    .padding(.horizontal, 24)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(forecasts.indices, id: \.self) { i in
                            DayForecastCell(forecast: forecasts[i], isToday: i == 0)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                }
                .accessibilityElement(children: .contain)

                if let label = locationLabel {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 9))
                            .accessibilityHidden(true)
                        Text(label)
                            .font(.caption2)
                    }
                    .foregroundStyle(Color.secondary.opacity(0.6))
                    .padding(.bottom, 4)
                    .accessibilityLabel("Localisation : \(label)")
                }
            }
        }
    }
}

/// Cellule d'un jour dans la bannière 7 jours.
private struct DayForecastCell: View {
    let forecast: DailyForecast
    let isToday: Bool

    private var dayLabel: String {
        if isToday { return "Auj." }
        let f = DateFormatter()
        f.locale = Locale(identifier: "fr_FR")
        f.dateFormat = "EEE"
        return f.string(from: forecast.date).capitalized
    }

    private var fullDayLabel: String {
        if isToday { return "Aujourd'hui" }
        let f = DateFormatter()
        f.locale = Locale(identifier: "fr_FR")
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

            Text(weatherIcon(for: forecast.weatherCode))
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

    /// Retourne l'emoji météo correspondant au code WMO.
    private func weatherIcon(for code: Int) -> String {
        switch code {
        case 0:        return "☀️"
        case 1:        return "🌤️"
        case 2:        return "⛅"
        case 3:        return "☁️"
        case 45, 48:   return "🌫️"
        case 51, 53, 55, 56, 57: return "🌦️"
        case 61, 63, 65: return "🌧️"
        case 66, 67:   return "🌨️"
        case 71, 73, 75, 77: return "❄️"
        case 80, 81, 82: return "🌧️"
        case 85, 86:   return "🌨️"
        case 95:       return "⛈️"
        case 96, 99:   return "⛈️"
        default:       return "🌡️"
        }
    }

    /// Description textuelle du code météo WMO pour VoiceOver.
    private func weatherDescription(for code: Int) -> String {
        switch code {
        case 0:        return "ciel dégagé"
        case 1:        return "principalement dégagé"
        case 2:        return "partiellement nuageux"
        case 3:        return "couvert"
        case 45, 48:   return "brouillard"
        case 51...57:  return "bruine"
        case 61, 63, 65: return "pluie"
        case 66, 67:   return "pluie verglaçante"
        case 71, 73, 75, 77: return "neige"
        case 80, 81, 82: return "averses"
        case 85, 86:   return "averses de neige"
        case 95, 96, 99: return "orages"
        default:       return "conditions variables"
        }
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
