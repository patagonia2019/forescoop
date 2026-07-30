//
//  ForecastDashboardViewModel.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 07/30/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if !os(watchOS)
import Combine
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
}
#endif
