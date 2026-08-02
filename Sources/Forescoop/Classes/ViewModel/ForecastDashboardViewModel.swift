//
//  ForecastDashboardViewModel.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 07/30/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if !os(watchOS)
import Combine
import CoreLocation
import Foundation

/// Owns dashboard domain state that is independent of SwiftUI presentation.
///
/// Forecast loading will move here incrementally; profile loading is the first
/// migrated workflow so views no longer perform account service calls directly.
@MainActor
public final class ForecastDashboardViewModel: ObservableObject {
    @Published public private(set) var userProfile: User?
    @Published var forecast: SpotForecast?
    @Published var coordinateLocationName: String?
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var selectedHour: String?
    @Published var selectedModelIDs = [String]()
    @Published var usableModelIDs = [String]()
    @Published var displayedForecastSpotID: String?
    @Published var modelIDsBySpot = [String: [String]]()
    @Published var selectedModelIDsBySpot = [String: [String]]()
    @Published var modelNamesByID = [String: String]()
    @Published var displayedModelForecasts = [SpotForecast]()
    @Published var savedMapLocations = SavedMapLocationStore.load()
    @Published var temperatureUnit: TemperatureUnit
    @Published var windSpeedUnit: WindSpeedUnit
    @Published var waveHeightUnit: WaveHeightUnit
    @Published var pressureUnit: PressureUnit
    @Published var precipitationUnit: PrecipitationUnit
    @Published var freezingLevelUnit: FreezingLevelUnit

    private let profileLoader: @MainActor (String, String) async throws -> User?
    private let preferencesProvider: any ForecastPreferencesProviding
    private let forecastLoader: @MainActor (String, String?) async throws -> SpotForecast?
    private let proSpotForecastLoader: @MainActor (String, String?, String, String) async throws -> SpotForecast?
    private let coordinateForecastLoader: @MainActor (Double, Double, String?, String, String) async throws -> WSpotForecast?
    private let spotInfoLoader: @MainActor (String) async throws -> SpotInfo?
    private let coordinateModelLoader: @MainActor (Double, Double) async throws -> [String]
    private let modelInfoLoader: @MainActor () async throws -> Models?

    public var deviceUnitPreferences: ForecastUnitPreferences {
        preferencesProvider.forecastUnitPreferences
    }

    public init(
        forecastService: ForecastWindguruProtocol = ForecastWindguruService(),
        preferencesProvider: any ForecastPreferencesProviding = DeviceForecastPreferenceProvider()
    ) {
        self.preferencesProvider = preferencesProvider
        let unitPreferences = preferencesProvider.forecastUnitPreferences
        temperatureUnit = unitPreferences.temperatureUnit
        windSpeedUnit = unitPreferences.windSpeedUnit
        waveHeightUnit = unitPreferences.waveHeightUnit
        pressureUnit = unitPreferences.pressureUnit
        precipitationUnit = unitPreferences.precipitationUnit
        freezingLevelUnit = unitPreferences.freezingLevelUnit
        profileLoader = { try await forecastService.login(withUsername: $0, password: $1) }
        forecastLoader = { try await forecastService.forecast(bySpotId: $0, model: $1) }
        proSpotForecastLoader = { spotID, modelID, username, password in
            guard let forecast = try await forecastService.wforecast(
                bySpotId: spotID,
                model: modelID,
                username: username,
                password: password
            ) else { return nil }
            return try SpotForecast.from(coordinateForecast: forecast)
        }
        coordinateForecastLoader = {
            try await forecastService.wforecast(byLatitude: $0, longitude: $1, model: $2, username: $3, password: $4)
        }
        spotInfoLoader = { try await forecastService.spotInfo(bySpotId: $0) }
        coordinateModelLoader = { latitude, longitude in
            let response = try await forecastService.models(bylat: String(latitude), lon: String(longitude))
            guard let response,
                  let data = response.data(using: .utf8),
                  let identifiers = try? JSONSerialization.jsonObject(with: data) as? [Int] else {
                return []
            }
            return identifiers.map(String.init)
        }
        modelInfoLoader = { try await forecastService.modelInfo(onlyModelId: nil) }
    }

    public func loadUserProfile(username: String, password: String) async -> User? {
        guard !username.isEmpty else { return nil }
        return try? await profileLoader(username, password)
    }

    public func applyUserProfile(_ profile: User) {
        userProfile = profile
        if let unit = WindSpeedUnit(windguruPreference: profile.windUnits) {
            windSpeedUnit = unit
        }
        if let unit = TemperatureUnit(windguruPreference: profile.temperatureUnits) {
            temperatureUnit = unit
        }
        if let unit = WaveHeightUnit(windguruPreference: profile.waveUnits) {
            waveHeightUnit = unit
        }
    }

    public func applyDeviceUnitPreferences() {
        let preferences = preferencesProvider.forecastUnitPreferences
        temperatureUnit = preferences.temperatureUnit
        windSpeedUnit = preferences.windSpeedUnit
        waveHeightUnit = preferences.waveHeightUnit
        pressureUnit = preferences.pressureUnit
        precipitationUnit = preferences.precipitationUnit
        freezingLevelUnit = preferences.freezingLevelUnit
    }

    public func clearUserProfile() {
        userProfile = nil
    }

    /// Clears forecast data scoped to the prior Windguru session or spot.
    func resetSessionForecastState() {
        selectedModelIDs = []
        usableModelIDs = []
        displayedForecastSpotID = nil
        modelIDsBySpot = [:]
        selectedModelIDsBySpot = [:]
        modelNamesByID = [:]
        displayedModelForecasts = []
        userProfile = nil
        selectedHour = nil
        forecast = nil
        coordinateLocationName = nil
        errorMessage = nil
    }

    func clearPersistedSessionData() {
        savedMapLocations = SavedMapLocationStore.clearSessionData()
    }

    /// Sets deterministic, already-loaded content for an Xcode preview.
    /// Preview rendering must not depend on credentials or network requests.
    func usePreviewForecast(_ forecast: SpotForecast, spotID: String) {
        self.forecast = forecast
        coordinateLocationName = nil
        errorMessage = nil
        isLoading = false
        displayedForecastSpotID = spotID

        let modelIDs = [forecast.model ?? Model.defaultModel]
        displayedModelForecasts = [forecast]
        usableModelIDs = modelIDs
        selectedModelIDs = modelIDs
        modelIDsBySpot[spotID] = modelIDs
        selectedModelIDsBySpot[spotID] = modelIDs
        selectedHour = closestHour(to: Date(), in: forecast)
    }

    func loadModelNames(for modelIDs: [String]) async {
        let missingModelIDs = modelIDs.filter { modelNamesByID[$0] == nil }
        guard !missingModelIDs.isEmpty,
              let models = try? await modelInfoLoader() else { return }

        let names = models.sorted.reduce(into: [String: String]()) { names, model in
            let identifier = String(model.identifier)
            guard modelIDs.contains(identifier) else { return }
            names[identifier] = model.oficinalName ?? model.shortName ?? "Model \(identifier)"
        }
        modelNamesByID.merge(names) { _, newValue in newValue }
    }

    @discardableResult
    func loadForecast(
        spotID: String,
        modelIDs: [String]? = nil,
        isChangingSpot: Bool,
        persistSelection: Bool,
        account: WindguruAccount
    ) async -> Bool {
        coordinateLocationName = nil
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            if isChangingSpot, persistSelection {
                selectedModelIDs = []
                usableModelIDs = []
            }
            let configuredModelIDs = modelIDs ?? (isChangingSpot ? [] : selectedModelIDs)
            let isDiscoveringSpotModels = configuredModelIDs.isEmpty
            let requestedModelIDs: [String]
            if configuredModelIDs.isEmpty {
                let spotInfo = try await spotInfoLoader(spotID)
                let spotModelIDs = spotInfo?.currentModels.map(String.init) ?? []
                if account.isProUser,
                   account.isAuthenticated,
                   let coordinate = spotInfo?.location?.coordinate {
                    let coordinateModelIDs = (try? await loadModelIDs(
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude
                    )) ?? []
                    requestedModelIDs = orderedUnique(coordinateModelIDs + spotModelIDs)
                } else {
                    requestedModelIDs = spotModelIDs
                }
            } else {
                requestedModelIDs = configuredModelIDs
            }

            let selectedForecastLoader: @MainActor (String?) async throws -> SpotForecast?
            if account.isProUser,
               account.isAuthenticated,
               let password = account.password,
               !account.username.isEmpty {
                selectedForecastLoader = { modelID in
                    try await self.proSpotForecastLoader(spotID, modelID, account.username, password)
                }
            } else {
                selectedForecastLoader = { modelID in
                    try await self.forecastLoader(spotID, modelID)
                }
            }

            var validForecasts = [SpotForecast]()
            var lastModelError: Error?
            for modelID in requestedModelIDs {
                do {
                    if let loadedForecast = try await selectedForecastLoader(modelID),
                       !loadedForecast.availableForecastHours.isEmpty {
                        validForecasts.append(loadedForecast)
                    }
                } catch {
                    lastModelError = error
                }
            }

            if validForecasts.isEmpty, configuredModelIDs.isEmpty,
               let loadedForecast = try await selectedForecastLoader(nil),
               !loadedForecast.availableForecastHours.isEmpty {
                forecast = loadedForecast
            } else if validForecasts.count == 1 {
                forecast = validForecasts[0]
            } else if validForecasts.count > 1 {
                forecast = try SpotForecast.blended(validForecasts)
            } else if configuredModelIDs.isEmpty {
                guard let loadedForecast = try await selectedForecastLoader(nil),
                      !loadedForecast.availableForecastHours.isEmpty else {
                    throw lastModelError ?? CustomError.unexpected(
                        code: nil,
                        message: "Windguru returned no usable forecast hours."
                    )
                }
                forecast = loadedForecast
            } else {
                throw lastModelError ?? CustomError.notMappeable
            }

            guard let forecast else { return false }
            displayedModelForecasts = validForecasts.isEmpty ? [forecast] : validForecasts
            let loadedModelIDs = validForecasts.compactMap(\.model)
            let currentSpotModelIDs = loadedModelIDs.isEmpty
                ? [forecast.model ?? Model.defaultModel]
                : loadedModelIDs
            displayedForecastSpotID = spotID
            if isDiscoveringSpotModels || modelIDsBySpot[spotID] == nil {
                modelIDsBySpot[spotID] = currentSpotModelIDs
            }
            selectedModelIDsBySpot[spotID] = currentSpotModelIDs
            if persistSelection {
                usableModelIDs = currentSpotModelIDs
                selectedModelIDs = currentSpotModelIDs
            }
            selectedHour = closestHour(to: Date(), in: forecast)
            return true
        } catch {
            errorMessage = forecastErrorMessage(for: error)
            return false
        }
    }

    func loadCoordinateForecast(
        coordinate: CLLocationCoordinate2D,
        locationName: String? = nil,
        modelIDs: [String]? = nil,
        account: WindguruAccount
    ) async {
        guard account.isProUser,
              account.isAuthenticated,
              let password = account.password,
              !account.username.isEmpty else {
            errorMessage = "Sign in with Windguru PRO to load an exact map coordinate."
            return
        }

        isLoading = true
        errorMessage = nil
        coordinateLocationName = locationName
        displayedForecastSpotID = nil
        defer { isLoading = false }

        do {
            let discoveredModelIDs = try await loadModelIDs(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let requestedModelIDs = modelIDs ?? (discoveredModelIDs.isEmpty ? [Model.defaultModel] : discoveredModelIDs)
            var coordinateForecasts = [SpotForecast]()
            var lastModelError: Error?
            for modelID in requestedModelIDs {
                do {
                    guard let coordinateForecast = try await coordinateForecastLoader(
                        coordinate.latitude,
                        coordinate.longitude,
                        modelID,
                        account.username,
                        password
                    ), let convertedForecast = try SpotForecast.from(coordinateForecast: coordinateForecast) else {
                        continue
                    }
                    coordinateForecasts.append(convertedForecast)
                } catch {
                    lastModelError = error
                }
            }
            guard !coordinateForecasts.isEmpty else { throw lastModelError ?? CustomError.notMappeable }
            forecast = coordinateForecasts.count == 1
                ? coordinateForecasts[0]
                : try SpotForecast.blended(coordinateForecasts)
            displayedModelForecasts = coordinateForecasts
            selectedModelIDs = coordinateForecasts.compactMap(\.model)
            usableModelIDs = selectedModelIDs
            selectedHour = forecast.flatMap { closestHour(to: Date(), in: $0) }
        } catch {
            errorMessage = forecastErrorMessage(for: error)
        }
    }

    func forecastErrorMessage(for error: Error) -> String {
#if DEBUG
        let nsError = error as NSError
        var details = [
            String(reflecting: error),
            "Domain: \(nsError.domain)",
            "Code: \(nsError.code)"
        ]
        if !error.localizedDescription.isEmpty { details.append("Description: \(error.localizedDescription)") }
        if !nsError.userInfo.isEmpty { details.append("Details: \(nsError.userInfo)") }
        return details.joined(separator: "\n")
#else
        return ""
#endif
    }

    private func loadModelIDs(latitude: Double, longitude: Double) async throws -> [String] {
        try await coordinateModelLoader(latitude, longitude)
    }

    private func closestHour(to date: Date, in forecast: SpotForecast) -> String? {
        forecast.availableForecastHours.last(where: {
            (forecast.forecastDate(hour: $0) ?? .distantFuture) <= date
        }) ?? forecast.availableForecastHours.first
    }

    private func orderedUnique(_ modelIDs: [String]) -> [String] {
        var seen = Set<String>()
        return modelIDs.filter { seen.insert($0).inserted }
    }
}
#endif
