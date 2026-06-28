import SwiftUI

/// Bannière météo compacte affichant les conditions de marche pour les 6 prochaines heures.
struct WeatherBannerView: View {
    let forecast: WalkingForecast?
    @ObservedObject var viewModel: StepCountViewModel

    private var isRaining: Bool {
        guard let f = forecast else { return false }
        return (f.hours.first?.precipitationMm ?? 0) > 0.1
    }

    private var rainSoon: Bool {
        guard let f = forecast, let rain = f.nextRainHour else { return false }
        return rain.timeIntervalSinceNow < 3600
    }

    private var iconName: String {
        guard let f = forecast else { return "cloud" }
        switch f.currentCode {
        case 0, 1:       return "sun.max"
        case 2:          return "cloud.sun"
        case 3:          return "cloud"
        case 45, 48:     return "cloud.fog"
        case 51...67:    return "cloud.drizzle"
        case 71...77:    return "cloud.snow"
        case 80...82:    return "cloud.rain"
        case 95, 96, 99: return "cloud.bolt.rain"
        default:         return "cloud"
        }
    }

    private var iconColor: Color {
        guard let f = forecast else { return .secondary }
        return f.nextRainHour == nil ? viewModel.ringColor : .secondary
    }

    private var message: String {
        guard let f = forecast else { return "Chargement de la météo..." }

        if isRaining {
            return "Pluie en cours — attendez une accalmie"
        }
        guard let rain = f.nextRainHour else {
            return "Conditions idéales pour marcher"
        }
        let hours = Int(rain.timeIntervalSinceNow / 3600)
        if hours < 1 {
            return "Pluie imminente — partez maintenant !"
        }
        return "Sec encore \(hours)h — profitez-en"
    }

    private var messageColor: Color {
        guard let f = forecast else { return .secondary }
        if isRaining { return .secondary }
        if rainSoon { return .orange }
        return .primary
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundStyle(iconColor)
                .frame(width: 28)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(messageColor)

            Spacer()

            if let f = forecast {
                Text("\(Int(f.currentTemp))°")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
    }
}

// MARK: - Preview

#Preview("Conditions idéales") {
    let forecast = WalkingForecast(
        nextRainHour: nil,
        currentTemp: 18,
        currentCode: 1,
        hours: []
    )
    return WeatherBannerView(forecast: forecast, viewModel: StepCountViewModel())
}

#Preview("Pluie dans 2h") {
    let forecast = WalkingForecast(
        nextRainHour: Date().addingTimeInterval(7200),
        currentTemp: 14,
        currentCode: 2,
        hours: []
    )
    return WeatherBannerView(forecast: forecast, viewModel: StepCountViewModel())
}

#Preview("Pluie imminente") {
    let forecast = WalkingForecast(
        nextRainHour: Date().addingTimeInterval(1800),
        currentTemp: 12,
        currentCode: 3,
        hours: []
    )
    return WeatherBannerView(forecast: forecast, viewModel: StepCountViewModel())
}

#Preview("Chargement") {
    WeatherBannerView(forecast: nil, viewModel: StepCountViewModel())
        .redacted(reason: .placeholder)
}
