//
//  WatchForecastGridView.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 08/02/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if os(watchOS)
import SwiftUI

/// A readable watch adaptation of the forecast grid: one compact row per hour.
struct WatchForecastGridView: View {
    let forecast: SpotForecast?
    @Binding var selectedHour: String?
    let temperatureUnit: TemperatureUnit
    let windSpeedUnit: WindSpeedUnit
    let precipitationUnit: PrecipitationUnit

    var body: some View {
        List {
            if let forecast, let weather = forecast.forecast {
                Section("Forecast grid") {
                    ForEach(forecast.availableForecastHours, id: \.self) { hour in
                        Button { selectedHour = hour } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 5) {
                                    Text(hourTitle(hour, in: forecast))
                                    Spacer(minLength: 0)
                                    ForEach(forecast.weatherSymbolNames(hour: hour), id: \.self) {
                                        Image(systemName: $0).foregroundStyle(.secondary)
                                    }
                                    if selectedHour == hour {
                                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.tint)
                                    }
                                }
                                .font(.caption)

                                HStack(spacing: 7) {
                                    compactValue(temperature(weather.temperatureReal(hh: hour) ?? weather.temperature(hh: hour)), symbol: "thermometer.medium", label: "Temperature")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    compactValue(wind(weather.windSpeed(hh: hour)), symbol: "wind", label: "Wind")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    compactValue(precipitation(weather.precipitation(hh: hour) ?? weather.precipitation1(hh: hour)), symbol: "drop", label: "Rain")
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                                .font(.system(size: 10, design: .monospaced))
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
        return WatchForecastFormatting.hour(date)
    }

    private func wind(_ value: Double?) -> String {
        WatchForecastFormatting.wind(value, unit: windSpeedUnit).replacingOccurrences(of: " ", with: "")
    }

    private func temperature(_ value: Double?) -> String {
        WatchForecastFormatting.temperature(value, unit: temperatureUnit)
    }

    private func precipitation(_ value: Double?) -> String {
        value.map { "\(Precipitation(millimeters: $0).value(in: precipitationUnit).formatted(.number.precision(.fractionLength(precipitationUnit == .inches ? 2 : 1))))\(precipitationUnit.label)" } ?? "—"
    }

    private func compactValue(_ value: String, symbol: String, label: String) -> some View {
        HStack(spacing: 2) {
            Image(systemName: symbol)
            Text(value)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .fixedSize(horizontal: true, vertical: false)
        .accessibilityLabel("\(label): \(value)")
    }
}
#endif
