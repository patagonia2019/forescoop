//
//  DashboardLocationWorkspace.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 08/01/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if !os(watchOS)
@preconcurrency import MapKit
import SwiftUI

/// Shows saved and favorite locations alongside the wide dashboard layout.
@MainActor
struct DashboardLocationWorkspace: View {
    let savedLocations: [SavedMapLocation]
    let favoriteLocations: [SavedMapLocation]
    @Binding var mapPosition: MapCameraPosition
    @Binding var selectedLocationID: SavedMapLocation.ID?
    let selectedHour: String?
    let forecast: (SavedMapLocation) -> SpotForecast?
    let onManageLocations: () -> Void
    let onSelectLocation: (SavedMapLocation) -> Void

    private var locations: [SavedMapLocation] { savedLocations + favoriteLocations }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Choose location", systemImage: "mappin.and.ellipse")
                    .font(.title2.bold())
                Spacer()
                Button("Manage locations", systemImage: "slider.horizontal.3", action: onManageLocations)
            }

            Map(position: $mapPosition, selection: $selectedLocationID) {
                locationAnnotations(savedLocations, isFavorite: false)
                locationAnnotations(favoriteLocations, isFavorite: true)
            }
            .frame(height: 280)
            .clipShape(.rect(cornerRadius: 16))
            .onChange(of: selectedLocationID) { _, locationID in
                guard let locationID, let location = locations.first(where: { $0.id == locationID }) else { return }
                onSelectLocation(location)
            }

            if locations.isEmpty {
                ContentUnavailableView("No saved locations", systemImage: "mappin.slash", description: Text("Use Manage locations to search, pick, and save a location."))
                    .frame(maxWidth: .infinity)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 12)], spacing: 12) {
                    ForEach(locations) { location in
                        Button { onSelectLocation(location) } label: {
                            Label {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(location.displayName)
                                    Text(location.detailText)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            } icon: {
                                Image(systemName: isFavorite(location) ? "star.circle.fill" : "mappin.and.ellipse")
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

    @MapContentBuilder
    private func locationAnnotations(_ locations: [SavedMapLocation], isFavorite: Bool) -> some MapContent {
        ForEach(locations) { location in
#if !os(tvOS)
            Annotation(location.displayName, coordinate: location.coordinate, anchor: .bottom) {
                SavedMapLocationAnnotation(
                    location: location,
                    forecast: forecast(location),
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

    private func isFavorite(_ location: SavedMapLocation) -> Bool {
        favoriteLocations.contains(where: { $0.id == location.id })
    }
}

#if DEBUG
#Preview("Dashboard location workspace") {
    DashboardLocationWorkspace(
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
        mapPosition: .constant(.region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -41.3, longitude: -72.1),
            span: MKCoordinateSpan(latitudeDelta: 3, longitudeDelta: 3)
        ))),
        selectedLocationID: .constant(nil),
        selectedHour: nil,
        forecast: { _ in nil },
        onManageLocations: {},
        onSelectLocation: { _ in }
    )
    .padding()
}
#endif
#endif
