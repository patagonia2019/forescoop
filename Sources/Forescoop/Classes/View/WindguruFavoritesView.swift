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
    private let account: WindguruAccount
    private var username: String { account.username }
    private var password: String { account.password ?? "" }
    private var isProUser: Bool { account.isProUser }
    private let onSpotSelected: (SpotOwner) -> Void

    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: WindguruFavoritesViewModel
    @State private var showsAddFavorite = false
    @State private var mapCoordinateToShow: CLLocationCoordinate2D?
#if !os(macOS)
    @State private var editMode: EditMode = .inactive
#endif

    public init(
        forecastService: ForecastWindguruProtocol = ForecastWindguruService(),
        account: WindguruAccount,
        onSpotSelected: @escaping (SpotOwner) -> Void = { _ in }
    ) {
        self.forecastService = forecastService
        self.account = account
        self.onSpotSelected = onSpotSelected
        _viewModel = StateObject(wrappedValue: WindguruFavoritesViewModel(forecastService: forecastService))
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
                    if viewModel.isLoading {
                        ProgressView("Loading favorites…")
                    } else if let errorMessage = viewModel.errorMessage {
                        ContentUnavailableView("Favorites unavailable", systemImage: "star.slash", description: Text(errorMessage))
                    } else if viewModel.favorites.isEmpty {
                        Text("No favorite spots")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.favorites.indices, id: \.self) { index in
                            favoriteRow(viewModel.favorites[index])
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
        .task { await viewModel.loadFavorites(username: username, password: password) }
        .sheet(isPresented: $showsAddFavorite) {
            WindguruSpotPicker(
                forecastService: forecastService,
                account: account,
                onSpotSelected: { _ in },
                onCoordinateSelected: { _, _ in },
                purpose: .addFavorite,
                onFavoriteAdded: {
                    Task { await viewModel.loadFavorites(username: username, password: password) }
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
            LocationMapButton(locationName: spot.displayName) {
                Task { await showMap(for: spot) }
            }
#endif
        }
        .disabled(viewModel.removingIDs.contains(spot.identifier ?? ""))
        .opacity(viewModel.removingIDs.contains(spot.identifier ?? "") ? 0.45 : 1)
        .contextMenu {
            Button("Remove from Favorites", systemImage: "star.slash", role: .destructive) {
                Task { await removeFavorite(spot) }
            }
        }
#if os(iOS) || os(visionOS)
        .swipeActions {
            Button("Remove", systemImage: "star.slash", role: .destructive) {
                Task { await removeFavorite(spot) }
            }
        }
#endif
    }

    private var isEditingFavorites: Bool {
#if os(iOS) || os(visionOS)
        editMode.isEditing
#else
        false
#endif
    }

    @MainActor
    private func showMap(for spot: SpotOwner) async {
        guard let coordinate = await viewModel.coordinate(for: spot) else {
            viewModel.errorMessage = "This favorite has no map location."
            return
        }
        mapCoordinateToShow = coordinate
    }

    private func removeFavorites(at offsets: IndexSet) {
        for spot in offsets.map({ viewModel.favorites[$0] }) {
            Task { await removeFavorite(spot) }
        }
    }

    @MainActor
    private func removeFavorite(_ spot: SpotOwner) async {
        await viewModel.removeFavorite(spot, username: username, password: password)
    }
}

#Preview("Favorites") {
    WindguruFavoritesView(forecastService: ForecastWindguruMockup(), account: WindguruAccount())
}
#endif
