//
//  VisionForescoopApp.swift
//  Forescoop
//
//  Created by Javier Fuchs on 07/23/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if os(visionOS)
import SwiftUI
import Forescoop

@main
struct VisionForescoopApp: App {
    var body: some Scene {
        WindowGroup {
            VisionForecastWindow()
        }
        .defaultSize(width: 1_100, height: 720)

        WindowGroup(id: "locations") {
            VisionLocationsView()
        }
        .defaultSize(width: 900, height: 680)
    }
}

private struct VisionForecastWindow: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VisionForecastView {
            openWindow(id: "locations")
        }
    }
}
#endif
