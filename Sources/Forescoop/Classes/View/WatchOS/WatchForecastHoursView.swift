//
//  WatchForecastHoursView.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 08/02/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if os(watchOS)
import SwiftUI

/// A compact hour picker for the watch dashboard.
struct WatchForecastHoursView: View {
    let forecast: SpotForecast?
    @Binding var selectedHour: String?
    let temperatureUnit: TemperatureUnit
    let windSpeedUnit: WindSpeedUnit
    let precipitationUnit: PrecipitationUnit
    let onHourSelected: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            if let forecast, let weather = forecast.forecast {
                ForEach(forecast.availableForecastHours, id: \.self) { hour in
                    Button {
                        selectedHour = hour
                        onHourSelected()
                        dismiss()
                    } label: {
                        WatchForecastHourCell(
                            hour: hour,
                            forecast: forecast,
                            weather: weather,
                            temperatureUnit: temperatureUnit,
                            windSpeedUnit: windSpeedUnit,
                            precipitationUnit: precipitationUnit,
                            isSelected: selectedHour == hour
                        )
                    }
                }
            }
        }
        .navigationTitle("Forecast hour")
        .forecastAccessibilityContainer(
            "Forecast hour selector",
            hint: "Select an hour to return to the dashboard.",
            identifier: "watch.forecast.hours"
        )
    }
}
#endif
