//
//  LocationMapButton.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 08/01/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if !os(watchOS)
import SwiftUI

/// Consistent, accessible map action for a named location.
struct LocationMapButton: View {
    enum ButtonStyle {
        case plain
        case borderless
    }

    let locationName: String
    let buttonStyle: ButtonStyle
    let action: () -> Void

    init(
        locationName: String,
        buttonStyle: ButtonStyle = .borderless,
        action: @escaping () -> Void
    ) {
        self.locationName = locationName
        self.buttonStyle = buttonStyle
        self.action = action
    }

    var body: some View {
        switch buttonStyle {
        case .plain:
            button.buttonStyle(.plain)
        case .borderless:
            button.buttonStyle(.borderless)
        }
    }

    private var button: some View {
        Button("Show \(locationName) on map", systemImage: "map", action: action)
            .labelStyle(.iconOnly)
    }
}

#if DEBUG
#Preview("Location map button") {
    LocationMapButton(locationName: "Bariloche #64141", action: {})
        .padding()
}
#endif
#endif
