//
//  ForecastLocationAnnotations.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 08/01/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if !os(watchOS)
import CoreLocation
@preconcurrency import MapKit
import SwiftUI

/// Shared saved and favorite location annotations for forecast maps.
@MainActor
struct ForecastLocationAnnotations: MapContent {
    let savedLocations: [SavedMapLocation]
    let favoriteLocations: [SavedMapLocation]
    let forecast: SpotForecast?
    let selectedHour: String?

    @MapContentBuilder
    var body: some MapContent {
        annotations(for: savedLocations, isFavorite: false)
        annotations(for: favoriteLocations, isFavorite: true)
    }

    @MapContentBuilder
    private func annotations(
        for locations: [SavedMapLocation],
        isFavorite: Bool
    ) -> some MapContent {
        ForEach(locations) { location in
#if !os(tvOS)
            Annotation(location.displayName, coordinate: location.coordinate, anchor: .bottom) {
                SavedMapLocationAnnotation(
                    location: location,
                    forecast: matchingForecast(for: location),
                    hour: selectedHour,
                    isFavorite: isFavorite
                )
            }
            .tag(location.id)
#else
            Marker(location.name, coordinate: location.coordinate)
                .tag(location.id)
#endif
        }
    }

    private func matchingForecast(for location: SavedMapLocation) -> SpotForecast? {
        guard let forecast else { return nil }
        if let spotID = location.spotID,
           spotID != "0",
           spotID == forecast.identifier {
            return forecast
        }
        guard let forecastCoordinate = forecast.location?.coordinate else { return nil }
        let latitudeMatches = abs(location.coordinate.latitude - forecastCoordinate.latitude) < 0.0001
        let longitudeMatches = abs(location.coordinate.longitude - forecastCoordinate.longitude) < 0.0001
        return latitudeMatches && longitudeMatches ? forecast : nil
    }
}

#if DEBUG
#Preview("Forecast location annotations") {
    Map {
        ForecastLocationAnnotations(
            savedLocations: [
                SavedMapLocation(
                    name: "Bariloche",
                    coordinate: CLLocationCoordinate2D(latitude: -41.1281, longitude: -71.3480),
                    spotID: "64141",
                    placeDescription: "Argentina"
                )
            ],
            favoriteLocations: [
                SavedMapLocation(
                    name: "Puerto Montt",
                    coordinate: CLLocationCoordinate2D(latitude: -41.4693, longitude: -72.9424),
                    spotID: "175",
                    placeDescription: "Chile"
                )
            ],
            forecast: nil,
            selectedHour: nil
        )
    }
}
#endif
#endif
