//
//  ForecastModelPicker.swift
//  Forescoop
//
//  Created by Javier on 23/07/2026.
//  Copyright © 2026 Forescoop. All rights reserved.

#if !os(watchOS)
import SwiftUI

private struct ForecastModelOption: Identifiable {
    let identifier: String
    let name: String

    var id: String { identifier }
}

public struct ForecastModelPicker: View {
    private let modelLoader: @MainActor (String, Bool) async throws -> (SpotInfo?, Models?, [String])
    let spotID: String
    let selectedModelIDs: Set<String>
    /// Model IDs verified by the dashboard to return usable forecast hours.
    let usableModelIDs: Set<String>
    let isProUser: Bool
    let onModelSelected: ([String]) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var models: [ForecastModelOption] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedIDs: Set<String> = []

    public init(
        forecastService: ForecastWindguruProtocol,
        spotID: String,
        selectedModelIDs: Set<String>,
        usableModelIDs: Set<String> = [],
        isProUser: Bool = false,
        onModelSelected: @escaping ([String]) -> Void
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
        self.selectedModelIDs = selectedModelIDs
        self.usableModelIDs = usableModelIDs
        self.isProUser = isProUser
        self.onModelSelected = onModelSelected
    }

    public var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading forecast models…")
                } else if let errorMessage {
                    ContentUnavailableView("Models unavailable", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
                } else if models.isEmpty {
                    ContentUnavailableView("No forecast models", systemImage: "cpu")
                } else {
                    List {
                        Section("\(selectedIDs.count) selected of \(models.count) available") {
                            ForEach(models) { model in
                                Button {
                                    toggle(model.identifier)
                                } label: {
                                    HStack {
                                        Image(systemName: selectedIDs.contains(model.identifier) ? "checkmark.square.fill" : "square")
                                        Text(model.name)
                                        Spacer()
                                    }
                                }
                                .foregroundStyle(.primary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Forecast model")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") { onModelSelected(selectedIDs.sorted()) }
                        .disabled(selectedIDs.isEmpty)
                }
            }
            .task {
                selectedIDs = selectedModelIDs
                await loadModels()
            }
        }
    }

    private func toggle(_ identifier: String) {
        if selectedIDs.contains(identifier) {
            selectedIDs.remove(identifier)
        } else {
            selectedIDs.insert(identifier)
        }
    }

    @MainActor
    private func loadModels() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let (spotInfo, modelInfo, proModelIDs) = try await modelLoader(spotID, isProUser)
            let discoveredAndPublicModelIDs = Set(spotInfo?.currentModels.map(String.init) ?? [])
                .union(isProUser ? Set(proModelIDs) : [])
            let availableModelIDs = (isProUser && !usableModelIDs.isEmpty
                ? usableModelIDs
                : discoveredAndPublicModelIDs)
                .union(selectedModelIDs)
            let availableModels = modelInfo?.sorted ?? []
            models = availableModels.compactMap { model in
                let identifier = String(model.identifier)
                guard availableModelIDs.contains(identifier) else { return nil }
                return ForecastModelOption(identifier: identifier, name: model.oficinalName ?? model.shortName ?? "Model \(identifier)")
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview("Forecast model picker") {
    ForecastModelPicker(
        forecastService: ForecastWindguruMockup(),
        spotID: "64141",
        selectedModelIDs: [],
        usableModelIDs: [],
        isProUser: true,
        onModelSelected: { _ in }
    )
}
#endif
