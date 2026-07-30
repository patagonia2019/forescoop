//
//  ForecastModelComparisonView.swift
//  ForescoopPackage
//
//  Created by Javier on 30/07/2026.
//

#if !os(watchOS)
import SwiftUI

/// Per-model values for the selected hour, shown alongside the blended dashboard forecast.
public struct ForecastModelComparisonView: View {
    public let forecast: SpotForecast
    public let forecasts: [SpotForecast]
    public let selectedHour: String?
    public let modelNamesByID: [String: String]
    public let temperatureUnit: TemperatureUnit
    public let windSpeedUnit: WindSpeedUnit
    public let freezingLevelUnit: FreezingLevelUnit
    public let precipitationUnit: PrecipitationUnit
    public let pressureUnit: PressureUnit
    @State private var expandedMetricIDs = Set<String>()

    public init(
        forecast: SpotForecast,
        forecasts: [SpotForecast],
        selectedHour: String?,
        modelNamesByID: [String: String],
        temperatureUnit: TemperatureUnit,
        windSpeedUnit: WindSpeedUnit,
        freezingLevelUnit: FreezingLevelUnit,
        precipitationUnit: PrecipitationUnit,
        pressureUnit: PressureUnit
    ) {
        self.forecast = forecast
        self.forecasts = forecasts
        self.selectedHour = selectedHour
        self.modelNamesByID = modelNamesByID
        self.temperatureUnit = temperatureUnit
        self.windSpeedUnit = windSpeedUnit
        self.freezingLevelUnit = freezingLevelUnit
        self.precipitationUnit = precipitationUnit
        self.pressureUnit = pressureUnit
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Model comparison", systemImage: "arrow.left.and.right")
                .font(.headline)

            comparisonRow(id: "windSpeed", title: "Wind speed", icon: "wind", value: wind(weather?.windSpeed(hh: hour))) { wind($0.forecast?.windSpeed(hh: hour)) }
            comparisonRow(id: "windGusts", title: "Wind gusts", icon: "wind.circle.fill", value: wind(weather?.windGustsKnots(hh: hour))) { wind($0.forecast?.windGustsKnots(hh: hour)) }
            comparisonRow(id: "windDirection", title: "Wind direction", icon: "location.north.line", value: weather?.windDirectionName(hh: hour) ?? "—") { $0.forecast?.windDirectionName(hh: hour) ?? "—" }
            comparisonRow(id: "temperature", title: "Temperature", icon: "thermometer.medium", value: temperature(weather?.temperatureReal(hh: hour) ?? weather?.temperature(hh: hour))) { temperature($0.forecast?.temperatureReal(hh: hour) ?? $0.forecast?.temperature(hh: hour)) }
            comparisonRow(id: "cloudCover", title: "Cloud cover", icon: "cloud.fill", value: percent(weather?.cloudCoverTotal(hh: hour))) { percent($0.forecast?.cloudCoverTotal(hh: hour)) }
            comparisonRow(id: "humidity", title: "Humidity", icon: "humidity", value: percent(weather?.relativeHumidity(hh: hour))) { percent($0.forecast?.relativeHumidity(hh: hour)) }
            comparisonRow(id: "precipitation", title: "Precipitation", icon: "cloud.rain", value: precipitation(weather?.precipitation(hh: hour) ?? weather?.precipitation1(hh: hour))) { precipitation($0.forecast?.precipitation(hh: hour) ?? $0.forecast?.precipitation1(hh: hour)) }
            comparisonRow(id: "freezingLevel", title: "Freezing level", icon: "snowflake", value: freezingLevel(weather?.freezingLevelHeightInMeters(hh: hour))) { freezingLevel($0.forecast?.freezingLevelHeightInMeters(hh: hour)) }
            comparisonRow(id: "pressure", title: "Sea level pressure", icon: "gauge.medium", value: pressure(weather?.seaLevelPressure(hh: hour))) { pressure($0.forecast?.seaLevelPressure(hh: hour)) }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var hour: String? { selectedHour ?? forecast.currentForecastHour }
    private var weather: Forecast? { forecast.forecast }

    private func comparisonRow(
        id: String,
        title: String,
        icon: String,
        value: String,
        sourceValue: @escaping (SpotForecast) -> String
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(title, systemImage: icon)
                Spacer()
                Text(value).monospacedDigit()
                Button {
                    toggle(id)
                } label: {
                    Image(systemName: expandedMetricIDs.contains(id) ? "rectangle.compress.vertical" : "rectangle.expand.vertical")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)
            }

            if expandedMetricIDs.contains(id) {
                ForEach(Array(forecasts.enumerated()), id: \.offset) { _, source in
                    HStack {
                        Label(modelName(for: source), systemImage: "cpu")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(sourceValue(source)).monospacedDigit()
                    }
                    .font(.caption)
                    .padding(.leading, 24)
                }
            }
        }
        .padding(.vertical, 6)
        .overlay(alignment: .bottom) { Divider() }
    }

    private func toggle(_ id: String) {
        if expandedMetricIDs.contains(id) {
            expandedMetricIDs.remove(id)
        } else {
            expandedMetricIDs.insert(id)
        }
    }

    private func modelName(for forecast: SpotForecast) -> String {
        guard let modelID = forecast.model else { return forecast.forecast?.modelName ?? "Forecast model" }
        return modelNamesByID[modelID] ?? forecast.forecast?.modelName ?? "Model \(modelID)"
    }

    private func wind(_ knots: Double?) -> String {
        guard let knots, let value = Knots(knots).value(in: windSpeedUnit) else { return "—" }
        return "\(value.forecastFormatted()) \(windSpeedUnit.label)"
    }

    private func temperature(_ celsius: Double?) -> String {
        guard let celsius else { return "—" }
        return "\(Temperature(celsius: celsius).value(in: temperatureUnit).forecastFormatted()) \(temperatureUnit.label)"
    }

    private func freezingLevel(_ meters: Double?) -> String {
        guard let meters else { return "—" }
        return "\(FreezingLevel(meters: meters).value(in: freezingLevelUnit).formatted(.number.precision(.fractionLength(0)))) \(freezingLevelUnit.label)"
    }

    private func precipitation(_ millimeters: Double?) -> String {
        guard let millimeters else { return "—" }
        let value = Precipitation(millimeters: millimeters).value(in: precipitationUnit)
        let precision = precipitationUnit == .inches ? 2 : 1
        return "\(value.formatted(.number.precision(.fractionLength(precision)))) \(precipitationUnit.label)"
    }

    private func pressure(_ hectopascals: Double?) -> String {
        guard let hectopascals else { return "—" }
        let value = AtmosphericPressure(hectopascals: hectopascals).value(in: pressureUnit)
        return "\(value.forecastFormatted()) \(pressureUnit.label)"
    }

    private func percent(_ value: Int?) -> String {
        value.map { "\($0)%" } ?? "—"
    }
}

#endif
