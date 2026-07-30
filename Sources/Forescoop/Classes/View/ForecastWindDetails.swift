//
//  ForecastWindDetails.swift
//  ForescoopPackage
//
//  Created by Javier on 30/07/2026.
//

#if !os(watchOS)
import SwiftUI

public struct ForecastWindDetails: View {
    public let forecast: SpotForecast
    public let selectedHour: String?
    @Binding public var windSpeedUnit: WindSpeedUnit
    @Binding public var showsDirectionArrow: Bool
    public let modelForecasts: [SpotForecast]
    public let modelNamesByID: [String: String]
    public let isModelComparisonEnabled: Bool

    public init(
        forecast: SpotForecast,
        selectedHour: String?,
        windSpeedUnit: Binding<WindSpeedUnit>,
        showsDirectionArrow: Binding<Bool>,
        modelForecasts: [SpotForecast] = [],
        modelNamesByID: [String: String] = [:],
        isModelComparisonEnabled: Bool = false
    ) {
        self.forecast = forecast
        self.selectedHour = selectedHour
        _windSpeedUnit = windSpeedUnit
        _showsDirectionArrow = showsDirectionArrow
        self.modelForecasts = modelForecasts
        self.modelNamesByID = modelNamesByID
        self.isModelComparisonEnabled = isModelComparisonEnabled
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Menu {
                Picker("Wind speed unit", selection: $windSpeedUnit) {
                    ForEach(WindSpeedUnit.allCases) { unit in
                        Text(unit.label).tag(unit)
                    }
                }
            } label: {
                LabeledContent { Text(windSpeed(weather?.windSpeed(hh: hour))) } label: {
                    Label("Wind speed", systemImage: "wind")
                }
            }
            .accessibilityLabel("Wind speed")

            LabeledContent { Text(windSpeed(weather?.windGustsKnots(hh: hour))) } label: {
                Label("Wind gusts", systemImage: "wind.circle.fill")
            }

            LabeledContent {
                Button {
                    showsDirectionArrow.toggle()
                } label: {
                    if showsDirectionArrow, let direction = weather?.windDirection(hh: hour) {
                        Image(systemName: "arrow.down")
                            .rotationEffect(.degrees(direction))
                    } else {
                        Text(weather?.windDirectionName(hh: hour) ?? "—")
                    }
                }
                .foregroundColor(.blue)
                .buttonStyle(.plain)
                .accessibilityLabel("Wind direction")
                .accessibilityHint("Shows the direction as an arrow")
            } label: {
                Label("Wind direction", systemImage: "location.north.line")
            }
        }
        .font(.body)
    }

    private var hour: String? { selectedHour ?? forecast.currentForecastHour }
    private var weather: Forecast? { forecast.forecast }

    private func windSpeed(_ knots: Double?) -> String {
        guard let knots, let value = Knots(knots).value(in: windSpeedUnit) else { return "—" }
        return "\(value.forecastFormatted()) \(windSpeedUnit.label)"
    }
}

#endif
