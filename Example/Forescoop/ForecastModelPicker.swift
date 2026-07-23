//
//  ForecastModelPicker.swift
//  Forescoop
//
//  Created by Javier on 23/07/2026.
//  Copyright © 2026 Forescoop. All rights reserved.

import SwiftUI
import Forescoop

private struct ForecastModelOption: Identifiable {
    let identifier: String
    let name: String

    var id: String { identifier }
}

struct ForecastModelPicker: View {
    let forecastService: ForecastWindguruProtocol
    let spotID: String
    let selectedModelIDs: Set<String>
    let onModelSelected: ([String]) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var models: [ForecastModelOption] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedIDs: Set<String> = []

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading forecast models…")
                } else if let errorMessage {
                    ContentUnavailableView("Models unavailable", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
                } else if models.isEmpty {
                    ContentUnavailableView("No forecast models", systemImage: "cpu")
                } else {
                    List(models) { model in
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
            let spotInfo = try await forecastService.spotInfo(bySpotId: spotID)
            let modelInfo = try await forecastService.modelInfo(onlyModelId: nil)
            let availableModelIDs = Set(spotInfo?.currentModels.map(String.init) ?? [])
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
        onModelSelected: { _ in }
    )
}
