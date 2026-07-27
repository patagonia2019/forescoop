//
//  ForecastDashboardView.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 07/22/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if !os(watchOS)
import CoreLocation
@preconcurrency import MapKit
import SwiftUI

@MainActor
public struct ForecastDashboardView: View {
    private let forecastService: ForecastWindguruProtocol
    private let forecastLoader: @MainActor (String, String?) async throws -> SpotForecast?
    private let proSpotForecastLoader: @MainActor (String, String?, String, String) async throws -> SpotForecast?
    private let coordinateForecastLoader: @MainActor (Double, Double, String?, String, String) async throws -> WSpotForecast?
    private let spotSearch: @MainActor (String) async throws -> SpotResult?
    private let profileLoader: @MainActor (String, String) async throws -> User?
    private let favoriteSpotsLoader: @MainActor (String, String) async throws -> SpotResult?
    private let spotInfoLoader: @MainActor (String) async throws -> SpotInfo?
    private let coordinateModelLoader: @MainActor (Double, Double) async throws -> [String]
#if !os(macOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
#endif
    @AppStorage("selectedWindguruSpotID") private var selectedSpotID = "64141"
    @AppStorage("windguruUsername") private var windguruUsername = ""
    @AppStorage("windguruIsProUser") private var windguruIsProUser = false
    @State private var forecast: SpotForecast?
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var selectedHour: String?
    @State private var temperatureUnit: TemperatureUnit = .celsius
    @State private var windSpeedUnit: WindSpeedUnit = .knots
    @AppStorage("windguruWaveHeightUnit") private var waveHeightUnit: WaveHeightUnit = .meters
    @State private var pressureUnit: PressureUnit = .hectopascals
    @State private var precipitationUnit: PrecipitationUnit = .millimeters
    @State private var freezingLevelUnit: FreezingLevelUnit = .meters
    @State private var showsWindDirectionArrow = false
    @State private var showsSpotPicker = false
    @State private var showsModelPicker = false
    @State private var showsLogin = false
    @State private var showsFavorites = false
    @State private var selectedModelIDs: [String] = []
    @State private var usableModelIDs: [String] = []
    @State private var displayedForecastSpotID: String?
    /// All models validated for each spot, independent of the current selection.
    @State private var modelIDsBySpot = [String: [String]]()
    @State private var selectedModelIDsBySpot = [String: [String]]()
    @State private var savedMapLocations = SavedMapLocationStore.load()
    @State private var iPadMapPosition: MapCameraPosition = .automatic
    @State private var selectedMapLocationID: SavedMapLocation.ID?

    public init(forecastService: ForecastWindguruProtocol = ForecastWindguruService()) {
        self.forecastService = forecastService
        forecastLoader = { try await forecastService.forecast(bySpotId: $0, model: $1) }
        proSpotForecastLoader = { spotID, modelID, username, password in
            guard let proForecast = try await forecastService.wforecast(
                bySpotId: spotID,
                model: modelID,
                username: username,
                password: password
            ) else {
                return nil
            }
            return try SpotForecast.from(coordinateForecast: proForecast)
        }
        coordinateForecastLoader = {
            try await forecastService.wforecast(byLatitude: $0, longitude: $1, model: $2, username: $3, password: $4)
        }
        spotSearch = { try await forecastService.searchSpots(byLocation: $0) }
        profileLoader = { try await forecastService.login(withUsername: $0, password: $1) }
        favoriteSpotsLoader = { try await forecastService.favoriteSpots(withUsername: $0, password: $1) }
        spotInfoLoader = { try await forecastService.spotInfo(bySpotId: $0) }
        coordinateModelLoader = { latitude, longitude in
            let response = try await forecastService.models(bylat: String(latitude), lon: String(longitude))
            return Self.modelIDs(from: response)
        }
    }

    private var usesWideLayout: Bool {
#if os(macOS)
        true
#else
        horizontalSizeClass == .regular
#endif
    }

    private var isProUser: Bool {
        windguruIsProUser
            && !windguruUsername.isEmpty
            && WindguruCredentialStore.password(for: windguruUsername) != nil
    }

    private var accountMenu: some View {
        Menu {
            if windguruUsername.isEmpty {
                Button("Login", systemImage: "person.crop.circle") {
                    showsLogin = true
                }
            } else {
                Button("Profile", systemImage: "person.crop.circle") {
                    showsLogin = true
                }

                Button("Favorites", systemImage: "star") {
                    showsFavorites = true
                }
            }

            if !windguruUsername.isEmpty {
                Divider()
                Button("Logout", systemImage: "rectangle.portrait.and.arrow.right", role: .destructive) {
                    logout()
                }
            }
        } label: {
            Label("Menu", systemImage: "line.3.horizontal")
                .labelStyle(.iconOnly)
        }
        .accessibilityLabel("Menu")
    }

    private func logout() {
        WindguruCredentialStore.removePassword(for: windguruUsername)
        windguruUsername = ""
        windguruIsProUser = false
        selectedSpotID = "64141"
        selectedModelIDs = []
        usableModelIDs = []
        displayedForecastSpotID = nil
        modelIDsBySpot = [:]
        selectedModelIDsBySpot = [:]
        selectedHour = nil
        forecast = nil
        errorMessage = nil
        savedMapLocations = []
        selectedMapLocationID = nil
        SavedMapLocationStore.removeAll()

        applyDevicePreferences()

        showsModelPicker = false
        showsLogin = false
        showsFavorites = false
        Task { await loadForecast() }
    }

    private func startSession(username: String, isProUser: Bool) {
        windguruUsername = username
        windguruIsProUser = isProUser
        // Do not reuse the previous session's model cache. A PRO session can
        // expose more models for the same spot, while a regular session must
        // return to the public forecast set.
        selectedModelIDs = []
        usableModelIDs = []
        displayedForecastSpotID = nil
        modelIDsBySpot = [:]
        selectedModelIDsBySpot = [:]
        selectedHour = nil
        forecast = nil
        errorMessage = nil
        showsLogin = false
        Task { await loadPreferredForecast() }
    }

    public var body: some View {
        NavigationStack {
            Group {
                if let forecast {
                    forecastContent(for: forecast)
                } else if isLoading {
                    ProgressView("Loading forecast…")
                } else if let errorMessage {
                    unavailableForecastContent(errorMessage: errorMessage)
                } else {
                    ContentUnavailableView("Forecast unavailable", systemImage: "cloud.sun")
                }
            }
            .navigationTitle("Forescoop")
            .toolbar {
#if os(macOS)
                ToolbarItem(placement: .navigation) {
                    accountMenu
                }
#else
                ToolbarItem(placement: .topBarLeading) {
                    accountMenu
                }
#endif
                ToolbarItem(placement: .primaryAction) {
                    Button("Refresh", systemImage: "arrow.clockwise") {
                        Task { await loadForecast() }
                    }
                }
            }
            .task {
                await loadUserPreferences()
                await loadPreferredForecast()
            }
            .sheet(isPresented: $showsSpotPicker, onDismiss: refreshSavedMapLocations) {
                WindguruSpotPicker(
                    forecastService: forecastService,
                    username: windguruUsername,
                    onSpotSelected: { spot in
                        guard let spotId = spot.identifier else { return }
                        showsSpotPicker = false
                        Task { await loadForecast(spotId: spotId) }
                    },
                    onFavoriteSelected: { spot in
                        guard let spotID = spot.identifier else { return }
                        showsSpotPicker = false
                        Task { await loadForecast(spotId: spotID, persistSelection: false) }
                    },
                    onCoordinateSelected: { coordinate in
                        showsSpotPicker = false
                        Task { await loadForecast(coordinate: coordinate) }
                    }
                )
            }
            .sheet(isPresented: $showsModelPicker) {
                let forecastSpotID = displayedForecastSpotID ?? selectedSpotID
                let availableModelIDs = modelIDsBySpot[forecastSpotID] ?? []
                let selectedForecastModelIDs = selectedModelIDsBySpot[forecastSpotID] ?? availableModelIDs
                ForecastModelPicker(
                    forecastService: forecastService,
                    spotID: forecastSpotID,
                    selectedModelIDs: Set(selectedForecastModelIDs),
                    usableModelIDs: Set(availableModelIDs),
                    isProUser: isProUser
                ) { modelIDs in
                    showsModelPicker = false
                    Task {
                        await loadForecast(
                            spotId: forecastSpotID,
                            modelIDs: modelIDs,
                            persistSelection: forecastSpotID == selectedSpotID
                        )
                    }
                }
            }
            .sheet(isPresented: $showsLogin) {
                WindguruLoginView(
                    forecastService: forecastService,
                    username: windguruUsername,
                    onLoggedIn: { username, isProUser in
                        if username.isEmpty {
                            logout()
                            return
                        }
                        startSession(username: username, isProUser: isProUser)
                    },
                    onProfileLoaded: applyUserPreferences
                )
            }
            .sheet(isPresented: $showsFavorites) {
                WindguruFavoritesView(
                    forecastService: forecastService,
                    username: windguruUsername
                )
            }
        }
    }

    private func forecastContent(for forecast: SpotForecast) -> some View {
        ScrollView {
            VStack(spacing: 28) {
                ForecastHourSelector(
                    forecast: forecast,
                    selectedHour: $selectedHour
                )

                if usesWideLayout {
                    HStack(alignment: .top, spacing: 56) {
                        ForecastOverview(forecast: forecast, selectedHour: selectedHour, temperatureUnit: $temperatureUnit, onSelectLocation: { showsSpotPicker = true }, onSelectModel: { showsModelPicker = true })
                            .frame(maxWidth: .infinity)

                        VStack(alignment: .leading, spacing: 28) {
                            ForecastWindDetails(forecast: forecast, selectedHour: selectedHour, windSpeedUnit: $windSpeedUnit, showsDirectionArrow: $showsWindDirectionArrow)
                            ForecastWeatherDetails(forecast: forecast, selectedHour: selectedHour, precipitationUnit: $precipitationUnit, freezingLevelUnit: $freezingLevelUnit, pressureUnit: $pressureUnit)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    iPadLocationWorkspace()
                } else {
                    VStack(spacing: 24) {
                        ForecastOverview(forecast: forecast, selectedHour: selectedHour, temperatureUnit: $temperatureUnit, onSelectLocation: { showsSpotPicker = true }, onSelectModel: { showsModelPicker = true })
                        ForecastWindDetails(forecast: forecast, selectedHour: selectedHour, windSpeedUnit: $windSpeedUnit, showsDirectionArrow: $showsWindDirectionArrow)
                        ForecastWeatherDetails(forecast: forecast, selectedHour: selectedHour, precipitationUnit: $precipitationUnit, freezingLevelUnit: $freezingLevelUnit, pressureUnit: $pressureUnit)
                    }
                }
            }
            .frame(maxWidth: 1_100)
            .padding()
        }
        .background {
            let hour = selectedHour ?? forecast.currentForecastHour
            AnimatedWeatherBackground(
                symbolNames: forecast.weatherSymbolNames(hour: hour),
                precipitationMillimeters: forecast.forecast?.precipitation(hh: hour)
                    ?? forecast.forecast?.precipitation1(hh: hour)
                    ?? 0,
                windSpeedKnots: forecast.forecast?.windSpeed(hh: hour) ?? 0,
                windDirectionDegrees: forecast.forecast?.windDirection(hh: hour),
                windGustKnots: forecast.forecast?.windGustsKnots(hh: hour) ?? 0,
                cloudCoverPercent: forecast.forecast?.cloudCoverTotal(hh: hour) ?? 0,
                temperatureCelsius: forecast.forecast?.temperatureReal(hh: hour)
                    ?? forecast.forecast?.temperature(hh: hour)
                    ?? 0,
                humidityPercent: forecast.forecast?.relativeHumidity(hh: hour) ?? 0,
                pressureHectopascals: forecast.forecast?.seaLevelPressure(hh: hour),
                forecastDate: forecast.forecastDate(hour: hour) ?? Date()
            )
                .ignoresSafeArea()
        }
    }

    private func iPadLocationWorkspace() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Choose location", systemImage: "mappin.and.ellipse")
                    .font(.title2.bold())
                Spacer()
                Button("Manage locations", systemImage: "slider.horizontal.3") {
                    showsSpotPicker = true
                }
            }

            Map(position: $iPadMapPosition, selection: $selectedMapLocationID) {
                ForEach(savedMapLocations) { location in
                    Marker(location.name, coordinate: location.coordinate)
                        .tag(location.id)
                }
            }
            .frame(height: 280)
            .clipShape(.rect(cornerRadius: 16))
            .onChange(of: selectedMapLocationID) { _, locationID in
                guard let locationID,
                      let location = savedMapLocations.first(where: { $0.id == locationID }) else { return }
                centerMap(on: location.coordinate)
                Task { await loadSavedLocation(location) }
            }

            if savedMapLocations.isEmpty {
                ContentUnavailableView("No saved locations", systemImage: "mappin.slash", description: Text("Use Manage locations to search, pick, and save a location."))
                    .frame(maxWidth: .infinity)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 12)], spacing: 12) {
                    ForEach(savedMapLocations) { location in
                        Button {
                            selectMapLocation(location)
                        } label: {
                            Label {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(location.displayName)
                                    Text(location.detailText)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            } icon: {
                                Image(systemName: "mappin.and.ellipse")
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(.thinMaterial, in: .rect(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.top, 8)
    }

    private func refreshSavedMapLocations() {
        savedMapLocations = SavedMapLocationStore.load()
    }

    private func centerMap(on coordinate: CLLocationCoordinate2D) {
        iPadMapPosition = .region(MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 3, longitudeDelta: 3)
        ))
    }

    private func selectMapLocation(_ location: SavedMapLocation) {
        centerMap(on: location.coordinate)
        if selectedMapLocationID == location.id {
            Task { await loadSavedLocation(location) }
        } else {
            selectedMapLocationID = location.id
        }
    }

    @MainActor
    private func loadSavedLocation(_ location: SavedMapLocation) async {
        if let spotID = location.spotID {
            await loadForecast(spotId: spotID)
            return
        }

        if !windguruUsername.isEmpty, WindguruCredentialStore.password(for: windguruUsername) != nil {
            await loadForecast(coordinate: location.coordinate)
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let clLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            guard let searchTerm = try await reverseGeocodedSearchTerm(for: clLocation) else {
                errorMessage = "The selected map location could not be identified."
                return
            }
            guard let spotID = try await spotSearch(searchTerm)?.allSpots.first?.identifier else {
                errorMessage = "No Windguru spot was found near the selected map location."
                return
            }
            await loadForecast(spotId: spotID)
        } catch {
            errorMessage = unavailableForecastMessage(for: error)
        }
    }

    private func reverseGeocodedSearchTerm(for location: CLLocation) async throws -> String? {
        guard let request = MKReverseGeocodingRequest(location: location),
              let mapItem = try await request.mapItems.first else {
            return nil
        }

        return mapItem.addressRepresentations?.cityName
            ?? mapItem.address?.shortAddress
            ?? mapItem.address?.fullAddress
    }

    @MainActor
    private func loadUserPreferences() async {
        guard !windguruUsername.isEmpty,
              let password = WindguruCredentialStore.password(for: windguruUsername),
              let user = try? await profileLoader(windguruUsername, password) else {
            applyDevicePreferences()
            return
        }
        windguruIsProUser = user.isPro
        applyUserPreferences(user)
    }

    private func applyUserPreferences(_ user: User) {
        if let unit = WindSpeedUnit(windguruPreference: user.windUnits) {
            windSpeedUnit = unit
        }
        if let unit = TemperatureUnit(windguruPreference: user.temperatureUnits) {
            temperatureUnit = unit
        }
        if let unit = WaveHeightUnit(windguruPreference: user.waveUnits) {
            waveHeightUnit = unit
        }
    }

    private func applyDevicePreferences() {
        temperatureUnit = DeviceForecastPreferences.temperatureUnit
        windSpeedUnit = DeviceForecastPreferences.windSpeedUnit
        waveHeightUnit = DeviceForecastPreferences.waveHeightUnit
        pressureUnit = DeviceForecastPreferences.pressureUnit
        precipitationUnit = DeviceForecastPreferences.precipitationUnit
        freezingLevelUnit = DeviceForecastPreferences.freezingLevelUnit
    }

    @MainActor
    private func loadPreferredForecast() async {
        let preferredSpotID: String
        if !windguruUsername.isEmpty,
           let password = WindguruCredentialStore.password(for: windguruUsername),
           let favoriteSpotID = try? await favoriteSpotsLoader(windguruUsername, password)?.allSpots.first?.identifier {
            preferredSpotID = favoriteSpotID
        } else {
            preferredSpotID = "64141"
        }
        await loadForecast(spotId: preferredSpotID, modelIDs: [])
    }

    @MainActor
    private func loadForecast(
        spotId: String? = nil,
        modelIDs: [String]? = nil,
        persistSelection: Bool = true
    ) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let requestedSpotID = spotId ?? selectedSpotID
            let isChangingSpot = requestedSpotID != selectedSpotID
            if isChangingSpot, persistSelection {
                // Model availability is scoped to a spot. Never let a prior
                // spot's cached model list drive the next spot's picker.
                selectedModelIDs = []
                usableModelIDs = []
            }
            let configuredModelIDs = modelIDs ?? (isChangingSpot ? [] : selectedModelIDs)
            let isDiscoveringSpotModels = configuredModelIDs.isEmpty
            let requestedModelIDs: [String]
            if configuredModelIDs.isEmpty {
                let spotInfo = try await spotInfoLoader(requestedSpotID)
                let spotModelIDs = spotInfo?.currentModels.map(String.init) ?? []
                if isProUser, let coordinate = spotInfo?.location?.coordinate {
                    let coordinateModelIDs = (try? await coordinateModelLoader(
                        coordinate.latitude,
                        coordinate.longitude
                    )) ?? []
                    requestedModelIDs = orderedUnique(coordinateModelIDs + spotModelIDs)
                } else {
                    requestedModelIDs = spotModelIDs
                }
            } else {
                requestedModelIDs = configuredModelIDs
            }
            let selectedForecastLoader: @MainActor (String?) async throws -> SpotForecast?
            if let password = WindguruCredentialStore.password(for: windguruUsername), !windguruUsername.isEmpty {
                selectedForecastLoader = { modelID in
                    try await proSpotForecastLoader(requestedSpotID, modelID, windguruUsername, password)
                }
            } else {
                selectedForecastLoader = { modelID in
                    try await forecastLoader(requestedSpotID, modelID)
                }
            }
            var validForecasts: [SpotForecast] = []
            var lastModelError: Error?
            for modelID in requestedModelIDs {
                do {
                    if let loadedForecast = try await selectedForecastLoader(modelID),
                       !loadedForecast.availableForecastHours.isEmpty {
                        validForecasts.append(loadedForecast)
                    }
                } catch {
                    // Models can be unavailable for a particular account or location.
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
            if forecast != nil {
                let loadedModelIDs = validForecasts.compactMap(\.model)
                let currentSpotModelIDs = loadedModelIDs.isEmpty
                    ? [forecast?.model ?? Model.defaultModel]
                    : loadedModelIDs
                displayedForecastSpotID = requestedSpotID
                if isDiscoveringSpotModels || modelIDsBySpot[requestedSpotID] == nil {
                    modelIDsBySpot[requestedSpotID] = currentSpotModelIDs
                }
                selectedModelIDsBySpot[requestedSpotID] = currentSpotModelIDs
                if persistSelection {
                    selectedSpotID = requestedSpotID
                    usableModelIDs = currentSpotModelIDs
                    selectedModelIDs = currentSpotModelIDs
                }
            }
            selectedHour = forecast.flatMap { closestHour(to: Date(), in: $0) }
        } catch {
            errorMessage = unavailableForecastMessage(for: error)
        }
    }

    @MainActor
    private func loadForecast(coordinate: CLLocationCoordinate2D) async {
        guard let password = WindguruCredentialStore.password(for: windguruUsername), !windguruUsername.isEmpty else {
            errorMessage = "Sign in with Windguru PRO to load an exact map coordinate."
            return
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let modelIDs = try await coordinateModelLoader(coordinate.latitude, coordinate.longitude)
            let requestedModelIDs = modelIDs.isEmpty ? [Model.defaultModel] : modelIDs
            var coordinateForecasts: [SpotForecast] = []
            var lastModelError: Error?
            for modelID in requestedModelIDs {
                do {
                    guard let coordinateForecast = try await coordinateForecastLoader(
                        coordinate.latitude,
                        coordinate.longitude,
                        modelID,
                        windguruUsername,
                        password
                    ) else {
                        continue
                    }
                    guard let convertedForecast = try SpotForecast.from(coordinateForecast: coordinateForecast) else {
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
            selectedModelIDs = coordinateForecasts.compactMap(\.model)
            usableModelIDs = selectedModelIDs
            selectedHour = forecast.flatMap { closestHour(to: Date(), in: $0) }
        } catch {
            errorMessage = unavailableForecastMessage(for: error)
        }
    }

    private func unavailableForecastContent(errorMessage: String) -> some View {
#if DEBUG
        ForecastOfflineView(retry: {
            Task { await loadForecast() }
        }, debugError: errorMessage)
#else
        ForecastOfflineView {
            Task { await loadForecast() }
        }
#endif
    }

    private func unavailableForecastMessage(for error: Error) -> String {
#if DEBUG
        let nsError = error as NSError
        var details = [
            String(reflecting: error),
            "Domain: \(nsError.domain)",
            "Code: \(nsError.code)"
        ]
        if !error.localizedDescription.isEmpty {
            details.append("Description: \(error.localizedDescription)")
        }
        if !nsError.userInfo.isEmpty {
            details.append("Details: \(nsError.userInfo)")
        }
        return details.joined(separator: "\n")
#else
        return ""
#endif
    }

    private func closestHour(to date: Date, in forecast: SpotForecast) -> String? {
        forecast.availableForecastHours.min {
            abs((forecast.forecastDate(hour: $0)?.timeIntervalSince(date) ?? .greatestFiniteMagnitude))
                < abs((forecast.forecastDate(hour: $1)?.timeIntervalSince(date) ?? .greatestFiniteMagnitude))
        }
    }

    private static func modelIDs(from response: String?) -> [String] {
        guard let response,
              let data = response.data(using: .utf8),
              let modelIDs = try? JSONSerialization.jsonObject(with: data) as? [Int] else {
            return []
        }
        return modelIDs.map(String.init)
    }

    private func orderedUnique(_ modelIDs: [String]) -> [String] {
        var seen = Set<String>()
        return modelIDs.filter { seen.insert($0).inserted }
    }

}

#Preview {
    ForecastDashboardView(forecastService: ForecastWindguruMockup())
}
#endif
