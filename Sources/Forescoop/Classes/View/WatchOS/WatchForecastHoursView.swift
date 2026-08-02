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

    var body: some View {
        List {
            if let forecast {
                ForEach(forecast.availableForecastHours, id: \.self) { hour in
                    Button { selectedHour = hour } label: {
                        HStack {
                            Text(title(for: hour, in: forecast))
                            Spacer()
                            if selectedHour == hour { Image(systemName: "checkmark").foregroundStyle(.tint) }
                        }
                    }
                }
            }
        }
        .navigationTitle("Forecast hour")
    }

    private func title(for hour: String, in forecast: SpotForecast) -> String {
        guard let date = forecast.forecastDate(hour: hour) else { return "\(hour) hs" }
        return WatchForecastFormatting.hour(date)
    }
}
#endif
