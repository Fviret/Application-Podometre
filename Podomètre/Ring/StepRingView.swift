import SwiftUI
import CoreLocation

struct StepRingView: View {
    @ObservedObject var viewModel: StepCountViewModel

    @StateObject private var locationManager = LocationManager()
    @State private var walkingForecast: WalkingForecast?
    @State private var dailyForecasts: [DailyForecast] = []
    @State private var locationLabel: String? = nil

    @AppStorage(.showWeatherForecast) private var showWeatherForecast: Bool = true
    @AppStorage(.showMonthCalendar) private var showMonthCalendar: Bool = true
    @AppStorage(.showWeeklyChart) private var showWeeklyChart: Bool = true
    @AppStorage(.hasCompletedOnboarding) private var hasCompletedOnboarding: Bool = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    private let ringDiameter: CGFloat = 240
    private let strokeWidth: CGFloat = 20
    private let haptic = UIImpactFeedbackGenerator(style: .light)
    /// Retour haptique fort de célébration, déclenché à la complétion de l'objectif du jour.
    private let celebrationHaptic = UINotificationFeedbackGenerator()

    /// État du pulse du halo de célébration (objectif atteint).
    @State private var haloPulse = false

    /// Vrai quand l'objectif du jour est atteint pour aujourd'hui — pilote le halo et la série 🔥.
    private var goalReachedToday: Bool {
        viewModel.selectedDayOffset == 0 && viewModel.stepCount >= viewModel.goal
    }

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                WeatherBannerView(forecast: walkingForecast)

                ScrollView {
                    VStack(spacing: 32) {
                        HStack(spacing: 0) {
                            Button {
                                haptic.impactOccurred()
                                viewModel.selectedDayOffset += 1
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.title2)
                                    .foregroundStyle(Color.secondary)
                                    .frame(width: 44, height: 44)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Jour précédent")

                            Spacer()

                            VStack(spacing: 16) {
                                ZStack {
                                    // Halo de célébration : lueur colorée derrière l'anneau quand l'objectif
                                    // du jour est atteint, avec un léger pulse à l'apparition (respecte reduceMotion).
                                    if goalReachedToday {
                                        Circle()
                                            .fill(viewModel.ringColor)
                                            .frame(width: ringDiameter, height: ringDiameter)
                                            .blur(radius: 30)
                                            .opacity(0.3)
                                            .scaleEffect(haloPulse ? 1.05 : 0.9)
                                            .accessibilityHidden(true)
                                            .transition(.opacity)
                                            .onAppear {
                                                guard !reduceMotion else { haloPulse = true; return }
                                                withAnimation(.spring(response: 0.7, dampingFraction: 0.55)) {
                                                    haloPulse = true
                                                }
                                            }
                                            .onDisappear { haloPulse = false }
                                    }

                                    // Piste : léger dégradé (gray6 → gray5) + ombre interne discrète
                                    // pour donner de la profondeur (aspect « creusé ») sans surcharge.
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color(.systemGray6), Color(.systemGray5)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                            .shadow(.inner(color: .black.opacity(0.12), radius: 3, y: 1)),
                                            lineWidth: strokeWidth
                                        )
                                        .frame(width: ringDiameter, height: ringDiameter)

                                    Circle()
                                        .trim(from: 0, to: viewModel.progress)
                                        .stroke(
                                            LinearGradient(
                                                colors: [viewModel.ringColor.opacity(0.7), viewModel.ringColor],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                                        )
                                        .frame(width: ringDiameter, height: ringDiameter)
                                        .rotationEffect(.degrees(-90))
                                        .animation(reduceMotion ? nil : .easeInOut(duration: 0.6), value: viewModel.progress)

                                    VStack(spacing: 4) {
                                        // Compteur qui monte en douceur (incrémentation progressive) au lieu de sauter.
                                        RollingNumberText(value: Double(viewModel.stepCount))
                                            .animation(reduceMotion ? nil : .easeOut(duration: 0.6), value: viewModel.stepCount)

                                        Text("pas")
                                            .font(.system(.callout, design: .rounded).weight(.medium))
                                            .foregroundStyle(Color.secondary)

                                        // Série en cours : affichée sous « pas » quand l'objectif du jour est atteint.
                                        if viewModel.selectedDayOffset == 0,
                                           viewModel.stepCount >= viewModel.goal,
                                           viewModel.currentStreak > 0 {
                                            Text("🔥 \(viewModel.currentStreak) jour\(viewModel.currentStreak > 1 ? "s" : "") de suite")
                                                .font(.system(.caption, design: .rounded).weight(.semibold))
                                                .foregroundStyle(Color.secondary)
                                                .padding(.top, 2)
                                                .transition(.opacity.combined(with: .scale))
                                                .accessibilityLabel("Série de \(viewModel.currentStreak) jour\(viewModel.currentStreak > 1 ? "s" : "") consécutif\(viewModel.currentStreak > 1 ? "s" : "")")
                                        }
                                    }
                                }
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel("Progression du jour")
                                .accessibilityValue("\(viewModel.stepCount.formatted()) pas sur \(viewModel.goal.formatted()), \(Int(viewModel.progress * 100)) %")
                                .accessibilityIdentifier("step_ring")

                                Text(viewModel.selectedDateLabel)
                                    .font(.system(.subheadline, design: .rounded).weight(.medium))
                                    .foregroundStyle(Color.primary)
                                    .id(viewModel.selectedDayOffset)
                                    .transition(.opacity)
                                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: viewModel.selectedDayOffset)
                                    .accessibilityIdentifier("date_label")
                            }

                            Spacer()

                            Button {
                                haptic.impactOccurred()
                                viewModel.selectedDayOffset -= 1
                            } label: {
                                Image(systemName: "chevron.right")
                                    .font(.title2)
                                    .foregroundStyle(Color.secondary)
                                    .frame(width: 44, height: 44)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Jour suivant")
                            .opacity(viewModel.selectedDayOffset > 0 ? 1 : 0)
                            .disabled(viewModel.selectedDayOffset <= 0)
                            .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: viewModel.selectedDayOffset)
                        }
                        .padding(.horizontal, 8)

                        Text("Objectif : \(viewModel.goal.formatted()) pas")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(Color.secondary)

                        if showWeatherForecast {
                            WeeklyForecastBannerView(forecasts: dailyForecasts, locationLabel: locationLabel)
                        }

                        if showMonthCalendar {
                            Divider()
                                .padding(.horizontal, 24)

                            MonthCalendarView(viewModel: viewModel)
                                .padding(.horizontal, 24)
                        }

                        if showWeeklyChart {
                            Divider()
                                .padding(.horizontal, 24)

                            WeeklyBarChartView(viewModel: viewModel)
                                .padding(.horizontal, 24)
                        }
                    }
                    .padding(.vertical, 32)
                }
            }
        }
        .onAppear {
            guard hasCompletedOnboarding else { return }
            viewModel.requestAuthorizationAndFetch()
            viewModel.startLiveStepUpdates()
            if showWeatherForecast {
                #if targetEnvironment(simulator)
                walkingForecast = WalkingForecast(
                    nextRainHour: Date().addingTimeInterval(1800),
                    currentTemp: 17,
                    currentCode: 2,
                    hours: [HourlyWeather(hour: Date().addingTimeInterval(1800), precipitationMm: 0.8, temperature: 17, weatherCode: 61)]
                )
                locationLabel = "Paris, France"
                dailyForecasts = [
                    DailyForecast(date: Date(), weatherCode: 1, tempMin: 14, tempMax: 22, precipitationMm: 0),
                    DailyForecast(date: Date().addingTimeInterval(86400), weatherCode: 61, tempMin: 12, tempMax: 17, precipitationMm: 4.2),
                    DailyForecast(date: Date().addingTimeInterval(86400 * 2), weatherCode: 3, tempMin: 13, tempMax: 19, precipitationMm: 0),
                    DailyForecast(date: Date().addingTimeInterval(86400 * 3), weatherCode: 0, tempMin: 15, tempMax: 24, precipitationMm: 0),
                    DailyForecast(date: Date().addingTimeInterval(86400 * 4), weatherCode: 80, tempMin: 11, tempMax: 16, precipitationMm: 8.0),
                    DailyForecast(date: Date().addingTimeInterval(86400 * 5), weatherCode: 2, tempMin: 14, tempMax: 21, precipitationMm: 0),
                    DailyForecast(date: Date().addingTimeInterval(86400 * 6), weatherCode: 0, tempMin: 16, tempMax: 25, precipitationMm: 0),
                ]
                #else
                locationManager.requestLocation()
                Timer.scheduledTimer(withTimeInterval: 1800, repeats: true) { _ in
                    guard showWeatherForecast, let loc = locationManager.location else { return }
                    Task { await fetchWeather(loc: loc) }
                }
                #endif
            }
        }
        .onChange(of: locationManager.location) { _, loc in
            guard showWeatherForecast, let loc else { return }
            Task { await fetchWeather(loc: loc) }
        }
        .onChange(of: hasCompletedOnboarding) { _, completed in
            guard completed else { return }
            viewModel.requestAuthorizationAndFetch()
            if showWeatherForecast {
                #if !targetEnvironment(simulator)
                locationManager.requestLocation()
                #endif
            }
        }
        .onChange(of: viewModel.progress) { oldValue, newValue in
            // Retour haptique fort de célébration au franchissement de l'objectif du jour (100 %).
            // Limité à aujourd'hui pour ne pas se déclencher en naviguant sur un jour passé déjà complété.
            guard viewModel.selectedDayOffset == 0, oldValue < 1.0, newValue >= 1.0 else { return }
            celebrationHaptic.notificationOccurred(.success)
        }
        .onChange(of: scenePhase) { _, phase in
            // Recale HealthKit et (re)démarre le live à chaque retour au premier plan ; coupe le live en arrière-plan.
            guard hasCompletedOnboarding else { return }
            switch phase {
            case .active:
                viewModel.fetchSteps(for: viewModel.selectedDate)
                viewModel.startLiveStepUpdates()
            default:
                viewModel.stopLiveStepUpdates()
            }
        }
        .onChange(of: viewModel.selectedDayOffset) { _, offset in
            // Le live ne concerne qu'aujourd'hui : on l'arrête sur un jour passé, on le relance au retour.
            if offset == 0 { viewModel.startLiveStepUpdates() } else { viewModel.stopLiveStepUpdates() }
        }
    }

    /// Récupère les prévisions horaires et journalières en parallèle, et reverse-géocode la ville.
    private func fetchWeather(loc: CLLocation) async {
        let lat = loc.coordinate.latitude
        let lon = loc.coordinate.longitude
        async let hourly = WeatherService.shared.fetch(lat: lat, lon: lon)
        async let daily = WeatherService.shared.fetchDaily(lat: lat, lon: lon)
        walkingForecast = try? await hourly
        dailyForecasts = (try? await daily) ?? []

        let placemarks = try? await CLGeocoder().reverseGeocodeLocation(loc)
        if let place = placemarks?.first {
            locationLabel = [place.locality, place.country].compactMap { $0 }.joined(separator: ", ")
        }
    }
}

#Preview("Objectif non atteint") {
    StepRingView(viewModel: StepCountViewModel())
}

#Preview("Objectif atteint (série 🔥)") {
    StepRingView(viewModel: .previewGoalReached)
}
