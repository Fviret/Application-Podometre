import Foundation

/// Prévisions météo pour une heure donnée.
struct HourlyWeather {
    let hour: Date
    let precipitationMm: Double
    let temperature: Double
    let weatherCode: Int
}

/// Résumé des conditions de marche sur les 6 prochaines heures.
struct WalkingForecast {
    let nextRainHour: Date?
    let currentTemp: Double
    let currentCode: Int
    let hours: [HourlyWeather]
}

/// Service de récupération des prévisions Open-Meteo (sans clé API).
actor WeatherService {
    static let shared = WeatherService()

    /// Retourne les prévisions de marche pour les 6 prochaines heures à la position donnée.
    func fetch(lat: Double, lon: Double) async throws -> WalkingForecast {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&hourly=temperature_2m,precipitation,weathercode&forecast_days=2&timezone=auto"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }

        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)

        let now = Date()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime]

        let hours: [HourlyWeather] = zip(json.hourly.time, zip(
            json.hourly.precipitation,
            zip(json.hourly.temperature_2m, json.hourly.weathercode)
        ))
        .compactMap { (timeStr, rest) -> HourlyWeather? in
            let (precip, (temp, code)) = rest
            guard let date = formatter.date(from: timeStr) else { return nil }
            guard date >= now && date <= now.addingTimeInterval(6 * 3600) else { return nil }
            return HourlyWeather(hour: date, precipitationMm: precip, temperature: temp, weatherCode: code)
        }

        let nextRainHour = hours.first { $0.precipitationMm > 0.1 }?.hour
        let currentTemp = hours.first?.temperature ?? 0
        let currentCode = hours.first?.weatherCode ?? 0

        return WalkingForecast(
            nextRainHour: nextRainHour,
            currentTemp: currentTemp,
            currentCode: currentCode,
            hours: hours
        )
    }
}

// MARK: - Codable

private struct OpenMeteoResponse: Codable {
    struct Hourly: Codable {
        let time: [String]
        let temperature_2m: [Double]
        let precipitation: [Double]
        let weathercode: [Int]
    }
    let hourly: Hourly
}
