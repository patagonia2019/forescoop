//
//  VisionLocationsView.swift
//  Forescoop
//

#if os(visionOS)
import MapKit
import SwiftUI

public struct VisionLocationsView: View {
    @State private var locations = SavedMapLocationStore.load()

    public init() {}

    public var body: some View {
        NavigationStack {
            HStack(spacing: 24) {
                Map {
                    ForEach(locations) { location in
                        Marker(location.name, coordinate: location.coordinate)
                    }
                }
                .clipShape(.rect(cornerRadius: 24))

                List {
                    LocationList(savedLocations: locations) { location, isFavorite in
                        SavedLocationRow(location: location, isFavorite: isFavorite)
                    }
                }
                .frame(width: 280)
                .scrollContentBackground(.hidden)
                .background(.thinMaterial, in: .rect(cornerRadius: 20))
            }
            .padding(28)
            .navigationTitle("Locations")
            .toolbar {
                Button("Refresh", systemImage: "arrow.clockwise") {
                    locations = SavedMapLocationStore.load()
                }
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    VisionLocationsView()
}
#endif
