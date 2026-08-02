//
//  ForecastWindDetails.swift
//  ForescoopPackage
//
//  Created by Javier on 30/07/2026.
//

#if !os(watchOS)
import SwiftUI

public struct ForecastWindDetails: View {
    @Environment(\.ventusTheme) private var theme
    public let forecast: SpotForecast
    public let selectedHour: String?
    @Binding public var windSpeedUnit: WindSpeedUnit
    public let modelForecasts: [SpotForecast]
    public let modelNamesByID: [String: String]
    public let isModelComparisonEnabled: Bool

    public init(
        forecast: SpotForecast,
        selectedHour: String?,
        windSpeedUnit: Binding<WindSpeedUnit>,
        modelForecasts: [SpotForecast] = [],
        modelNamesByID: [String: String] = [:],
        isModelComparisonEnabled: Bool = false
    ) {
        self.forecast = forecast
        self.selectedHour = selectedHour
        _windSpeedUnit = windSpeedUnit
        self.modelForecasts = modelForecasts
        self.modelNamesByID = modelNamesByID
        self.isModelComparisonEnabled = isModelComparisonEnabled
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForecastUnitSelector(
                "Wind speed unit",
                selection: $windSpeedUnit,
                unitTitle: \.label
            ) {
                LabeledContent { Text(windSpeed(weather?.windSpeed(hh: hour))) } label: {
                    Label("Wind speed", systemImage: "wind")
                        .foregroundStyle(theme.accentColor)
                }
            }
            .accessibilityLabel("Wind speed")
            ForecastModelSourceRows(forecasts: modelForecasts, modelNamesByID: modelNamesByID, isEnabled: isModelComparisonEnabled) {
                windSpeed($0.forecast?.windSpeed(hh: hour))
            }

            ForecastUnitSelector(
                "Wind speed unit",
                selection: $windSpeedUnit,
                unitTitle: \.label
            ) {
                LabeledContent { Text(windSpeed(weather?.windGustsKnots(hh: hour))) } label: {
                    Label("Wind gusts", systemImage: "wind.circle.fill")
                        .foregroundStyle(theme.accentColor)
                }
            }
            .accessibilityLabel("Wind gusts")
            ForecastModelSourceRows(forecasts: modelForecasts, modelNamesByID: modelNamesByID, isEnabled: isModelComparisonEnabled) {
                windSpeed($0.forecast?.windGustsKnots(hh: hour))
            }

            LabeledContent {
                if let direction = weather?.windDirection(hh: hour) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.down")
                            .rotationEffect(.degrees(direction))
                        Text(weather?.windDirectionName(hh: hour) ?? "—")
                    }
                } else {
                    Text("—")
                }
            } label: {
                Label("Wind direction", systemImage: "location.north.line")
            }
            ForecastModelSourceRows(forecasts: modelForecasts, modelNamesByID: modelNamesByID, isEnabled: isModelComparisonEnabled) {
                $0.forecast?.windDirectionName(hh: hour) ?? "—"
            }
        }
        .font(.body)
        .labelStyle(ForecastDetailLabelStyle())
    }

    private var hour: String? { selectedHour ?? forecast.currentForecastHour }
    private var weather: Forecast? { forecast.forecast }

    private func windSpeed(_ knots: Double?) -> String {
        guard let knots, let value = Knots(knots).value(in: windSpeedUnit) else { return "—" }
        return "\(value.forecastFormatted()) \(windSpeedUnit.label)"
    }
}

#Preview("Wind details") {
    let forecast = try! SpotForecast(map: Definition().json(jsonFile: "SpotForecast"))!
    ForecastWindDetails(
        forecast: forecast,
        selectedHour: "29",
        windSpeedUnit: .constant(.knots)
    )
    .padding()
}

#endif
