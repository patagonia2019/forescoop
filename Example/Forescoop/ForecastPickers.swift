//
//  ForecastPickers.swift
//  Forescoop
//
//  Created by Javier Fuchs on 07/22/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

import CoreLocation
import Security
import SwiftUI
import Forescoop

private struct ForecastModelOption: Identifiable {
    let identifier: String
    let name: String

    var id: String { identifier }
}

struct ForecastModelPicker: View {
    let forecastService: ForecastWindguruProtocol
    let spotID: String
    let selectedModelIDs: Set<String>
    let onModelSelected: ([String]) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var models: [ForecastModelOption] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedIDs: Set<String> = []

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading forecast models…")
                } else if let errorMessage {
                    ContentUnavailableView("Models unavailable", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
                } else if models.isEmpty {
                    ContentUnavailableView("No forecast models", systemImage: "cpu")
                } else {
                    List(models) { model in
                        Button {
                            toggle(model.identifier)
                        } label: {
                            HStack {
                                Image(systemName: selectedIDs.contains(model.identifier) ? "checkmark.square.fill" : "square")
                                Text(model.name)
                                Spacer()
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
            .navigationTitle("Forecast model")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") { onModelSelected(selectedIDs.sorted()) }
                        .disabled(selectedIDs.isEmpty)
                }
            }
            .task {
                selectedIDs = selectedModelIDs
                await loadModels()
            }
        }
    }

    private func toggle(_ identifier: String) {
        if selectedIDs.contains(identifier) {
            selectedIDs.remove(identifier)
        } else {
            selectedIDs.insert(identifier)
        }
    }

    @MainActor
    private func loadModels() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let spotInfo = try await forecastService.spotInfo(bySpotId: spotID)
            let modelInfo = try await forecastService.modelInfo(onlyModelId: nil)
            let availableModelIDs = Set(spotInfo?.currentModels.map(String.init) ?? [])
            let availableModels = modelInfo?.sorted ?? []
            models = availableModels.compactMap { model in
                let identifier = String(model.identifier)
                guard availableModelIDs.contains(identifier) else { return nil }
                return ForecastModelOption(identifier: identifier, name: model.oficinalName ?? model.shortName ?? "Model \(identifier)")
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct WindguruLoginView: View {
    let forecastService: ForecastWindguruProtocol
    let username: String
    let onLoggedIn: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var enteredUsername = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Windguru PRO") {
                    TextField("Username", text: $enteredUsername)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    SecureField("Password", text: $password)
                }
                if let errorMessage {
                    Section { Text(errorMessage).foregroundStyle(.red) }
                }
            }
            .navigationTitle("Windguru Login")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Login") { Task { await login() } }
                        .disabled(enteredUsername.isEmpty || password.isEmpty || isLoading)
                }
            }
            .onAppear {
                enteredUsername = username
                password = WindguruCredentialStore.password(for: username) ?? ""
            }
            .overlay { if isLoading { ProgressView("Signing in…") } }
        }
    }

    @MainActor
    private func login() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            guard let user = try await forecastService.login(withUsername: enteredUsername, password: password), user.isPro else {
                throw LoginError.proRequired
            }
            try WindguruCredentialStore.save(password: password, for: enteredUsername)
            onLoggedIn(enteredUsername)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private enum LoginError: LocalizedError {
    case proRequired
    var errorDescription: String? { "A Windguru PRO account is required for coordinate forecasts." }
}

private enum WindguruCredentialStore {
    static func password(for username: String) -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: "Forescoop.Windguru",
                                    kSecAttrAccount as String: username,
                                    kSecReturnData as String: true]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func save(password: String, for username: String) throws {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: "Forescoop.Windguru",
                                    kSecAttrAccount as String: username]
        let attributes = [kSecValueData as String: Data(password.utf8)]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            var item = query
            item[kSecValueData as String] = Data(password.utf8)
            guard SecItemAdd(item as CFDictionary, nil) == errSecSuccess else { throw LoginError.proRequired }
        } else if status != errSecSuccess {
            throw LoginError.proRequired
        }
    }
}

struct WindguruSpotPicker: View {
    let forecastService: ForecastWindguruProtocol
    let onSpotSelected: (SpotOwner) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var spots: [SpotOwner] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button("Use Current Location", systemImage: "location.fill") {
                        Task { await searchCurrentLocation() }
                    }
                    .disabled(isLoading)
                } footer: {
                    Text("Uses the nearest matching public Windguru spot for the Simulator location.")
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
        case .permissionDenied: "Allow location access to use the Simulator's current location."
        case .noPlacemark: "The current coordinate could not be resolved to a city."
        case .noWindguruSpot: "Windguru has no public spot matching this location."
        }
    }
}

#Preview("Forecast model picker") {
    ForecastModelPicker(
        forecastService: ForecastWindguruMockup(),
        spotID: "64141",
        selectedModelIDs: [],
        onModelSelected: { _ in }
    )
}

#Preview("Windguru spot picker") {
    WindguruSpotPicker(
        forecastService: ForecastWindguruMockup(),
        onSpotSelected: { _ in }
    )
}
