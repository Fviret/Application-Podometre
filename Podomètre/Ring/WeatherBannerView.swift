import SwiftUI

/// Bannière météo affichée en haut de l'écran Activité.
/// Invisible si la localisation n'est pas autorisée.
/// Indique uniquement si de la pluie est attendue dans l'heure suivante.
struct WeatherBannerView: View {
    let forecast: WalkingForecast?

    /// Pluie prévue dans moins d'une heure.
    private var rainWithinHour: Bool {
        guard let f = forecast, let rain = f.nextRainHour else { return false }
        return rain.timeIntervalSinceNow < 3600
    }

    /// Pluie en cours maintenant.
    private var rainingNow: Bool {
        guard let f = forecast else { return false }
        return (f.hours.first?.precipitationMm ?? 0) > 0.1
    }

    private var bannerText: String {
        if rainingNow { return "Pluie en cours" }
        if rainWithinHour { return "Pluie dans moins d'1h" }
        return "Pas de pluie prévue dans la prochaine heure"
    }

    var body: some View {
        if let _ = forecast {
            HStack(spacing: 6) {
                if rainingNow {
                    Image(systemName: "cloud.rain.fill").font(.caption).accessibilityHidden(true)
                    Text("Pluie en cours").font(.caption).fontWeight(.medium)
                } else if rainWithinHour {
                    Image(systemName: "cloud.drizzle.fill").font(.caption).accessibilityHidden(true)
                    Text("Pluie dans moins d'1h").font(.caption).fontWeight(.medium)
                } else {
                    Image(systemName: "sun.max.fill").font(.caption).accessibilityHidden(true)
                    Text("Pas de pluie prévue dans la prochaine heure").font(.caption).fontWeight(.medium)
                }
            }
            .foregroundStyle(rainingNow || rainWithinHour ? Color.blue : Color.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background((rainingNow || rainWithinHour) ? Color.blue.opacity(0.08) : Color.clear)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(bannerText)
        }
    }
}

#Preview("Pluie imminente") {
    WeatherBannerView(forecast: WalkingForecast(
        nextRainHour: Date().addingTimeInterval(1800),
        currentTemp: 14,
        currentCode: 2,
        hours: []
    ))
}

#Preview("Pas de pluie — soleil") {
    WeatherBannerView(forecast: WalkingForecast(
        nextRainHour: nil,
        currentTemp: 20,
        currentCode: 0,
        hours: []
    ))
}

#Preview("Pas de localisation — invisible") {
    WeatherBannerView(forecast: nil)
}
