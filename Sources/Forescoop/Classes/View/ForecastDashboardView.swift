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

        var id: String { rawValue }
    }

    private let forecastService: ForecastWindguruProtocol
    private let forecastLoader: @MainActor (String, String?) async throws -> SpotForecast?
    private let proSpotForecastLoader: @MainActor (String, String?, String, String) async throws -> SpotForecast?
    private let coordinateForecastLoader: @MainActor (Double, Double, String?, String, String) async throws -> WSpotForecast?
    private let spotSearch: @MainActor (String) async throws -> SpotResult?
    private let favoriteSpotsLoader: @MainActor (String, String) async throws -> SpotResult?
    private let spotInfoLoader: @MainActor (String) async throws -> SpotInfo?
    private let coordinateModelLoader: @MainActor (Double, Double) async throws -> [String]
    private let modelInfoLoader: @MainActor () async throws -> Models?
#if !os(macOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
#endif
    @State private var selectedSpotID: String
    @StateObject private var account: WindguruAccount
    @StateObject private var viewModel: ForecastDashboardViewModel
    @State private var showsWindDirectionArrow = false
    @State private var activeSheet: DashboardSheet?
    @State private var content = DashboardContent.dashboard
    @State private var showsDashboardModelComparison = false
    @State private var iPadMapPosition: MapCameraPosition = .automatic
    @State private var selectedMapLocationID: SavedMapLocation.ID?

    public init(forecastService: ForecastWindguruProtocol = ForecastWindguruService()) {
        self.forecastService = forecastService
        _selectedSpotID = State(initialValue: SelectedWindguruSpotStore.load())
        _viewModel = StateObject(wrappedValue: ForecastDashboardViewModel(forecastService: forecastService))
        _account = StateObject(wrappedValue: WindguruAccount())
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
        favoriteSpotsLoader = { try await forecastService.favoriteSpots(withUsername: $0, password: $1) }
        spotInfoLoader = { try await forecastService.spotInfo(bySpotId: $0) }
        coordinateModelLoader = { latitude, longitude in
            let response = try await forecastService.models(bylat: String(latitude), lon: String(longitude))
            return Self.modelIDs(from: response)
        }
        modelInfoLoader = { try await forecastService.modelInfo(onlyModelId: nil) }
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
        Menu {
            if content == .grid {
                Button("Forecast Dashboard", systemImage: "rectangle.3.group") {
                    content = .dashboard
                }
            } else {
                Button("Forecast Grid", systemImage: "tablecells") {
                    content = .grid
                }
            }

            Divider()

            if account.username.isEmpty {
                Button("Login", systemImage: "person.crop.circle") {
                    activeSheet = .login
                }
            } else {
                Button("Profile", systemImage: "person.crop.circle") {
                    activeSheet = .login
                }

                Button("Favorites", systemImage: "star") {
                    activeSheet = .favorites
                }
            }

            if !account.username.isEmpty {
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
        Task { await loadPreferredForecast() }
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
                await loadPreferredForecast()
            }
            .onChange(of: selectedSpotID) { _, spotID in SelectedWindguruSpotStore.save(spotID) }
            .sheet(isPresented: sheetBinding(.spotPicker), onDismiss: refreshSavedMapLocations) {
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
            .sheet(isPresented: sheetBinding(.favorites)) {
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
#if !os(tvOS)
            .sheet(isPresented: sheetBinding(.forecastMap)) {
                MapLocationPicker(
                    initialCoordinate: forecast?.location?.coordinate,
                    isSelectionEnabled: false,
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

                    iPadLocationWorkspace()
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
            style: .lottie,
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
            }
        )
        .task(id: availableModelIDs) {
            await loadModelNames(for: availableModelIDs)
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

    private func loadModelNames(for modelIDs: [String]) async {
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

    private func iPadLocationWorkspace() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Choose location", systemImage: "mappin.and.ellipse")
                    .font(.title2.bold())
                Spacer()
                Button("Manage locations", systemImage: "slider.horizontal.3") {
                    activeSheet = .spotPicker
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
        coordinateLocationName = nil
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
            if isProUser,
               let password = account.password,
               !account.username.isEmpty {
                selectedForecastLoader = { modelID in
                    try await proSpotForecastLoader(requestedSpotID, modelID, account.username, password)
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
                displayedModelForecasts = validForecasts.isEmpty ? forecast.map { [$0] } ?? [] : validForecasts
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
    private func loadForecast(
        coordinate: CLLocationCoordinate2D,
        locationName: String? = nil,
        modelIDs: [String]? = nil
    ) async {
        guard let password = account.password, !account.username.isEmpty else {
            errorMessage = "Sign in with Windguru PRO to load an exact map coordinate."
            return
        }
        isLoading = true
        errorMessage = nil
        coordinateLocationName = locationName
        displayedForecastSpotID = nil
        defer { isLoading = false }
        do {
            let discoveredModelIDs = try await coordinateModelLoader(coordinate.latitude, coordinate.longitude)
            let requestedModelIDs = modelIDs ?? (discoveredModelIDs.isEmpty ? [Model.defaultModel] : discoveredModelIDs)
            var coordinateForecasts: [SpotForecast] = []
            var lastModelError: Error?
            for modelID in requestedModelIDs {
                do {
                    guard let coordinateForecast = try await coordinateForecastLoader(
                        coordinate.latitude,
                        coordinate.longitude,
                        modelID,
                        account.username,
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
            displayedModelForecasts = coordinateForecasts
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
        forecast.availableForecastHours.last(where: {
            (forecast.forecastDate(hour: $0) ?? .distantFuture) <= date
        }) ?? forecast.availableForecastHours.first
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
