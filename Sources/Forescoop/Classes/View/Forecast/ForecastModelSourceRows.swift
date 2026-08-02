//
//  ForecastModelSourceRows.swift
//  Forescoop package
//
//  Created by Javier on 07/30/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if !os(watchOS)
import SwiftUI

/// An inline disclosure that shows the selected models' source values for one forecast metric.
public struct ForecastModelSourceRows: View {
    @Environment(\.ventusTheme) private var theme
    public let forecasts: [SpotForecast]
    public let modelNamesByID: [String: String]
    public let isEnabled: Bool
    private let sourceValue: (SpotForecast) -> String
    @State private var isExpanded = false

    public init(
        forecasts: [SpotForecast],
        modelNamesByID: [String: String],
        isEnabled: Bool,
        sourceValue: @escaping (SpotForecast) -> String
    ) {
        self.forecasts = forecasts
        self.modelNamesByID = modelNamesByID
        self.isEnabled = isEnabled
        self.sourceValue = sourceValue
    }

    public var body: some View {
        if isEnabled && forecasts.count > 1 {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Spacer()
                    Button("Compare models", systemImage: isExpanded ? "rectangle.compress.vertical" : "rectangle.expand.vertical") {
                        isExpanded.toggle()
                    }
                    .labelStyle(.iconOnly)
                    .foregroundStyle(theme.accentColor)
                }

                if isExpanded {
                    ForEach(Array(forecasts.enumerated()), id: \.offset) { _, forecast in
                        HStack {
                            Label(modelName(for: forecast), systemImage: "cpu")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(sourceValue(forecast)).monospacedDigit()
                        }
                        .font(.caption)
                    }
                }
            }
        }
    }

    private func modelName(for forecast: SpotForecast) -> String {
        guard let identifier = forecast.model else { return forecast.forecast?.modelName ?? "Forecast model" }
        return modelNamesByID[identifier] ?? forecast.forecast?.modelName ?? "Model \(identifier)"
    }
}

#Preview("Model source rows") {
    let forecast = try! SpotForecast(map: Definition().json(jsonFile: "SpotForecast"))!
    let modelID = forecast.model ?? Model.defaultModel
    ForecastModelSourceRows(
        forecasts: [forecast, forecast],
        modelNamesByID: [modelID: forecast.forecast?.modelName ?? "Forecast model"],
        isEnabled: true
    ) { source in
        let hour = source.currentForecastHour
        guard let value = source.forecast?.windSpeed(hh: hour) else { return "—" }
        return "\(value.forecastFormatted()) kn"
    }
    .padding()
}
#endif
