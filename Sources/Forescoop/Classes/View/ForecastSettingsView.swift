//
//  ForecastSettingsView.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 07/26/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if !os(watchOS)
import Foundation
import SwiftUI

public struct ForecastSettingsView: View {
    private let modelLoader: @MainActor (String, Bool) async throws -> (SpotInfo?, Models?, [String])
    private let spotID: String
    private let initiallySelectedModelIDs: Set<String>
    private let usableModelIDs: Set<String>
    private let isProUser: Bool
    private let onModelsApplied: ([String]) -> Void

    @AppStorage("forecastDisplayInterval") private var forecastDisplayInterval = ForecastDisplayInterval.hourly.rawValue
    @Environment(\.dismiss) private var dismiss
    @State private var models: [SettingsModelOption] = []
    @State private var selectedModelIDs: Set<String> = []
    @State private var isLoadingModels = true
    @State private var modelErrorMessage: String?

    public init(
        forecastService: ForecastWindguruProtocol,
        spotID: String,
        selectedModelIDs: Set<String>,
        usableModelIDs: Set<String> = [],
        isProUser: Bool = false,
        onModelsApplied: @escaping ([String]) -> Void
    ) {
        modelLoader = { spotID, isProUser in
            let spotInfo = try await forecastService.spotInfo(bySpotId: spotID)
            let modelInfo = try await forecastService.modelInfo(onlyModelId: nil)
            guard isProUser, let coordinate = spotInfo?.location?.coordinate else {
                return (spotInfo, modelInfo, [])
            }
            let discoveredModelIDs: [String]
            if let response = try? await forecastService.models(
                bylat: String(coordinate.latitude),
                lon: String(coordinate.longitude)
            ), let data = response.data(using: .utf8),
               let modelIDs = try? JSONSerialization.jsonObject(with: data) as? [Int] {
                discoveredModelIDs = modelIDs.map(String.init)
            } else {
                discoveredModelIDs = []
            }
            return (spotInfo, modelInfo, discoveredModelIDs)
        }
        self.spotID = spotID
        initiallySelectedModelIDs = selectedModelIDs
        self.usableModelIDs = usableModelIDs
        self.isProUser = isProUser
        self.onModelsApplied = onModelsApplied
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
                }

                Section("Models") {
                    if isLoadingModels {
                        ProgressView("Loading forecast models…")
                    } else if let modelErrorMessage {
                        Text(modelErrorMessage)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(models) { model in
                            Button {
                                toggle(model.identifier)
                            } label: {
                                HStack {
                                    Image(systemName: selectedModelIDs.contains(model.identifier) ? "checkmark.square.fill" : "square")
                                    Text(model.name)
                                    Spacer()
                                }
                            }
                            .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        if selectedModelIDs != initiallySelectedModelIDs {
                            onModelsApplied(selectedModelIDs.sorted())
                        }
                        dismiss()
                    }
                }
            }
            .task {
                selectedModelIDs = initiallySelectedModelIDs
                await loadModels()
            }
        }
    }

    private func toggle(_ identifier: String) {
        if selectedModelIDs.contains(identifier) {
            selectedModelIDs.remove(identifier)
        } else {
            selectedModelIDs.insert(identifier)
        }
    }

    @MainActor
    private func loadModels() async {
        isLoadingModels = true
        modelErrorMessage = nil
        defer { isLoadingModels = false }
        do {
            let (spotInfo, modelInfo, proModelIDs) = try await modelLoader(spotID, isProUser)
            let discoveredAndPublicModelIDs = Set(spotInfo?.currentModels.map(String.init) ?? [])
                .union(isProUser ? Set(proModelIDs) : [])
            let availableModelIDs = (isProUser && !usableModelIDs.isEmpty
                ? usableModelIDs
                : discoveredAndPublicModelIDs)
                .union(initiallySelectedModelIDs)
            models = (modelInfo?.sorted ?? []).compactMap { model in
                let identifier = String(model.identifier)
                guard availableModelIDs.contains(identifier) else { return nil }
                return SettingsModelOption(identifier: identifier, name: model.oficinalName ?? model.shortName ?? "Model \(identifier)")
            }
        } catch {
            modelErrorMessage = error.localizedDescription
        }
    }
}

private struct SettingsModelOption: Identifiable {
    let identifier: String
    let name: String

    var id: String { identifier }
}

#Preview("Settings") {
    ForecastSettingsView(
        forecastService: ForecastWindguruMockup(),
        spotID: "64141",
        selectedModelIDs: [],
        onModelsApplied: { _ in }
    )
}
#endif
