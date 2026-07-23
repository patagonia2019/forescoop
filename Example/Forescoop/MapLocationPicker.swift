//
//  MapLocationPicker.swift
//  Forescoop
//
//  Created by Javier on 23/07/2026.
//  Copyright © 2026 Forescoop. All rights reserved.

import CoreLocation
import MapKit
import SwiftUI
import Forescoop

struct MapLocationPicker: View {
    let onSelection: (CLLocationCoordinate2D) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        NavigationStack {
            MapReader { proxy in
                Map(position: $position) {
                    if let selectedCoordinate {
                        Marker("Selected location", coordinate: selectedCoordinate)
                    }
                }
                .onTapGesture { point in
                    selectedCoordinate = proxy.convert(point, from: .local)
                }
            }
            .navigationTitle("Pick location")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Use Location") {
                        if let selectedCoordinate { onSelection(selectedCoordinate) }
                    }
                    .disabled(selectedCoordinate == nil)
                }
            }
        }
    }
}

#Preview("Map location picker") {
    MapLocationPicker(onSelection: { _ in })
}
