//
//  WindguruSpotPicker.swift
//  Forescoop
//
//  Created by Javier on 23/07/2026.
//  Copyright © 2026 Forescoop. All rights reserved.

#if !os(watchOS)
import CoreLocation
@preconcurrency import MapKit
import SwiftUI

public struct WindguruSpotPicker: View {
    public enum Purpose {
        case chooseLocation
        case addFavorite
    }

    private let searchSpots: @MainActor (String) async throws -> SpotResult?
    private let loadSpotInfo: @MainActor (String) async throws -> SpotInfo?
    private let loadFavoriteSpots: @MainActor (String, String) async throws -> SpotResult?
    private let removeFavoriteSpot: @MainActor (String, String, String) async throws -> WGSuccess?
    private let addFavoriteSpot: @MainActor (String, String, String) async throws -> WGSuccess?
    private let purpose: Purpose
    let account: WindguruAccount
    private var username: String { account.username }
    private var isProUser: Bool { account.isProUser }
    let onSpotSelected: (SpotOwner) -> Void
    let onSpotIDSelected: (String) -> Void
    let onFavoriteSelected: (SpotOwner) -> Void
    let onCoordinateSelected: (CLLocationCoordinate2D, String?) -> Void
    let onFavoriteAdded: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var spots: [SpotOwner] = []
    @State private var favoriteSpots: [SpotOwner] = []
    @State private var isLoading = false
    @State private var isLoadingFavorites = false
    @State private var errorMessage: String?
    @State private var favoritesErrorMessage: String?
    @State private var favoriteIDsBeingRemoved = Set<String>()
    @State private var favoriteIDsBeingAdded = Set<String>()
    @State private var showsMap = false
    @State private var mapCoordinateToShow: CLLocationCoordinate2D?
    @State private var savedLocations = SavedMapLocationStore.load()
    @State private var locationToRename: SavedMapLocation?
    @State private var renamedLocation = ""
#if !os(macOS)
    @State private var editMode: EditMode = .inactive
#endif

    public init(
        forecastService: ForecastWindguruProtocol,
        account: WindguruAccount,
        onSpotSelected: @escaping (SpotOwner) -> Void,
        onSpotIDSelected: @escaping (String) -> Void = { _ in },
        onFavoriteSelected: @escaping (SpotOwner) -> Void = { _ in },
        onCoordinateSelected: @escaping (CLLocationCoordinate2D, String?) -> Void,
        purpose: Purpose = .chooseLocation,
        onFavoriteAdded: @escaping () -> Void = {}
    ) {
        searchSpots = { try await forecastService.searchSpots(byLocation: $0) }
        loadSpotInfo = { try await forecastService.spotInfo(bySpotId: $0) }
        loadFavoriteSpots = { try await forecastService.favoriteSpots(withUsername: $0, password: $1) }
        removeFavoriteSpot = { spotID, username, password in
            try await forecastService.removeFavoriteSpot(withSpotId: spotID, username: username, password: password)
        }
        addFavoriteSpot = { spotID, username, password in
            try await forecastService.addFavoriteSpot(withSpotId: spotID, username: username, password: password)
        }
        self.purpose = purpose
        self.account = account
        self.onSpotSelected = onSpotSelected
        self.onSpotIDSelected = onSpotIDSelected
        self.onFavoriteSelected = onFavoriteSelected
        self.onCoordinateSelected = onCoordinateSelected
        self.onFavoriteAdded = onFavoriteAdded
    }

    private var lastSavedCoordinate: CLLocationCoordinate2D? { savedLocations.last?.coordinate }

    public var body: some View {
        NavigationStack {
            List {
                Section {
                    Button("Use Current Location", systemImage: "location.fill") {
                        Task { await searchCurrentLocation() }
                    }
                    .disabled(isLoading)
#if !os(tvOS)
                    if isProUser {
                    Button("Pick on Map", systemImage: "map") {
                        showsMap = true
                    }
                    }
#endif
                } footer: {
                    Text(isProUser
                        ? "Pick any coordinate worldwide for a Windguru PRO forecast."
                        : "Use your current location or enter a Windguru spot ID.")
                }

                if purpose == .chooseLocation {
                    mapLocationsSection
                    favoritesSection
                }

                Section("Search Windguru spots") {
                    HStack {
                        TextField("City or spot", text: $query)
#if !os(macOS)
                            .textInputAutocapitalization(.words)
#endif
                            .onSubmit { Task { await submitSearch() } }
                        Button("Search") { Task { await submitSearch() } }
                            .disabled(query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                    }
                }

                if isLoading {
                    ProgressView("Searching spots…")
                } else if let errorMessage {
                    ContentUnavailableView("Location unavailable", systemImage: "location.slash", description: Text(errorMessage))
                } else if !spots.isEmpty {
                    Section("Windguru spots") {
                        ForEach(spots.indices, id: \.self) { index in
                            let spot = spots[index]
                            Button {
                                Task { await selectSpot(spot) }
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(spot.displayName)
                                    Text(spot.countryName ?? "")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(purpose == .addFavorite ? "Add Favorite" : "Choose location")
#if !os(macOS)
            .environment(\.editMode, $editMode)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
#if !os(macOS)
                ToolbarItem(placement: .primaryAction) {
                    if purpose == .chooseLocation {
                        Button(editMode.isEditing ? "Done" : "Edit") {
                            editMode = editMode.isEditing ? .inactive : .active
                        }
                    }
                }
#endif
            }
        }
        .task {
            await loadFavorites()
        }
#if !os(tvOS)
        .sheet(isPresented: $showsMap) {
            MapLocationPicker(initialCoordinate: lastSavedCoordinate) { coordinate in
                showsMap = false
                Task {
                    if purpose == .addFavorite {
                        await selectMapCoordinate(coordinate)
                    } else {
                        await saveMapCoordinate(coordinate)
                    }
                }
            }
        }
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
        .alert("Rename location", isPresented: Binding(
            get: { locationToRename != nil },
            set: { if !$0 { locationToRename = nil } }
        )) {
            TextField("Location name", text: $renamedLocation)
            Button("Save") { renameLocation() }
            Button("Cancel", role: .cancel) { locationToRename = nil }
        }
    }

    @ViewBuilder
    private var mapLocationsSection: some View {
        let locations = isProUser ? savedLocations : savedLocations.filter { $0.spotID != nil }
        if !locations.isEmpty {
            Section("Map locations") {
                ForEach(locations) { location in
                    savedLocationRow(location)
                }
                .onDelete(perform: delete)
                .onMove(perform: move)
            }
        }
    }

    @ViewBuilder
    private var favoritesSection: some View {
        if isLoadingFavorites || !favoriteSpots.isEmpty || favoritesErrorMessage != nil {
            Section("Favorites") {
                if isLoadingFavorites {
                    ProgressView("Loading favorites…")
                } else if let favoritesErrorMessage {
                    Text(favoritesErrorMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(favoriteSpots.indices, id: \.self) { index in
                        let spot = favoriteSpots[index]
                        favoriteSpotRow(spot)
                    }
#if !os(macOS)
                    .onDelete(perform: removeFavorites)
#endif
                }
            }
        }
    }

    private func favoriteSpotRow(_ spot: SpotOwner) -> some View {
        HStack(spacing: 12) {
            Button {
                // Favorites are a temporary lookup: do not add them to map
                // locations or replace the user's stored spot/model selection.
                onFavoriteSelected(spot)
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
        .disabled(isLoading || favoriteIDsBeingRemoved.contains(spot.identifier ?? ""))
        .contextMenu {
            Button("Remove from Favorites", systemImage: "star.slash", role: .destructive) {
                Task { await removeFavorite(spot) }
            }
        }
    }

    private func savedLocationRow(_ location: SavedMapLocation) -> some View {
        HStack(spacing: 12) {
            SavedLocationRow(
                location: location,
                isDisabled: isLoading || favoriteIDsBeingAdded.contains(location.spotID ?? ""),
                onSelect: { selectSavedLocation(location) }
            )

#if !os(tvOS)
            Button("Show \(location.displayName) on map", systemImage: "map") {
                mapCoordinateToShow = location.coordinate
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
#endif

#if !os(macOS)
            if editMode.isEditing {
                Button("Rename \(location.name)", systemImage: "pencil") {
                    beginRenaming(location)
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .accessibilityHint("Changes this saved location's name")

                if location.spotID != nil, !location.isPrimaryLocation {
                    Button("Move \(location.name) to Favorites", systemImage: "star") {
                        Task { await moveToFavorites(location) }
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderless)
                    .disabled(favoriteIDsBeingAdded.contains(location.spotID ?? ""))
                    .accessibilityHint("Adds this Windguru spot to Favorites and removes the saved map location")
                }
            }
#endif
        }
        .contextMenu {
            Button("Rename", systemImage: "pencil") { beginRenaming(location) }
            if location.spotID != nil, !location.isPrimaryLocation {
                Button("Move to Favorites", systemImage: "star") {
                    Task { await moveToFavorites(location) }
                }
            }
            if !location.isPrimaryLocation {
                Button("Delete", systemImage: "trash", role: .destructive) { delete(location) }
            }
        }
    }

    @MainActor
    private func loadFavorites() async {
        guard !username.isEmpty,
              let password = account.password else {
            return
        }

        isLoadingFavorites = true
        favoritesErrorMessage = nil
        defer { isLoadingFavorites = false }
        do {
            favoriteSpots = try await loadFavoriteSpots(username, password)?.allSpots ?? []
        } catch {
            favoritesErrorMessage = "Favorites are unavailable right now."
        }
    }

    private func removeFavorites(at offsets: IndexSet) {
        let spotsToRemove = offsets.map { favoriteSpots[$0] }
        for spot in spotsToRemove {
            Task { await removeFavorite(spot) }
        }
    }

    @MainActor
    private func removeFavorite(_ spot: SpotOwner) async {
        guard let identifier = spot.identifier,
              !username.isEmpty,
              let password = account.password else {
            return
        }
        favoriteIDsBeingRemoved.insert(identifier)
        defer { favoriteIDsBeingRemoved.remove(identifier) }
        do {
            _ = try await removeFavoriteSpot(identifier, username, password)
            favoriteSpots.removeAll { $0.identifier == identifier }
        } catch {
            favoritesErrorMessage = "Couldn’t remove this favorite."
        }
    }

    @MainActor
    private func moveToFavorites(_ location: SavedMapLocation) async {
        guard !location.isPrimaryLocation,
              let spotID = location.spotID,
              !username.isEmpty,
              let password = account.password else {
            return
        }
        favoriteIDsBeingAdded.insert(spotID)
        defer { favoriteIDsBeingAdded.remove(spotID) }
        do {
            _ = try await addFavoriteSpot(spotID, username, password)
            savedLocations.removeAll { $0.id == location.id }
            saveLocations()
            await loadFavorites()
        } catch {
            favoritesErrorMessage = "Couldn’t add this spot to Favorites."
        }
    }

    @MainActor
    private func searchCurrentLocation() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let location = try await CurrentLocationProvider().location()
            if purpose == .chooseLocation, isProUser,
               !username.isEmpty,
               account.password != nil {
                onCoordinateSelected(location.coordinate, nil)
                return
            }
            guard let searchTerm = try await searchTerm(for: location) else {
                throw DeviceLocationError.noPlacemark
            }
            query = searchTerm
            spots = try await searchSpots(searchTerm)?.allSpots ?? []
            guard let closestSpot = spots.first else { throw DeviceLocationError.noWindguruSpot }
            await selectSpot(closestSpot)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func search() async {
        let searchTerm = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !searchTerm.isEmpty else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            spots = try await searchSpots(searchTerm)?.allSpots ?? []
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func submitSearch() async {
        await search()
    }

    @MainActor
    private func openSpotID() async {
        let spotID = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !spotID.isEmpty, spotID.allSatisfy(\.isNumber) else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            guard let info = try await loadSpotInfo(spotID) else { throw DeviceLocationError.noWindguruSpot }
            if let coordinate = info.location?.coordinate {
                appendSavedLocation(SavedMapLocation(
                    name: info.name ?? "Windguru spot",
                    coordinate: coordinate,
                    spotID: spotID,
                    placeDescription: info.countryName
                ))
            }
            if purpose == .addFavorite {
                guard let spot = try SpotOwner(map: [
                    "id_spot": spotID,
                    "spotname": info.name ?? "Windguru spot",
                    "country": info.countryName ?? ""
                ]) else { throw DeviceLocationError.noWindguruSpot }
                await addFavorite(spot)
            } else {
                onSpotIDSelected(spotID)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func selectSavedLocation(_ location: SavedMapLocation) {
        if let spotID = location.spotID, spotID != "0" {
            onSpotIDSelected(spotID)
        } else {
            onCoordinateSelected(
                location.coordinate,
                location.placeDescription?.isEmpty == false ? location.placeDescription : location.name
            )
        }
    }

    @MainActor
    private func selectMapCoordinate(_ coordinate: CLLocationCoordinate2D) async {
        if purpose == .chooseLocation, isProUser,
           !username.isEmpty,
           account.password != nil {
            onCoordinateSelected(coordinate, nil)
            return
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            guard let term = try await searchTerm(for: location) else { throw DeviceLocationError.noPlacemark }
            guard let spot = try await spotForMapCoordinate(coordinate, placeName: term) else {
                throw DeviceLocationError.noWindguruSpot
            }
            await selectSpot(spot)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func saveMapCoordinate(_ coordinate: CLLocationCoordinate2D) async {
        var name = "Selected map location"
        var resolvedPlaceDescription: String?
        var spotID: String?
        var savedCoordinate = coordinate
        do {
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            resolvedPlaceDescription = try await placeDescription(for: location)
            guard let term = try await searchTerm(for: location) else { return }
            if let spot = try await spotForMapCoordinate(coordinate, placeName: term) {
                name = spot.name ?? name
                spotID = spot.identifier
                resolvedPlaceDescription = spot.countryName ?? resolvedPlaceDescription
                if let spotID,
                   let spotCoordinate = try await loadSpotInfo(spotID)?.location?.coordinate {
                    savedCoordinate = spotCoordinate
                }
            }
        } catch {
            // The coordinate remains usable even if a public spot cannot be resolved.
        }
        let isCoordinateOnly = spotID == nil || spotID == "0"
        let savedLocation = SavedMapLocation(
            name: isCoordinateOnly ? (resolvedPlaceDescription ?? name) : name,
            coordinate: savedCoordinate,
            spotID: isCoordinateOnly ? nil : spotID,
            placeDescription: isCoordinateOnly ? nil : resolvedPlaceDescription
        )
        appendSavedLocation(savedLocation)

        // A picked place should behave exactly like a searched place: keep it
        // in Map Locations and immediately make it the dashboard location.
        if let spotID, spotID != "0" {
            onSpotIDSelected(spotID)
        } else {
            onCoordinateSelected(
                savedLocation.coordinate,
                savedLocation.placeDescription?.isEmpty == false
                    ? savedLocation.placeDescription
                    : savedLocation.name
            )
        }
    }

    @MainActor
    private func selectSpot(_ spot: SpotOwner) async {
        if purpose == .addFavorite {
            await addFavorite(spot)
            return
        }

        if let identifier = spot.identifier,
           let spotInfo = try? await loadSpotInfo(identifier),
           let coordinate = spotInfo.location?.coordinate {
            appendSavedLocation(SavedMapLocation(
                name: spot.name ?? "Windguru spot",
                coordinate: coordinate,
                spotID: identifier,
                placeDescription: spot.countryName
            ))
        }
        onSpotSelected(spot)
    }

    @MainActor
    private func addFavorite(_ spot: SpotOwner) async {
        guard let spotID = spot.identifier,
              !username.isEmpty,
              let password = account.password else {
            errorMessage = "Sign in to add Windguru favorites."
            return
        }

        favoriteIDsBeingAdded.insert(spotID)
        defer { favoriteIDsBeingAdded.remove(spotID) }
        do {
            _ = try await addFavoriteSpot(spotID, username, password)
            onFavoriteAdded()
            dismiss()
        } catch {
            errorMessage = "Couldn’t add this spot to Favorites."
        }
    }

    private func beginRenaming(_ location: SavedMapLocation) {
        locationToRename = location
        renamedLocation = location.name
    }

    private func renameLocation() {
        guard let locationToRename,
              let index = savedLocations.firstIndex(where: { $0.id == locationToRename.id }) else { return }
        savedLocations[index].name = renamedLocation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? locationToRename.name : renamedLocation
        self.locationToRename = nil
        saveLocations()
    }

    private func delete(_ offsets: IndexSet) {
        let idsToDelete = Set(offsets.map { savedLocations[$0].id })
        savedLocations.removeAll { idsToDelete.contains($0.id) && !$0.isPrimaryLocation }
        saveLocations()
    }

    private func delete(_ location: SavedMapLocation) {
        guard !location.isPrimaryLocation else { return }
        savedLocations.removeAll { $0.id == location.id }
        saveLocations()
    }

    private func move(from source: IndexSet, to destination: Int) {
        savedLocations.move(fromOffsets: source, toOffset: destination)
        saveLocations()
    }

    private func saveLocations() {
        SavedMapLocationStore.save(savedLocations)
        savedLocations = SavedMapLocationStore.load()
    }

    private func appendSavedLocation(_ location: SavedMapLocation) {
        guard !savedLocations.contains(where: { SavedMapLocationStore.isSameLocation($0, location) }) else { return }
        savedLocations.append(location)
        saveLocations()
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
    private func spotForMapCoordinate(
        _ coordinate: CLLocationCoordinate2D,
        placeName: String
    ) async throws -> SpotOwner? {
        // A named place is the most useful Windguru lookup (for example,
        // "South Brisbane"). Only use coordinates when that lookup has no
        // results, since the API can return unrelated results for a lat/lon
        // text query.
        let placeMatches = (try? await searchSpots(placeName))?.allSpots ?? []
        let matches: [SpotOwner]
        if placeMatches.isEmpty {
            let coordinateQuery = "\(coordinate.latitude),\(coordinate.longitude)"
            matches = (try? await searchSpots(coordinateQuery))?.allSpots ?? []
        } else {
            matches = placeMatches
        }

        var nearest: (spot: SpotOwner, distance: CLLocationDistance)?
        for spot in matches.prefix(12) {
            guard let spotID = spot.identifier,
                  let spotCoordinate = try? await loadSpotInfo(spotID)?.location?.coordinate else {
                continue
            }
            let distance = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                .distance(from: CLLocation(latitude: spotCoordinate.latitude, longitude: spotCoordinate.longitude))
            if nearest == nil || distance < nearest!.distance {
                nearest = (spot, distance)
            }
        }
        return nearest?.spot ?? bestSpot(in: matches, matching: placeName)
    }

    private func bestSpot(in spots: [SpotOwner], matching searchTerm: String) -> SpotOwner? {
        let normalizedTerm = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return spots.first(where: {
            $0.name?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == normalizedTerm
        }) ?? spots.first
    }

    private func searchTerm(for location: CLLocation) async throws -> String? {
        guard let request = MKReverseGeocodingRequest(location: location),
              let mapItem = try await request.mapItems.first else {
            return nil
        }
        return mapItem.address?.shortAddress
            ?? mapItem.addressRepresentations?.cityName
            ?? mapItem.address?.fullAddress
    }

    private func placeDescription(for location: CLLocation) async throws -> String? {
        guard let request = MKReverseGeocodingRequest(location: location),
              let mapItem = try await request.mapItems.first else {
            return nil
        }
        return mapItem.address?.fullAddress
            ?? mapItem.address?.shortAddress
            ?? mapItem.addressRepresentations?.cityName
    }
}

@MainActor
private final class CurrentLocationProvider: NSObject, @preconcurrency CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Error>?

    override init() {
        super.init()
        manager.delegate = self
    }

    func location() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            requestLocationIfAuthorized()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        requestLocationIfAuthorized()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        finish(with: .success(locations.last ?? locations[0]))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        finish(with: .failure(error))
    }

    private func requestLocationIfAuthorized() {
        guard continuation != nil else { return }
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        case .denied, .restricted:
            finish(with: .failure(DeviceLocationError.permissionDenied))
        @unknown default:
            finish(with: .failure(DeviceLocationError.permissionDenied))
        }
    }

    private func finish(with result: Result<CLLocation, Error>) {
        guard let continuation else { return }
        self.continuation = nil
        continuation.resume(with: result)
    }
}

private enum DeviceLocationError: LocalizedError {
    case permissionDenied
    case noPlacemark
    case noWindguruSpot

    var errorDescription: String? {
        switch self {
        case .permissionDenied: "Allow location access to use the Device's current location."
        case .noPlacemark: "The current coordinate could not be resolved to a city."
        case .noWindguruSpot: "Windguru has no public spot matching this location."
        }
    }
}

#Preview("Windguru spot picker") {
    WindguruSpotPicker(
        forecastService: ForecastWindguruMockup(),
        account: WindguruAccount(),
        onSpotSelected: { _ in },
        onCoordinateSelected: { _, _ in }
    )
}

#if !os(tvOS)
#Preview("Map location picker") {
    MapLocationPicker(onSelection: { _ in })
}
#endif
#endif
