//
//  WindguruFavoritesView.swift
//  Forescoop package
//
//  Created by Javier on 07/26/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if !os(watchOS)
import SwiftUI

public struct WindguruFavoritesView: View {
    private let forecastService: ForecastWindguruProtocol
    private let username: String
    private let password: String
    private let isProUser: Bool
    private let loadFavoriteSpots: @MainActor (String, String) async throws -> SpotResult?
    private let removeFavoriteSpot: @MainActor (String, String, String) async throws -> WGSuccess?

    @State private var favorites: [SpotOwner] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var removingIDs = Set<String>()
    @State private var showsAddFavorite = false
#if !os(macOS)
    @State private var editMode: EditMode = .inactive
#endif

    public init(
        forecastService: ForecastWindguruProtocol = ForecastWindguruService(),
        username: String,
        password: String? = nil,
        isProUser: Bool = false
    ) {
        self.forecastService = forecastService
        self.username = username
        self.password = password ?? WindguruCredentialStore.password(for: username) ?? ""
        self.isProUser = isProUser
        loadFavoriteSpots = { try await forecastService.favoriteSpots(withUsername: $0, password: $1) }
        removeFavoriteSpot = { spotID, username, password in
            try await forecastService.removeFavoriteSpot(withSpotId: spotID, username: username, password: password)
        }
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
#if !os(macOS)
            .environment(\.editMode, $editMode)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(editMode.isEditing ? "Done" : "Edit") {
                        editMode = editMode.isEditing ? .inactive : .active
                    }
                }
            }
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
    }

    private func favoriteRow(_ spot: SpotOwner) -> some View {
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
