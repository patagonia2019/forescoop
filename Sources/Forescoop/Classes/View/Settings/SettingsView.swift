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
    @Binding private var theme: VentusTheme

    public init(
        weatherBackgroundStyle: Binding<WeatherBackgroundStyle>,
        forecastViewMode: Binding<ForecastViewMode>,
        theme: Binding<VentusTheme>
    ) {
        _weatherBackgroundStyle = weatherBackgroundStyle
        _forecastViewMode = forecastViewMode
        _theme = theme
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Theme", selection: $theme) {
                        ForEach(VentusTheme.allCases) { theme in
                            Label(theme.title, systemImage: "paintpalette")
                                .tag(theme)
                        }
                    }
                    .pickerStyle(.inline)
                } header: {
                    Text("Appearance")
                } footer: {
                    Text("Themes change colors and font design without changing text sizes. System Default follows the current device appearance.")
                }

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
        .onChange(of: theme) { _, theme in
            VentusThemeStore.save(theme)
        }
    }
}

#Preview {
    SettingsView(
        weatherBackgroundStyle: .constant(.lottieAdriana),
        forecastViewMode: .constant(.dashboard),
        theme: .constant(.system)
    )
}
