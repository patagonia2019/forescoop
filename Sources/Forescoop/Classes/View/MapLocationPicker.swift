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
    let initialCoordinate: CLLocationCoordinate2D?
    let onSelection: (CLLocationCoordinate2D) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var position: MapCameraPosition = .automatic

    public init(initialCoordinate: CLLocationCoordinate2D? = nil, onSelection: @escaping (CLLocationCoordinate2D) -> Void) {
        self.initialCoordinate = initialCoordinate
        self.onSelection = onSelection
        _selectedCoordinate = State(initialValue: initialCoordinate)
    }

    public var body: some View {
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
    MapLocationPicker(initialCoordinate: CLLocationCoordinate2D(latitude: -41.13, longitude: -71.31), onSelection: { _ in })
}
#endif
