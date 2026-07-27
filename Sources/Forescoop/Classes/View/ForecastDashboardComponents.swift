//
//  ForecastDashboardComponents.swift
//  Forescoop
//

#if !os(watchOS)
import SwiftUI

public struct ForecastOverview: View {
    public let forecast: SpotForecast
    public let selectedHour: String?
    public let coordinateLocationName: String?
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
        modelInfoURL: URL = URL(string: "https://www.windguru.cz/help.php?sec=models")!,
        onSelectLocation: @escaping () -> Void,
        onSelectModel: @escaping () -> Void,
        onShowMap: @escaping () -> Void = {}
    ) {
        self.forecast = forecast
        self.selectedHour = selectedHour
        self.coordinateLocationName = coordinateLocationName
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
        return "\(format(Temperature(celsius: value).value(in: temperatureUnit)))\(temperatureUnit.label)"
    }

    private var locationName: String {
        forecast.locationDisplayName(coordinateLocationName: coordinateLocationName)
    }
}

public struct ForecastWindDetails: View {
    public let forecast: SpotForecast
    public let selectedHour: String?
    @Binding public var windSpeedUnit: WindSpeedUnit
    @Binding public var showsDirectionArrow: Bool

    public init(
        forecast: SpotForecast,
        selectedHour: String?,
        windSpeedUnit: Binding<WindSpeedUnit>,
        showsDirectionArrow: Binding<Bool>
    ) {
        self.forecast = forecast
        self.selectedHour = selectedHour
        _windSpeedUnit = windSpeedUnit
        _showsDirectionArrow = showsDirectionArrow
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
                Label("Wind gusts", systemImage: "wind")
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
        return "\(format(value)) \(windSpeedUnit.label)"
    }
}

public struct ForecastWeatherDetails: View {
    public let forecast: SpotForecast
    public let selectedHour: String?
    @Binding public var waveHeightUnit: WaveHeightUnit
    @Binding public var precipitationUnit: PrecipitationUnit
    @Binding public var freezingLevelUnit: FreezingLevelUnit
    @Binding public var pressureUnit: PressureUnit

    public init(
        forecast: SpotForecast,
        selectedHour: String?,
        waveHeightUnit: Binding<WaveHeightUnit>,
        precipitationUnit: Binding<PrecipitationUnit>,
        freezingLevelUnit: Binding<FreezingLevelUnit>,
        pressureUnit: Binding<PressureUnit>
    ) {
        self.forecast = forecast
        self.selectedHour = selectedHour
        _waveHeightUnit = waveHeightUnit
        _precipitationUnit = precipitationUnit
        _freezingLevelUnit = freezingLevelUnit
        _pressureUnit = pressureUnit
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            cloudCover(high: weather?.cloudCoverHigh(hh: hour), mid: weather?.cloudCoverMid(hh: hour), low: weather?.cloudCoverLow(hh: hour))
            relativeHumidity(weather?.relativeHumidity(hh: hour))
            waveRows
            precipitationRow
            freezingLevelRow
            pressureRow
        }
        .font(.body)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var hour: String? { selectedHour ?? forecast.currentForecastHour }
    private var weather: Forecast? { forecast.forecast }

    private var precipitationRow: some View {
        Menu {
            Picker("Precipitation unit", selection: $precipitationUnit) {
                ForEach(PrecipitationUnit.allCases) { unit in Text(unit.label).tag(unit) }
            }
        } label: {
            LabeledContent {
                HStack(spacing: 6) {
                    precipitationIndicator
                    Text(precipitation)
                }
            } label: {
                Label("Precipitation", systemImage: "cloud.rain")
            }
        }
    }

    @ViewBuilder private var waveRows: some View {
        if let waveHeight = weather?.waveHeight(hh: hour) {
            Menu {
                Picker("Wave height unit", selection: $waveHeightUnit) {
                    ForEach(WaveHeightUnit.allCases) { unit in Text(unit.label).tag(unit) }
                }
            } label: {
                LabeledContent { Text(waveHeightText(waveHeight)) } label: {
                    Label("Wave", systemImage: "water.waves")
                }
            }
        }

        if let period = weather?.wavePeriod(hh: hour) {
            LabeledContent { Text("\(format(period)) s") } label: {
                Label("Wave period", systemImage: "waveform")
            }
        }

        if let direction = weather?.waveDirection(hh: hour) {
            LabeledContent {
                Image(systemName: "arrow.right")
                    .rotationEffect(.degrees(direction))
                    .accessibilityLabel("\(Int(direction.rounded())) degrees")
            } label: {
                Label("Wave direction", systemImage: "arrow.triangle.turn.up.right.diamond")
            }
        }
    }

    private var freezingLevelRow: some View {
        Menu {
            Picker("Freezing level unit", selection: $freezingLevelUnit) {
                ForEach(FreezingLevelUnit.allCases) { unit in Text(unit.label).tag(unit) }
            }
        } label: {
            LabeledContent { Text(freezingLevel) } label: { Label("Freezing level", systemImage: "ruler") }
        }
    }

    private var pressureRow: some View {
        Menu {
            Picker("Pressure unit", selection: $pressureUnit) {
                ForEach(PressureUnit.allCases) { unit in Text(unit.label).tag(unit) }
            }
        } label: {
            LabeledContent { Text(pressure) } label: { Label("Sea level pressure", systemImage: "gauge.medium") }
        }
    }

    private func cloudCover(high: Int?, mid: Int?, low: Int?) -> some View {
        LabeledContent {
            HStack(alignment: .bottom, spacing: 8) {
                cloudColumn("High", value: high)
                cloudColumn("Mid", value: mid)
                cloudColumn("Low", value: low)
            }
        } label: {
            HStack(alignment: .bottom) {
                Label("Cloud", systemImage: "cloud.fill")
            }
        }
    }

    private func relativeHumidity(_ value: Int?) -> some View {
        LabeledContent {
            HStack(spacing: 8) {
                ProgressView(value: Double(min(max(value ?? 0, 0), 100)), total: 100)
                    .tint(.cyan)
                    .frame(width: 120)
                Text(percent(value)).monospacedDigit().frame(minWidth: 40, alignment: .trailing)
            }
        } label: {
            Label("Relative humidity", systemImage: "humidity")
        }
    }

    private func cloudColumn(_ title: String, value: Int?) -> some View {
        VStack(spacing: 4) {
            Text(title).font(.caption2).foregroundStyle(.secondary)
            Text(percent(value)).monospacedDigit().frame(maxWidth: .infinity).padding(.vertical, 4)
                .background(Color.gray.opacity(0.12 + Double(min(max(value ?? 0, 0), 100)) / 100 * 0.48))
                .clipShape(.rect(cornerRadius: 4))
        }
        .frame(maxWidth: .infinity)
    }

    private var precipitation: String {
        let converted = Precipitation(millimeters: precipitationValue).value(in: precipitationUnit)
        let precision = precipitationUnit == .inches ? 2 : 1
        return "\(converted.formatted(.number.precision(.fractionLength(precision)))) \(precipitationUnit.label)"
    }

    @ViewBuilder private var precipitationIndicator: some View {
        let dropCount = precipitationValue > 0 ? min(max(Int(ceil(precipitationValue / 2)), 1), 4) : 0
        let temperature = weather?.temperature(hh: hour) ?? weather?.temperatureReal(hh: hour)
        if precipitationValue > 0, let temperature, temperature <= 0 {
            Image(systemName: "snowflake").foregroundStyle(.cyan).accessibilityLabel("Snow")
        } else if dropCount > 0 {
            HStack(spacing: 2) {
                ForEach(0..<dropCount, id: \.self) { _ in Image(systemName: "drop.fill") }
            }
            .foregroundStyle(.blue)
            .accessibilityLabel("Precipitation intensity \(dropCount) of 4")
        }
    }

    private var precipitationValue: Double { weather?.precipitation(hh: hour) ?? weather?.precipitation1(hh: hour) ?? 0 }
    private var freezingLevel: String {
        guard let value = weather?.freezingLevelHeightInMeters(hh: hour) else { return "—" }
        return "\(FreezingLevel(meters: value).value(in: freezingLevelUnit).formatted(.number.precision(.fractionLength(0)))) \(freezingLevelUnit.label)"
    }
    private var pressure: String {
        guard let value = weather?.seaLevelPressure(hh: hour) else { return "—" }
        return "\(format(AtmosphericPressure(hectopascals: value).value(in: pressureUnit))) \(pressureUnit.label)"
    }
    private func waveHeightText(_ height: Double) -> String {
        "\(WaveHeight(meters: height).value(in: waveHeightUnit).formatted(.number.precision(.fractionLength(1)))) \(waveHeightUnit.label)"
    }
    private func percent(_ value: Int?) -> String { value.map { "\($0)%" } ?? "—" }
}

private func format(_ value: Double) -> String {
    value.formatted(.number.precision(.fractionLength(1)))
}

#Preview("Weather details") { ForecastComponentPreview { forecast, hour in ForecastWeatherDetails(forecast: forecast, selectedHour: hour, waveHeightUnit: .constant(.meters), precipitationUnit: .constant(.millimeters), freezingLevelUnit: .constant(.meters), pressureUnit: .constant(.hectopascals)) } }

@MainActor
private enum ForecastComponentPreviewData {
    static let forecast: SpotForecast = try! SpotForecast(map: Definition().json(jsonFile: "SpotForecast"))!
}

@MainActor
private struct ForecastComponentPreview<Content: View>: View {
    let content: (SpotForecast, String?) -> Content
    var body: some View { content(ForecastComponentPreviewData.forecast, ForecastComponentPreviewData.forecast.currentForecastHour).padding() }
}
#endif
