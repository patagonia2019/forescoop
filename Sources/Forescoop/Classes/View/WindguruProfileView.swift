//
//  WindguruProfileView.swift
//  Forescoop package
//

#if !os(watchOS)
import Foundation
import SwiftUI

public struct WindguruProfileView: View {
    public let user: User
    private let username: String
    private let password: String
    private let onSignOut: () -> Void
    private let loadFavoriteSpots: @MainActor (String, String) async throws -> SpotResult?
    private let removeFavoriteSpot: @MainActor (String, String, String) async throws -> WGSuccess?

    @State private var favorites: [SpotOwner] = []
    @State private var isLoadingFavorites = false
    @State private var favoritesErrorMessage: String?
    @State private var favoriteIDsBeingRemoved = Set<String>()
#if !os(macOS)
    @State private var editMode: EditMode = .inactive
#endif

    public init(
        user: User,
        forecastService: ForecastWindguruProtocol = ForecastWindguruService(),
        username: String? = nil,
        password: String? = nil,
        onSignOut: @escaping () -> Void = {}
    ) {
        self.user = user
        self.username = username ?? user.username ?? ""
        self.password = password ?? WindguruCredentialStore.password(for: username ?? user.username ?? "") ?? ""
        self.onSignOut = onSignOut
        loadFavoriteSpots = { try await forecastService.favoriteSpots(withUsername: $0, password: $1) }
        removeFavoriteSpot = { spotID, username, password in
            try await forecastService.removeFavoriteSpot(withSpotId: spotID, username: username, password: password)
        }
    }

    public var body: some View {
        List {
            Section {
                Label {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(user.name)
                            .font(.title3.bold())
                        Text(user.username ?? "Windguru account")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .font(.system(size: 34))
                        .foregroundStyle(.blue)
                }
                .padding(.vertical, 4)

                LabeledContent("Account ID", value: "#\(user.id_user)")
                LabeledContent("Membership", value: user.isPro ? "Windguru PRO" : "Standard")
                if user.noAdvertisement {
                    Label("Ad-free account", systemImage: "checkmark.shield")
                        .foregroundStyle(.secondary)
                }

                Button("Logout", systemImage: "rectangle.portrait.and.arrow.right", role: .destructive, action: onSignOut)
            } header: {
                Text("Account")
            }

            Section("Forecast preferences") {
                LabeledContent("Wind", value: unitLabel(user.windUnits, fallback: "Default"))
                LabeledContent("Temperature", value: unitLabel(user.temperatureUnits, fallback: "Default"))
                LabeledContent("Waves", value: unitLabel(user.waveUnits, fallback: "Default"))
                if user.viewHoursTo > user.viewHoursFrom {
                    LabeledContent("Visible hours", value: "\(user.viewHoursFrom):00–\(user.viewHoursTo):00")
                }
                if !user.windRatingLimits.isEmpty {
                    LabeledContent("Wind ratings", value: user.windRatingLimits.map { String(format: "%.1f", $0) }.joined(separator: ", "))
                }
            }

            Section("Favorites") {
                if isLoadingFavorites {
                    ProgressView("Loading favorites…")
                } else if let favoritesErrorMessage {
                    Text(favoritesErrorMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
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
#if os(macOS)
        .listStyle(.inset)
#else
        .listStyle(.insetGrouped)
        .environment(\.editMode, $editMode)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(editMode.isEditing ? "Done" : "Edit") {
                    editMode = editMode.isEditing ? .inactive : .active
                }
            }
        }
#endif
        .task { await loadFavorites() }
    }

    private func favoriteRow(_ spot: SpotOwner) -> some View {
        Label {
            VStack(alignment: .leading) {
                Text(spot.name ?? "Unknown spot")
                Text(spot.countryName ?? "")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: "star.fill")
        }
        .opacity(favoriteIDsBeingRemoved.contains(spot.identifier ?? "") ? 0.45 : 1)
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
        isLoadingFavorites = true
        favoritesErrorMessage = nil
        defer { isLoadingFavorites = false }
        do {
            favorites = try await loadFavoriteSpots(username, password)?.allSpots ?? []
        } catch {
            favoritesErrorMessage = "Favorites are unavailable right now."
        }
    }

    private func removeFavorites(at offsets: IndexSet) {
        let spotsToRemove = offsets.map { favorites[$0] }
        for spot in spotsToRemove {
            Task { await removeFavorite(spot) }
        }
    }

    @MainActor
    private func removeFavorite(_ spot: SpotOwner) async {
        guard let spotID = spot.identifier else { return }
        favoriteIDsBeingRemoved.insert(spotID)
        defer { favoriteIDsBeingRemoved.remove(spotID) }
        do {
            _ = try await removeFavoriteSpot(spotID, username, password)
            favorites.removeAll { $0.identifier == spotID }
        } catch {
            favoritesErrorMessage = "Couldn’t remove this favorite."
        }
    }

    private func unitLabel(_ value: String?, fallback: String) -> String {
        guard let value, !value.isEmpty else { return fallback }
        return value.uppercased()
    }
}

#Preview("Windguru PRO profile") {
    let user = try! User(map: [
        "id_user": 42,
        "username": "forescoop",
        "pro": 1,
        "no_ads": 1,
        "wind_units": "knots",
        "temp_units": "c",
        "wave_units": "m",
        "view_hours_from": 3,
        "view_hours_to": 22,
        "wind_rating_limits": [10.6, 15.6, 19.4]
    ])!
    WindguruProfileView(user: user, forecastService: ForecastWindguruMockup())
}
#endif
