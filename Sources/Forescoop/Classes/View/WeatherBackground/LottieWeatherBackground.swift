//
//  LottieWeatherBackground.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 07/31/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

import SwiftUI

/// The bundled Lottie artwork collections available in Ventus.
enum LottieWeatherTheme {
    case adrianaMandjarova
    case asadAwan
}

#if canImport(Lottie)
import Lottie

/// A locally bundled, designer-authored weather animation.
/// Missing animations safely fall back to the native SwiftUI background, so the
/// app remains fully offline and usable.
public struct LottieWeatherBackground: WeatherBackground {
    private let forecast: SpotForecast
    private let hour: String?
    private let asset: LottieWeatherAsset?
    private let showsRainbow: Bool

    public init(forecast: SpotForecast, hour: String? = nil) {
        self.init(forecast: forecast, hour: hour, theme: .adrianaMandjarova)
    }

    init(forecast: SpotForecast, hour: String? = nil, theme: LottieWeatherTheme) {
        self.forecast = forecast
        self.hour = hour
        asset = Self.animationAsset(for: forecast, hour: hour, theme: theme)
        showsRainbow = Self.showsRainbow(for: forecast, hour: hour)
    }

    public var body: some View {
        if let asset, asset.isAvailable {
            LottieWeatherAnimationView(asset: asset)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(0.30)
                .overlay { WeatherRainbowOverlay(isVisible: showsRainbow) }
                .accessibilityHidden(true)
                .allowsHitTesting(false)
        } else {
            AnimatedWeatherBackground(forecast: forecast, hour: hour)
        }
    }

    private static func animationAsset(
        for forecast: SpotForecast,
        hour: String?,
        theme: LottieWeatherTheme
    ) -> LottieWeatherAsset? {
        let selectedHour = hour ?? forecast.currentForecastHour
        let weather = forecast.forecast
        let symbols = forecast.weatherSymbolNames(hour: selectedHour)
        let precipitation = weather?.precipitation(hh: selectedHour)
            ?? weather?.precipitation1(hh: selectedHour)
            ?? 0
        let windSpeed = weather?.windSpeed(hh: selectedHour) ?? 0
        let gusts = weather?.windGustsKnots(hh: selectedHour) ?? 0
        let cloudCover = weather?.cloudCoverTotal(hh: selectedHour) ?? 0

        switch theme {
        case .adrianaMandjarova:
            return adrianaAsset(
                symbols: symbols,
                precipitation: precipitation,
                windSpeed: windSpeed,
                gusts: gusts,
                cloudCover: cloudCover
            )
        case .asadAwan:
            return asadAsset(
                symbols: symbols,
                precipitation: precipitation,
                windSpeed: windSpeed,
                gusts: gusts,
                cloudCover: cloudCover
            )
        }
    }

    private static func showsRainbow(for forecast: SpotForecast, hour: String?) -> Bool {
        let selectedHour = hour ?? forecast.currentForecastHour
        let weather = forecast.forecast
        let symbols = forecast.weatherSymbolNames(hour: selectedHour)
        let precipitation = weather?.precipitation(hh: selectedHour)
            ?? weather?.precipitation1(hh: selectedHour)
            ?? 0
        return symbols.contains { $0.contains("sun") }
            && precipitation > 0
            && !symbols.contains(where: { $0.contains("snow") })
    }

    private static func adrianaAsset(
        symbols: [String],
        precipitation: Double,
        windSpeed: Double,
        gusts: Double,
        cloudCover: Int
    ) -> LottieWeatherAsset {
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

    private static func asadAsset(
        symbols: [String],
        precipitation: Double,
        windSpeed: Double,
        gusts: Double,
        cloudCover: Int
    ) -> LottieWeatherAsset {
        if symbols.contains(where: { $0.contains("snow") }) { return .dotLottie("Snow Day") }
        if precipitation >= 8 { return .dotLottie("Thunder Night") }
        if precipitation > 0 { return .dotLottie("Rainy Day") }
        if symbols.contains(where: { $0.contains("fog") }) || max(windSpeed, gusts) >= 18 || cloudCover > 0 {
            return .dotLottie("Cloudy Day")
        }
        return .dotLottie("Clear Day")
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

#Preview("Asad · clear day") { LottieAssetPreview(name: "Clear Day") }
#Preview("Asad · cloudy day") { LottieAssetPreview(name: "Cloudy Day") }
#Preview("Asad · rainy day") { LottieAssetPreview(name: "Rainy Day") }
#Preview("Asad · snow day") { LottieAssetPreview(name: "Snow Day") }
#Preview("Asad · thunder night") { LottieAssetPreview(name: "Thunder Night") }

#Preview("Lottie · sun shower rainbow") {
    LottieWeatherBackground(
        forecast: AnimatedWeatherPreviewData.forecast(precipitation: 2, temperature: 18, cloudCover: 25, windSpeed: 8, gusts: 13),
        hour: "29"
    )
    .frame(height: 400)
}

#Preview("Lottie Asad · sun shower rainbow") {
    LottieWeatherBackground(
        forecast: AnimatedWeatherPreviewData.forecast(precipitation: 2, temperature: 18, cloudCover: 25, windSpeed: 8, gusts: 13),
        hour: "29",
        theme: .asadAwan
    )
    .frame(height: 400)
}
#else
/// Native fallback on platforms where the Lottie framework is unavailable.
public struct LottieWeatherBackground: WeatherBackground {
    private let forecast: SpotForecast
    private let hour: String?

    public init(forecast: SpotForecast, hour: String? = nil) {
        self.forecast = forecast
        self.hour = hour
    }

    init(forecast: SpotForecast, hour: String? = nil, theme: LottieWeatherTheme) {
        self.init(forecast: forecast, hour: hour)
    }

    public var body: some View {
        AnimatedWeatherBackground(forecast: forecast, hour: hour)
    }
}
#endif
