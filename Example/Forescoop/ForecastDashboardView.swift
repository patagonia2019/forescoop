import SwiftUI
import CoreLocation
import Forescoop

struct ForecastDashboardView: View {
    private let forecastService: ForecastWindguruProtocol
    @State private var forecast: SpotForecast?
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var selectedHour: String?
    @State private var temperatureUnit: TemperatureUnit = .celsius
    @State private var windSpeedUnit: WindSpeedUnit = .knots
    @State private var pressureUnit: PressureUnit = .hectopascals
    @State private var showsWindDirectionArrow = false
    @State private var showsSpotPicker = false

    init(forecastService: ForecastWindguruProtocol = ForecastWindguruService()) {
        self.forecastService = forecastService
    }

    var body: some View {
        NavigationStack {
            Group {
                if let forecast {
                    VStack(spacing: 24) {
                        hourSelector(for: forecast)

                        Button {
                            showsSpotPicker = true
                        } label: {
                            Text(forecast.asCurrentLocation ?? "Unknown location")
                        }
                        .buttonStyle(.plain)
                            .font(.title.bold())
                        HStack(spacing: 12) {
                            ForEach(forecast.weatherSymbolNames(hour: selectedHour), id: \.self) { symbol in
                                Image(systemName: symbol)
                            }
                        }
                        .font(.system(size: 42))
                        .symbolRenderingMode(.hierarchical)
                        Menu {
                            Picker("Temperature unit", selection: $temperatureUnit) {
                                ForEach(TemperatureUnit.allCases) { unit in
                                    Text(unit.label).tag(unit)
                                }
                            }
                        } label: {
                            Text(temperature(for: forecast, hour: selectedHour))
                                .font(.system(size: 44, weight: .semibold))
                        }
                        .accessibilityLabel("Temperature")
                        HStack(spacing: 8) {
                            Image(systemName: "wind")
                            Text("Wind")
                            Menu {
                                Picker("Wind speed unit", selection: $windSpeedUnit) {
                                    ForEach(WindSpeedUnit.allCases) { unit in
                                        Text(unit.label).tag(unit)
                                    }
                                }
                            } label: {
                                Text(windSpeed(for: forecast, hour: selectedHour))
                            }
                            .accessibilityLabel("Wind speed")
                            Text("/")
                                .foregroundStyle(.secondary)
                            Text("Gusts")
                            Text(windSpeed(forecast.forecast?.windGustsKnots(hh: selectedHour ?? forecast.currentForecastHour)))
                            Button {
                                showsWindDirectionArrow.toggle()
                            } label: {
                                if showsWindDirectionArrow,
                                   let direction = forecast.forecast?.windDirection(hh: selectedHour ?? forecast.currentForecastHour) {
                                    // Wind directions describe where the wind comes from; this arrow points where it travels.
                                    Image(systemName: "arrow.down")
                                        .rotationEffect(.degrees(direction))
                                } else {
                                    Text(forecast.forecast?.windDirectionName(hh: selectedHour ?? forecast.currentForecastHour) ?? "—")
                                }
                            }
                            .foregroundColor(.blue)
                            .buttonStyle(.plain)
                            .accessibilityLabel("Wind direction")
                            .accessibilityHint("Shows the direction as an arrow")
                        }
                        .font(.body)

                        weatherDetails(for: forecast)
                    }
                    .padding()
                } else if isLoading {
                    ProgressView("Loading forecast…")
                } else if let errorMessage {
                    ContentUnavailableView("Forecast unavailable", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
                } else {
                    ContentUnavailableView("Forecast unavailable", systemImage: "cloud.sun")
                }
            }
            .navigationTitle("Forescoop")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Refresh", systemImage: "arrow.clockwise") {
                        Task { await loadForecast() }
                    }
                }
            }
            .task { await loadForecast() }
            .sheet(isPresented: $showsSpotPicker) {
                WindguruSpotPicker(forecastService: forecastService) { spot in
                    guard let spotId = spot.identifier else { return }
                    showsSpotPicker = false
                    Task { await loadForecast(spotId: spotId) }
                }
            }
        }
    }

    @MainActor
    private func loadForecast(spotId: String = "64141") async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            forecast = try await forecastService.forecast(bySpotId: spotId, model: nil)
            selectedHour = forecast.flatMap { closestHour(to: Date(), in: $0) }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func hourSelector(for forecast: SpotForecast) -> some View {
        let hours = forecast.availableForecastHours
        let currentHour = closestHour(to: Date(), in: forecast)
        let selection = selectedHour ?? currentHour
        let selectedIndex = selection.flatMap { hours.firstIndex(of: $0) }

        return HStack(spacing: 16) {
            Button {
                moveSelection(by: -1, in: hours)
            } label: {
                Label("Previous forecast hour", systemImage: "chevron.left")
                    .labelStyle(.iconOnly)
            }
            .disabled(selectedIndex == nil || selectedIndex == 0)

            Picker("Forecast hour", selection: $selectedHour) {
                ForEach(hours, id: \.self) { hour in
                    Text(hourLabel(for: hour, forecast: forecast))
                        .fontWeight(hour == currentHour ? .bold : .regular)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                        .fixedSize(horizontal: true, vertical: false)
                        .tag(Optional(hour))
                }
            }
            .pickerStyle(.menu)
            .fontWeight(selection == currentHour ? .bold : .regular)

            Button {
                moveSelection(by: 1, in: hours)
            } label: {
                Label("Next forecast hour", systemImage: "chevron.right")
                    .labelStyle(.iconOnly)
            }
            .disabled(selectedIndex == nil || selectedIndex == hours.count - 1)
        }
        .accessibilityElement(children: .contain)
    }

    private func moveSelection(by offset: Int, in hours: [String]) {
        guard let currentSelectedHour = selectedHour,
              let index = hours.firstIndex(of: currentSelectedHour) else { return }
        selectedHour = hours[hours.index(index, offsetBy: offset)]
    }

    private func closestHour(to date: Date, in forecast: SpotForecast) -> String? {
        forecast.availableForecastHours.min {
            abs((forecast.forecastDate(hour: $0)?.timeIntervalSince(date) ?? .greatestFiniteMagnitude))
                < abs((forecast.forecastDate(hour: $1)?.timeIntervalSince(date) ?? .greatestFiniteMagnitude))
        }
    }

    private func hourLabel(for hour: String, forecast: SpotForecast) -> String {
        guard let date = forecast.forecastDate(hour: hour) else {
            return String(format: "%02d hs", (Int(hour) ?? 0) % 24)
        }

        let calendar = Calendar.current
        let day: String
        if calendar.isDateInToday(date) {
            day = "Today"
        } else {
            day = date.formatted(.dateTime.weekday(.abbreviated).day())
        }
        return "\(day), \(date.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)))) hs"
    }

    private func temperature(for forecast: SpotForecast, hour: String?) -> String {
        let hour = hour ?? forecast.currentForecastHour
        guard let value = forecast.forecast?.temperatureReal(hh: hour) ?? forecast.forecast?.temperature(hh: hour) else { return "—" }
        return "\(formatted(Temperature(celsius: value).value(in: temperatureUnit)))\(temperatureUnit.label)"
    }

    private func windSpeed(for forecast: SpotForecast, hour: String?) -> String {
        let hour = hour ?? forecast.currentForecastHour
        guard let value = forecast.forecast?.windSpeed(hh: hour) else { return "—" }
        guard let convertedValue = Knots(value).value(in: windSpeedUnit) else { return "—" }
        return "\(formatted(convertedValue)) \(windSpeedUnit.label)"
    }

    private func weatherDetails(for forecast: SpotForecast) -> some View {
        let hour = selectedHour ?? forecast.currentForecastHour
        let weather = forecast.forecast

        return VStack(alignment: .leading, spacing: 10) {
            cloudCover(
                high: weather?.cloudCoverHigh(hh: hour),
                mid: weather?.cloudCoverMid(hh: hour),
                low: weather?.cloudCoverLow(hh: hour)
            )
            detail("Relative humidity", percent(weather?.relativeHumidity(hh: hour)), systemImage: "humidity")
            detail("Freezing level", meters(weather?.freezingLevelHeightInMeters(hh: hour)), systemImage: "thermometer.low")
            Menu {
                Picker("Pressure unit", selection: $pressureUnit) {
                    ForEach(PressureUnit.allCases) { unit in
                        Text(unit.label).tag(unit)
                    }
                }
            } label: {
                LabeledContent {
                    Text(pressure(weather?.seaLevelPressure(hh: hour)))
                } label: {
                    Label("Sea level pressure", systemImage: "gauge.medium")
                }
            }
        }
        .font(.body)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func cloudCover(high: Int?, mid: Int?, low: Int?) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            Label("Cloud", systemImage: "cloud.fill")
            cloudColumn("High", value: high)
            cloudColumn("Mid", value: mid)
            cloudColumn("Low", value: low)
        }
    }

    private func cloudColumn(_ title: String, value: Int?) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(percent(value))
                .monospacedDigit()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(cloudBackgroundOpacity(value)))
                .clipShape(.rect(cornerRadius: 6))
        }
        .frame(maxWidth: .infinity)
    }

    private func cloudBackgroundOpacity(_ value: Int?) -> Double {
        let percent = min(max(value ?? 0, 0), 100)
        return 0.12 + Double(percent) / 100 * 0.48
    }

    private func detail(_ title: String, _ value: String) -> some View {
        LabeledContent(title, value: value)
    }

    private func detail(_ title: String, _ value: String, systemImage: String) -> some View {
        LabeledContent {
            Text(value)
        } label: {
            Label(title, systemImage: systemImage)
        }
    }

    private func windSpeed(_ knots: Double?) -> String {
        guard let knots, let value = Knots(knots).value(in: windSpeedUnit) else { return "—" }
        return "\(formatted(value)) \(windSpeedUnit.label)"
    }

    private func percent(_ value: Int?) -> String {
        guard let value else { return "—" }
        return "\(value)%"
    }

    private func percent(_ value: Double?) -> String {
        guard let value else { return "—" }
        return "\(formatted(value))%"
    }

    private func meters(_ value: Double?) -> String {
        guard let value else { return "—" }
        return "\(value.formatted(.number.precision(.fractionLength(0)))) m"
    }

    private func pressure(_ value: Double?) -> String {
        guard let value else { return "—" }
        let converted = AtmosphericPressure(hectopascals: value).value(in: pressureUnit)
        return "\(formatted(converted)) \(pressureUnit.label)"
    }

    private func formatted(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(1)))
    }
}

#Preview {
    ForecastDashboardView(forecastService: ForecastWindguruMockup())
}

private struct WindguruSpotPicker: View {
    let forecastService: ForecastWindguruProtocol
    let onSpotSelected: (SpotOwner) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var spots: [SpotOwner] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button("Use Current Location", systemImage: "location.fill") {
                        Task { await searchCurrentLocation() }
                    }
                    .disabled(isLoading)
                } footer: {
                    Text("Uses the nearest matching public Windguru spot for the Simulator location.")
                }

                Section("Search Windguru spots") {
                    HStack {
                        TextField("City or spot", text: $query)
                            .textInputAutocapitalization(.words)
                            .onSubmit { Task { await search() } }
                        Button("Search") { Task { await search() } }
                            .disabled(query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                    }
                }

                if isLoading {
                    ProgressView("Searching spots…")
                } else if let errorMessage {
                    ContentUnavailableView("Location unavailable", systemImage: "location.slash", description: Text(errorMessage))
                } else if !spots.isEmpty {
                    Section("Windguru spots") {
                        ForEach(spots.indices, id: \.self) { index in
                            let spot = spots[index]
                            Button {
                                onSpotSelected(spot)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(spot.name ?? "Unknown spot")
                                    Text(spot.countryName ?? "")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Choose location")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    @MainActor
    private func searchCurrentLocation() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let location = try await CurrentLocationProvider().location()
            let placemark = try await CLGeocoder().reverseGeocodeLocation(location).first
            guard let searchTerm = placemark?.locality ?? placemark?.administrativeArea else {
                throw DeviceLocationError.noPlacemark
            }
            query = searchTerm
            spots = try await forecastService.searchSpots(byLocation: searchTerm)?.allSpots ?? []
            guard let closestSpot = spots.first else { throw DeviceLocationError.noWindguruSpot }
            onSpotSelected(closestSpot)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func search() async {
        let searchTerm = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !searchTerm.isEmpty else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            spots = try await forecastService.searchSpots(byLocation: searchTerm)?.allSpots ?? []
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

@MainActor
private final class CurrentLocationProvider: NSObject, @preconcurrency CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Error>?

    override init() {
        super.init()
        manager.delegate = self
    }

    func location() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            requestLocationIfAuthorized()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        requestLocationIfAuthorized()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        finish(with: .success(locations.last ?? locations[0]))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        finish(with: .failure(error))
    }

    private func requestLocationIfAuthorized() {
        guard continuation != nil else { return }
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        case .denied, .restricted:
            finish(with: .failure(DeviceLocationError.permissionDenied))
        @unknown default:
            finish(with: .failure(DeviceLocationError.permissionDenied))
        }
    }

    private func finish(with result: Result<CLLocation, Error>) {
        guard let continuation else { return }
        self.continuation = nil
        continuation.resume(with: result)
    }
}

private enum DeviceLocationError: LocalizedError {
    case permissionDenied
    case noPlacemark
    case noWindguruSpot

    var errorDescription: String? {
        switch self {
        case .permissionDenied: "Allow location access to use the Simulator's current location."
        case .noPlacemark: "The current coordinate could not be resolved to a city."
        case .noWindguruSpot: "Windguru has no public spot matching this location."
        }
    }
}
