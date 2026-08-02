//
//  ForecastGraphView.swift
//  Forescoop package
//

#if !os(watchOS)
import ForescoopGraph
import SwiftUI

/// Maps the app's forecast model into the independently compiled graph target.
public struct ForecastGraphView: View {
    public let forecast: SpotForecast
    @Binding public var selectedHour: String?
    @Binding private var windSpeedUnit: WindSpeedUnit
    private let modelForecasts: [SpotForecast]
    private let modelNamesByID: [String: String]
    @Binding private var isModelComparisonEnabled: Bool

    public init(
        forecast: SpotForecast,
        selectedHour: Binding<String?>,
        windSpeedUnit: Binding<WindSpeedUnit>,
        modelForecasts: [SpotForecast] = [],
        modelNamesByID: [String: String] = [:],
        isModelComparisonEnabled: Binding<Bool> = .constant(false)
    ) {
        self.forecast = forecast
        _selectedHour = selectedHour
        _windSpeedUnit = windSpeedUnit
        self.modelForecasts = modelForecasts
        self.modelNamesByID = modelNamesByID
        _isModelComparisonEnabled = isModelComparisonEnabled
    }

    private var points: [ForecastGraphPoint] {
        points(for: forecast)
    }

    private func points(for source: SpotForecast) -> [ForecastGraphPoint] {
        source.availableForecastHours.compactMap { hour in
            guard let offset = Int(hour) else { return nil }
                let date = source.forecastDate(hour: hour)
                    ?? Calendar.current.date(byAdding: .hour, value: offset, to: Calendar.current.startOfDay(for: .now))
                    ?? .now
                let windKnots = source.forecast?.windSpeed(hh: hour) ?? 0
                let gustKnots = source.forecast?.windGustsKnots(hh: hour) ?? windKnots
                return ForecastGraphPoint(
                    id: hour,
                    date: date,
                    wind: Knots(windKnots).value(in: windSpeedUnit) ?? windKnots,
                    gust: Knots(gustKnots).value(in: windSpeedUnit) ?? gustKnots,
                    direction: source.forecast?.windDirection(hh: hour),
                    cloudCover: Double(source.forecast?.cloudCoverTotal(hh: hour) ?? 0),
                    humidity: Double(source.forecast?.relativeHumidity(hh: hour) ?? 0),
                    pressure: source.forecast?.seaLevelPressure(hh: hour) ?? 0,
                    temperature: source.forecast?.temperatureReal(hh: hour) ?? source.forecast?.temperature(hh: hour) ?? 0,
                    precipitation: source.forecast?.precipitation1(hh: hour) ?? source.forecast?.precipitation(hh: hour) ?? 0
                )
            }
    }

    private var comparisonSeries: [ForecastGraphSeries] {
        guard isModelComparisonEnabled else { return [] }
        return modelForecasts.enumerated().compactMap { index, modelForecast in
            let modelID = modelForecast.model ?? "model-\(index)"
            return ForecastGraphSeries(
                id: modelID,
                name: modelNamesByID[modelID] ?? modelForecast.forecast?.model_name ?? modelID,
                points: points(for: modelForecast)
            )
        }
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(forecast.locationDisplayName())
                    .font(.title2.weight(.semibold))
                if points.isEmpty {
                    ContentUnavailableView("Graph unavailable", systemImage: "chart.xyaxis.line")
                } else {
                    ForecastGraphCanvas(
                        points: points,
                        comparisonSeries: comparisonSeries,
                        selectedID: $selectedHour,
                        windUnitLabel: windSpeedUnit.label
                    )
                }
            }
            .frame(maxWidth: 1_300, alignment: .leading)
            .padding()
        }
        .forecastAccessibilityContainer(
            "Forecast graph for \(forecast.locationDisplayName())",
            hint: "Explore forecast metrics and select a point to change the active forecast hour.",
            identifier: "forecast.graph"
        )
    }
}
#endif
