//
//  VisionLocationsView.swift
//  Forescoop
//
//  Created by Javier Fuchs on 07/23/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if os(visionOS)
import MapKit
import SwiftUI

struct VisionLocationsView: View {
    @State private var locations = SavedMapLocationStore.load()

    var body: some View {
        NavigationStack {
            HStack(spacing: 24) {
                Map {
                    ForEach(locations) { location in
                        Marker(location.name, coordinate: location.coordinate)
                    }
                }
                .clipShape(.rect(cornerRadius: 24))

                List(locations) { location in
                    Label {
                        VStack(alignment: .leading) {
                            Text(location.name)
                            Text(location.coordinateText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "mappin.and.ellipse")
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
#endif
