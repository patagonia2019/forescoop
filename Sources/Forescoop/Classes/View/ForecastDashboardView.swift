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
#if !os(macOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
#endif
    @AppStorage("selectedWindguruSpotID") private var selectedSpotID = "64141"
    @AppStorage("windguruUsername") private var windguruUsername = ""
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
    @State private var selectedModelIDs: [String] = []
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
    }

    private var usesWideLayout: Bool {
#if os(macOS)
        true
#else
        horizontalSizeClass == .regular
#endif
    }

    public var body: some View {
        NavigationStack {
            Group {
                if let forecast {
                    forecastContent(for: forecast)
                } else if isLoading {
                    ProgressView("Loading forecast…")
                } else if let errorMessage {
                    ContentUnavailableView("Forecast unavailable", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
                } else {
                    ContentUnavailableView("Forecast unavailable", systemImage: "cloud.sun")
                }
            }
            .navigationTitle("Forescoop")
            .toolbar {
#if os(macOS)
                ToolbarItem(placement: .navigation) {
                    Button(windguruUsername.isEmpty ? "Login" : windguruUsername, systemImage: "person.crop.circle") {
                        showsLogin = true
                    }
                }
#else
                ToolbarItem(placement: .topBarLeading) {
                    Button(windguruUsername.isEmpty ? "Login" : windguruUsername, systemImage: "person.crop.circle") {
                        showsLogin = true
                    }
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
                await loadForecast()
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
                    onCoordinateSelected: { coordinate in
                        showsSpotPicker = false
                        Task { await loadForecast(coordinate: coordinate) }
                    }
                )
            }
            .sheet(isPresented: $showsModelPicker) {
                ForecastModelPicker(
                    forecastService: forecastService,
                    spotID: selectedSpotID,
                    selectedModelIDs: Set(selectedModelIDs)
                ) { modelIDs in
                    showsModelPicker = false
                    Task { await loadForecast(modelIDs: modelIDs) }
                }
            }
            .sheet(isPresented: $showsLogin) {
                WindguruLoginView(
                    forecastService: forecastService,
                    username: windguruUsername,
                    onLoggedIn: { username in
                        windguruUsername = username
                        showsLogin = false
                        Task { await loadForecast() }
                    },
                    onProfileLoaded: applyUserPreferences
                )
            }
        }
    }

    private func forecastContent(for forecast: SpotForecast) -> some View {
        ScrollView {
            VStack(spacing: 28) {
                ForecastHourSelector(forecast: forecast, selectedHour: $selectedHour)

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
                                    Text(location.name)
                                    Text(location.coordinateText)
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
            errorMessage = error.localizedDescription
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
              let user = try? await profileLoader(windguruUsername, password),
              user.isPro else {
            return
        }
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

    @MainActor
    private func loadForecast(spotId: String? = nil, modelIDs: [String]? = nil) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let requestedSpotID = spotId ?? selectedSpotID
            let isChangingSpot = requestedSpotID != selectedSpotID
            let requestedModelIDs = modelIDs ?? (isChangingSpot ? [] : selectedModelIDs)
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
            for modelID in requestedModelIDs {
                if let loadedForecast = try await selectedForecastLoader(modelID),
                   loadedForecast.forecast != nil {
                    validForecasts.append(loadedForecast)
                }
            }
            if requestedModelIDs.isEmpty {
                forecast = try await selectedForecastLoader(nil)
            } else if validForecasts.count == 1 {
                forecast = validForecasts[0]
            } else if validForecasts.count == requestedModelIDs.count {
                forecast = try SpotForecast.blended(validForecasts)
            } else {
                throw CustomError.notMappeable
            }
            if forecast != nil {
                selectedSpotID = requestedSpotID
                selectedModelIDs = requestedModelIDs.isEmpty
                    ? [forecast?.model ?? Model.defaultModel]
                    : requestedModelIDs
            }
            selectedHour = forecast.flatMap { closestHour(to: Date(), in: $0) }
        } catch {
            errorMessage = error.localizedDescription
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
            let coordinateForecast = try await coordinateForecastLoader(
                coordinate.latitude,
                coordinate.longitude,
                nil,
                windguruUsername,
                password
            )
            guard let coordinateForecast else { throw CustomError.notMappeable }
            forecast = try SpotForecast.from(coordinateForecast: coordinateForecast)
            selectedModelIDs = forecast?.model.map { [$0] } ?? []
            selectedHour = forecast.flatMap { closestHour(to: Date(), in: $0) }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func closestHour(to date: Date, in forecast: SpotForecast) -> String? {
        forecast.availableForecastHours.min {
            abs((forecast.forecastDate(hour: $0)?.timeIntervalSince(date) ?? .greatestFiniteMagnitude))
                < abs((forecast.forecastDate(hour: $1)?.timeIntervalSince(date) ?? .greatestFiniteMagnitude))
        }
    }

}

#Preview {
    ForecastDashboardView(forecastService: ForecastWindguruMockup())
}
#endif
