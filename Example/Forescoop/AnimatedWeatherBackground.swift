//
//  AnimatedWeatherBackground.swift
//  Forescoop
//
//  Created by Javier Fuchs on 07/23/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

import SwiftUI

struct AnimatedWeatherBackground: View {
    let symbolNames: [String]
    let precipitationMillimeters: Double
    let windSpeedKnots: Double
    let windDirectionDegrees: Double?

    @State private var isAnimating = false

    private var isSunny: Bool { symbolNames.contains { $0.contains("sun") } }
    private var isNight: Bool { symbolNames.contains { $0.contains("moon") } }
    private var isCloudy: Bool { symbolNames.contains { $0.contains("cloud") } }
    private var isWindy: Bool { symbolNames.contains { $0 == "wind" || $0.contains("tornado") } }
    private var isRainy: Bool { symbolNames.contains { $0.contains("rain") || $0.contains("drizzle") } }
    private var isSnowy: Bool { symbolNames.contains { $0.contains("snow") } }
    private var precipitationParticleCount: Int {
        if isSnowy {
            return min(max(Int((precipitationMillimeters * 14).rounded(.up)) + 4, 5), 48)
        }
        if isRainy {
            return min(max(Int((precipitationMillimeters * 18).rounded(.up)) + 5, 6), 60)
        }
        return 0
    }
    // Windguru directions describe where wind comes from. Decorative particles travel downwind.
    private var windTravelDirectionDegrees: Double { (windDirectionDegrees ?? 270) + 180 }
    private var windTravelVector: (x: CGFloat, y: CGFloat) {
        let radians = windTravelDirectionDegrees * .pi / 180
        return (sin(radians), -cos(radians))
    }
    private var windVelocity: Double { min(max(windSpeedKnots, 0), 50) }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(
                    colors: backgroundColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                if isSunny {
                    Circle()
                        .fill(.yellow.opacity(0.30))
                        .frame(width: 220, height: 220)
                        .blur(radius: 30)
                        .offset(x: isAnimating ? proxy.size.width * 0.28 : proxy.size.width * 0.20,
                                y: isAnimating ? -proxy.size.height * 0.26 : -proxy.size.height * 0.20)
                }

                if isCloudy {
                    ForEach(0..<4, id: \.self) { index in
                        Capsule()
                            .fill(.white.opacity(0.12))
                            .frame(width: 190, height: 74)
                            .blur(radius: 18)
                            .offset(
                                x: cloudOffset(for: index, width: proxy.size.width),
                                y: CGFloat(index * 92) - proxy.size.height * 0.30
                            )
                    }
                }

                if isWindy {
                    ForEach(0..<9, id: \.self) { index in
                        Capsule()
                            .fill(.white.opacity(0.20))
                            .frame(width: CGFloat(48 + (index % 3) * 30), height: 2)
                            .rotationEffect(.degrees(windTravelDirectionDegrees - 90))
                            .offset(x: windOffset(for: index, width: proxy.size.width) * windTravelVector.x,
                                    y: windOffset(for: index, width: proxy.size.height) * windTravelVector.y)
                    }

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
        if isNight { return [.indigo.opacity(0.55), .blue.opacity(0.18), .clear] }
        if isSunny { return [.yellow.opacity(0.25), .cyan.opacity(0.17), .clear] }
        if isRainy || isSnowy { return [.blue.opacity(0.20), .gray.opacity(0.14), .clear] }
        if isWindy { return [.teal.opacity(0.20), .blue.opacity(0.12), .clear] }
        return [.gray.opacity(0.15), .blue.opacity(0.08), .clear]
    }

    private func cloudOffset(for index: Int, width: CGFloat) -> CGFloat {
        let direction: CGFloat = index.isMultiple(of: 2) ? 1 : -1
        let travel = isAnimating ? width * 0.22 : -width * 0.12
        return direction * travel + CGFloat(index * 50) - width * 0.25
    }

    private func windOffset(for index: Int, width: CGFloat) -> CGFloat {
        let start = CGFloat((index * 67) % 240) - width * 0.50
        return start + (isAnimating ? width * 0.75 : 0)
    }

    private func windLeaf(index: Int, in size: CGSize, time: TimeInterval) -> some View {
        let progress = (time * (0.025 + windVelocity * 0.002) + Double(index) * 0.17).truncatingRemainder(dividingBy: 1)
        let travel = max(size.width, size.height) * 1.35 * (CGFloat(progress) - 0.5)
        let lane = max(size.width, size.height) * (CGFloat((index * 29) % 100) / 100 - 0.5)
        let perpendicular = (x: -windTravelVector.y, y: windTravelVector.x)
        let x = windTravelVector.x * travel + perpendicular.x * lane
        let y = windTravelVector.y * travel + perpendicular.y * lane
            + CGFloat(sin(time * 1.8 + Double(index))) * 18

        return Image(systemName: "leaf.fill")
            .font(.system(size: CGFloat(10 + index % 7)))
            .foregroundStyle(index.isMultiple(of: 2) ? Color.green.opacity(0.55) : Color.brown.opacity(0.60))
            .rotationEffect(.degrees(time * Double(40 + index * 7)))
            .offset(x: x, y: y)
    }

    @ViewBuilder
    private func precipitationParticle(index: Int, in size: CGSize, time: TimeInterval) -> some View {
        let column = CGFloat((index * 37) % 100) / 100
        let speed = isSnowy ? 0.07 : 0.26
        let progress = (time * speed + Double(index) * 0.137).truncatingRemainder(dividingBy: 1)
        let y = size.height * (CGFloat(progress) - 0.55)
        let sway = CGFloat(sin(time * (isSnowy ? 1.4 : 0.7) + Double(index))) * (isSnowy ? 18 : 8)
        let rainDrift = windTravelVector.x * CGFloat(windVelocity / 50) * 42 * CGFloat(progress)
        let rainTilt = atan2(Double(rainDrift), 110) * 180 / .pi

        if isSnowy {
            Image(systemName: "snowflake")
                .font(.system(size: CGFloat(8 + index % 5)))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.white.opacity(0.55))
                .rotationEffect(.degrees(time * Double(8 + index % 7)))
                .offset(x: size.width * (column - 0.5) + sway, y: y)
        } else {
            Image(systemName: "drop.fill")
                .font(.system(size: CGFloat(9 + index % 6), weight: .medium))
                .foregroundStyle(.cyan.opacity(0.55))
                .shadow(color: .cyan.opacity(0.25), radius: 2)
                .rotationEffect(.degrees(rainTilt))
                .offset(x: size.width * (column - 0.5) + sway + rainDrift,
                        y: y + windTravelVector.y * CGFloat(windVelocity / 50) * 8)
        }
    }
}

#Preview("Sunny and windy") {
    AnimatedWeatherBackground(
        symbolNames: ["sun.max.fill", "wind"],
        precipitationMillimeters: 0,
        windSpeedKnots: 22,
        windDirectionDegrees: 270
    )
        .frame(height: 400)
}
