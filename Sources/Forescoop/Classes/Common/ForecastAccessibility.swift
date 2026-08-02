//
//  ForecastAccessibility.swift
//  Forescoop package
//

import SwiftUI

/// Shared VoiceOver descriptions for the forecast surfaces used on every app.
enum ForecastAccessibility {
    static func summary(for forecast: SpotForecast, hour: String? = nil) -> String {
        let selectedHour = hour ?? forecast.currentForecastHour
        let weather = forecast.forecast
        let temperature = weather?.temperatureReal(hh: selectedHour) ?? weather?.temperature(hh: selectedHour)
        let wind = weather?.windSpeed(hh: selectedHour)
        let rain = weather?.precipitation1(hh: selectedHour) ?? weather?.precipitation(hh: selectedHour)

        var values = [forecast.locationDisplayName()]
        if let temperature { values.append("temperature \(Int(temperature.rounded())) degrees Celsius") }
        if let wind { values.append("wind \(Int(wind.rounded())) knots") }
        if let rain { values.append("rain \(rain.formatted(.number.precision(.fractionLength(0...1)))) millimeters") }
        return values.joined(separator: ", ")
    }
}

extension View {
    /// Keeps child controls individually reachable while giving the screen a
    /// meaningful VoiceOver group name and a stable identifier for UI tests.
    func forecastAccessibilityContainer(_ label: String, hint: String, identifier: String) -> some View {
        accessibilityElement(children: .contain)
            .accessibilityLabel(label)
            .accessibilityHint(hint)
            .accessibilityIdentifier(identifier)
    }
}
