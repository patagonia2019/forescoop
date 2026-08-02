//
//  WatchForecastView.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 08/02/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if os(watchOS)
import SwiftUI

/// The compact watchOS forecast dashboard.
public struct WatchForecastView: View {
    nonisolated(unsafe) private let forecastService: ForecastWindguruProtocol
    @AppStorage("watchSelectedWindguruSpotID") private var selectedSpotID = "64141"
    @AppStorage("watchTemperatureUnit") private var temperatureUnitRaw = DeviceForecastPreferences.temperatureUnit.rawValue
    @AppStorage("watchWindSpeedUnit") private var windSpeedUnitRaw = DeviceForecastPreferences.windSpeedUnit.rawValue
    @AppStorage("watchWaveHeightUnit") private var waveHeightUnitRaw = DeviceForecastPreferences.waveHeightUnit.rawValue
    @AppStorage("watchPressureUnit") private var pressureUnitRaw = DeviceForecastPreferences.pressureUnit.rawValue
    @AppStorage("watchPrecipitationUnit") private var precipitationUnitRaw = DeviceForecastPreferences.precipitationUnit.rawValue
    @AppStorage("watchFreezingLevelUnit") private var freezingLevelUnitRaw = DeviceForecastPreferences.freezingLevelUnit.rawValue
    @State private var locations = WatchLocationStore.load()
    @State private var forecast: SpotForecast?
    @State private var errorMessage: String?
    @State private var selectedHour: String?
    @State private var selectedModelID: String?
    @State private var navigationPath = NavigationPath()

    public init(forecastService: ForecastWindguruProtocol = ForecastWindguruService()) {
        self.forecastService = forecastService
    }

    public var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if let forecast {
                    dashboard(for: forecast)
                } else if let errorMessage {
                    ContentUnavailableView("Forecast unavailable", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
                } else {
                    ProgressView()
                }
            }
            .navigationDestination(for: WatchDestination.self) { destination in
                switch destination {
                case .locations:
                    WatchLocationPicker(locations: locations, selectedSpotID: selectedSpotID, select: select, add: add)
                case .hours:
                    WatchForecastHoursView(forecast: forecast, selectedHour: $selectedHour, temperatureUnit: temperatureUnit, windSpeedUnit: windSpeedUnit, precipitationUnit: precipitationUnit) {
                        navigationPath = NavigationPath()
                    }
                case .settings:
                    WatchForecastSettingsView(temperatureUnitRaw: $temperatureUnitRaw, windSpeedUnitRaw: $windSpeedUnitRaw, waveHeightUnitRaw: $waveHeightUnitRaw, pressureUnitRaw: $pressureUnitRaw, precipitationUnitRaw: $precipitationUnitRaw, freezingLevelUnitRaw: $freezingLevelUnitRaw)
                case .models:
                    if let forecast {
                        WatchForecastModelPicker(forecast: forecast, selectedModelID: selectedModelID, select: selectModel)
                    }
                }
            }
        }
        .task { await loadForecast() }
        .onChange(of: selectedSpotID) { _, _ in Task { await loadForecast() } }
    }

    private func dashboard(for forecast: SpotForecast) -> some View {
        let hour = selectedHour ?? forecast.currentForecastHour
        let weather = forecast.forecast
        return ScrollView {
            VStack(spacing: 10) {
                HStack(spacing: 8) {
                NavigationLink(value: WatchDestination.locations) { Image(systemName: "mappin.circle.fill") }.accessibilityLabel("Choose location")
                NavigationLink(value: WatchDestination.settings) { Image(systemName: "gearshape") }.accessibilityLabel("Settings")
                Button { Task { await loadForecast() } } label: { Image(systemName: "arrow.clockwise") }
                    .accessibilityLabel("Refresh forecast")
                    .handGestureShortcut(.primaryAction)
                }
                .font(.caption)

                Text(forecast.asCurrentLocation ?? selectedLocation?.name ?? "Forecast")
                    .font(.headline)
                    .lineLimit(1)

                NavigationLink(value: WatchDestination.hours) {
                    Label(hourTitle(forecast, hour: hour), systemImage: "clock").font(.caption).foregroundStyle(.secondary)
                }

                HStack(spacing: 5) {
                    ForEach(forecast.weatherSymbolNames(hour: hour), id: \.self) { Image(systemName: $0) }
                }
                .font(.title2)
                Text(temperature(weather?.temperatureReal(hh: hour) ?? weather?.temperature(hh: hour)))
                    .font(.system(.title2, design: .rounded).weight(.semibold))

                HStack(spacing: 12) {
                    metric("Wind", value: wind(weather?.windSpeed(hh: hour)), symbol: "wind")
                    metric("Gusts", value: wind(weather?.windGustsKnots(hh: hour)), symbol: "wind.circle")
                    metric("Direction", value: weather?.windDirectionName(hh: hour) ?? "—", symbol: "location.north.line")
                }
                
                HStack(spacing: 12) {
                    metric("Cloud", value: percentage(weather?.cloudCoverTotal(hh: hour)), symbol: "cloud")
                    metric("Rain", value: precipitation(weather?.precipitation(hh: hour) ?? weather?.precipitation1(hh: hour)), symbol: "drop")
                    metric("Humidity", value: percentage(weather?.relativeHumidity(hh: hour)), symbol: "humidity")
                }

                HStack(spacing: 12) {
                    metric("Pressure", value: pressure(weather?.seaLevelPressure(hh: hour)), symbol: "gauge.medium")
                    metric("Isotherm", value: freezingLevel(weather?.freezingLevelHeightInMeters(hh: hour)), symbol: "thermometer.medium")
                    metric("Waves", value: waveHeight(weather?.waveHeight(hh: hour)), symbol: "water.waves")
                }

                NavigationLink(value: WatchDestination.models) {
                    Label(weather?.modelName ?? "Forecast model", systemImage: "cpu")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
        }
        .scrollIndicators(.hidden)
        .multilineTextAlignment(.center)
    }

    @MainActor private func loadForecast() async {
        do {
            errorMessage = nil
            forecast = try await forecastService.forecast(bySpotId: selectedSpotID, model: nil)
            selectedHour = forecast?.currentForecastHour
            selectedModelID = forecast?.model
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private var selectedLocation: WatchLocation? { locations.first { $0.spotID == selectedSpotID } }
    private func select(_ location: WatchLocation) { selectedSpotID = location.spotID }
    private func add(_ location: WatchLocation) {
        if !locations.contains(where: { $0.spotID == location.spotID }) {
            locations.append(location)
            WatchLocationStore.save(locations)
        }
        selectedSpotID = location.spotID
    }

    private var temperatureUnit: TemperatureUnit { TemperatureUnit(rawValue: temperatureUnitRaw) ?? DeviceForecastPreferences.temperatureUnit }
    private var windSpeedUnit: WindSpeedUnit { WindSpeedUnit(rawValue: windSpeedUnitRaw) ?? DeviceForecastPreferences.windSpeedUnit }
    private var waveHeightUnit: WaveHeightUnit { WaveHeightUnit(rawValue: waveHeightUnitRaw) ?? DeviceForecastPreferences.waveHeightUnit }
    private var pressureUnit: PressureUnit { PressureUnit(rawValue: pressureUnitRaw) ?? DeviceForecastPreferences.pressureUnit }
    private var precipitationUnit: PrecipitationUnit { PrecipitationUnit(rawValue: precipitationUnitRaw) ?? DeviceForecastPreferences.precipitationUnit }
    private var freezingLevelUnit: FreezingLevelUnit { FreezingLevelUnit(rawValue: freezingLevelUnitRaw) ?? DeviceForecastPreferences.freezingLevelUnit }
    private func temperature(_ value: Double?) -> String { WatchForecastFormatting.temperature(value, unit: temperatureUnit) }
    private func wind(_ value: Double?) -> String { WatchForecastFormatting.wind(value, unit: windSpeedUnit) }
    private func precipitation(_ value: Double?) -> String {
        value.map { "\(Precipitation(millimeters: $0).value(in: precipitationUnit).formatted(.number.precision(.fractionLength(precipitationUnit == .inches ? 2 : 1)))) \(precipitationUnit.label)" } ?? "—"
    }
    private func percentage(_ value: Int?) -> String { value.map { "\($0)%" } ?? "—" }
    private func pressure(_ value: Double?) -> String {
        value.map { "\(AtmosphericPressure(hectopascals: $0).value(in: pressureUnit).formatted(.number.precision(.fractionLength(pressureUnit == .inchesOfMercury ? 2 : 0)))) \(pressureUnit.label)" } ?? "—"
    }
    private func freezingLevel(_ value: Double?) -> String {
        value.map { "\(FreezingLevel(meters: $0).value(in: freezingLevelUnit).formatted(.number.precision(.fractionLength(0)))) \(freezingLevelUnit.label)" } ?? "—"
    }
    private func waveHeight(_ value: Double?) -> String {
        value.map { "\(WaveHeight(meters: $0).value(in: waveHeightUnit).formatted(.number.precision(.fractionLength(1)))) \(waveHeightUnit.label)" } ?? "—"
    }
    private func selectModel(_ modelID: String) {
        forecast?.currentModel = modelID
        selectedModelID = modelID
        selectedHour = forecast?.currentForecastHour
    }
    private func metric(_ title: String, value: String, symbol: String) -> some View {
        VStack(spacing: 2) { Image(systemName: symbol).font(.caption2); Text(value).font(.caption2.monospacedDigit()); Text(title).font(.system(size: 9)).foregroundStyle(.secondary) }
            .frame(maxWidth: .infinity)
    }
    private func hourTitle(_ forecast: SpotForecast, hour: String?) -> String {
        guard let hour, let date = forecast.forecastDate(hour: hour) else { return "Select hour" }
        return WatchForecastFormatting.hour(date)
    }
}

enum WatchDestination: Hashable { case locations, hours, settings, models }

enum WatchForecastFormatting {
    /// Uses the system's 12/24-hour preference while keeping the watch label concise.
    static func hour(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        let hourTemplate = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: .autoupdatingCurrent) ?? "H"
        formatter.dateFormat = hourTemplate.contains("H") || hourTemplate.contains("k") ? "EEE, HH'h'" : "EEE, h a"
        return formatter.string(from: date).replacingOccurrences(of: " AM", with: "am").replacingOccurrences(of: " PM", with: "pm")
    }

    static func temperature(_ value: Double?, unit: TemperatureUnit) -> String {
        guard let value else { return "—" }
        let converted = unit == .fahrenheit ? value * 9 / 5 + 32 : value
        return "\(converted.formatted(.number.precision(.fractionLength(0))))\(unit.label)"
    }
    static func wind(_ value: Double?, unit: WindSpeedUnit) -> String {
        guard let value else { return "—" }
        let converted: Double
        switch unit {
        case .knots: converted = value
        case .metersPerSecond: converted = value * 0.514_444
        case .kilometersPerHour: converted = value * 1.852
        case .milesPerHour: converted = value * 1.150_78
        case .beaufort: converted = min(12, (value / 3.01).rounded())
        }
        return "\(converted.formatted(.number.precision(.fractionLength(0)))) \(unit.label)"
    }
}

#Preview("Watch forecast dashboard") { WatchForecastView(forecastService: ForecastWindguruMockup()) }
#endif
