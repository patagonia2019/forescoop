//
//  WindguruForecastGridView.swift
//  Forescoop package
//
//  Created by Javier on 07/27/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if !os(watchOS)
import SwiftUI

/// A compact, Windguru-inspired table for comparing forecast hours at a glance.
public struct WindguruForecastGridView: View {
    public let forecast: SpotForecast
    public let coordinateLocationName: String?
    public let temperatureUnit: TemperatureUnit
    public let windSpeedUnit: WindSpeedUnit
    public let waveHeightUnit: WaveHeightUnit
    public let pressureUnit: PressureUnit
    public let precipitationUnit: PrecipitationUnit
    public let freezingLevelUnit: FreezingLevelUnit

    @Environment(\.dismiss) private var dismiss

    public init(
        forecast: SpotForecast,
        coordinateLocationName: String? = nil,
        temperatureUnit: TemperatureUnit,
        windSpeedUnit: WindSpeedUnit,
        waveHeightUnit: WaveHeightUnit,
        pressureUnit: PressureUnit,
        precipitationUnit: PrecipitationUnit,
        freezingLevelUnit: FreezingLevelUnit
    ) {
        self.forecast = forecast
        self.coordinateLocationName = coordinateLocationName
        self.temperatureUnit = temperatureUnit
        self.windSpeedUnit = windSpeedUnit
        self.waveHeightUnit = waveHeightUnit
        self.pressureUnit = pressureUnit
        self.precipitationUnit = precipitationUnit
        self.freezingLevelUnit = freezingLevelUnit
    }

    public var body: some View {
        NavigationStack {
            ScrollView([.horizontal, .vertical]) {
                VStack(alignment: .leading, spacing: 0) {
                    header
                    gridRow("Wind speed (\(windSpeedUnit.label))", values: { windSpeed($0) }, background: windColor)
                    gridRow("Wind gusts (\(windSpeedUnit.label))", values: { windGusts($0) }, background: gustColor)
                    gridRow("Wind direction", values: { windDirection($0) })
                    gridRow("Temperature (\(temperatureUnit.label))", values: { temperature($0) }, background: temperatureColor)
                    gridRow("Freezing level (\(freezingLevelUnit.label))", values: { freezingLevel($0) })
                    gridRow("Cloud cover (%)", values: { cloudCover($0) }, background: cloudColor)
                    gridRow("Precipitation (\(precipitationUnit.label))", values: { precipitation($0) }, background: precipitationColor)
                    gridRow("Sea level pressure (\(pressureUnit.label))", values: { pressure($0) })
                    gridRow("Humidity (%)", values: { humidity($0) }, background: humidityColor)
                    if hasWaveData {
                        Divider()
                        gridRow("Wave (\(waveHeightUnit.label))", values: { waveHeight($0) }, background: waveColor)
                        gridRow("Wave period (s)", values: { wavePeriod($0) })
                        gridRow("Wave direction", values: { waveDirection($0) })
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle(forecast.locationDisplayName(coordinateLocationName: coordinateLocationName))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var hours: [String] { forecast.availableForecastHours }
    private var weather: Forecast? { forecast.forecast }
    private var hasWaveData: Bool {
        hours.contains { weather?.waveHeight(hh: $0) != nil }
    }

    private var header: some View {
        HStack(spacing: 0) {
            Text("Updated")
                .frame(width: 150, height: 48, alignment: .leading)
                .font(.caption.bold())
                .padding(.horizontal, 8)
                .background(.thinMaterial)
            ForEach(hours, id: \.self) { hour in
                VStack(spacing: 2) {
                    Text(day(for: hour)).font(.caption2)
                    Text(time(for: hour)).font(.caption.bold())
                }
                .frame(width: 56, height: 48)
                .background(Color.secondary.opacity(0.12))
            }
        }
    }

    private func gridRow(
        _ title: String,
        values: @escaping (String) -> GridCell,
        background: @escaping (GridCell) -> Color = { _ in .clear }
    ) -> some View {
        HStack(spacing: 0) {
            Text(title)
                .font(.caption)
                .frame(width: 150, height: 30, alignment: .leading)
                .padding(.horizontal, 8)
                .background(.thinMaterial)
            ForEach(hours, id: \.self) { hour in
                let cell = values(hour)
                Text(cell.text)
                    .font(cell.isDirection ? .body : .caption)
                    .monospacedDigit()
                    .frame(width: 56, height: 30)
                    .background(background(cell))
                    .overlay(alignment: .bottom) { Divider().opacity(0.3) }
            }
        }
    }

    private func day(for hour: String) -> String {
        guard let date = forecast.forecastDate(hour: hour) else { return "" }
        return date.formatted(.dateTime.weekday(.abbreviated).day())
    }

    private func time(for hour: String) -> String {
        guard let date = forecast.forecastDate(hour: hour) else { return hour }
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("j")
        return formatter.string(from: date)
    }

    private func windSpeed(_ hour: String) -> GridCell {
        guard let value = weather?.windSpeed(hh: hour), let converted = Knots(value).value(in: windSpeedUnit) else { return .empty }
        return GridCell(value: converted, text: number(converted))
    }

    private func windGusts(_ hour: String) -> GridCell {
        guard let value = weather?.windGustsKnots(hh: hour), let converted = Knots(value).value(in: windSpeedUnit) else { return .empty }
        return GridCell(value: converted, text: number(converted))
    }

    private func windDirection(_ hour: String) -> GridCell {
        guard let direction = weather?.windDirection(hh: hour) else { return .empty }
        return GridCell(value: direction, text: arrow(direction), isDirection: true)
    }

    private func temperature(_ hour: String) -> GridCell {
        guard let value = weather?.temperatureReal(hh: hour) ?? weather?.temperature(hh: hour) else { return .empty }
        let converted = Temperature(celsius: value).value(in: temperatureUnit)
        return GridCell(value: converted, text: number(converted))
    }

    private func freezingLevel(_ hour: String) -> GridCell {
        guard let value = weather?.freezingLevelHeightInMeters(hh: hour) else { return .empty }
        let converted = FreezingLevel(meters: value).value(in: freezingLevelUnit)
        return GridCell(value: converted, text: number(converted, precision: 0))
    }

    private func cloudCover(_ hour: String) -> GridCell {
        guard let value = weather?.cloudCoverTotal(hh: hour) else { return .empty }
        return GridCell(value: Double(value), text: "\(value)")
    }

    private func precipitation(_ hour: String) -> GridCell {
        let millimeters = weather?.precipitation(hh: hour) ?? weather?.precipitation1(hh: hour)
        guard let millimeters else { return .empty }
        let converted = Precipitation(millimeters: millimeters).value(in: precipitationUnit)
        return GridCell(value: converted, text: number(converted))
    }

    private func pressure(_ hour: String) -> GridCell {
        guard let value = weather?.seaLevelPressure(hh: hour) else { return .empty }
        let converted = AtmosphericPressure(hectopascals: value).value(in: pressureUnit)
        return GridCell(value: converted, text: number(converted, precision: 0))
    }

    private func humidity(_ hour: String) -> GridCell {
        guard let value = weather?.relativeHumidity(hh: hour) else { return .empty }
        return GridCell(value: Double(value), text: "\(value)")
    }

    private func waveHeight(_ hour: String) -> GridCell {
        guard let value = weather?.waveHeight(hh: hour) else { return .empty }
        let converted = WaveHeight(meters: value).value(in: waveHeightUnit)
        return GridCell(value: converted, text: number(converted))
    }

    private func wavePeriod(_ hour: String) -> GridCell {
        guard let value = weather?.wavePeriod(hh: hour) else { return .empty }
        return GridCell(value: value, text: number(value))
    }

    private func waveDirection(_ hour: String) -> GridCell {
        guard let value = weather?.waveDirection(hh: hour) else { return .empty }
        return GridCell(value: value, text: arrow(value), isDirection: true)
    }

    private func number(_ value: Double, precision: Int = 0) -> String {
        value.formatted(.number.precision(.fractionLength(precision)))
    }

    private func arrow(_ direction: Double) -> String {
        let arrows = ["↑", "↗", "→", "↘", "↓", "↙", "←", "↖"]
        return arrows[Int((direction + 22.5) / 45) % arrows.count]
    }

    private func windColor(_ cell: GridCell) -> Color { .cyan.opacity(min((cell.value ?? 0) / 45, 1) * 0.55) }
    private func gustColor(_ cell: GridCell) -> Color { .mint.opacity(min((cell.value ?? 0) / 55, 1) * 0.65) }
    private func temperatureColor(_ cell: GridCell) -> Color { .yellow.opacity(min(max((cell.value ?? 0) + 10, 0) / 40, 1) * 0.6) }
    private func cloudColor(_ cell: GridCell) -> Color { .gray.opacity(min((cell.value ?? 0) / 100, 1) * 0.65) }
    private func precipitationColor(_ cell: GridCell) -> Color { .blue.opacity(min((cell.value ?? 0) / 5, 1) * 0.5) }
    private func humidityColor(_ cell: GridCell) -> Color { .yellow.opacity(min((cell.value ?? 0) / 100, 1) * 0.4) }
    private func waveColor(_ cell: GridCell) -> Color { .cyan.opacity(min((cell.value ?? 0) / 4, 1) * 0.5) }

    private struct GridCell {
        let value: Double?
        let text: String
        var isDirection = false

        static let empty = GridCell(value: nil, text: "—")
    }
}

#endif
