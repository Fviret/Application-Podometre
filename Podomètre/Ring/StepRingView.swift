import SwiftUI
import CoreLocation

struct StepRingView: View {
    @ObservedObject var viewModel: StepCountViewModel

    @StateObject private var locationManager = LocationManager()
    @State private var walkingForecast: WalkingForecast?
    @State private var dailyForecasts: [DailyForecast] = []
    @State private var locationLabel: String? = nil

    @AppStorage("showWeatherForecast") private var showWeatherForecast: Bool = true
    @AppStorage("showMonthCalendar") private var showMonthCalendar: Bool = true
    @AppStorage("showWeeklyChart") private var showWeeklyChart: Bool = true

    private let ringDiameter: CGFloat = 240
    private let strokeWidth: CGFloat = 20
    private let haptic = UIImpactFeedbackGenerator(style: .light)

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

                            Spacer()

                            VStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .stroke(Color(.systemGray5), lineWidth: strokeWidth)
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
                                        .animation(.easeInOut(duration: 0.6), value: viewModel.progress)

                                    VStack(spacing: 4) {
                                        Text(viewModel.stepCount.formatted())
                                            .font(.system(size: 44, weight: .bold, design: .rounded))
                                            .foregroundStyle(Color.primary)
                                            .contentTransition(.numericText())
                                            .animation(.easeInOut(duration: 0.6), value: viewModel.stepCount)

                                        Text("pas")
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundStyle(Color.secondary)
                                    }
                                }

                                Text(viewModel.selectedDateLabel)
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.primary)
                                    .id(viewModel.selectedDayOffset)
                                    .transition(.opacity)
                                    .animation(.easeInOut(duration: 0.2), value: viewModel.selectedDayOffset)
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
                            .opacity(viewModel.selectedDayOffset > 0 ? 1 : 0)
                            .disabled(viewModel.selectedDayOffset <= 0)
                            .animation(.easeInOut(duration: 0.15), value: viewModel.selectedDayOffset)
                        }
                        .padding(.horizontal, 8)

                        Text("Objectif : \(viewModel.goal.formatted()) pas")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
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
            viewModel.requestAuthorizationAndFetch()
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

#Preview {
    StepRingView(viewModel: StepCountViewModel())
}
