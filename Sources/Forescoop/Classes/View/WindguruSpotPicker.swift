//
//  WindguruSpotPicker.swift
//  Forescoop
//
//  Created by Javier on 23/07/2026.
//  Copyright © 2026 Forescoop. All rights reserved.

#if !os(watchOS)
import CoreLocation
import MapKit
import SwiftUI

public struct WindguruSpotPicker: View {
    private let searchSpots: @MainActor (String) async throws -> SpotResult?
    private let loadSpotInfo: @MainActor (String) async throws -> SpotInfo?
    let username: String
    let onSpotSelected: (SpotOwner) -> Void
    let onCoordinateSelected: (CLLocationCoordinate2D) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var spots: [SpotOwner] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showsMap = false
    @State private var savedLocations = SavedMapLocationStore.load()
    @State private var locationToRename: SavedMapLocation?
    @State private var renamedLocation = ""
#if !os(macOS)
    @State private var editMode: EditMode = .inactive
#endif

    public init(
        forecastService: ForecastWindguruProtocol,
        username: String,
        onSpotSelected: @escaping (SpotOwner) -> Void,
        onCoordinateSelected: @escaping (CLLocationCoordinate2D) -> Void
    ) {
        searchSpots = { try await forecastService.searchSpots(byLocation: $0) }
        loadSpotInfo = { try await forecastService.spotInfo(bySpotId: $0) }
        self.username = username
        self.onSpotSelected = onSpotSelected
        self.onCoordinateSelected = onCoordinateSelected
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
                    Button("Pick on Map", systemImage: "map") {
                        showsMap = true
                    }
                } footer: {
                    Text("Map picks use an exact coordinate forecast for Windguru PRO, or the nearest public spot for guests.")
                }

                mapLocationsSection

                Section("Search Windguru spots") {
                    HStack {
                        TextField("City or spot", text: $query)
#if !os(macOS)
                            .textInputAutocapitalization(.words)
#endif
                            .onSubmit { Task { await search() } }
                        Button("Search") { Task { await search() } }
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
                                    Text(spot.name ?? "Unknown spot")
                                    Text(spot.countryName ?? "")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Choose location")
#if !os(macOS)
            .environment(\.editMode, $editMode)
#endif
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
        }
        .sheet(isPresented: $showsMap) {
            MapLocationPicker(initialCoordinate: lastSavedCoordinate) { coordinate in
                showsMap = false
                Task { await saveMapCoordinate(coordinate) }
            }
        }
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
        if !savedLocations.isEmpty {
            Section("Map locations") {
                ForEach(savedLocations) { location in
                    savedLocationRow(location)
                }
                .onDelete(perform: delete)
                .onMove(perform: move)
            }
        }
    }

    private func savedLocationRow(_ location: SavedMapLocation) -> some View {
        HStack(spacing: 12) {
            Button {
                Task { await selectMapCoordinate(location.coordinate) }
            } label: {
                Label {
                    VStack(alignment: .leading) {
                        Text(location.name)
                        Text(location.coordinateText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "mappin.and.ellipse")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .buttonStyle(.plain)
            .disabled(isLoading)

#if !os(macOS)
            if editMode.isEditing {
                Button("Rename \(location.name)", systemImage: "pencil") {
                    beginRenaming(location)
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .accessibilityHint("Changes this saved location's name")
            }
#endif
        }
        .contextMenu {
            Button("Rename", systemImage: "pencil") { beginRenaming(location) }
            Button("Delete", systemImage: "trash", role: .destructive) { delete(location) }
        }
    }

    @MainActor
    private func searchCurrentLocation() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let location = try await CurrentLocationProvider().location()
            if !username.isEmpty, WindguruCredentialStore.password(for: username) != nil {
                onCoordinateSelected(location.coordinate)
                return
            }
            let placemark = try await CLGeocoder().reverseGeocodeLocation(location).first
            guard let searchTerm = placemark?.locality ?? placemark?.administrativeArea else {
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
    private func selectMapCoordinate(_ coordinate: CLLocationCoordinate2D) async {
        if !username.isEmpty, WindguruCredentialStore.password(for: username) != nil {
            onCoordinateSelected(coordinate)
            return
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let placemark = try await CLGeocoder().reverseGeocodeLocation(location).first
            guard let term = placemark?.locality ?? placemark?.administrativeArea else { throw DeviceLocationError.noPlacemark }
            guard let spot = try await searchSpots(term)?.allSpots.first else {
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
        do {
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let placemark = try await CLGeocoder().reverseGeocodeLocation(location).first
            guard let term = placemark?.locality ?? placemark?.administrativeArea else { return }
            name = try await searchSpots(term)?.allSpots.first?.name ?? name
        } catch {
            // The coordinate remains usable even if a public spot name cannot be resolved.
        }
        savedLocations.append(SavedMapLocation(name: name, coordinate: coordinate))
        saveLocations()
    }

    @MainActor
    private func selectSpot(_ spot: SpotOwner) async {
        if let identifier = spot.identifier,
           let spotInfo = try? await loadSpotInfo(identifier),
           let coordinate = spotInfo.location?.coordinate {
            let alreadySaved = savedLocations.contains {
                abs($0.latitude - coordinate.latitude) < 0.0001 && abs($0.longitude - coordinate.longitude) < 0.0001
            }
            if !alreadySaved {
                savedLocations.append(SavedMapLocation(name: spot.name ?? "Windguru spot", coordinate: coordinate, spotID: identifier))
                saveLocations()
            }
        }
        onSpotSelected(spot)
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
        savedLocations.remove(atOffsets: offsets)
        saveLocations()
    }

    private func delete(_ location: SavedMapLocation) {
        savedLocations.removeAll { $0.id == location.id }
        saveLocations()
    }

    private func move(from source: IndexSet, to destination: Int) {
        savedLocations.move(fromOffsets: source, toOffset: destination)
        saveLocations()
    }

    private func saveLocations() {
        SavedMapLocationStore.save(savedLocations)
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
        username: "",
        onSpotSelected: { _ in },
        onCoordinateSelected: { _ in }
    )
}

#Preview("Map location picker") {
    MapLocationPicker(onSelection: { _ in })
}
#endif
