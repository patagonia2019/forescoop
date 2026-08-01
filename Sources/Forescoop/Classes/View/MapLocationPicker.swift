//
//  MapLocationPicker.swift
//  Forescoop
//
//  Created by Javier on 23/07/2026.
//  Copyright © 2026 Forescoop. All rights reserved.

#if !os(watchOS) && !os(tvOS)
import CoreLocation
import MapKit
import SwiftUI

public struct MapLocationPicker: View {
    private enum MapDisplayStyle: String, CaseIterable, Identifiable {
        case outdoors
        case satellite
        case hybrid

        var id: Self { self }

        var label: String {
            switch self {
            case .outdoors: "Outdoors"
            case .satellite: "Satellite"
            case .hybrid: "Hybrid"
            }
        }

        var symbolName: String {
            switch self {
            case .outdoors: "mountain.2"
            case .satellite: "globe.americas.fill"
            case .hybrid: "map.fill"
            }
        }
    }

    let initialCoordinate: CLLocationCoordinate2D?
    let isSelectionEnabled: Bool
    let onSelection: (CLLocationCoordinate2D) -> Void
    let savedLocations: [SavedMapLocation]
    let favoriteLocations: [SavedMapLocation]
    let forecast: SpotForecast?
    let selectedForecastHour: String?
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var position: MapCameraPosition = .automatic
    @State private var displayStyle: MapDisplayStyle = .outdoors

    public init(
        initialCoordinate: CLLocationCoordinate2D? = nil,
        isSelectionEnabled: Bool = true,
        savedLocations: [SavedMapLocation]? = nil,
        favoriteLocations: [SavedMapLocation] = [],
        forecast: SpotForecast? = nil,
        selectedForecastHour: String? = nil,
        onSelection: @escaping (CLLocationCoordinate2D) -> Void
    ) {
        self.initialCoordinate = initialCoordinate
        self.isSelectionEnabled = isSelectionEnabled
        self.savedLocations = savedLocations ?? SavedMapLocationStore.load()
        self.favoriteLocations = favoriteLocations.filter { favorite in
            !(savedLocations ?? SavedMapLocationStore.load()).contains {
                SavedMapLocationStore.isSameLocation($0, favorite)
            }
        }
        self.forecast = forecast
        self.selectedForecastHour = selectedForecastHour
        self.onSelection = onSelection
        _selectedCoordinate = State(initialValue: initialCoordinate)
        if let initialCoordinate {
            _position = State(initialValue: .region(MKCoordinateRegion(
                center: initialCoordinate,
                latitudinalMeters: 3000,
                longitudinalMeters: 3000
            )))
        }
    }

    public var body: some View {
        NavigationStack {
            MapReader { proxy in
                map
                .onTapGesture { point in
                    guard isSelectionEnabled else { return }
                    selectedCoordinate = proxy.convert(point, from: .local)
                }
            }
            .navigationTitle(isSelectionEnabled ? "Pick location" : "Location")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isSelectionEnabled ? "Use Location" : "Done") {
                        if isSelectionEnabled, let selectedCoordinate {
                            onSelection(selectedCoordinate)
                        } else {
                            dismiss()
                        }
                    }
                    .disabled(isSelectionEnabled && selectedCoordinate == nil)
                }
                ToolbarItem(placement: .secondaryAction) {
                    Menu {
                        Picker("Map style", selection: $displayStyle) {
                            ForEach(MapDisplayStyle.allCases) { style in
                                Label(style.label, systemImage: style.symbolName).tag(style)
                            }
                        }
                    } label: {
                        Label("Map style", systemImage: displayStyle.symbolName)
                    }
                }
            }
        }
    }

    @ViewBuilder private var map: some View {
        switch displayStyle {
        case .outdoors:
            mapContent
                .mapStyle(.standard(
                    elevation: .realistic,
                    pointsOfInterest: .including(outdoorPlaces)
                ))
        case .satellite:
            mapContent.mapStyle(.imagery(elevation: .realistic))
        case .hybrid:
            mapContent
                .mapStyle(.hybrid(
                    elevation: .realistic,
                    pointsOfInterest: .including(outdoorPlaces)
                ))
        }
    }

    private var mapContent: some View {
        Map(position: $position) {
            ForEach(savedLocations) { location in
                Annotation(location.displayName, coordinate: location.coordinate, anchor: .bottom) {
                    SavedMapLocationAnnotation(
                        location: location,
                        forecast: forecast(for: location),
                        hour: selectedForecastHour
                    )
                }
            }
            ForEach(favoriteLocations) { location in
                Annotation(location.displayName, coordinate: location.coordinate, anchor: .bottom) {
                    SavedMapLocationAnnotation(
                        location: location,
                        forecast: forecast(for: location),
                        hour: selectedForecastHour,
                        isFavorite: true
                    )
                }
            }
            if let selectedCoordinate {
                if !(savedLocations + favoriteLocations).contains(where: { isSameCoordinate($0.coordinate, selectedCoordinate) }) {
                    Marker("Selected location", coordinate: selectedCoordinate)
                }
            }
        }
        .mapControls {
            MapCompass()
            MapPitchToggle()
            MapScaleView()
        }
    }

    private var outdoorPlaces: [MKPointOfInterestCategory] {
        [.beach, .campground, .marina, .nationalPark, .park]
    }

    private func forecast(for location: SavedMapLocation) -> SpotForecast? {
        guard let forecast else { return nil }
        if let savedSpotID = location.spotID,
           savedSpotID != "0",
           savedSpotID == forecast.identifier {
            return forecast
        }
        guard let forecastCoordinate = forecast.location?.coordinate else { return nil }
        return isSameCoordinate(location.coordinate, forecastCoordinate) ? forecast : nil
    }

    private func isSameCoordinate(_ lhs: CLLocationCoordinate2D, _ rhs: CLLocationCoordinate2D) -> Bool {
        abs(lhs.latitude - rhs.latitude) < 0.0001 && abs(lhs.longitude - rhs.longitude) < 0.0001
    }
}

#Preview("Map location picker") {
    MapLocationPicker(initialCoordinate: CLLocationCoordinate2D(latitude: -41.13, longitude: -71.31), onSelection: { _ in })
}
#endif
