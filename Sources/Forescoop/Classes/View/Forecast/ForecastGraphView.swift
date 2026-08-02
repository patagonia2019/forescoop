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

    public init(forecast: SpotForecast, selectedHour: Binding<String?>, windSpeedUnit: Binding<WindSpeedUnit>) {
        self.forecast = forecast
        _selectedHour = selectedHour
        _windSpeedUnit = windSpeedUnit
    }

    private var points: [ForecastGraphPoint] {
        forecast.availableForecastHours.compactMap { hour in
                guard let offset = Int(hour) else { return nil }
                let date = forecast.forecastDate(hour: hour)
                    ?? Calendar.current.date(byAdding: .hour, value: offset, to: Calendar.current.startOfDay(for: .now))
                    ?? .now
                let windKnots = forecast.forecast?.windSpeed(hh: hour) ?? 0
                let gustKnots = forecast.forecast?.windGustsKnots(hh: hour) ?? windKnots
                return ForecastGraphPoint(
                    id: hour,
                    date: date,
                    wind: Knots(windKnots).value(in: windSpeedUnit) ?? windKnots,
                    gust: Knots(gustKnots).value(in: windSpeedUnit) ?? gustKnots,
                    direction: forecast.forecast?.windDirection(hh: hour),
                    cloudCover: Double(forecast.forecast?.cloudCoverTotal(hh: hour) ?? 0),
                    humidity: Double(forecast.forecast?.relativeHumidity(hh: hour) ?? 0),
                    pressure: forecast.forecast?.seaLevelPressure(hh: hour) ?? 0,
                    temperature: forecast.forecast?.temperatureReal(hh: hour) ?? forecast.forecast?.temperature(hh: hour) ?? 0,
                    precipitation: forecast.forecast?.precipitation1(hh: hour) ?? forecast.forecast?.precipitation(hh: hour) ?? 0
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
                    ForecastGraphCanvas(points: points, selectedID: $selectedHour, windUnitLabel: windSpeedUnit.label)
                }
            }
            .frame(maxWidth: 1_300, alignment: .leading)
            .padding()
        }
    }
}
#endif
