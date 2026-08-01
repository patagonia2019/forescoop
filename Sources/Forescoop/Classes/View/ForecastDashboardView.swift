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
    private enum DashboardContent: Equatable {
        case dashboard
        case grid
    }

    private enum DashboardSheet: String, Identifiable, Equatable {
        case spotPicker
        case modelPicker
        case login
        case favorites
        case forecastMap
        case weatherBackgroundSettings
        case about

        var id: String { rawValue }
    }

    private let forecastService: ForecastWindguruProtocol
    private let spotSearch: @MainActor (String) async throws -> SpotResult?
    private let favoriteSpotsLoader: @MainActor (String, String) async throws -> SpotResult?
    private let spotInfoLoader: @MainActor (String) async throws -> SpotInfo?
#if !os(macOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
#endif
    @State private var selectedSpotID: String
    @StateObject private var account: WindguruAccount
    @StateObject private var viewModel: ForecastDashboardViewModel
    @State private var showsWindDirectionArrow = false
    @State private var activeSheet: DashboardSheet?
    @State private var content = DashboardContent.dashboard
    @State private var weatherBackgroundStyle: WeatherBackgroundStyle
    @State private var showsDashboardModelComparison = false
    @State private var iPadMapPosition: MapCameraPosition = .automatic
    @State private var selectedMapLocationID: SavedMapLocation.ID?
    @State private var favoriteMapLocations = [SavedMapLocation]()

    public init(forecastService: ForecastWindguruProtocol = ForecastWindguruService()) {
        self.forecastService = forecastService
        _selectedSpotID = State(initialValue: SelectedWindguruSpotStore.load())
        _weatherBackgroundStyle = State(initialValue: WeatherBackgroundStyleStore.load())
        _viewModel = StateObject(wrappedValue: ForecastDashboardViewModel(forecastService: forecastService))
        _account = StateObject(wrappedValue: WindguruAccount())
        spotSearch = { try await forecastService.searchSpots(byLocation: $0) }
        favoriteSpotsLoader = { try await forecastService.favoriteSpots(withUsername: $0, password: $1) }
        spotInfoLoader = { try await forecastService.spotInfo(bySpotId: $0) }
    }

    private var forecast: SpotForecast? { get { viewModel.forecast } nonmutating set { viewModel.forecast = newValue } }
    private var coordinateLocationName: String? { get { viewModel.coordinateLocationName } nonmutating set { viewModel.coordinateLocationName = newValue } }
    private var errorMessage: String? { get { viewModel.errorMessage } nonmutating set { viewModel.errorMessage = newValue } }
    private var isLoading: Bool { get { viewModel.isLoading } nonmutating set { viewModel.isLoading = newValue } }
    private var selectedHour: String? { get { viewModel.selectedHour } nonmutating set { viewModel.selectedHour = newValue } }
    private var selectedModelIDs: [String] { get { viewModel.selectedModelIDs } nonmutating set { viewModel.selectedModelIDs = newValue } }
    private var usableModelIDs: [String] { get { viewModel.usableModelIDs } nonmutating set { viewModel.usableModelIDs = newValue } }
    private var displayedForecastSpotID: String? { get { viewModel.displayedForecastSpotID } nonmutating set { viewModel.displayedForecastSpotID = newValue } }
    private var modelIDsBySpot: [String: [String]] { get { viewModel.modelIDsBySpot } nonmutating set { viewModel.modelIDsBySpot = newValue } }
    private var selectedModelIDsBySpot: [String: [String]] { get { viewModel.selectedModelIDsBySpot } nonmutating set { viewModel.selectedModelIDsBySpot = newValue } }
    private var modelNamesByID: [String: String] { get { viewModel.modelNamesByID } nonmutating set { viewModel.modelNamesByID = newValue } }
    private var displayedModelForecasts: [SpotForecast] { get { viewModel.displayedModelForecasts } nonmutating set { viewModel.displayedModelForecasts = newValue } }
    private var savedMapLocations: [SavedMapLocation] { get { viewModel.savedMapLocations } nonmutating set { viewModel.savedMapLocations = newValue } }

    private var selectedHourBinding: Binding<String?> {
        Binding(get: { viewModel.selectedHour }, set: { viewModel.selectedHour = $0 })
    }

    private var usesWideLayout: Bool {
#if os(macOS)
        true
#else
        horizontalSizeClass == .regular
#endif
    }

    private var isProUser: Bool {
        account.isProUser && account.isAuthenticated
    }

    private func sheetBinding(_ sheet: DashboardSheet) -> Binding<Bool> {
        Binding(
            get: { activeSheet == sheet },
            set: { isPresented in
                if isPresented {
                    activeSheet = sheet
                } else if activeSheet == sheet {
                    activeSheet = nil
                }
            }
        )
    }

    private var accountMenu: some View {
        DashboardAccountMenu(
            isShowingGrid: content == .grid,
            isLoggedIn: !account.username.isEmpty,
            onShowDashboard: { content = .dashboard },
            onShowGrid: { content = .grid },
            onShowSettings: { activeSheet = .weatherBackgroundSettings },
            onShowAbout: { activeSheet = .about },
            onShowAccount: { activeSheet = .login },
            onShowFavorites: { activeSheet = .favorites },
            onLogout: logout
        )
    }

    private func logout() {
        account.signOut()
        selectedSpotID = "64141"
        selectedModelIDs = []
        usableModelIDs = []
        displayedForecastSpotID = nil
        modelIDsBySpot = [:]
        selectedModelIDsBySpot = [:]
        displayedModelForecasts = []
        viewModel.clearUserProfile()
        selectedHour = nil
        forecast = nil
        coordinateLocationName = nil
        errorMessage = nil
        savedMapLocations = []
        favoriteMapLocations = []
        selectedMapLocationID = nil
        SavedMapLocationStore.removeAll()

        applyDevicePreferences()

        activeSheet = nil
        Task { await loadForecast() }
    }

    private func startSession(username: String, isProUser: Bool) {
        account.signIn(username: username, isProUser: isProUser)
        viewModel.clearUserProfile()
        // Do not reuse the previous session's model cache. A PRO session can
        // expose more models for the same spot, while a regular session must
        // return to the public forecast set.
        selectedModelIDs = []
        usableModelIDs = []
        displayedForecastSpotID = nil
        modelIDsBySpot = [:]
        selectedModelIDsBySpot = [:]
        displayedModelForecasts = []
        selectedHour = nil
        forecast = nil
        coordinateLocationName = nil
        errorMessage = nil
        activeSheet = nil
        Task {
            await loadFavoriteMapLocations()
            await loadPreferredForecast()
        }
    }

    public var body: some View {
        NavigationStack {
            Group {
                if let forecast {
                    Group {
                        if content == .grid {
                            forecastGridContent(for: forecast)
                        } else {
                            forecastContent(for: forecast)
                        }
                    }
                    .background {
                        weatherBackground(for: forecast)
                    }
                } else if isLoading {
                    ProgressView("Loading forecast…")
                } else if let errorMessage {
                    unavailableForecastContent(errorMessage: errorMessage)
                } else {
                    ContentUnavailableView("Forecast unavailable", systemImage: "cloud.sun")
                }
            }
            .navigationTitle("Ventus")
#if !os(macOS)
            .navigationBarTitleDisplayMode(.large)
#endif
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
                    HStack {
                        if content == .dashboard, displayedModelForecasts.count > 1 {
                            Button("Compare models", systemImage: "arrow.left.and.right") {
                                showsDashboardModelComparison.toggle()
                            }
                            .tint(showsDashboardModelComparison ? .accentColor : .secondary)
                        }

                        Button("Refresh", systemImage: "arrow.clockwise") {
                            Task { await loadForecast() }
                        }
                    }
                }
            }
            .task {
                await loadUserPreferences()
                await loadFavoriteMapLocations()
                await loadPreferredForecast()
            }
            .onChange(of: selectedSpotID) { _, spotID in SelectedWindguruSpotStore.save(spotID) }
            .sheet(isPresented: sheetBinding(.spotPicker), onDismiss: {
                refreshSavedMapLocations()
                Task { await loadFavoriteMapLocations() }
            }) {
                WindguruSpotPicker(
                    forecastService: forecastService,
                    account: account,
                    onSpotSelected: { spot in
                        guard let spotId = spot.identifier else { return }
                        activeSheet = nil
                        Task { await loadForecast(spotId: spotId) }
                    },
                    onSpotIDSelected: { spotID in
                        activeSheet = nil
                        Task { await loadForecast(spotId: spotID) }
                    },
                    onFavoriteSelected: { spot in
                        guard let spotID = spot.identifier else { return }
                        activeSheet = nil
                        Task { await loadForecast(spotId: spotID, persistSelection: false) }
                    },
                    onCoordinateSelected: { coordinate, locationName in
                        activeSheet = nil
                        Task { await loadForecast(coordinate: coordinate, locationName: locationName) }
                    }
                )
            }
            .sheet(isPresented: sheetBinding(.modelPicker)) {
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
                    activeSheet = nil
                    Task {
                        await loadForecast(
                            spotId: forecastSpotID,
                            modelIDs: modelIDs,
                            persistSelection: forecastSpotID == selectedSpotID
                        )
                    }
                }
            }
            .sheet(isPresented: sheetBinding(.login)) {
                WindguruLoginView(
                    forecastService: forecastService,
                    username: account.username,
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
            .sheet(isPresented: sheetBinding(.favorites), onDismiss: {
                Task { await loadFavoriteMapLocations() }
            }) {
                WindguruFavoritesView(
                    forecastService: forecastService,
                    account: account,
                    onSpotSelected: { spot in
                        guard let spotID = spot.identifier else { return }
                        activeSheet = nil
                        Task { await loadForecast(spotId: spotID, persistSelection: false) }
                    }
                )
            }
            .sheet(isPresented: sheetBinding(.weatherBackgroundSettings)) {
                SettingsView(weatherBackgroundStyle: $weatherBackgroundStyle)
            }
            .sheet(isPresented: sheetBinding(.about)) {
                NavigationStack {
                    AboutView()
                }
            }
#if !os(tvOS)
            .sheet(isPresented: sheetBinding(.forecastMap)) {
                MapLocationPicker(
                    initialCoordinate: forecast?.location?.coordinate,
                    isSelectionEnabled: false,
                    savedLocations: savedMapLocations,
                    favoriteLocations: favoriteMapLocations,
                    forecast: forecast,
                    selectedForecastHour: selectedHour,
                    onSelection: { _ in }
                )
            }
#endif
        }
    }

    private func forecastContent(for forecast: SpotForecast) -> some View {
        ScrollView {
            VStack(spacing: 28) {
                ForecastHourSelector(
                    forecast: forecast,
                    selectedHour: selectedHourBinding
                )

                if usesWideLayout {
                    HStack(alignment: .top, spacing: 56) {
                        ForecastOverview(forecast: forecast, selectedHour: selectedHour, temperatureUnit: $viewModel.temperatureUnit, coordinateLocationName: coordinateLocationName, modelForecasts: displayedModelForecasts, modelNamesByID: modelNamesByID, isModelComparisonEnabled: showsDashboardModelComparison, onSelectLocation: { activeSheet = .spotPicker }, onSelectModel: { activeSheet = .modelPicker }, onShowMap: { activeSheet = .forecastMap })
                            .frame(maxWidth: .infinity)

                        VStack(alignment: .leading, spacing: 28) {
                            ForecastWindDetails(forecast: forecast, selectedHour: selectedHour, windSpeedUnit: $viewModel.windSpeedUnit, showsDirectionArrow: $showsWindDirectionArrow, modelForecasts: displayedModelForecasts, modelNamesByID: modelNamesByID, isModelComparisonEnabled: showsDashboardModelComparison)
                            ForecastWeatherDetails(forecast: forecast, selectedHour: selectedHour, waveHeightUnit: $viewModel.waveHeightUnit, precipitationUnit: $viewModel.precipitationUnit, freezingLevelUnit: $viewModel.freezingLevelUnit, pressureUnit: $viewModel.pressureUnit, modelForecasts: displayedModelForecasts, modelNamesByID: modelNamesByID, isModelComparisonEnabled: showsDashboardModelComparison)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardLocationWorkspace(
                        savedLocations: savedMapLocations,
                        favoriteLocations: favoriteLocationsNotSaved,
                        mapPosition: $iPadMapPosition,
                        selectedLocationID: $selectedMapLocationID,
                        selectedHour: selectedHour,
                        forecast: forecast,
                        onManageLocations: { activeSheet = .spotPicker },
                        onSelectLocation: selectMapLocation
                    )
                } else {
                    VStack(spacing: 24) {
                        ForecastOverview(forecast: forecast, selectedHour: selectedHour, temperatureUnit: $viewModel.temperatureUnit, coordinateLocationName: coordinateLocationName, modelForecasts: displayedModelForecasts, modelNamesByID: modelNamesByID, isModelComparisonEnabled: showsDashboardModelComparison, onSelectLocation: { activeSheet = .spotPicker }, onSelectModel: { activeSheet = .modelPicker }, onShowMap: { activeSheet = .forecastMap })
                        ForecastWindDetails(forecast: forecast, selectedHour: selectedHour, windSpeedUnit: $viewModel.windSpeedUnit, showsDirectionArrow: $showsWindDirectionArrow, modelForecasts: displayedModelForecasts, modelNamesByID: modelNamesByID, isModelComparisonEnabled: showsDashboardModelComparison)
                        ForecastWeatherDetails(forecast: forecast, selectedHour: selectedHour, waveHeightUnit: $viewModel.waveHeightUnit, precipitationUnit: $viewModel.precipitationUnit, freezingLevelUnit: $viewModel.freezingLevelUnit, pressureUnit: $viewModel.pressureUnit, modelForecasts: displayedModelForecasts, modelNamesByID: modelNamesByID, isModelComparisonEnabled: showsDashboardModelComparison)
                    }
                }

            }
            .frame(maxWidth: 1_100)
            .padding()
        }
    }

    @ViewBuilder
    private func weatherBackground(for forecast: SpotForecast) -> some View {
        WeatherBackgroundRenderer(
            style: weatherBackgroundStyle,
            forecast: forecast,
            hour: selectedHour
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }

    private func forecastGridContent(for forecast: SpotForecast) -> some View {
        let isCoordinateForecast = coordinateLocationName != nil
        let forecastSpotID = displayedForecastSpotID ?? selectedSpotID
        let availableModelIDs = isCoordinateForecast
            ? usableModelIDs
            : modelIDsBySpot[forecastSpotID] ?? usableModelIDs
        let selectedForecastModelIDs = isCoordinateForecast
            ? selectedModelIDs
            : selectedModelIDsBySpot[forecastSpotID] ?? selectedModelIDs

        return WindguruForecastGridView(
            forecast: forecast,
            coordinateLocationName: coordinateLocationName,
            selectedHour: selectedHour,
            availableModelIDs: availableModelIDs,
            selectedModelIDs: selectedForecastModelIDs,
            modelNamesByID: modelNamesByID,
            modelForecasts: displayedModelForecasts,
            userProfile: viewModel.userProfile,
            temperatureUnit: $viewModel.temperatureUnit,
            windSpeedUnit: $viewModel.windSpeedUnit,
            waveHeightUnit: $viewModel.waveHeightUnit,
            pressureUnit: $viewModel.pressureUnit,
            precipitationUnit: $viewModel.precipitationUnit,
            freezingLevelUnit: $viewModel.freezingLevelUnit,
            showsWindDirectionArrow: $showsWindDirectionArrow,
            onSelectLocation: { activeSheet = .spotPicker },
            onToggleModel: { modelID in
                toggleGridModel(
                    modelID,
                    for: forecastSpotID,
                    coordinate: isCoordinateForecast ? forecast.location?.coordinate : nil,
                    locationName: coordinateLocationName
                )
            },
            onSelectHour: { hour in
                selectedHour = hour
                content = .dashboard
            },
            onShowMap: { activeSheet = .forecastMap }
        )
        .task(id: availableModelIDs) {
            await viewModel.loadModelNames(for: availableModelIDs)
        }
    }

    private func toggleGridModel(
        _ modelID: String,
        for spotID: String,
        coordinate: CLLocationCoordinate2D? = nil,
        locationName: String? = nil
    ) {
        let availableModelIDs = coordinate == nil ? modelIDsBySpot[spotID] ?? usableModelIDs : usableModelIDs
        var selectedModelIDs = coordinate == nil ? selectedModelIDsBySpot[spotID] ?? self.selectedModelIDs : self.selectedModelIDs

        if selectedModelIDs.contains(modelID) {
            guard selectedModelIDs.count > 1 else { return }
            selectedModelIDs.removeAll { $0 == modelID }
        } else if availableModelIDs.contains(modelID) {
            selectedModelIDs.append(modelID)
        }

        Task {
            if let coordinate {
                await loadForecast(
                    coordinate: coordinate,
                    locationName: locationName,
                    modelIDs: selectedModelIDs
                )
            } else {
                await loadForecast(
                    spotId: spotID,
                    modelIDs: selectedModelIDs,
                    persistSelection: spotID == selectedSpotID
                )
            }
        }
    }

    private func refreshSavedMapLocations() {
        savedMapLocations = SavedMapLocationStore.load()
    }

    private var favoriteLocationsNotSaved: [SavedMapLocation] {
        favoriteMapLocations.filter { favorite in
            !savedMapLocations.contains { SavedMapLocationStore.isSameLocation($0, favorite) }
        }
    }

    @MainActor
    private func loadFavoriteMapLocations() async {
        guard !account.username.isEmpty, let password = account.password else {
            favoriteMapLocations = []
            return
        }

        guard let spots = try? await favoriteSpotsLoader(account.username, password)?.allSpots else {
            favoriteMapLocations = []
            return
        }

        var locations = [SavedMapLocation]()
        for spot in spots {
            guard let spotID = spot.identifier,
                  let info = try? await spotInfoLoader(spotID),
                  let coordinate = info.location?.coordinate else { continue }
            let location = SavedMapLocation(
                name: spot.name?.isEmpty == false ? spot.name! : info.name ?? "Windguru spot",
                coordinate: coordinate,
                spotID: spotID,
                placeDescription: spot.countryName ?? info.countryName
            )
            guard !locations.contains(where: { SavedMapLocationStore.isSameLocation($0, location) }) else { continue }
            locations.append(location)
        }
        favoriteMapLocations = locations
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
        if let spotID = location.spotID, spotID != "0" {
            await loadForecast(spotId: spotID)
            return
        }

        if isProUser {
            await loadForecast(
                coordinate: location.coordinate,
                locationName: location.placeDescription?.isEmpty == false
                    ? location.placeDescription
                    : location.name
            )
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
            errorMessage = viewModel.forecastErrorMessage(for: error)
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
        guard !account.username.isEmpty,
              let password = account.password,
              let user = await viewModel.loadUserProfile(username: account.username, password: password) else {
            applyDevicePreferences()
            return
        }
        applyUserPreferences(user)
    }

    private func applyUserPreferences(_ user: User) {
        account.update(profile: user)
        viewModel.applyUserProfile(user)
    }

    private func applyDevicePreferences() {
        viewModel.applyDeviceUnitPreferences()
    }

    @MainActor
    private func loadPreferredForecast() async {
        let preferredSpotID: String
        if !account.username.isEmpty,
           let password = account.password,
           let favoriteSpotID = try? await favoriteSpotsLoader(account.username, password)?.allSpots.first?.identifier {
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
        let requestedSpotID = spotId ?? selectedSpotID
        let didLoad = await viewModel.loadForecast(
            spotID: requestedSpotID,
            modelIDs: modelIDs,
            isChangingSpot: requestedSpotID != selectedSpotID,
            persistSelection: persistSelection,
            account: account
        )
        if didLoad, persistSelection {
            selectedSpotID = requestedSpotID
        }
    }

    @MainActor
    private func loadForecast(
        coordinate: CLLocationCoordinate2D,
        locationName: String? = nil,
        modelIDs: [String]? = nil
    ) async {
        await viewModel.loadCoordinateForecast(
            coordinate: coordinate,
            locationName: locationName,
            modelIDs: modelIDs,
            account: account
        )
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

}

#Preview {
    ForecastDashboardView(forecastService: ForecastWindguruMockup())
}
#endif
