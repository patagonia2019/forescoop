//
//  ForecastUnitSelector.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 08/02/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

import SwiftUI

/// Selects a forecast unit without making two-choice controls unnecessarily modal.
///
/// Celsius/Fahrenheit and other binary unit sets toggle immediately. Sets with
/// three or more choices retain a menu so every value remains discoverable.
struct ForecastUnitSelector<Unit, Label: View>: View where Unit: CaseIterable & Identifiable & Hashable, Unit.AllCases: RandomAccessCollection, Unit.AllCases.Element == Unit {
    private let title: String
    @Binding private var selection: Unit
    private let units: [Unit]
    private let unitTitle: (Unit) -> String
    private let label: () -> Label

    init(
        _ title: String,
        selection: Binding<Unit>,
        unitTitle: @escaping (Unit) -> String,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.title = title
        _selection = selection
        units = Array(Unit.allCases)
        self.unitTitle = unitTitle
        self.label = label
    }

    @ViewBuilder var body: some View {
        if units.count == 2,
           let alternateUnit = units.first(where: { $0 != selection }) {
            Button {
                selection = alternateUnit
            } label: {
                label()
            }
            .buttonStyle(.plain)
        } else {
#if os(watchOS)
            Button {
                guard let currentIndex = units.firstIndex(of: selection) else {
                    selection = units[units.startIndex]
                    return
                }
                let nextIndex = units.index(after: currentIndex)
                selection = nextIndex == units.endIndex ? units[units.startIndex] : units[nextIndex]
            } label: {
                label()
            }
            .buttonStyle(.plain)
#else
            Menu {
                Picker(title, selection: $selection) {
                    ForEach(units) { unit in
                        Text(unitTitle(unit)).tag(unit)
                    }
                }
            } label: {
                label()
            }
            .buttonStyle(.plain)
#endif
        }
    }
}

#if DEBUG
private struct ForecastUnitSelectorTogglePreview: View {
    @State private var temperatureUnit = TemperatureUnit.celsius
    @State private var precipitationUnit = PrecipitationUnit.millimeters
    @State private var waveHeightUnit = WaveHeightUnit.meters
    @State private var freezingLevelUnit = FreezingLevelUnit.meters

    var body: some View {
        Form {
            Section("Two-option direct toggles") {
                ForecastUnitSelector("Temperature unit", selection: $temperatureUnit, unitTitle: \.label) {
                    LabeledContent("Temperature") { Text(temperatureUnit.label) }
                }
                ForecastUnitSelector("Precipitation unit", selection: $precipitationUnit, unitTitle: \.label) {
                    LabeledContent("Precipitation") { Text(precipitationUnit.label) }
                }
                ForecastUnitSelector("Wave height unit", selection: $waveHeightUnit, unitTitle: \.label) {
                    LabeledContent("Wave") { Text(waveHeightUnit.label) }
                }
                ForecastUnitSelector("Freezing level unit", selection: $freezingLevelUnit, unitTitle: \.label) {
                    LabeledContent("Freezing level") { Text(freezingLevelUnit.label) }
                }
            }
        }
    }
}

private struct ForecastUnitSelectorMenuPreview: View {
    @State private var windSpeedUnit = WindSpeedUnit.knots
    @State private var pressureUnit = PressureUnit.hectopascals

    var body: some View {
        Form {
            Section("Multi-option menus") {
                ForecastUnitSelector("Wind speed unit", selection: $windSpeedUnit, unitTitle: \.label) {
                    LabeledContent("Wind speed") { Text(windSpeedUnit.label) }
                }
                ForecastUnitSelector("Pressure unit", selection: $pressureUnit, unitTitle: \.label) {
                    LabeledContent("Sea level pressure") { Text(pressureUnit.label) }
                }
            }
        }
    }
}

#Preview("Forecast unit selector · direct toggles") {
    ForecastUnitSelectorTogglePreview()
}

#Preview("Forecast unit selector · menus") {
    ForecastUnitSelectorMenuPreview()
}
#endif
