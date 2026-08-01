//
//  SavedMapLocationAnnotation.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 08/01/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if !os(watchOS) && !os(tvOS)
import SwiftUI

/// A compact map marker for a saved location or Windguru favorite, with current forecast data when available.
struct SavedMapLocationAnnotation: View {
    let location: SavedMapLocation
    let forecast: SpotForecast?
    let hour: String?
    var isFavorite = false

    private var weatherSymbols: [String] {
        guard let forecast else { return [] }
        return forecast.weatherSymbolNames(hour: hour ?? forecast.currentForecastHour)
    }

    private var temperature: Double? {
        guard let forecast else { return nil }
        let selectedHour = hour ?? forecast.currentForecastHour
        return forecast.forecast?.temperatureReal(hh: selectedHour)
            ?? forecast.forecast?.temperature(hh: selectedHour)
    }

    var body: some View {
        VStack(spacing: 3) {
            VStack(spacing: 2) {
                Text(location.displayName)
                    .lineLimit(1)
                    .font(.caption.weight(.semibold))

                if !weatherSymbols.isEmpty || temperature != nil {
                    HStack(spacing: 3) {
                        ForEach(weatherSymbols, id: \.self) { symbol in
                            Image(systemName: symbol)
                        }
                        if let temperature {
                            Text("\(temperature.forecastFormatted())°C")
                                .monospacedDigit()
                        }
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(.regularMaterial, in: .rect(cornerRadius: 8))

            Image(systemName: isFavorite ? "star.circle.fill" : "mappin.circle.fill")
                .font(.title3)
                .foregroundStyle(isFavorite ? .yellow : .red)
        }
        .fixedSize()
        .accessibilityElement(children: .combine)
    }
}
#endif
