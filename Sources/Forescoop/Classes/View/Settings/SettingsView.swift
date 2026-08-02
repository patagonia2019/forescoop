//
//  SettingsView.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 07/31/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

import SwiftUI

/// Device settings that are available regardless of Windguru account status.
public struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding private var weatherBackgroundStyle: WeatherBackgroundStyle
    @Binding private var forecastViewMode: ForecastViewMode

    public init(
        weatherBackgroundStyle: Binding<WeatherBackgroundStyle>,
        forecastViewMode: Binding<ForecastViewMode>
    ) {
        _weatherBackgroundStyle = weatherBackgroundStyle
        _forecastViewMode = forecastViewMode
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Forecast view", selection: $forecastViewMode) {
                        ForEach(ForecastViewMode.allCases) { mode in
                            Label(mode.title, systemImage: mode.systemImage)
                                .tag(mode)
                        }
                    }
                    .pickerStyle(.inline)
                } header: {
                    Text("Layout")
                } footer: {
                    Text("Choose the default presentation for forecasts on this device.")
                }

                Section {
                    Picker("Weather background", selection: $weatherBackgroundStyle) {
                        ForEach(WeatherBackgroundStyle.allCases) { style in
                            Label(style.title, systemImage: style.systemImage)
                                .tag(style)
                        }
                    }
                    .pickerStyle(.inline)
                } header: {
                    Text("Animations")
                } footer: {
                    Text("The selected animation is used as the forecast background on this device.")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .onChange(of: weatherBackgroundStyle) { _, style in
            WeatherBackgroundStyleStore.save(style)
        }
        .onChange(of: forecastViewMode) { _, mode in
            ForecastViewModeStore.save(mode)
        }
    }
}

#Preview {
    SettingsView(
        weatherBackgroundStyle: .constant(.lottieAdriana),
        forecastViewMode: .constant(.dashboard)
    )
}
