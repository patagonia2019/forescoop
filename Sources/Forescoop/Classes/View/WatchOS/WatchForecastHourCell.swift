//
//  WatchForecastHourCell.swift
//  Forescoop package
//

#if os(watchOS)
import SwiftUI

/// Shared compact forecast row for the watch hour selector.
struct WatchForecastHourCell: View {
    let hour: String
    let forecast: SpotForecast
    let weather: Forecast
    let temperatureUnit: TemperatureUnit
    let windSpeedUnit: WindSpeedUnit
    let precipitationUnit: PrecipitationUnit
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 5) {
                Text(hourTitle)
                Spacer(minLength: 0)
                ForEach(forecast.weatherSymbolNames(hour: hour), id: \.self) {
                    Image(systemName: $0).foregroundStyle(.secondary)
                }
                if isSelected {
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

    private var hourTitle: String {
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
