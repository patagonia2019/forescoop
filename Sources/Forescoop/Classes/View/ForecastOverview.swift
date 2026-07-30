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
                HStack(spacing: 8) {
                    Button(action: onSelectLocation) {
                        Label(locationName, systemImage: "mappin.and.ellipse")
                    }
                    .buttonStyle(.plain)

#if !os(tvOS)
                    Button("Show \(locationName) on map", systemImage: "map", action: onShowMap)
                        .labelStyle(.iconOnly)
                        .buttonStyle(.plain)
#endif
                }
                .font(.title.bold())
                .foregroundColor(.blue)

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
        }
    }

    private var temperature: String {
        let hour = selectedHour ?? forecast.currentForecastHour
        guard let value = forecast.forecast?.temperatureReal(hh: hour) ?? forecast.forecast?.temperature(hh: hour) else { return "—" }
        return "\(Temperature(celsius: value).value(in: temperatureUnit).forecastFormatted())\(temperatureUnit.label)"
    }

    private var locationName: String {
        forecast.locationDisplayName(coordinateLocationName: coordinateLocationName)
    }
}

#endif
