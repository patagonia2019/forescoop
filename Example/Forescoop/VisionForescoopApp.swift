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
            VisionForecastView()
        }
        .defaultSize(width: 1_280, height: 900)
    }
}
#endif
