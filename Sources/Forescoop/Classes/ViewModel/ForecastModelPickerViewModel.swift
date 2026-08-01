//
//  ForecastModelPickerViewModel.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 07/30/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if !os(watchOS)
import Combine
import Foundation

@MainActor
final class ForecastModelPickerViewModel: ObservableObject {
    @Published private(set) var models = [ForecastModelOption]()
    @Published private(set) var isLoading = true
    @Published private(set) var errorMessage: String?
    @Published var selectedIDs: Set<String>

    private let modelLoader: @MainActor (String, Bool) async throws -> (SpotInfo?, Models?, [String])

    init(forecastService: ForecastWindguruProtocol, selectedModelIDs: Set<String>) {
        selectedIDs = selectedModelIDs
        modelLoader = { spotID, isProUser in
            let spotInfo = try await forecastService.spotInfo(bySpotId: spotID)
            let modelInfo = try await forecastService.modelInfo(onlyModelId: nil)
            guard isProUser, let coordinate = spotInfo?.location?.coordinate else { return (spotInfo, modelInfo, []) }
            let response = try? await forecastService.models(bylat: String(coordinate.latitude), lon: String(coordinate.longitude))
            let modelIDs = response.flatMap { response in
                response.data(using: .utf8).flatMap { try? JSONSerialization.jsonObject(with: $0) as? [Int] }
            } ?? []
            return (spotInfo, modelInfo, modelIDs.map(String.init))
        }
    }

    func toggle(_ identifier: String) {
        if selectedIDs.contains(identifier) { selectedIDs.remove(identifier) } else { selectedIDs.insert(identifier) }
    }

    func loadModels(spotID: String, selectedModelIDs: Set<String>, usableModelIDs: Set<String>, isProUser: Bool) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let (spotInfo, modelInfo, proModelIDs) = try await modelLoader(spotID, isProUser)
            let discoveredIDs = Set(spotInfo?.currentModels.map(String.init) ?? []).union(isProUser ? Set(proModelIDs) : [])
            let availableIDs = (isProUser && !usableModelIDs.isEmpty ? usableModelIDs : discoveredIDs).union(selectedModelIDs)
            models = (modelInfo?.sorted ?? []).compactMap { model in
                let identifier = String(model.identifier)
                guard availableIDs.contains(identifier) else { return nil }
                return ForecastModelOption(identifier: identifier, name: model.oficinalName ?? model.shortName ?? "Model \(identifier)")
            }
        } catch { errorMessage = error.localizedDescription }
    }
}
#endif
