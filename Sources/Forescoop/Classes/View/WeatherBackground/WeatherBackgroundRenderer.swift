//
//  WeatherBackgroundRenderer.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 07/31/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

import SwiftUI

/// A weather-background treatment that can be created from one forecast hour.
public protocol WeatherBackground: View {
    init(forecast: SpotForecast, hour: String?)
}

/// The available visual renderers for a forecast background.
public enum WeatherBackgroundStyle: Sendable {
    case animated
    case metal
    case lottie
}

/// Selects one of the interchangeable weather-background renderers.
///
/// The wrapper avoids storing a `WeatherBackground` existential, whose SwiftUI
/// `Body` associated type prevents direct rendering.
public struct WeatherBackgroundRenderer: View {
    private let style: WeatherBackgroundStyle
    private let forecast: SpotForecast
    private let hour: String?

    public init(
        style: WeatherBackgroundStyle,
        forecast: SpotForecast,
        hour: String? = nil
    ) {
        self.style = style
        self.forecast = forecast
        self.hour = hour
    }

    @ViewBuilder public var body: some View {
        switch style {
        case .animated:
            AnimatedWeatherBackground(forecast: forecast, hour: hour)
        case .metal:
            MetalWeatherBackground(forecast: forecast, hour: hour)
        case .lottie:
            LottieWeatherBackground(forecast: forecast, hour: hour)
        }
    }
}
