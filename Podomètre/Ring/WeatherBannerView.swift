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

    var body: some View {
        if let _ = forecast {
            HStack(spacing: 6) {
                if rainingNow {
                    Image(systemName: "cloud.rain.fill").font(.caption)
                    Text("Pluie en cours").font(.caption).fontWeight(.medium)
                } else if rainWithinHour {
                    Image(systemName: "cloud.drizzle.fill").font(.caption)
                    Text("Pluie dans moins d'1h").font(.caption).fontWeight(.medium)
                } else {
                    Image(systemName: "sun.max.fill").font(.caption)
                    Text("Pas de pluie prévue dans la prochaine heure").font(.caption).fontWeight(.medium)
                }
            }
            .foregroundStyle(rainingNow || rainWithinHour ? Color.blue : Color.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background((rainingNow || rainWithinHour) ? Color.blue.opacity(0.08) : Color.clear)
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

#Preview("Pas de pluie — invisible") {
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
