//
//  WindguruForecastGridView.swift
//  Forescoop package
//
//  Created by Javier on 07/27/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if !os(watchOS)
import SwiftUI

/// A compact, Windguru-inspired table for comparing forecast hours at a glance.
public struct WindguruForecastGridView: View {
    public let forecast: SpotForecast
    public let coordinateLocationName: String?
    public let selectedHour: String?
    public let availableModelIDs: [String]
    public let selectedModelIDs: [String]
    public let modelNamesByID: [String: String]
    public let modelForecasts: [SpotForecast]
    @Binding public var temperatureUnit: TemperatureUnit
    @Binding public var windSpeedUnit: WindSpeedUnit
    @Binding public var waveHeightUnit: WaveHeightUnit
    @Binding public var pressureUnit: PressureUnit
    @Binding public var precipitationUnit: PrecipitationUnit
    @Binding public var freezingLevelUnit: FreezingLevelUnit
    @Binding public var showsWindDirectionArrow: Bool
    private let onSelectLocation: () -> Void
    private let onToggleModel: (String) -> Void
    private let onSelectHour: (String) -> Void

    @State private var areRowTitlesCollapsed = false
    @State private var expandedComparisonRows = Set<String>()
    @State private var isModelComparisonEnabled = false
    @State private var horizontalGridOffset: CGFloat = 0

    public init(
        forecast: SpotForecast,
        coordinateLocationName: String? = nil,
        selectedHour: String? = nil,
        availableModelIDs: [String] = [],
        selectedModelIDs: [String] = [],
        modelNamesByID: [String: String] = [:],
        modelForecasts: [SpotForecast] = [],
        temperatureUnit: Binding<TemperatureUnit>,
        windSpeedUnit: Binding<WindSpeedUnit>,
        waveHeightUnit: Binding<WaveHeightUnit>,
        pressureUnit: Binding<PressureUnit>,
        precipitationUnit: Binding<PrecipitationUnit>,
        freezingLevelUnit: Binding<FreezingLevelUnit>,
        showsWindDirectionArrow: Binding<Bool>,
        onSelectLocation: @escaping () -> Void,
        onToggleModel: @escaping (String) -> Void,
        onSelectHour: @escaping (String) -> Void
    ) {
        self.forecast = forecast
        self.coordinateLocationName = coordinateLocationName
        self.selectedHour = selectedHour
        self.availableModelIDs = availableModelIDs
        self.selectedModelIDs = selectedModelIDs
        self.modelNamesByID = modelNamesByID
        self.modelForecasts = modelForecasts
        _temperatureUnit = temperatureUnit
        _windSpeedUnit = windSpeedUnit
        _waveHeightUnit = waveHeightUnit
        _pressureUnit = pressureUnit
        _precipitationUnit = precipitationUnit
        _freezingLevelUnit = freezingLevelUnit
        _showsWindDirectionArrow = showsWindDirectionArrow
        self.onSelectLocation = onSelectLocation
        self.onToggleModel = onToggleModel
        self.onSelectHour = onSelectHour
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) {
                ScrollView(.vertical) {
                HStack(alignment: .top, spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        Color.clear.frame(width: rowLabelWidth, height: 48)
                        gridRows(in: .labels)
                    }

                    ScrollView(.horizontal) {
                        ScrollViewReader { proxy in
                            VStack(alignment: .leading, spacing: 0) {
                                Color.clear.frame(height: 48)
                                gridRows(in: .values)
                            }
                            .overlay(alignment: .topLeading) {
                                selectedHourOutline
                            }
                            .onAppear {
                                scrollToSelectedHour(with: proxy)
                            }
                            .onChange(of: selectedHour) { _, _ in
                                scrollToSelectedHour(with: proxy)
                            }
                        }
                    }
                    .onScrollGeometryChange(for: CGFloat.self) { geometry in
                        geometry.contentOffset.x
                    } action: { _, offset in
                        horizontalGridOffset = offset
                        withAnimation(.easeInOut(duration: 0.15)) {
                            areRowTitlesCollapsed = offset > 8
                        }
                    }
                }
                .padding(.bottom)
                }

                stickyGridHeader
            }

            modelSelector
        }
        .padding(.horizontal, 2)
        .navigationTitle(forecast.locationDisplayName(coordinateLocationName: coordinateLocationName))
        .onChange(of: modelForecasts.count) { _, count in
            guard count < 2 else { return }
            isModelComparisonEnabled = false
            expandedComparisonRows = []
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button("Choose location", systemImage: "mappin.and.ellipse", action: onSelectLocation)
                if modelForecasts.count > 1 {
                    Button(
                        "Compare models",
                        systemImage: "arrow.left.and.right"
                    ) {
                        isModelComparisonEnabled.toggle()
                        if !isModelComparisonEnabled {
                            expandedComparisonRows = []
                        }
                    }
                    .tint(isModelComparisonEnabled ? .accentColor : .secondary)
                }
            }
        }
    }

    private var hours: [String] { forecast.availableForecastHours }
    private var weather: Forecast? { forecast.forecast }
    private var hasWaveData: Bool {
        hours.contains { weather?.waveHeight(hh: $0) != nil }
    }

    private func weather(for source: SpotForecast?) -> Forecast? {
        source?.forecast ?? weather
    }

    private func modelName(for source: SpotForecast) -> String {
        guard let modelID = source.model else { return source.forecast?.modelName ?? "Forecast model" }
        return modelNamesByID[modelID] ?? source.forecast?.modelName ?? "Model \(modelID)"
    }

    private func toggleComparisonRow(_ id: String) {
        if expandedComparisonRows.contains(id) {
            expandedComparisonRows.remove(id)
        } else {
            expandedComparisonRows.insert(id)
        }
    }

    @ViewBuilder private var modelSelector: some View {
        if !availableModelIDs.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Label("Forecast models", systemImage: "cpu")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)

                VStack(spacing: 0) {
                    ForEach(availableModelIDs, id: \.self) { modelID in
                        let isSelected = selectedModelIDs.contains(modelID)
                        Button {
                            guard isSelected ? selectedModelIDs.count > 1 : true else { return }
                            onToggleModel(modelID)
                        } label: {
                            HStack {
                                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                                Text(modelNamesByID[modelID] ?? "Model \(modelID)")
                                Spacer()
                            }
                            .font(.subheadline)
                            .padding(.vertical, 5)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(isSelected ? .blue : .primary)

                        if modelID != availableModelIDs.last {
                            Divider()
                        }
                    }
                }
                .padding(.horizontal, 10)
                .background(gridLabelBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private var labelHeader: some View {
        Text("Updated")
            .opacity(showsRowTitles ? 1 : 0)
            .overlay {
                if !showsRowTitles {
                    Image(systemName: "clock.arrow.circlepath")
                }
            }
            .frame(width: rowLabelWidth, height: 48, alignment: .leading)
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .background(gridLabelBackground)
    }

    private var stickyGridHeader: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                labelHeader

                ZStack(alignment: .leading) {
                    timeHeader.offset(x: -horizontalGridOffset)
                }
                .frame(width: max(0, geometry.size.width - rowLabelWidth), height: 48, alignment: .leading)
                .clipped()
            }
        }
        .frame(height: 48)
    }

    private var timeHeader: some View {
        HStack(spacing: 0) {
            ForEach(hours, id: \.self) { hour in
                Button {
                    onSelectHour(hour)
                } label: {
                    VStack(spacing: 2) {
                        Text(day(for: hour)).font(.caption2)
                        Text(time(for: hour)).font(.caption.bold())
                    }
                    .frame(width: 56, height: 48)
                    .background(Color.secondary.opacity(0.12))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)
            }
        }
    }

    private enum GridColumn {
        case labels
        case values
    }

    @ViewBuilder private func gridRows(in column: GridColumn) -> some View {
        gridRow(id: "windSpeed", label: unitLabel("Wind speed (\(windSpeedUnit.label))", compactLabel: windSpeedUnit.label, icon: "wind", selection: $windSpeedUnit, unitLabel: \.label), values: { windSpeed($0) }, comparisonValues: { windSpeed($1, source: $0) }, background: windColor, in: column)
        gridRow(id: "windGusts", label: unitLabel("Wind gusts (\(windSpeedUnit.label))", compactLabel: windSpeedUnit.label, icon: "wind.circle.fill", selection: $windSpeedUnit, unitLabel: \.label), values: { windGusts($0) }, comparisonValues: { windGusts($1, source: $0) }, background: gustColor, in: column)
        gridRow(id: "windDirection", label: windDirectionLabel, values: { windDirection($0) }, comparisonValues: { windDirection($1, source: $0) }, in: column)
        gridRow(id: "temperature", label: unitLabel("Temperature (\(temperatureUnit.label))", compactLabel: temperatureUnit.label, icon: "thermometer.medium", selection: $temperatureUnit, unitLabel: \.label), values: { temperature($0) }, comparisonValues: { temperature($1, source: $0) }, background: temperatureColor, in: column)
        gridRow(id: "freezingLevel", label: unitLabel("Freezing level (\(freezingLevelUnit.label))", compactLabel: freezingLevelUnit.label, icon: "snowflake", selection: $freezingLevelUnit, unitLabel: \.label), values: { freezingLevel($0) }, comparisonValues: { freezingLevel($1, source: $0) }, in: column)
        gridRow(id: "cloudCover", label: rowLabel("Cloud cover (%)", icon: "cloud.fill"), values: { cloudCover($0) }, comparisonValues: { cloudCover($1, source: $0) }, background: cloudColor, in: column)
        gridRow(id: "precipitation", label: unitLabel("Precipitation (\(precipitationUnit.label))", compactLabel: precipitationUnit.label, icon: "cloud.rain", selection: $precipitationUnit, unitLabel: \.label), values: { precipitation($0) }, comparisonValues: { precipitation($1, source: $0) }, background: precipitationColor, in: column)
        gridRow(id: "pressure", label: unitLabel("Pressure (\(pressureUnit.label))", compactLabel: pressureUnit.label, icon: "gauge.medium", selection: $pressureUnit, unitLabel: \.label), values: { pressure($0) }, comparisonValues: { pressure($1, source: $0) }, in: column)
        gridRow(id: "humidity", label: rowLabel("Humidity (%)", icon: "humidity"), values: { humidity($0) }, comparisonValues: { humidity($1, source: $0) }, background: humidityColor, in: column)
        if hasWaveData {
            Divider()
            gridRow(id: "waveHeight", label: unitLabel("Wave (\(waveHeightUnit.label))", compactLabel: waveHeightUnit.label, icon: "water.waves", selection: $waveHeightUnit, unitLabel: \.label), values: { waveHeight($0) }, comparisonValues: { waveHeight($1, source: $0) }, background: waveColor, in: column)
            gridRow(id: "wavePeriod", label: rowLabel("Wave period (s)", icon: "waveform"), values: { wavePeriod($0) }, comparisonValues: { wavePeriod($1, source: $0) }, in: column)
            gridRow(id: "waveDirection", label: rowLabel("Wave direction", icon: "location.north.line"), values: { waveDirection($0) }, comparisonValues: { waveDirection($1, source: $0) }, in: column)
        }
    }

    @ViewBuilder private func gridRow<Label: View>(
        id: String,
        label: Label,
        values: @escaping (String) -> GridCell,
        comparisonValues: @escaping (SpotForecast, String) -> GridCell,
        background: @escaping (GridCell) -> Color = { _ in .clear },
        in column: GridColumn
    ) -> some View {
        let isExpanded = expandedComparisonRows.contains(id)
        switch column {
        case .labels:
            VStack(spacing: 0) {
                HStack(spacing: 4) {
                    label
                    Spacer(minLength: 0)
                    if isModelComparisonEnabled, modelForecasts.count > 1 {
                        Button {
                            toggleComparisonRow(id)
                        } label: {
                            Image(systemName: isExpanded ? "rectangle.compress.vertical" : "rectangle.expand.vertical")
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.blue)
                    }
                }
                .font(.caption)
                .frame(width: rowLabelWidth, height: 30, alignment: showsRowTitles ? .leading : .center)
                .padding(.horizontal, 8)
                .background(gridLabelBackground)

                if isExpanded {
                    ForEach(Array(modelForecasts.enumerated()), id: \.offset) { _, source in
                        Text(modelName(for: source))
                            .font(.caption2)
                            .lineLimit(1)
                            .frame(width: rowLabelWidth, height: 24, alignment: showsRowTitles ? .leading : .center)
                            .padding(.horizontal, 8)
                            .background(gridLabelBackground)
                    }
                }
            }
        case .values:
            VStack(spacing: 0) {
                forecastValueRow(values: values, background: background)
                if isExpanded {
                    ForEach(Array(modelForecasts.enumerated()), id: \.offset) { _, source in
                        forecastValueRow(
                            values: { comparisonValues(source, $0) },
                            background: background,
                            height: 24
                        )
                    }
                }
            }
        }
    }

    private func forecastValueRow(
        values: @escaping (String) -> GridCell,
        background: @escaping (GridCell) -> Color,
        height: CGFloat = 30
    ) -> some View {
        HStack(spacing: 0) {
            ForEach(hours, id: \.self) { hour in
                let cell = values(hour)
                Button {
                    onSelectHour(hour)
                } label: {
                    Text(cell.text)
                        .font(cell.isDirection ? .body : .caption)
                        .monospacedDigit()
                        .frame(width: 56, height: height)
                        .background(background(cell))
                        .overlay(alignment: .bottom) { Divider().opacity(0.3) }
                }
                .buttonStyle(.plain)
                .id(hour)
            }
        }
    }

    private func unitLabel<Unit>(
        _ title: String,
        compactLabel: String,
        icon: String,
        selection: Binding<Unit>,
        unitLabel: @escaping (Unit) -> String
    ) -> some View where Unit: CaseIterable & Identifiable & Hashable, Unit.AllCases: RandomAccessCollection, Unit.AllCases.Element == Unit {
        Menu {
            Picker(title, selection: selection) {
                ForEach(Unit.allCases) { unit in
                    Text(unitLabel(unit)).tag(unit)
                }
            }
        } label: {
            rowLabel(title, compactTitle: compactLabel, icon: icon, isInteractive: true)
        }
        .buttonStyle(.plain)
    }

    private var windDirectionLabel: some View {
        Button {
            showsWindDirectionArrow.toggle()
        } label: {
            rowLabel("Wind direction (\(showsWindDirectionArrow ? "→" : "X"))", compactTitle: showsWindDirectionArrow ? "→" : "X", icon: "location.north.line", isInteractive: true)
        }
        .buttonStyle(.plain)
    }

    private func rowLabel(
        _ title: String,
        compactTitle: String? = nil,
        icon: String,
        isInteractive: Bool = false
    ) -> some View {
        Group {
            if showsRowTitles {
                Label(title, systemImage: icon)
            } else {
                HStack(spacing: 3) {
                    Image(systemName: icon)
                    if let compactTitle { Text(compactTitle) }
                }
            }
        }
        .foregroundStyle(isInteractive ? .blue : .primary)
    }

    private var showsRowTitles: Bool { !areRowTitlesCollapsed }
    private var rowLabelWidth: CGFloat { (showsRowTitles ? 134 : 60) + (isModelComparisonEnabled && modelForecasts.count > 1 ? 20 : 0) }
    private var gridLabelBackground: Color { .primary.opacity(0.06) }

    @ViewBuilder private var selectedHourOutline: some View {
        GeometryReader { geometry in
            if let selectedHour,
               let index = hours.firstIndex(of: selectedHour) {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(.blue, lineWidth: 2)
                    .frame(width: 56, height: geometry.size.height)
                    .offset(x: CGFloat(index) * 56)
            }
        }
        .allowsHitTesting(false)
    }

    private func day(for hour: String) -> String {
        guard let date = forecast.forecastDate(hour: hour) else { return "" }
        return date.formatted(.dateTime.weekday(.abbreviated).day())
    }

    private func time(for hour: String) -> String {
        guard let date = forecast.forecastDate(hour: hour) else { return hour }
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("j")
        return formatter.string(from: date) + "h"
    }

    private func windSpeed(_ hour: String, source: SpotForecast? = nil) -> GridCell {
        guard let value = weather(for: source)?.windSpeed(hh: hour), let converted = Knots(value).value(in: windSpeedUnit) else { return .empty }
        return GridCell(value: converted, text: number(converted))
    }

    private func scrollToSelectedHour(with proxy: ScrollViewProxy) {
        guard let selectedHour else { return }
        DispatchQueue.main.async {
            proxy.scrollTo(selectedHour, anchor: .center)
        }
    }

    private func windGusts(_ hour: String, source: SpotForecast? = nil) -> GridCell {
        guard let value = weather(for: source)?.windGustsKnots(hh: hour), let converted = Knots(value).value(in: windSpeedUnit) else { return .empty }
        return GridCell(value: converted, text: number(converted))
    }

    private func windDirection(_ hour: String, source: SpotForecast? = nil) -> GridCell {
        guard let direction = weather(for: source)?.windDirection(hh: hour) else { return .empty }
        return GridCell(value: direction, text: windDirectionText(direction), isDirection: showsWindDirectionArrow)
    }

    private func temperature(_ hour: String, source: SpotForecast? = nil) -> GridCell {
        guard let value = weather(for: source)?.temperatureReal(hh: hour) ?? weather(for: source)?.temperature(hh: hour) else { return .empty }
        let converted = Temperature(celsius: value).value(in: temperatureUnit)
        return GridCell(value: converted, text: number(converted))
    }

    private func freezingLevel(_ hour: String, source: SpotForecast? = nil) -> GridCell {
        guard let value = weather(for: source)?.freezingLevelHeightInMeters(hh: hour) else { return .empty }
        let converted = FreezingLevel(meters: value).value(in: freezingLevelUnit)
        return GridCell(value: converted, text: number(converted, precision: 0))
    }

    private func cloudCover(_ hour: String, source: SpotForecast? = nil) -> GridCell {
        guard let value = weather(for: source)?.cloudCoverTotal(hh: hour) else { return .empty }
        return GridCell(value: Double(value), text: "\(value)")
    }

    private func precipitation(_ hour: String, source: SpotForecast? = nil) -> GridCell {
        let millimeters = weather(for: source)?.precipitation(hh: hour) ?? weather(for: source)?.precipitation1(hh: hour)
        guard let millimeters else { return .empty }
        let converted = Precipitation(millimeters: millimeters).value(in: precipitationUnit)
        return GridCell(value: converted, text: number(converted))
    }

    private func pressure(_ hour: String, source: SpotForecast? = nil) -> GridCell {
        guard let value = weather(for: source)?.seaLevelPressure(hh: hour) else { return .empty }
        let converted = AtmosphericPressure(hectopascals: value).value(in: pressureUnit)
        return GridCell(value: converted, text: number(converted, precision: 0))
    }

    private func humidity(_ hour: String, source: SpotForecast? = nil) -> GridCell {
        guard let value = weather(for: source)?.relativeHumidity(hh: hour) else { return .empty }
        return GridCell(value: Double(value), text: "\(value)")
    }

    private func waveHeight(_ hour: String, source: SpotForecast? = nil) -> GridCell {
        guard let value = weather(for: source)?.waveHeight(hh: hour) else { return .empty }
        let converted = WaveHeight(meters: value).value(in: waveHeightUnit)
        return GridCell(value: converted, text: number(converted))
    }

    private func wavePeriod(_ hour: String, source: SpotForecast? = nil) -> GridCell {
        guard let value = weather(for: source)?.wavePeriod(hh: hour) else { return .empty }
        return GridCell(value: value, text: number(value))
    }

    private func waveDirection(_ hour: String, source: SpotForecast? = nil) -> GridCell {
        guard let value = weather(for: source)?.waveDirection(hh: hour) else { return .empty }
        return GridCell(value: value, text: arrow(value), isDirection: true)
    }

    private func number(_ value: Double, precision: Int = 0) -> String {
        value.formatted(.number.precision(.fractionLength(precision)))
    }

    private func arrow(_ direction: Double) -> String {
        let arrows = ["↑", "↗", "→", "↘", "↓", "↙", "←", "↖"]
        return arrows[Int((direction + 22.5) / 45) % arrows.count]
    }

    private func windDirectionText(_ direction: Double) -> String {
        showsWindDirectionArrow
            ? arrow(direction)
            : WindDirection(value: Int(direction.rounded())).description
    }

    private func windColor(_ cell: GridCell) -> Color { .cyan.opacity(min((cell.value ?? 0) / 45, 1) * 0.55) }
    private func gustColor(_ cell: GridCell) -> Color { .mint.opacity(min((cell.value ?? 0) / 55, 1) * 0.65) }
    private func temperatureColor(_ cell: GridCell) -> Color { .yellow.opacity(min(max((cell.value ?? 0) + 10, 0) / 40, 1) * 0.6) }
    private func cloudColor(_ cell: GridCell) -> Color { .gray.opacity(min((cell.value ?? 0) / 100, 1) * 0.65) }
    private func precipitationColor(_ cell: GridCell) -> Color { .blue.opacity(min((cell.value ?? 0) / 5, 1) * 0.5) }
    private func humidityColor(_ cell: GridCell) -> Color { .yellow.opacity(min((cell.value ?? 0) / 100, 1) * 0.4) }
    private func waveColor(_ cell: GridCell) -> Color { .cyan.opacity(min((cell.value ?? 0) / 4, 1) * 0.5) }

    private struct GridCell {
        let value: Double?
        let text: String
        var isDirection = false

        static let empty = GridCell(value: nil, text: "—")
    }
}

#endif
