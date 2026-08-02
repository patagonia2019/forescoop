//
//  WatchOnlyApp.swift
//  Forescoop
//
//  Created by Javier Fuchs on 07/23/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if os(watchOS)
import SwiftUI
import Forescoop

@main
struct ForescoopWatchOnlyApp: App {
    var body: some Scene {
        WindowGroup {
            WatchForecastView()
        }
    }
}

private struct WatchForecastView: View {
    private let forecastService: ForecastWindguruProtocol = ForecastWindguruService()
    @AppStorage("watchSelectedWindguruSpotID") private var selectedSpotID = "64141"
    @AppStorage("watchTemperatureUnit") private var temperatureUnitRaw = DeviceForecastPreferences.temperatureUnit.rawValue
    @AppStorage("watchWindSpeedUnit") private var windSpeedUnitRaw = DeviceForecastPreferences.windSpeedUnit.rawValue
    @State private var locations = WatchLocationStore.load()
    @State private var forecast: SpotForecast?
    @State private var errorMessage: String?
    @State private var selectedHour: String?

    var body: some View {
        NavigationStack {
            Group {
                if let forecast {
                    let hour = selectedHour ?? forecast.currentForecastHour
                    let weather = forecast.forecast
                    VStack(spacing: 10) {
                        HStack(spacing: 4) {
                            Text(forecast.asCurrentLocation ?? selectedLocation?.name ?? "Forecast")
                            .font(.headline)
                            .lineLimit(1)

                            NavigationLink(value: WatchDestination.locations) {
                                Image(systemName: "mappin.circle.fill")
                            }
                            .accessibilityLabel("Choose location")

                            NavigationLink(value: WatchDestination.grid) {
                                Image(systemName: "tablecells")
                            }
                            .accessibilityLabel("Forecast grid")

                            NavigationLink(value: WatchDestination.settings) {
                                Image(systemName: "gearshape")
                            }
                            .accessibilityLabel("Settings")
                        }

                        NavigationLink(value: WatchDestination.hours) {
                            Label(hourTitle(forecast, hour: hour), systemImage: "clock")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        HStack(spacing: 5) {
                            ForEach(forecast.weatherSymbolNames(hour: hour), id: \.self) {
                                Image(systemName: $0)
                            }
                        }
                        .font(.title2)

                        Text(temperature(weather?.temperatureReal(hh: hour) ?? weather?.temperature(hh: hour)))
                            .font(.system(.title2, design: .rounded).weight(.semibold))

                        HStack(spacing: 12) {
                            watchMetric("Wind", value: wind(weather?.windSpeed(hh: hour)), symbol: "wind")
                            watchMetric("Gusts", value: wind(weather?.windGustsKnots(hh: hour)), symbol: "wind.circle")
                            watchMetric("Rain", value: precipitation(weather?.precipitation(hh: hour) ?? weather?.precipitation1(hh: hour)), symbol: "drop")
                        }

                        Label(weather?.modelName ?? "Forecast model", systemImage: "cpu")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                } else if let errorMessage {
                    ContentUnavailableView("Forecast unavailable", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
                } else {
                    ProgressView()
                }
            }
            .navigationDestination(for: WatchDestination.self) { destination in
                switch destination {
                case .locations:
                    WatchLocationPicker(
                        locations: locations,
                        selectedSpotID: selectedSpotID,
                        select: select,
                        add: add
                    )
                case .hours:
                    WatchForecastHoursView(
                        forecast: forecast,
                        selectedHour: $selectedHour
                    )
                case .grid:
                    WatchForecastGridView(
                        forecast: forecast,
                        selectedHour: $selectedHour,
                        temperatureUnit: temperatureUnit,
                        windSpeedUnit: windSpeedUnit
                    )
                case .settings:
                    WatchForecastSettingsView(
                        temperatureUnitRaw: $temperatureUnitRaw,
                        windSpeedUnitRaw: $windSpeedUnitRaw
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Refresh", systemImage: "arrow.clockwise") {
                        Task { await loadForecast() }
                    }
                }
            }
        }
        .task { await loadForecast() }
        .onChange(of: selectedSpotID) { _, _ in
            Task { await loadForecast() }
        }
    }

    @MainActor
    private func loadForecast() async {
        do {
            errorMessage = nil
            forecast = try await forecastService.forecast(bySpotId: selectedSpotID, model: nil)
            selectedHour = forecast?.currentForecastHour
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private var selectedLocation: WatchLocation? {
        locations.first { $0.spotID == selectedSpotID }
    }

    private func select(_ location: WatchLocation) {
        selectedSpotID = location.spotID
    }

    private func add(_ location: WatchLocation) {
        guard locations.contains(where: { $0.spotID == location.spotID }) == false else {
            selectedSpotID = location.spotID
            return
        }
        locations.append(location)
        WatchLocationStore.save(locations)
        selectedSpotID = location.spotID
    }

    private func temperature(_ value: Double?) -> String {
        guard let value else { return "—" }
        let converted = temperatureUnit == .fahrenheit ? value * 9 / 5 + 32 : value
        return "\(converted.formatted(.number.precision(.fractionLength(0))))\(temperatureUnit.label)"
    }

    private func wind(_ value: Double?) -> String {
        guard let value else { return "—" }
        let converted: Double
        switch windSpeedUnit {
        case .knots: converted = value
        case .metersPerSecond: converted = value * 0.514_444
        case .kilometersPerHour: converted = value * 1.852
        case .milesPerHour: converted = value * 1.150_78
        case .beaufort: converted = min(12, (value / 3.01).rounded())
        }
        return "\(converted.formatted(.number.precision(.fractionLength(0)))) \(windSpeedUnit.label)"
    }

    private func precipitation(_ value: Double?) -> String {
        guard let value else { return "—" }
        return "\(value.formatted(.number.precision(.fractionLength(1)))) mm"
    }

    private func watchMetric(_ title: String, value: String, symbol: String) -> some View {
        VStack(spacing: 2) {
            Image(systemName: symbol).font(.caption2)
            Text(value).font(.caption2.monospacedDigit())
            Text(title).font(.system(size: 9)).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func hourTitle(_ forecast: SpotForecast, hour: String?) -> String {
        guard let hour, let date = forecast.forecastDate(hour: hour) else { return "Select hour" }
        return date.formatted(.dateTime.weekday(.abbreviated).hour())
    }

    private var temperatureUnit: TemperatureUnit {
        TemperatureUnit(rawValue: temperatureUnitRaw) ?? DeviceForecastPreferences.temperatureUnit
    }

    private var windSpeedUnit: WindSpeedUnit {
        WindSpeedUnit(rawValue: windSpeedUnitRaw) ?? DeviceForecastPreferences.windSpeedUnit
    }
}

private enum WatchDestination: Hashable {
    case locations
    case hours
    case grid
    case settings
}

private struct WatchLocation: Codable, Identifiable, Hashable {
    let spotID: String
    let name: String

    var id: String { spotID }
}

private enum WatchLocationStore {
    private static let key = "watchSavedWindguruLocations"
    private static let defaultLocations = [WatchLocation(spotID: "64141", name: "Bariloche")]

    static func load() -> [WatchLocation] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let locations = try? JSONDecoder().decode([WatchLocation].self, from: data),
              locations.isEmpty == false else {
            return defaultLocations
        }
        return locations
    }

    static func save(_ locations: [WatchLocation]) {
        UserDefaults.standard.set(try? JSONEncoder().encode(locations), forKey: key)
    }
}

private struct WatchLocationPicker: View {
    let locations: [WatchLocation]
    let selectedSpotID: String
    let select: (WatchLocation) -> Void
    let add: (WatchLocation) -> Void

    var body: some View {
        List {
            Section("Locations") {
                ForEach(locations) { location in
                    Button {
                        select(location)
                    } label: {
                        HStack {
                            Label(location.name, systemImage: "mappin.circle")
                            Spacer()
                            if location.spotID == selectedSpotID {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.tint)
                            }
                        }
                    }
                }
            }

            HStack {
                Spacer()
                NavigationLink(value: true) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
                .accessibilityLabel("Add Windguru spot")
                Spacer()
            }
        }
        .navigationTitle("Location")
        .navigationDestination(for: Bool.self) { _ in
            WatchSpotIDEditor(add: add)
        }
    }
}

private struct WatchSpotIDEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var spotID = ""
    let add: (WatchLocation) -> Void

    var body: some View {
        Form {
            TextField("Name", text: $name)
            TextField("Windguru spot ID", text: $spotID)

            Button {
                let trimmedID = spotID.trimmingCharacters(in: .whitespacesAndNewlines)
                guard trimmedID.isEmpty == false else { return }
                let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                add(WatchLocation(spotID: trimmedID, name: trimmedName.isEmpty ? "Windguru spot" : trimmedName))
                dismiss()
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
            }
            .accessibilityLabel("Add location")
            .disabled(spotID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .navigationTitle("Add location")
    }
}

/// A compact hour picker for the watch dashboard.
private struct WatchForecastHoursView: View {
    let forecast: SpotForecast?
    @Binding var selectedHour: String?

    var body: some View {
        List {
            if let forecast {
                ForEach(forecast.availableForecastHours, id: \.self) { hour in
                    Button {
                        selectedHour = hour
                    } label: {
                        HStack {
                            Text(title(for: hour, in: forecast))
                            Spacer()
                            if selectedHour == hour {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.tint)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Forecast hour")
    }

    private func title(for hour: String, in forecast: SpotForecast) -> String {
        guard let date = forecast.forecastDate(hour: hour) else { return "\(hour) hs" }
        return date.formatted(.dateTime.weekday(.abbreviated).hour())
    }
}

/// A readable watch adaptation of the forecast grid: one compact row per hour.
private struct WatchForecastGridView: View {
    let forecast: SpotForecast?
    @Binding var selectedHour: String?
    let temperatureUnit: TemperatureUnit
    let windSpeedUnit: WindSpeedUnit

    var body: some View {
        List {
            if let forecast, let weather = forecast.forecast {
                Section("Forecast grid") {
                    ForEach(forecast.availableForecastHours, id: \.self) { hour in
                        Button {
                            selectedHour = hour
                        } label: {
                            HStack(spacing: 8) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(hourTitle(hour, in: forecast))
                                    Image(systemName: forecast.weatherSymbolName(hour: hour))
                                        .foregroundStyle(.secondary)
                                }
                                .frame(width: 58, alignment: .leading)

                                VStack(alignment: .trailing, spacing: 2) {
                                    Label(wind(weather.windSpeed(hh: hour)), systemImage: "wind")
                                    Text(temperature(weather.temperatureReal(hh: hour) ?? weather.temperature(hh: hour)))
                                }
                                .font(.caption.monospacedDigit())

                                if selectedHour == hour {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.tint)
                                }
                            }
                        }
                    }
                }
            } else {
                ContentUnavailableView("Forecast unavailable", systemImage: "exclamationmark.triangle")
            }
        }
        .navigationTitle("Forecast grid")
    }

    private func hourTitle(_ hour: String, in forecast: SpotForecast) -> String {
        guard let date = forecast.forecastDate(hour: hour) else { return "\(hour) hs" }
        return date.formatted(.dateTime.weekday(.narrow).hour())
    }

    private func temperature(_ value: Double?) -> String {
        guard let value else { return "—" }
        let converted = temperatureUnit == .fahrenheit ? value * 9 / 5 + 32 : value
        return "\(converted.formatted(.number.precision(.fractionLength(0))))\(temperatureUnit.label)"
    }

    private func wind(_ value: Double?) -> String {
        guard let value else { return "—" }
        let converted: Double
        switch windSpeedUnit {
        case .knots: converted = value
        case .metersPerSecond: converted = value * 0.514_444
        case .kilometersPerHour: converted = value * 1.852
        case .milesPerHour: converted = value * 1.150_78
        case .beaufort: converted = min(12, (value / 3.01).rounded())
        }
        return "\(converted.formatted(.number.precision(.fractionLength(0)))) \(windSpeedUnit.label)"
    }
}

/// Watch-sized settings for the units visible in its dashboard and grid.
private struct WatchForecastSettingsView: View {
    @Binding var temperatureUnitRaw: String
    @Binding var windSpeedUnitRaw: String

    var body: some View {
        Form {
            Picker("Temperature", selection: $temperatureUnitRaw) {
                ForEach(TemperatureUnit.allCases) { unit in
                    Text(unit.label).tag(unit.rawValue)
                }
            }
            Picker("Wind", selection: $windSpeedUnitRaw) {
                ForEach(WindSpeedUnit.allCases) { unit in
                    Text(unit.label).tag(unit.rawValue)
                }
            }
        }
        .navigationTitle("Settings")
    }
}
#endif
