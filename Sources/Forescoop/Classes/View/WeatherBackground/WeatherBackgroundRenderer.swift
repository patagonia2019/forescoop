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
public enum WeatherBackgroundStyle: String, CaseIterable, Identifiable, Sendable {
    case animated
    case metal
    case spriteKit
    case lottieAdriana
    case lottieAsad

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .animated: "Native"
        case .metal: "Metal"
        case .spriteKit: "SpriteKit"
        case .lottieAdriana: "Lottie – Adriana"
        case .lottieAsad: "Lottie – Asad"
        }
    }

    public var systemImage: String {
        switch self {
        case .animated: "sparkles"
        case .metal: "cpu"
        case .spriteKit: "leaf.arrow.circlepath"
        case .lottieAdriana, .lottieAsad: "play.rectangle"
        }
    }
}

/// Selects one of the interchangeable weather-background renderers.
///
/// The wrapper avoids storing a `WeatherBackground` existential, whose SwiftUI
/// `Body` associated type prevents direct rendering.
public struct WeatherBackgroundRenderer: View {
    private let style: WeatherBackgroundStyle
    private let forecast: SpotForecast
    private let hour: String?
    private let isNight: Bool
    private let showsStars: Bool

    public init(
        style: WeatherBackgroundStyle,
        forecast: SpotForecast,
        hour: String? = nil
    ) {
        self.style = style
        self.forecast = forecast
        self.hour = hour
        let selectedHour = hour ?? forecast.currentForecastHour
        let symbols = forecast.weatherSymbolNames(hour: selectedHour)
        let hasClouds = symbols.contains { $0.contains("cloud") || $0.contains("fog") }
        let precipitation = forecast.forecast?.precipitation(hh: selectedHour)
            ?? forecast.forecast?.precipitation1(hh: selectedHour)
            ?? 0
        isNight = !forecast.isDaylight(at: forecast.forecastDate(hour: selectedHour) ?? Date())
        showsStars = !hasClouds && precipitation <= 0
    }

    public var body: some View {
        Group {
            switch style {
            case .animated:
                AnimatedWeatherBackground(forecast: forecast, hour: hour)
            case .metal:
                MetalWeatherBackground(forecast: forecast, hour: hour)
            case .spriteKit:
                SpriteKitWeatherBackground(forecast: forecast, hour: hour)
            case .lottieAdriana:
                LottieWeatherBackground(forecast: forecast, hour: hour, theme: .adrianaMandjarova)
            case .lottieAsad:
                LottieWeatherBackground(forecast: forecast, hour: hour, theme: .asadAwan)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .overlay {
            // Native rendering already paints its own stars; the other engines
            // receive this layer so nighttime never presents daytime sun art.
            if style != .animated {
                WeatherNightSkyOverlay(isVisible: isNight, showsStars: showsStars)
            }
        }
    }
}
