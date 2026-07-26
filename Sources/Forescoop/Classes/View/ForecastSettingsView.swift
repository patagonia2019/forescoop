//
//  ForecastSettingsView.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 07/26/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if !os(watchOS)
import SwiftUI

public struct ForecastSettingsView: View {
    @AppStorage("forecastDisplayInterval") private var forecastDisplayInterval = ForecastDisplayInterval.hourly.rawValue
    @Environment(\.dismiss) private var dismiss
    private let modelSelectionTitle: String?
    private let onSelectModels: (() -> Void)?

    public init(
        modelSelectionTitle: String? = nil,
        onSelectModels: (() -> Void)? = nil
    ) {
        self.modelSelectionTitle = modelSelectionTitle
        self.onSelectModels = onSelectModels
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section("Forecast") {
                    Picker("Interval", selection: $forecastDisplayInterval) {
                        ForEach(ForecastDisplayInterval.allCases) { interval in
                            Text(interval.title).tag(interval.rawValue)
                        }
                    }
                    .pickerStyle(.menu)

                    Text("Shows the nearest available forecast at this interval. Models that publish less frequently remain at their native cadence.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    if let onSelectModels {
                        Button(action: onSelectModels) {
                            LabeledContent("Forecast models") {
                                Text(modelSelectionTitle ?? "Select")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .foregroundStyle(.primary)
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
    }
}

#Preview("Settings") {
    ForecastSettingsView()
}
#endif
