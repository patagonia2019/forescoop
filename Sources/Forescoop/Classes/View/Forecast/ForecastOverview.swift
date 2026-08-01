//
//  ForecastOverview.swift
//  ForescoopPackage
//
//  Created by Javier on 30/07/2026.
//  

#if !os(watchOS)
import SwiftUI

public struct ForecastOverview: View {
    public let forecast: SpotForecast
    public let selectedHour: String?
    public let coordinateLocationName: String?
    public let modelForecasts: [SpotForecast]
    public let modelNamesByID: [String: String]
    public let isModelComparisonEnabled: Bool
    @Binding public var temperatureUnit: TemperatureUnit
    @State private var showsTemperatureSources = false
    private let onSelectLocation: () -> Void
    private let onSelectModel: () -> Void
    private let onShowMap: () -> Void
    private let modelInfoURL: URL

    public init(
        forecast: SpotForecast,
        selectedHour: String?,
        temperatureUnit: Binding<TemperatureUnit>,
        coordinateLocationName: String? = nil,
        modelForecasts: [SpotForecast] = [],
        modelNamesByID: [String: String] = [:],
        isModelComparisonEnabled: Bool = false,
        modelInfoURL: URL = URL(string: "https://www.windguru.cz/help.php?sec=models")!,
        onSelectLocation: @escaping () -> Void,
        onSelectModel: @escaping () -> Void,
        onShowMap: @escaping () -> Void = {}
    ) {
        self.forecast = forecast
        self.selectedHour = selectedHour
        self.coordinateLocationName = coordinateLocationName
        self.modelForecasts = modelForecasts
        self.modelNamesByID = modelNamesByID
        self.isModelComparisonEnabled = isModelComparisonEnabled
        _temperatureUnit = temperatureUnit
        self.modelInfoURL = modelInfoURL
        self.onSelectLocation = onSelectLocation
        self.onSelectModel = onSelectModel
        self.onShowMap = onShowMap
    }

    public var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                ForecastLocationHeader(
                    locationName: locationName,
                    onSelectLocation: onSelectLocation,
                    onShowMap: onShowMap
                )

                if forecast.isCoordinateLocation {
                    Text(forecast.coordinateSummary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 6) {
                    Button(action: onSelectModel) {
                        Label(forecast.forecast?.modelName ?? "Forecast model", systemImage: "cpu")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)

                    Link(destination: modelInfoURL) {
                        Image(systemName: "info.circle")
                    }
                    .accessibilityLabel("About Windguru forecast models")
                    .accessibilityHint("Opens Windguru's model explanation")
                }

                Text(forecast.forecast?.cadenceDescription ?? "Forecast cadence unavailable")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                ForEach(forecast.weatherSymbolNames(hour: selectedHour), id: \.self) { symbol in
                    Image(systemName: symbol)
                }
            }
            .font(.system(size: 42))
            .symbolRenderingMode(.hierarchical)

            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    Menu {
                        Picker("Temperature unit", selection: $temperatureUnit) {
                            ForEach(TemperatureUnit.allCases) { unit in
                                Text(unit.label).tag(unit)
                            }
                        }
                    } label: {
                        Label(temperature, systemImage: "thermometer.medium")
                            .font(.system(size: 44, weight: .semibold))
                    }
                    .accessibilityLabel("Temperature")

                    if supportsModelComparison {
                        Button("Compare temperature", systemImage: showsTemperatureSources ? "rectangle.compress.vertical" : "rectangle.expand.vertical") {
                            showsTemperatureSources.toggle()
                        }
                        .labelStyle(.iconOnly)
                        .foregroundStyle(.blue)
                    }
                }

                if showsTemperatureSources {
                    ForEach(Array(modelForecasts.enumerated()), id: \.offset) { _, source in
                        HStack {
                            Label(modelName(for: source), systemImage: "cpu")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(temperature(for: source)).monospacedDigit()
                        }
                        .font(.caption)
                    }
                }
            }
        }
    }

    private var temperature: String {
        temperature(for: forecast)
    }

    private func temperature(for source: SpotForecast) -> String {
        let hour = selectedHour ?? source.currentForecastHour
        guard let value = source.forecast?.temperatureReal(hh: hour) ?? source.forecast?.temperature(hh: hour) else { return "—" }
        return "\(Temperature(celsius: value).value(in: temperatureUnit).forecastFormatted())\(temperatureUnit.label)"
    }

    private var supportsModelComparison: Bool { isModelComparisonEnabled && modelForecasts.count > 1 }

    private func modelName(for source: SpotForecast) -> String {
        guard let identifier = source.model else { return source.forecast?.modelName ?? "Forecast model" }
        return modelNamesByID[identifier] ?? source.forecast?.modelName ?? "Model \(identifier)"
    }

    private var locationName: String {
        forecast.locationDisplayName(coordinateLocationName: coordinateLocationName)
    }
}

#Preview("Forecast overview") {
    let forecast = try! SpotForecast(map: Definition().json(jsonFile: "SpotForecast"))!
    ForecastOverview(
        forecast: forecast,
        selectedHour: "29",
        temperatureUnit: .constant(.celsius),
        onSelectLocation: {},
        onSelectModel: {},
        onShowMap: {}
    )
    .padding()
}

#endif
