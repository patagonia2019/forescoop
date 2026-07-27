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
    let isSelectionEnabled: Bool
    let onSelection: (CLLocationCoordinate2D) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var position: MapCameraPosition = .automatic

    public init(
        initialCoordinate: CLLocationCoordinate2D? = nil,
        isSelectionEnabled: Bool = true,
        onSelection: @escaping (CLLocationCoordinate2D) -> Void
    ) {
        self.initialCoordinate = initialCoordinate
        self.isSelectionEnabled = isSelectionEnabled
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
                Map(position: $position) {
                    if let selectedCoordinate {
                        Marker("Selected location", coordinate: selectedCoordinate)
                    }
                }
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
            }
        }
    }
}

#Preview("Map location picker") {
    MapLocationPicker(initialCoordinate: CLLocationCoordinate2D(latitude: -41.13, longitude: -71.31), onSelection: { _ in })
}
#endif
