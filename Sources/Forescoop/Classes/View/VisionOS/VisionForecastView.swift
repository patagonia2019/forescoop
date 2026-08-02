//
//  VisionForecastView.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 08/02/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if os(visionOS)
import SwiftUI

/// The visionOS entry point for Ventus.
///
/// It deliberately hosts the shared dashboard instead of maintaining a
/// separate summary-only experience. This keeps the forecast grid, dashboard,
/// combined workspace, model comparison, location picker, account, and unit
/// controls consistent across Apple platforms.
@MainActor
public struct VisionForecastView: View {
    private let forecastService: ForecastWindguruProtocol

    public init(forecastService: ForecastWindguruProtocol = ForecastWindguruService()) {
        self.forecastService = forecastService
    }

    public var body: some View {
        ForecastDashboardView(forecastService: forecastService)
    }
}

#Preview(windowStyle: .automatic) {
    VisionForecastView(forecastService: ForecastWindguruMockup())
}
#endif
