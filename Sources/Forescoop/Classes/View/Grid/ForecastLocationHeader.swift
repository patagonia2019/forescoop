//
//  ForecastLocationHeader.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 08/01/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if !os(watchOS)
import SwiftUI

/// Location and map actions shared by dashboard and grid forecast headers.
struct ForecastLocationHeader: View {
    let locationName: String
    let onSelectLocation: () -> Void
    let onShowMap: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onSelectLocation) {
                Label(locationName, systemImage: "mappin.and.ellipse")
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Choose location")

#if !os(tvOS)
            LocationMapButton(
                locationName: locationName,
                buttonStyle: .plain,
                action: onShowMap
            )
#endif
        }
        .font(.title.bold())
        .foregroundStyle(.blue)
    }
}

#if DEBUG
#Preview("Forecast location header") {
    ForecastLocationHeader(
        locationName: "Bariloche #64141",
        onSelectLocation: {},
        onShowMap: {}
    )
    .padding()
}
#endif
#endif
