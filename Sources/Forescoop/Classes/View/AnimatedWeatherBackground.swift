//
//  AnimatedWeatherBackground.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 07/23/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

import SwiftUI

public struct AnimatedWeatherBackground: View {
    let symbolNames: [String]
    let precipitationMillimeters: Double
    let windSpeedKnots: Double
    let windDirectionDegrees: Double?
    let windGustKnots: Double
    let cloudCoverPercent: Int
    let temperatureCelsius: Double
    let humidityPercent: Int
    let pressureHectopascals: Double?
    let forecastDate: Date

    @Environment(\.colorScheme) private var colorScheme
    @State private var isAnimating = false

    /// Creates the animation from a forecast at the selected (or current) hour.
    public init(forecast: SpotForecast, hour: String? = nil) {
        let selectedHour = hour ?? forecast.currentForecastHour
        let weather = forecast.forecast
        symbolNames = forecast.weatherSymbolNames(hour: selectedHour)
        precipitationMillimeters = weather?.precipitation(hh: selectedHour) ?? weather?.precipitation1(hh: selectedHour) ?? 0
        windSpeedKnots = weather?.windSpeed(hh: selectedHour) ?? 0
        windDirectionDegrees = weather?.windDirection(hh: selectedHour)
        windGustKnots = weather?.windGustsKnots(hh: selectedHour) ?? 0
        cloudCoverPercent = weather?.cloudCoverTotal(hh: selectedHour) ?? 0
        temperatureCelsius = weather?.temperatureReal(hh: selectedHour) ?? weather?.temperature(hh: selectedHour) ?? 0
        humidityPercent = weather?.relativeHumidity(hh: selectedHour) ?? 0
        pressureHectopascals = weather?.seaLevelPressure(hh: selectedHour)
        forecastDate = forecast.forecastDate(hour: selectedHour) ?? Date()
    }

    private var isSunny: Bool { symbolNames.contains { $0.contains("sun") } }
    private var isNight: Bool { symbolNames.contains { $0.contains("moon") } }
    private var isCloudy: Bool { symbolNames.contains { $0.contains("cloud") } }
    private var isWindy: Bool { symbolNames.contains { $0 == "wind" || $0.contains("tornado") } }
    private var isRainy: Bool { symbolNames.contains { $0.contains("rain") || $0.contains("drizzle") } }
    private var isSnowy: Bool { symbolNames.contains { $0.contains("snow") } }
    private var isFoggy: Bool { symbolNames.contains { $0.contains("fog") } || (humidityPercent >= 95 && cloudCoverPercent >= 80) }
    private var isHeavyRain: Bool { isRainy && precipitationMillimeters >= 8 }
    private var isFreezing: Bool { temperatureCelsius <= 0 }
    private var isHot: Bool { temperatureCelsius >= 30 }
    private var usesPressurePulse: Bool { (pressureHectopascals ?? 1_013) < 995 || (pressureHectopascals ?? 1_013) > 1_030 }
    private var cloudParticleCount: Int { min(max(cloudCoverPercent / 25, 1), 4) }
    private var precipitationParticleCount: Int {
        if isSnowy {
            return min(max(Int((precipitationMillimeters * 18).rounded(.up)) + 16, 32), 72)
        }
        if isRainy {
            return min(max(Int((precipitationMillimeters * 10).rounded(.up)) + 18, 26), 72)
        }
        return 0
    }
    // Windguru directions describe where wind comes from. Decorative particles travel downwind.
    private var windTravelDirectionDegrees: Double { (windDirectionDegrees ?? 270) + 180 }
    private var windTravelVector: (x: CGFloat, y: CGFloat) {
        let radians = windTravelDirectionDegrees * .pi / 180
        return (sin(radians), -cos(radians))
    }
    private var windVelocity: Double { min(max(max(windSpeedKnots, windGustKnots), 0), 50) }
    private var isTwilight: Bool {
        let hour = Calendar.current.component(.hour, from: forecastDate)
        return (5...7).contains(hour) || (18...20).contains(hour)
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color(colorScheme == .dark ? .black : .white)

                LinearGradient(
                    colors: backgroundColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                if isTwilight {
                    LinearGradient(
                        colors: [.orange.opacity(0.28), .pink.opacity(0.12), .clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                }

                if isSunny {
                    Circle()
                        .fill(.yellow.opacity(0.30))
                        .frame(width: 220, height: 220)
                        .blur(radius: 30)
                        .scaleEffect(isAnimating ? 1.08 : 0.92)
                        .offset(x: isAnimating ? proxy.size.width * 0.28 : proxy.size.width * 0.20,
                                y: isAnimating ? -proxy.size.height * 0.26 : -proxy.size.height * 0.20)
                }

                if isCloudy {
                    ForEach(0..<cloudParticleCount, id: \.self) { index in
                        Image(systemName: "cloud.fill")
                            .font(.system(size: CGFloat(88 + (index % 2) * 36)))
                            .foregroundStyle(.white.opacity(0.08 + Double(cloudCoverPercent) / 1_000))
                            .blur(radius: 8)
                            .offset(
                                x: cloudOffset(for: index, width: proxy.size.width),
                                y: CGFloat(index * 92) - proxy.size.height * 0.30
                            )
                    }
                }

                if isFoggy {
                    ForEach(0..<3, id: \.self) { index in
                        Capsule()
                            .fill(.white.opacity(0.10))
                            .frame(width: proxy.size.width * 0.82, height: 56)
                            .blur(radius: 18)
                            .offset(
                                x: isAnimating ? proxy.size.width * 0.18 : -proxy.size.width * 0.18,
                                y: proxy.size.height * (CGFloat(index) * 0.15 - 0.12)
                            )
                    }
                }

                if isNight {
                    TimelineView(.animation) { timeline in
                        let time = timeline.date.timeIntervalSinceReferenceDate
                        ForEach(0..<12, id: \.self) { index in
                            nightSparkle(index: index, in: proxy.size, time: time)
                        }
                    }
                }

                if isWindy {
                    TimelineView(.animation) { timeline in
                        let time = timeline.date.timeIntervalSinceReferenceDate
                        ForEach(0..<12, id: \.self) { index in
                            windLeaf(index: index, in: proxy.size, time: time)
                        }
                    }
                }

                if isRainy || isSnowy {
                    if isRainy {
                        LinearGradient(
                            colors: [.indigo.opacity(0.18), .clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    }

                    TimelineView(.animation) { timeline in
                        let time = timeline.date.timeIntervalSinceReferenceDate
                        ForEach(0..<precipitationParticleCount, id: \.self) { index in
                            precipitationParticle(index: index, in: proxy.size, time: time)
                        }
                    }
                }

                if isFreezing {
                    LinearGradient(
                        colors: [.cyan.opacity(0.10), .clear, .cyan.opacity(0.06)],
                        startPoint: isAnimating ? .topLeading : .bottomTrailing,
                        endPoint: isAnimating ? .bottomTrailing : .topLeading
                    )
                } else if isHot {
                    RadialGradient(
                        colors: [.orange.opacity(0.16), .clear],
                        center: .topTrailing,
                        startRadius: 20,
                        endRadius: max(proxy.size.width, proxy.size.height) * 0.75
                    )
                }

                if usesPressurePulse {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(.white.opacity(0.10), lineWidth: 1)
                            .scaleEffect(isAnimating ? CGFloat(1.2 + Double(index) * 0.28) : CGFloat(0.8 + Double(index) * 0.28))
                            .offset(x: proxy.size.width * 0.32, y: -proxy.size.height * 0.26)
                    }
                }

                if isHeavyRain {
                    TimelineView(.animation) { timeline in
                        Color.white
                            .opacity(lightningOpacity(at: timeline.date) * 0.22)
                            .blendMode(.screen)
                    }
                }
            }
            .scaleEffect(1.10)
            .offset(
                x: isAnimating ? 22 : -22,
                y: isAnimating ? -14 : 14
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
        }
        .clipped()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var backgroundColors: [Color] {
        let intensity = colorScheme == .dark ? 1.65 : 1.0
        if isNight { return [.indigo.opacity(0.55 * intensity), .blue.opacity(0.18 * intensity), .clear] }
        if isSunny { return [.yellow.opacity(0.25 * intensity), .cyan.opacity(0.17 * intensity), .clear] }
        if isRainy || isSnowy { return [.blue.opacity(0.20 * intensity), .gray.opacity(0.14 * intensity), .clear] }
        if isWindy { return [.teal.opacity(0.20 * intensity), .blue.opacity(0.12 * intensity), .clear] }
        return [.gray.opacity(0.15 * intensity), .blue.opacity(0.08 * intensity), .clear]
    }

    private func cloudOffset(for index: Int, width: CGFloat) -> CGFloat {
        let direction: CGFloat = index.isMultiple(of: 2) ? 1 : -1
        let travel = isAnimating ? width * 0.22 : -width * 0.12
        return direction * travel + CGFloat(index * 50) - width * 0.25
    }

    private func nightSparkle(index: Int, in size: CGSize, time: TimeInterval) -> some View {
        let x = size.width * (CGFloat((index * 37) % 100) / 100 - 0.5)
        let y = size.height * (CGFloat((index * 61) % 70) / 100 - 0.45)
        let pulse = 0.25 + 0.35 * (sin(time * 1.4 + Double(index)) + 1) / 2

        return Image(systemName: "sparkle")
            .font(.system(size: CGFloat(7 + index % 5)))
            .foregroundStyle(.white.opacity(pulse))
            .offset(x: x, y: y)
    }

    private func lightningOpacity(at date: Date) -> Double {
        let cycle = date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 5.8)
        return (0.08...0.18).contains(cycle) || (0.28...0.34).contains(cycle) ? 0.85 : 0
    }

    private func windLeaf(index: Int, in size: CGSize, time: TimeInterval) -> some View {
        let progress = (time * (0.025 + windVelocity * 0.002) + Double(index) * 0.17).truncatingRemainder(dividingBy: 1)
        let travel = max(size.width, size.height) * 1.35 * (CGFloat(progress) - 0.5)
        let lane = max(size.width, size.height) * (CGFloat((index * 29) % 100) / 100 - 0.5)
        let perpendicular = (x: -windTravelVector.y, y: windTravelVector.x)
        let x = windTravelVector.x * travel + perpendicular.x * lane
        let y = windTravelVector.y * travel + perpendicular.y * lane
            + CGFloat(sin(time * 1.8 + Double(index))) * 18

        let symbolName: String
        switch index % 5 {
        case 3:
            // `feather.fill` is not present in every SF Symbols catalog.
            // Keep the foliage particle with the widely available leaf symbol.
            symbolName = "leaf.fill"
        case 4:
            symbolName = "sparkles"
        default:
            symbolName = "leaf.fill"
        }

        return Image(systemName: symbolName)
            .font(.system(size: CGFloat(10 + index % 7)))
            .foregroundStyle(particleColor(for: symbolName, index: index))
            .rotationEffect(.degrees(time * Double(40 + index * 7)))
            .offset(x: x, y: y)
    }

    private func particleColor(for symbolName: String, index: Int) -> Color {
        switch symbolName {
        case "leaf.fill":
            .white.opacity(0.5)
        case "sparkles":
            .cyan.opacity(0.55)
        default:
            index.isMultiple(of: 2) ? .green.opacity(0.55) : .brown.opacity(0.60)
        }
    }

    @ViewBuilder
    private func precipitationParticle(index: Int, in size: CGSize, time: TimeInterval) -> some View {
        let column = CGFloat((index * 37) % 100) / 100
        // A deterministic depth value gives foreground particles more size and speed.
        let depth = CGFloat((index * 53) % 100) / 100
        let speed = isSnowy ? 0.075 + Double(depth) * 0.09 : 0.16 + Double(depth) * 0.17
        let progress = (time * speed + Double(index) * 0.137).truncatingRemainder(dividingBy: 1)
        let y = size.height * (CGFloat(progress) - 0.55)
        let sway = CGFloat(sin(time * (isSnowy ? 1.4 : 0.7) + Double(index))) * (isSnowy ? 26 : 5)
        let windStrength = CGFloat(windVelocity / 50)
        let windTravel = windStrength * (isSnowy ? 125 : 58) * CGFloat(progress)
        let windDriftX = windTravelVector.x * windTravel
        // Gravity remains dominant while the precipitation is carried slightly downwind.
        let windDriftY = windTravelVector.y * windTravel * 0.20
        let rainTilt = atan2(Double(windDriftX), 150) * 180 / .pi

        if isSnowy {
            Image(systemName: "snowflake")
                .font(.system(size: 7 + depth * 8))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.white.opacity(0.25 + Double(depth) * 0.50))
                .rotationEffect(.degrees(time * (14 + Double(index % 7))))
                .offset(x: size.width * (column - 0.5) + sway + windDriftX,
                        y: y + windDriftY)
        } else {
            Image(systemName: "drop.fill")
                .font(.system(size: 8 + depth * (isHeavyRain ? 10 : 6), weight: .medium))
                .foregroundStyle((isHeavyRain ? Color.blue : Color.cyan).opacity(0.22 + Double(depth) * (isHeavyRain ? 0.60 : 0.42)))
                .shadow(color: .cyan.opacity(0.22), radius: isHeavyRain ? 2 : 1)
                .rotationEffect(.degrees(rainTilt))
                .offset(x: size.width * (column - 0.5) + sway + windDriftX,
                        y: y + windDriftY)
        }
    }
}

private enum AnimatedWeatherPreviewData {
    static func forecast(
        precipitation: Double,
        temperature: Double,
        cloudCover: Int,
        windSpeed: Double,
        gusts: Double
    ) -> SpotForecast {
        guard var response = Definition().json(jsonFile: "SpotForecast"),
              var forecasts = response["forecast"] as? [String: Any] else {
            fatalError("Missing SpotForecast preview fixture")
        }

        response["sunrise"] = "00:00"
        response["sunset"] = "23:59"
        for identifier in forecasts.keys {
            guard var model = forecasts[identifier] as? [String: Any] else { continue }
            set(precipitation, for: ["APCP", "APCP1"], in: &model)
            set(temperature, for: ["TMP", "TMPE"], in: &model)
            set(cloudCover, for: ["TCDC"], in: &model)
            set(windSpeed, for: ["WINDSPD"], in: &model)
            set(gusts, for: ["GUST"], in: &model)
            forecasts[identifier] = model
        }
        response["forecast"] = forecasts
        return try! SpotForecast(map: response)!
    }

    private static func set(_ value: Any, for keys: [String], in model: inout [String: Any]) {
        for key in keys {
            guard var values = model[key] as? [String: Any] else { continue }
            values["29"] = value
            model[key] = values
        }
    }
}

#Preview("Sunny") {
    AnimatedWeatherBackground(
        forecast: AnimatedWeatherPreviewData.forecast(precipitation: 0, temperature: 23, cloudCover: 0, windSpeed: 7, gusts: 10),
        hour: "29"
    )
    .frame(height: 400)
}

#Preview("Rain") {
    AnimatedWeatherBackground(
        forecast: AnimatedWeatherPreviewData.forecast(precipitation: 3, temperature: 11, cloudCover: 95, windSpeed: 14, gusts: 20),
        hour: "29"
    )
    .frame(height: 400)
}

#Preview("Snow") {
    AnimatedWeatherBackground(
        forecast: AnimatedWeatherPreviewData.forecast(precipitation: 4, temperature: -3, cloudCover: 95, windSpeed: 12, gusts: 18),
        hour: "29"
    )
    .frame(height: 400)
}

#Preview("Heavy rain and lightning") {
    AnimatedWeatherBackground(
        forecast: AnimatedWeatherPreviewData.forecast(precipitation: 12, temperature: 14, cloudCover: 100, windSpeed: 28, gusts: 45),
        hour: "29"
    )
        .frame(height: 400)
}
