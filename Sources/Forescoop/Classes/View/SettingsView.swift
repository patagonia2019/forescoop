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

    public init(weatherBackgroundStyle: Binding<WeatherBackgroundStyle>) {
        _weatherBackgroundStyle = weatherBackgroundStyle
    }

    public var body: some View {
        NavigationStack {
            Form {
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

                Section {
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("About Ventus", systemImage: "info.circle")
                    }
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
    }
}

#Preview {
    SettingsView(weatherBackgroundStyle: .constant(.lottieAdriana))
}
