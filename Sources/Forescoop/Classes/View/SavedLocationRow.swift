//
//  SavedLocationRow.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 08/01/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if !os(watchOS)
import SwiftUI

/// Consistent saved-location label with an optional selection action.
struct SavedLocationRow: View {
    let location: SavedMapLocation
    let isFavorite: Bool
    let isDisabled: Bool
    let onSelect: (() -> Void)?

    init(
        location: SavedMapLocation,
        isFavorite: Bool = false,
        isDisabled: Bool = false,
        onSelect: (() -> Void)? = nil
    ) {
        self.location = location
        self.isFavorite = isFavorite
        self.isDisabled = isDisabled
        self.onSelect = onSelect
    }

    var body: some View {
        Group {
            if let onSelect {
                Button(action: onSelect) { label }
                    .buttonStyle(.plain)
                    .disabled(isDisabled)
            } else {
                label
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var label: some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(location.displayName)
                Text(location.detailText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: isFavorite ? "star.circle.fill" : "mappin.and.ellipse")
        }
    }
}

#if DEBUG
#Preview("Saved location row") {
    VStack(alignment: .leading, spacing: 16) {
        SavedLocationRow(
            location: SavedMapLocation(
                name: "Bariloche",
                coordinate: .init(latitude: -41.1281, longitude: -71.3480),
                spotID: "64141",
                placeDescription: "Argentina"
            ),
            onSelect: {}
        )
        SavedLocationRow(
            location: SavedMapLocation(
                name: "Puerto Montt",
                coordinate: .init(latitude: -41.4693, longitude: -72.9424),
                spotID: "175",
                placeDescription: "Chile"
            ),
            isFavorite: true
        )
    }
    .padding()
}
#endif
#endif
