//
//  WatchOnlyApp.swift
//  Forescoop
//
//  Created by Javier Fuchs on 07/23/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if os(watchOS)
import SwiftUI
import Forescoop

@main
struct ForescoopWatchOnlyApp: App {
    var body: some Scene {
        WindowGroup {
            WatchForecastView()
        }
    }
}

#if DEBUG
#Preview {
    WatchForecastView(forecastService: ForecastWindguruMockup())
}
#endif

#endif
