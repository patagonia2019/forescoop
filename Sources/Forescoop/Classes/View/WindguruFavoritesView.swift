//
//  WindguruFavoritesView.swift
//  Forescoop package
//
//  Created by Javier on 07/26/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if !os(watchOS)
import CoreLocation
import SwiftUI

public struct WindguruFavoritesView: View {
    private let forecastService: ForecastWindguruProtocol
    private let username: String
    private let password: String
    private let isProUser: Bool
    private let loadFavoriteSpots: @MainActor (String, String) async throws -> SpotResult?
    private let removeFavoriteSpot: @MainActor (String, String, String) async throws -> WGSuccess?
    private let loadSpotInfo: @MainActor (String) async throws -> SpotInfo?
    private let onSpotSelected: (SpotOwner) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var favorites: [SpotOwner] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var removingIDs = Set<String>()
    @State private var showsAddFavorite = false
    @State private var mapCoordinateToShow: CLLocationCoordinate2D?
#if !os(macOS)
    @State private var editMode: EditMode = .inactive
#endif

    public init(
        forecastService: ForecastWindguruProtocol = ForecastWindguruService(),
        username: String,
        password: String? = nil,
        isProUser: Bool = false,
        onSpotSelected: @escaping (SpotOwner) -> Void = { _ in }
    ) {
        self.forecastService = forecastService
        self.username = username
        self.password = password ?? WindguruCredentialStore.password(for: username) ?? ""
        self.isProUser = isProUser
        self.onSpotSelected = onSpotSelected
        loadFavoriteSpots = { try await forecastService.favoriteSpots(withUsername: $0, password: $1) }
        removeFavoriteSpot = { spotID, username, password in
            try await forecastService.removeFavoriteSpot(withSpotId: spotID, username: username, password: password)
        }
        loadSpotInfo = { try await forecastService.spotInfo(bySpotId: $0) }
    }

    public var body: some View {
        NavigationStack {
            List {
                Section {
                    Button("Add Favorite", systemImage: "star.badge.plus") {
                        showsAddFavorite = true
                    }
                } footer: {
                    Text("Search Windguru, choose a map location, or use your current location to add a favorite.")
                }

                Section("Favorites") {
                    if isLoading {
                        ProgressView("Loading favorites…")
                    } else if let errorMessage {
                        ContentUnavailableView("Favorites unavailable", systemImage: "star.slash", description: Text(errorMessage))
                    } else if favorites.isEmpty {
                        Text("No favorite spots")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(favorites.indices, id: \.self) { index in
                            favoriteRow(favorites[index])
                        }
#if !os(macOS)
                        .onDelete(perform: removeFavorites)
#endif
                    }
                }
            }
            .navigationTitle("Favorites")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
#if !os(macOS)
                ToolbarItem(placement: .primaryAction) {
                    Button(editMode.isEditing ? "Done" : "Edit") {
                        editMode = editMode.isEditing ? .inactive : .active
                    }
                }
#endif
            }
#if !os(macOS)
            .environment(\.editMode, $editMode)
#endif
        }
        .task { await loadFavorites() }
        .sheet(isPresented: $showsAddFavorite) {
            WindguruSpotPicker(
                forecastService: forecastService,
                username: username,
                isProUser: isProUser,
                onSpotSelected: { _ in },
                onCoordinateSelected: { _, _ in },
                purpose: .addFavorite,
                onFavoriteAdded: {
                    Task { await loadFavorites() }
                }
            )
        }
#if !os(tvOS)
        .sheet(isPresented: Binding(
            get: { mapCoordinateToShow != nil },
            set: { if !$0 { mapCoordinateToShow = nil } }
        )) {
            MapLocationPicker(
                initialCoordinate: mapCoordinateToShow,
                isSelectionEnabled: false,
                onSelection: { _ in }
            )
        }
#endif
    }

    private func favoriteRow(_ spot: SpotOwner) -> some View {
        HStack(spacing: 12) {
            Button {
                guard !isEditingFavorites else { return }
                onSpotSelected(spot)
            } label: {
                Label {
                    VStack(alignment: .leading) {
                        Text(spot.displayName)
                        Text(spot.countryName ?? "")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "star.fill")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .buttonStyle(.plain)

#if !os(tvOS)
            Button("Show \(spot.displayName) on map", systemImage: "map") {
                Task { await showMap(for: spot) }
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
#endif
        }
        .disabled(removingIDs.contains(spot.identifier ?? ""))
        .opacity(removingIDs.contains(spot.identifier ?? "") ? 0.45 : 1)
        .contextMenu {
            Button("Remove from Favorites", systemImage: "star.slash", role: .destructive) {
                Task { await removeFavorite(spot) }
            }
        }
#if !os(macOS)
        .swipeActions {
            Button("Remove", systemImage: "star.slash", role: .destructive) {
                Task { await removeFavorite(spot) }
            }
        }
#endif
    }

    private var isEditingFavorites: Bool {
#if !os(macOS)
        editMode.isEditing
#else
        false
#endif
    }

    @MainActor
    private func showMap(for spot: SpotOwner) async {
        guard let spotID = spot.identifier,
              let coordinate = try? await loadSpotInfo(spotID)?.location?.coordinate else {
            errorMessage = "This favorite has no map location."
            return
        }
        mapCoordinateToShow = coordinate
    }

    @MainActor
    private func loadFavorites() async {
        guard !username.isEmpty, !password.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            favorites = try await loadFavoriteSpots(username, password)?.allSpots ?? []
        } catch {
            errorMessage = "Windguru favorites are unavailable right now."
        }
    }

    private func removeFavorites(at offsets: IndexSet) {
        for spot in offsets.map({ favorites[$0] }) {
            Task { await removeFavorite(spot) }
        }
    }

    @MainActor
    private func removeFavorite(_ spot: SpotOwner) async {
        guard let spotID = spot.identifier else { return }
        removingIDs.insert(spotID)
        defer { removingIDs.remove(spotID) }
        do {
            _ = try await removeFavoriteSpot(spotID, username, password)
            favorites.removeAll { $0.identifier == spotID }
        } catch {
            errorMessage = "Couldn’t remove this favorite."
        }
    }
}

#Preview("Favorites") {
    WindguruFavoritesView(forecastService: ForecastWindguruMockup(), username: "forescoop", password: "password")
}
#endif
