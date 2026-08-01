//
//  LocationList.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 08/01/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if !os(watchOS)
import SwiftUI

/// Iterates the distinct saved and favorite locations using a caller-provided row.
struct LocationList<Row: View>: View {
    let savedLocations: [SavedMapLocation]
    let favoriteLocations: [SavedMapLocation]
    private let row: (SavedMapLocation, Bool) -> Row

    init(
        savedLocations: [SavedMapLocation],
        favoriteLocations: [SavedMapLocation] = [],
        @ViewBuilder row: @escaping (SavedMapLocation, Bool) -> Row
    ) {
        self.savedLocations = savedLocations
        self.favoriteLocations = favoriteLocations
        self.row = row
    }

    var body: some View {
        ForEach(locations) { location in
            row(location, isFavorite(location))
        }
    }

    static func merged(
        savedLocations: [SavedMapLocation],
        favoriteLocations: [SavedMapLocation]
    ) -> [SavedMapLocation] {
        savedLocations + favoriteLocations.reduce(into: [SavedMapLocation]()) { locations, favorite in
            guard !locations.contains(where: { SavedMapLocationStore.isSameLocation($0, favorite) }) else { return }
            locations.append(favorite)
        }
    }

    private var locations: [SavedMapLocation] {
        Self.merged(savedLocations: savedLocations, favoriteLocations: favoriteLocations)
    }

    private func isFavorite(_ location: SavedMapLocation) -> Bool {
        favoriteLocations.contains { $0.id == location.id }
    }
}

#if DEBUG
#Preview("Location list") {
    VStack(alignment: .leading, spacing: 12) {
        LocationList(
            savedLocations: [
                SavedMapLocation(
                    name: "Bariloche",
                    coordinate: .init(latitude: -41.1281, longitude: -71.3480),
                    spotID: "64141",
                    placeDescription: "Argentina"
                )
            ],
            favoriteLocations: [
                SavedMapLocation(
                    name: "Puerto Montt",
                    coordinate: .init(latitude: -41.4693, longitude: -72.9424),
                    spotID: "175",
                    placeDescription: "Chile"
                )
            ]
        ) { location, isFavorite in
            SavedLocationRow(location: location, isFavorite: isFavorite)
        }
    }
    .padding()
}
#endif
#endif
