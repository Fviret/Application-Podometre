import CoreLocation
import Foundation

/// Cache local de la dernière météo récupérée, avec la position à laquelle elle correspond.
/// Évite un appel réseau au lancement si l'utilisateur n'a pas quitté les environs de sa
/// dernière position connue et que le cache n'est pas trop ancien.
struct WeatherCache: Codable {
    let latitude: Double
    let longitude: Double
    let walkingForecast: WalkingForecast?
    let dailyForecasts: [DailyForecast]
    let allHourly: [HourlyWeather]
    let locationLabel: String?
    let fetchedAt: Date

    /// Distance à partir de laquelle un nouvel appel météo est justifié — la météo n'a
    /// pas d'intérêt à être rafraîchie pour un déplacement local à l'échelle d'une ville.
    private static let significantDistanceMeters: CLLocationDistance = 3000

    /// Durée de validité du cache avant qu'il soit considéré périmé, même sans déplacement
    /// (la météo elle-même évolue avec le temps) — aligné sur le rafraîchissement périodique.
    private static let maxAge: TimeInterval = 1800

    /// `true` si ce cache reste valable pour `location` : position proche ET pas trop ancien.
    func isValid(for location: CLLocation, now: Date = Date()) -> Bool {
        let cachedLocation = CLLocation(latitude: latitude, longitude: longitude)
        guard location.distance(from: cachedLocation) <= Self.significantDistanceMeters else { return false }
        return now.timeIntervalSince(fetchedAt) <= Self.maxAge
    }

    static func load() -> WeatherCache? {
        guard let data = Preferences.shared.data(.weatherCache) else { return nil }
        return try? JSONDecoder().decode(WeatherCache.self, from: data)
    }

    static func save(
        location: CLLocation,
        walkingForecast: WalkingForecast?,
        dailyForecasts: [DailyForecast],
        allHourly: [HourlyWeather],
        locationLabel: String?
    ) {
        let cache = WeatherCache(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            walkingForecast: walkingForecast,
            dailyForecasts: dailyForecasts,
            allHourly: allHourly,
            locationLabel: locationLabel,
            fetchedAt: Date()
        )
        guard let data = try? JSONEncoder().encode(cache) else { return }
        Preferences.shared.set(data, for: .weatherCache)
    }
}
