//
//  LottieWeatherBackground.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 07/31/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

import SwiftUI

#if canImport(Lottie)
import Lottie

/// A locally bundled, designer-authored weather animation.
/// Missing animations safely fall back to the native SwiftUI background, so the
/// app remains fully offline and usable.
public struct LottieWeatherBackground: WeatherBackground {
    private let forecast: SpotForecast
    private let hour: String?
    private let asset: LottieWeatherAsset?

    public init(forecast: SpotForecast, hour: String? = nil) {
        self.forecast = forecast
        self.hour = hour
        asset = Self.animationAsset(for: forecast, hour: hour)
    }

    public var body: some View {
        if let asset, asset.isAvailable {
            LottieWeatherAnimationView(asset: asset)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(0.30)
                .accessibilityHidden(true)
                .allowsHitTesting(false)
        } else {
            AnimatedWeatherBackground(forecast: forecast, hour: hour)
        }
    }

    private static func animationAsset(for forecast: SpotForecast, hour: String?) -> LottieWeatherAsset? {
        let selectedHour = hour ?? forecast.currentForecastHour
        let weather = forecast.forecast
        let symbols = forecast.weatherSymbolNames(hour: selectedHour)
        let precipitation = weather?.precipitation(hh: selectedHour)
            ?? weather?.precipitation1(hh: selectedHour)
            ?? 0
        let windSpeed = weather?.windSpeed(hh: selectedHour) ?? 0
        let gusts = weather?.windGustsKnots(hh: selectedHour) ?? 0
        let isNight = symbols.contains { $0.contains("moon") || $0.contains("stars") }
        let dayOrNight = isNight ? "Weather Night - " : "Weather Day - "
        let brokenClouds: LottieWeatherAsset = isNight
            ? .dotLottie("Weather Night - Broken clouds")
            : .dotLottie("Weather Day - broken clouds")

        if symbols.contains(where: { $0.contains("snow") }) { return .dotLottie(dayOrNight + "snow") }
        if precipitation >= 8 { return .dotLottie(dayOrNight + "thunderstorm") }
        if precipitation > 0 { return .dotLottie(dayOrNight + "rain") }
        if symbols.contains(where: { $0.contains("fog") }) {
            return .dotLottie(dayOrNight + "mist")
        }
        // The supplied set has no dedicated wind artwork; use moving broken clouds.
        if max(windSpeed, gusts) >= 18 { return brokenClouds }
        let cloudCover = weather?.cloudCoverTotal(hh: selectedHour) ?? 0
        if cloudCover >= 80 { return brokenClouds }
        if cloudCover > 0 {
            return isNight
                ? .dotLottie("Weather Night - Few clouds")
                : .dotLottie("Weather Day - few clouds")
        }
        return isNight
            ? .dotLottie("Weather Night - Few clouds")
            : .dotLottie("Weather Day - clear sky")
    }
}

private enum LottieWeatherAsset {
    case dotLottie(String)

    var isAvailable: Bool {
        Bundle.module.url(forResource: name, withExtension: "lottie") != nil
    }

    private var name: String {
        switch self {
        case let .dotLottie(name): name
        }
    }
}

private struct LottieWeatherAnimationView: View {
    let asset: LottieWeatherAsset

    @ViewBuilder var body: some View {
        switch asset {
        case let .dotLottie(name):
            switch DotLottieFile.SynchronouslyBlockingCurrentThread.named(name, bundle: .module) {
            case let .success(file):
                LottieView(dotLottieFile: file)
                    .resizable()
                    .configure(\.contentMode, to: .scaleAspectFill)
                    .playing(loopMode: .loop)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .failure:
                Color.clear
            }
        }
    }
}

private struct LottieAssetPreview: View {
    let name: String

    var body: some View {
        LottieWeatherAnimationView(asset: .dotLottie(name))
            .frame(height: 400)
            .background(.black.opacity(0.08))
    }
}

#Preview("Day · clear sky") { LottieAssetPreview(name: "Weather Day - clear sky") }
#Preview("Day · few clouds") { LottieAssetPreview(name: "Weather Day - few clouds") }
#Preview("Day · scattered clouds") { LottieAssetPreview(name: "Weather Day - scattered clouds") }
#Preview("Day · broken clouds") { LottieAssetPreview(name: "Weather Day - broken clouds") }
#Preview("Day · mist") { LottieAssetPreview(name: "Weather Day - mist") }
#Preview("Day · rain") { LottieAssetPreview(name: "Weather Day - rain") }
#Preview("Day · shower rains") { LottieAssetPreview(name: "Weather Day - Shower rains") }
#Preview("Day · snow") { LottieAssetPreview(name: "Weather Day - snow") }
#Preview("Day · thunderstorm") { LottieAssetPreview(name: "Weather Day - thunderstorm") }

#Preview("Night · few clouds") { LottieAssetPreview(name: "Weather Night - Few clouds") }
#Preview("Night · scattered clouds") { LottieAssetPreview(name: "Weather Night - Scattered clouds") }
#Preview("Night · broken clouds") { LottieAssetPreview(name: "Weather Night - Broken clouds") }
#Preview("Night · mist") { LottieAssetPreview(name: "Weather Night - mist") }
#Preview("Night · rain") { LottieAssetPreview(name: "Weather Night - rain") }
#Preview("Night · shower rains") { LottieAssetPreview(name: "Weather Night - Shower rains") }
#Preview("Night · snow") { LottieAssetPreview(name: "Weather Night - snow") }
#Preview("Night · thunderstorm") { LottieAssetPreview(name: "Weather Night - Thunderstorm") }
#else
/// Native fallback on platforms where the Lottie framework is unavailable.
public struct LottieWeatherBackground: WeatherBackground {
    private let forecast: SpotForecast
    private let hour: String?

    public init(forecast: SpotForecast, hour: String? = nil) {
        self.forecast = forecast
        self.hour = hour
    }

    public var body: some View {
        AnimatedWeatherBackground(forecast: forecast, hour: hour)
    }
}
#endif
