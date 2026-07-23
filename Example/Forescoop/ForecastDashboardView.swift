//
//  ForecastDashboardView.swift
//  Forescoop
//
//  Created by Javier Fuchs on 07/22/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

import CoreLocation
import SwiftUI
import Forescoop

struct ForecastDashboardView: View {
    private static let windguruModelInfoURL = URL(string: "https://www.windguru.cz/help.php?sec=models")!
    private let forecastService: ForecastWindguruProtocol
    @AppStorage("selectedWindguruSpotID") private var selectedSpotID = "64141"
    @AppStorage("windguruUsername") private var windguruUsername = ""
    @State private var forecast: SpotForecast?
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var selectedHour: String?
    @State private var temperatureUnit: TemperatureUnit = .celsius
    @State private var windSpeedUnit: WindSpeedUnit = .knots
    @State private var pressureUnit: PressureUnit = .hectopascals
    @State private var precipitationUnit: PrecipitationUnit = .millimeters
    @State private var freezingLevelUnit: FreezingLevelUnit = .meters
    @State private var showsWindDirectionArrow = false
    @State private var showsSpotPicker = false
    @State private var showsModelPicker = false
    @State private var showsLogin = false
    @State private var selectedModelIDs: [String] = []

    init(forecastService: ForecastWindguruProtocol = ForecastWindguruService()) {
        self.forecastService = forecastService
    }

    var body: some View {
        NavigationStack {
            Group {
                if let forecast {
                    VStack(spacing: 24) {
                        hourSelector(for: forecast)

                        VStack(spacing: 4) {
                            Button {
                                showsSpotPicker = true
                            } label: {
                                Label(forecast.asCurrentLocation ?? "Unknown location", systemImage: "mappin.and.ellipse")
                            }
                            .buttonStyle(.plain)
                            .font(.title.bold())
                            .foregroundColor(.blue)

                            HStack(spacing: 6) {
                                Button {
                                    showsModelPicker = true
                                } label: {
                                    Label(forecast.forecast?.modelName ?? "Forecast model", systemImage: "cpu")
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)

                                Link(destination: Self.windguruModelInfoURL) {
                                    Image(systemName: "info.circle")
                                }
                                .accessibilityLabel("About Windguru forecast models")
                                .accessibilityHint("Opens Windguru's model explanation")
                            }
                            .font(.title.bold())
                            .foregroundColor(.blue)
                        }
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
                            Label(temperature(for: forecast, hour: selectedHour), systemImage: "thermometer.medium")
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
                ToolbarItem(placement: .topBarLeading) {
                    Button(windguruUsername.isEmpty ? "Login" : windguruUsername, systemImage: "person.crop.circle") {
                        showsLogin = true
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Refresh", systemImage: "arrow.clockwise") {
                        Task { await loadForecast() }
                    }
                }
            }
            .task { await loadForecast() }
            .sheet(isPresented: $showsSpotPicker) {
                WindguruSpotPicker(
                    forecastService: forecastService,
                    username: windguruUsername,
                    onSpotSelected: { spot in
                        guard let spotId = spot.identifier else { return }
                        showsSpotPicker = false
                        Task { await loadForecast(spotId: spotId) }
                    },
                    onCoordinateSelected: { coordinate in
                        showsSpotPicker = false
                        Task { await loadForecast(coordinate: coordinate) }
                    }
                )
            }
            .sheet(isPresented: $showsModelPicker) {
                ForecastModelPicker(
                    forecastService: forecastService,
                    spotID: selectedSpotID,
                    selectedModelIDs: Set(selectedModelIDs)
                ) { modelIDs in
                    showsModelPicker = false
                    Task { await loadForecast(modelIDs: modelIDs) }
                }
            }
            .sheet(isPresented: $showsLogin) {
                WindguruLoginView(forecastService: forecastService, username: windguruUsername) { username in
                    windguruUsername = username
                    showsLogin = false
                }
            }
        }
    }

    @MainActor
    private func loadForecast(spotId: String? = nil, modelIDs: [String]? = nil) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let requestedSpotID = spotId ?? selectedSpotID
            let isChangingSpot = requestedSpotID != selectedSpotID
            let requestedModelIDs = modelIDs ?? (isChangingSpot ? [] : selectedModelIDs)
            var validForecasts: [SpotForecast] = []
            for modelID in requestedModelIDs {
                if let loadedForecast = try await forecastService.forecast(bySpotId: requestedSpotID, model: modelID),
                   loadedForecast.forecast != nil {
                    validForecasts.append(loadedForecast)
                }
            }
            if requestedModelIDs.isEmpty {
                forecast = try await forecastService.forecast(bySpotId: requestedSpotID, model: nil)
            } else if validForecasts.count == 1 {
                forecast = validForecasts[0]
            } else if validForecasts.count == requestedModelIDs.count {
                forecast = try SpotForecast.blended(validForecasts)
            } else {
                throw CustomError.notMappeable
            }
            if forecast != nil {
                selectedSpotID = requestedSpotID
                selectedModelIDs = requestedModelIDs.isEmpty
                    ? [forecast?.model ?? Model.defaultModel]
                    : requestedModelIDs
            }
            selectedHour = forecast.flatMap { closestHour(to: Date(), in: $0) }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func loadForecast(coordinate: CLLocationCoordinate2D) async {
        guard let password = WindguruCredentialStore.password(for: windguruUsername), !windguruUsername.isEmpty else {
            errorMessage = "Sign in with Windguru PRO to load an exact map coordinate."
            return
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let coordinateForecast = try await forecastService.wforecast(
                byLatitude: coordinate.latitude,
                longitude: coordinate.longitude,
                model: nil,
                username: windguruUsername,
                password: password
            )
            guard let coordinateForecast else { throw CustomError.notMappeable }
            forecast = try SpotForecast.from(coordinateForecast: coordinateForecast)
            selectedModelIDs = forecast?.model.map { [$0] } ?? []
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

            Image(systemName: "calendar")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            Picker("Forecast date and hour", selection: $selectedHour) {
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
            relativeHumidity(weather?.relativeHumidity(hh: hour))
            Menu {
                Picker("Precipitation unit", selection: $precipitationUnit) {
                    ForEach(PrecipitationUnit.allCases) { unit in
                        Text(unit.label).tag(unit)
                    }
                }
            } label: {
                LabeledContent {
                    HStack(spacing: 6) {
                        precipitationIndicator(weather, hour: hour)
                        Text(precipitation(weather, hour: hour))
                    }
                } label: {
                    Label("Precipitation", systemImage: "cloud.rain")
                }
            }
            Menu {
                Picker("Freezing level unit", selection: $freezingLevelUnit) {
                    ForEach(FreezingLevelUnit.allCases) { unit in
                        Text(unit.label).tag(unit)
                    }
                }
            } label: {
                LabeledContent {
                    Text(freezingLevel(weather?.freezingLevelHeightInMeters(hh: hour)))
                } label: {
                    Label("Freezing level", systemImage: "thermometer.low")
                }
            }
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

    private func relativeHumidity(_ value: Int?) -> some View {
        LabeledContent {
            HStack(spacing: 8) {
                ProgressView(value: Double(min(max(value ?? 0, 0), 100)), total: 100)
                    .tint(.cyan)
                    .frame(width: 120)
                Text(percent(value))
                    .monospacedDigit()
                    .frame(minWidth: 40, alignment: .trailing)
            }
        } label: {
            Label("Relative humidity", systemImage: "humidity")
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

    private func freezingLevel(_ value: Double?) -> String {
        guard let value else { return "—" }
        let converted = FreezingLevel(meters: value).value(in: freezingLevelUnit)
        return "\(converted.formatted(.number.precision(.fractionLength(0)))) \(freezingLevelUnit.label)"
    }

    private func pressure(_ value: Double?) -> String {
        guard let value else { return "—" }
        let converted = AtmosphericPressure(hectopascals: value).value(in: pressureUnit)
        return "\(formatted(converted)) \(pressureUnit.label)"
    }

    private func precipitation(_ forecast: Forecast?, hour: String?) -> String {
        let value = precipitationValue(forecast, hour: hour)
        let converted = Precipitation(millimeters: value).value(in: precipitationUnit)
        let precision = precipitationUnit == .inches ? 2 : 1
        let displayValue = converted.formatted(.number.precision(.fractionLength(precision)))
        return "\(displayValue) \(precipitationUnit.label)"
    }

    @ViewBuilder
    private func precipitationIndicator(_ forecast: Forecast?, hour: String?) -> some View {
        let amount = precipitationValue(forecast, hour: hour)
        let dropCount = amount > 0 ? min(max(Int(ceil(amount / 2)), 1), 4) : 0
        let temperature = forecast?.temperature(hh: hour) ?? forecast?.temperatureReal(hh: hour)

        if amount > 0, let temperature, temperature <= 0 {
            Image(systemName: "snowflake")
                .foregroundStyle(.cyan)
                .accessibilityLabel("Snow")
        } else if dropCount > 0 {
            HStack(spacing: 2) {
                ForEach(0..<dropCount, id: \.self) { _ in
                    Image(systemName: "drop.fill")
                }
            }
            .foregroundStyle(.blue)
            .accessibilityLabel("Precipitation intensity \(dropCount) of 4")
        }
    }

    private func precipitationValue(_ forecast: Forecast?, hour: String?) -> Double {
        forecast?.precipitation(hh: hour)
            ?? forecast?.precipitation1(hh: hour)
            ?? 0
    }

    private func formatted(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(1)))
    }
}

#Preview {
    ForecastDashboardView(forecastService: ForecastWindguruMockup())
}
