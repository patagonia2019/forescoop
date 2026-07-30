//
//  ForecastModelPicker.swift
//  Forescoop
//
//  Created by Javier on 23/07/2026.
//  Copyright © 2026 Forescoop. All rights reserved.

#if !os(watchOS)
import SwiftUI

public struct ForecastModelPicker: View {
    let spotID: String
    let selectedModelIDs: Set<String>
    /// Model IDs verified by the dashboard to return usable forecast hours.
    let usableModelIDs: Set<String>
    let isProUser: Bool
    let onModelSelected: ([String]) -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ForecastModelPickerViewModel

    public init(
        forecastService: ForecastWindguruProtocol,
        spotID: String,
        selectedModelIDs: Set<String>,
        usableModelIDs: Set<String> = [],
        isProUser: Bool = false,
        onModelSelected: @escaping ([String]) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: ForecastModelPickerViewModel(forecastService: forecastService, selectedModelIDs: selectedModelIDs))
        self.spotID = spotID
        self.selectedModelIDs = selectedModelIDs
        self.usableModelIDs = usableModelIDs
        self.isProUser = isProUser
        self.onModelSelected = onModelSelected
    }

    public var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading forecast models…")
                } else if let errorMessage = viewModel.errorMessage {
                    ContentUnavailableView("Models unavailable", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
                } else if viewModel.models.isEmpty {
                    ContentUnavailableView("No forecast models", systemImage: "cpu")
                } else {
                    List {
                        Section("\(viewModel.selectedIDs.count) selected of \(viewModel.models.count) available") {
                            ForEach(viewModel.models) { model in
                                Button {
                                    viewModel.toggle(model.identifier)
                                } label: {
                                    HStack {
                                        Image(systemName: viewModel.selectedIDs.contains(model.identifier) ? "checkmark.square.fill" : "square")
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
                    Button("Apply") { onModelSelected(viewModel.selectedIDs.sorted()) }
                        .disabled(viewModel.selectedIDs.isEmpty)
                }
            }
            .task {
                await viewModel.loadModels(spotID: spotID, selectedModelIDs: selectedModelIDs, usableModelIDs: usableModelIDs, isProUser: isProUser)
            }
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
