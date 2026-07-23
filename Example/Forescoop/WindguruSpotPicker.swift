//
//  WindguruSpotPicker.swift
//  Forescoop
//
//  Created by Javier on 23/07/2026.
//  Copyright © 2026 Forescoop. All rights reserved.

import CoreLocation
import MapKit
import SwiftUI
import Forescoop

struct WindguruSpotPicker: View {
    let forecastService: ForecastWindguruProtocol
    let username: String
    let onSpotSelected: (SpotOwner) -> Void
    let onCoordinateSelected: (CLLocationCoordinate2D) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var spots: [SpotOwner] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showsMap = false

    var body: some View {
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

                Section("Search Windguru spots") {
                    HStack {
                        TextField("City or spot", text: $query)
                            .textInputAutocapitalization(.words)
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
                                onSpotSelected(spot)
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
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .sheet(isPresented: $showsMap) {
            MapLocationPicker { coordinate in
                showsMap = false
                Task { await selectMapCoordinate(coordinate) }
            }
        }
    }

    @MainActor
    private func searchCurrentLocation() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let location = try await CurrentLocationProvider().location()
            let placemark = try await CLGeocoder().reverseGeocodeLocation(location).first
            guard let searchTerm = placemark?.locality ?? placemark?.administrativeArea else {
                throw DeviceLocationError.noPlacemark
            }
            query = searchTerm
            spots = try await forecastService.searchSpots(byLocation: searchTerm)?.allSpots ?? []
            guard let closestSpot = spots.first else { throw DeviceLocationError.noWindguruSpot }
            onSpotSelected(closestSpot)
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
            spots = try await forecastService.searchSpots(byLocation: searchTerm)?.allSpots ?? []
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
            guard let spot = try await forecastService.searchSpots(byLocation: term)?.allSpots.first else {
                throw DeviceLocationError.noWindguruSpot
            }
            onSpotSelected(spot)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct MapLocationPicker: View {
    let onSelection: (CLLocationCoordinate2D) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        NavigationStack {
            MapReader { proxy in
                Map(position: $position) {
                    if let selectedCoordinate {
                        Marker("Selected location", coordinate: selectedCoordinate)
                    }
                }
                .onTapGesture { point in
                    selectedCoordinate = proxy.convert(point, from: .local)
                }
            }
            .navigationTitle("Pick location")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Use Location") {
                        if let selectedCoordinate { onSelection(selectedCoordinate) }
                    }
                    .disabled(selectedCoordinate == nil)
                }
            }
        }
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
