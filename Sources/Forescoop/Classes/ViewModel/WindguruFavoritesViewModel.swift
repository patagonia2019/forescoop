//
//  WindguruFavoritesViewModel.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 07/30/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if !os(watchOS)
import Combine
import CoreLocation
import Foundation

@MainActor
final class WindguruFavoritesViewModel: ObservableObject {
    @Published private(set) var favorites = [SpotOwner]()
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    @Published private(set) var removingIDs = Set<String>()

    private let loadFavoritesRequest: @MainActor (String, String) async throws -> SpotResult?
    private let removeFavoriteRequest: @MainActor (String, String, String) async throws -> WGSuccess?
    private let spotInfoRequest: @MainActor (String) async throws -> SpotInfo?

    init(forecastService: ForecastWindguruProtocol) {
        loadFavoritesRequest = { try await forecastService.favoriteSpots(withUsername: $0, password: $1) }
        removeFavoriteRequest = { try await forecastService.removeFavoriteSpot(withSpotId: $0, username: $1, password: $2) }
        spotInfoRequest = { try await forecastService.spotInfo(bySpotId: $0) }
    }

    func loadFavorites(username: String, password: String) async {
        guard !username.isEmpty, !password.isEmpty else { return }
        isLoading = true; errorMessage = nil
        defer { isLoading = false }
        do { favorites = try await loadFavoritesRequest(username, password)?.allSpots ?? [] }
        catch { errorMessage = "Windguru favorites are unavailable right now." }
    }

    func removeFavorite(_ spot: SpotOwner, username: String, password: String) async {
        guard let spotID = spot.identifier else { return }
        removingIDs.insert(spotID)
        defer { removingIDs.remove(spotID) }
        do {
            _ = try await removeFavoriteRequest(spotID, username, password)
            favorites.removeAll { $0.identifier == spotID }
        } catch { errorMessage = "Couldn’t remove this favorite." }
    }

    func coordinate(for spot: SpotOwner) async -> CLLocationCoordinate2D? {
        guard let spotID = spot.identifier else { return nil }
        return try? await spotInfoRequest(spotID)?.location?.coordinate
    }
}
#endif
