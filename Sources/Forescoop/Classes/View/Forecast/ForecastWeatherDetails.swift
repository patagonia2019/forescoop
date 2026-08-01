//
//  ForecastWeatherDetails.swift
//  ForescoopPackage
//
//  Created by Javier on 30/07/2026.
//

#if !os(watchOS)
import SwiftUI

public struct ForecastWeatherDetails: View {
    public let forecast: SpotForecast
    public let selectedHour: String?
    @Binding public var waveHeightUnit: WaveHeightUnit
    @Binding public var precipitationUnit: PrecipitationUnit
    @Binding public var freezingLevelUnit: FreezingLevelUnit
    @Binding public var pressureUnit: PressureUnit
    public let modelForecasts: [SpotForecast]
    public let modelNamesByID: [String: String]
    public let isModelComparisonEnabled: Bool

    public init(
        forecast: SpotForecast,
        selectedHour: String?,
        waveHeightUnit: Binding<WaveHeightUnit>,
        precipitationUnit: Binding<PrecipitationUnit>,
        freezingLevelUnit: Binding<FreezingLevelUnit>,
        pressureUnit: Binding<PressureUnit>,
        modelForecasts: [SpotForecast] = [],
        modelNamesByID: [String: String] = [:],
        isModelComparisonEnabled: Bool = false
    ) {
        self.forecast = forecast
        self.selectedHour = selectedHour
        _waveHeightUnit = waveHeightUnit
        _precipitationUnit = precipitationUnit
        _freezingLevelUnit = freezingLevelUnit
        _pressureUnit = pressureUnit
        self.modelForecasts = modelForecasts
        self.modelNamesByID = modelNamesByID
        self.isModelComparisonEnabled = isModelComparisonEnabled
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            cloudCover(high: weather?.cloudCoverHigh(hh: hour), mid: weather?.cloudCoverMid(hh: hour), low: weather?.cloudCoverLow(hh: hour))
            sourceRows { percent($0.forecast?.cloudCoverTotal(hh: hour)) }
            relativeHumidity(weather?.relativeHumidity(hh: hour))
            sourceRows { percent($0.forecast?.relativeHumidity(hh: hour)) }
            waveRows
            precipitationRow
            sourceRows { precipitation(for: $0.forecast) }
            freezingLevelRow
            sourceRows { freezingLevel(for: $0.forecast) }
            pressureRow
            sourceRows { pressure(for: $0.forecast) }
        }
        .font(.body)
        .labelStyle(ForecastDetailLabelStyle())
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
            LabeledContent { Text("\(period.forecastFormatted()) s") } label: {
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
        HStack(alignment: .bottom, spacing: 16) {
            Label("Cloud", systemImage: "cloud.fill")
            Spacer(minLength: 16)
            HStack(alignment: .bottom, spacing: 8) {
                cloudColumn("High", value: high)
                cloudColumn("Mid", value: mid)
                cloudColumn("Low", value: low)
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
        precipitation(for: weather)
    }

    private func precipitation(for source: Forecast?) -> String {
        let millimeters = source?.precipitation(hh: hour) ?? source?.precipitation1(hh: hour) ?? 0
        let converted = Precipitation(millimeters: millimeters).value(in: precipitationUnit)
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
        freezingLevel(for: weather)
    }
    private func freezingLevel(for source: Forecast?) -> String {
        guard let value = source?.freezingLevelHeightInMeters(hh: hour) else { return "—" }
        return "\(FreezingLevel(meters: value).value(in: freezingLevelUnit).formatted(.number.precision(.fractionLength(0)))) \(freezingLevelUnit.label)"
    }
    private var pressure: String {
        pressure(for: weather)
    }
    private func pressure(for source: Forecast?) -> String {
        guard let value = source?.seaLevelPressure(hh: hour) else { return "—" }
        return "\(AtmosphericPressure(hectopascals: value).value(in: pressureUnit).forecastFormatted()) \(pressureUnit.label)"
    }
    private func waveHeightText(_ height: Double) -> String {
        "\(WaveHeight(meters: height).value(in: waveHeightUnit).formatted(.number.precision(.fractionLength(1)))) \(waveHeightUnit.label)"
    }
    private func percent(_ value: Int?) -> String { value.map { "\($0)%" } ?? "—" }

    private func sourceRows(value: @escaping (SpotForecast) -> String) -> some View {
        ForecastModelSourceRows(
            forecasts: modelForecasts,
            modelNamesByID: modelNamesByID,
            isEnabled: isModelComparisonEnabled,
            sourceValue: value
        )
    }
}
@MainActor
private enum ForecastComponentPreviewData {
    static let forecast: SpotForecast = try! SpotForecast(map: Definition().json(jsonFile: "SpotForecast"))!
}

@MainActor
private struct ForecastComponentPreview<Content: View>: View {
    let content: (SpotForecast, String?) -> Content
    var body: some View { content(ForecastComponentPreviewData.forecast, "29").padding() }
}

#Preview("Weather details") { ForecastComponentPreview { forecast, hour in ForecastWeatherDetails(forecast: forecast, selectedHour: hour, waveHeightUnit: .constant(.meters), precipitationUnit: .constant(.millimeters), freezingLevelUnit: .constant(.meters), pressureUnit: .constant(.hectopascals)) } }

#endif
