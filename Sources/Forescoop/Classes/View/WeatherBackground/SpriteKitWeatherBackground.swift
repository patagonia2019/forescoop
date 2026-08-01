//
//  SpriteKitWeatherBackground.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 08/01/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

import SwiftUI

#if canImport(SpriteKit) && !os(watchOS)
import SpriteKit
#if os(macOS)
import AppKit
#else
import UIKit
#endif
#endif

/// A forecast-reactive background made from SpriteKit particle sprites.
///
/// Unlike the illustrated Lottie treatments, rain, snow and leaves here react
/// to the forecast precipitation, wind strength and downwind direction.
public struct SpriteKitWeatherBackground: WeatherBackground {
    private let condition: SpriteWeatherCondition

    public init(forecast: SpotForecast, hour: String? = nil) {
        let selectedHour = hour ?? forecast.currentForecastHour
        let weather = forecast.forecast
        let symbols = forecast.weatherSymbolNames(hour: selectedHour)
        let precipitation = weather?.precipitation(hh: selectedHour)
            ?? weather?.precipitation1(hh: selectedHour)
            ?? 0
        let windDirection = weather?.windDirection(hh: selectedHour) ?? 270
        let downwindRadians = (windDirection + 180) * .pi / 180

        condition = SpriteWeatherCondition(
            isSunny: symbols.contains { $0.contains("sun") },
            isCloudy: symbols.contains { $0.contains("cloud") },
            isSnowy: symbols.contains { $0.contains("snow") },
            precipitationMillimeters: precipitation,
            windVector: CGPoint(
                x: sin(downwindRadians),
                y: -cos(downwindRadians)
            ),
            windSpeedKnots: max(
                weather?.windSpeed(hh: selectedHour) ?? 0,
                weather?.windGustsKnots(hh: selectedHour) ?? 0
            )
        )
    }

    public var body: some View {
        #if canImport(SpriteKit) && !os(watchOS)
        SpriteKitWeatherSurface(condition: condition)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        #else
        Color.clear
            .accessibilityHidden(true)
        #endif
    }
}

private struct SpriteWeatherCondition: Equatable {
    let isSunny: Bool
    let isCloudy: Bool
    let isSnowy: Bool
    let precipitationMillimeters: Double
    let windVector: CGPoint
    let windSpeedKnots: Double

    var hasPrecipitation: Bool { precipitationMillimeters > 0 }
    var hasWind: Bool { windSpeedKnots >= 12 }
    var isHeavyRain: Bool { !isSnowy && precipitationMillimeters >= 8 }
}

#if canImport(SpriteKit) && !os(watchOS)
private struct SpriteKitWeatherSurface: View {
    let condition: SpriteWeatherCondition
    @State private var scene: SpriteWeatherScene

    init(condition: SpriteWeatherCondition) {
        self.condition = condition
        _scene = State(initialValue: SpriteWeatherScene(condition: condition))
    }

    var body: some View {
        SpriteView(scene: scene, options: [.allowsTransparency])
            .onChange(of: condition) { _, newCondition in
                scene.update(condition: newCondition)
            }
    }
}

private final class SpriteWeatherScene: SKScene {
    private var condition: SpriteWeatherCondition
    private var didBuildParticles = false

    init(condition: SpriteWeatherCondition) {
        self.condition = condition
        super.init(size: CGSize(width: 1, height: 1))
        scaleMode = .resizeFill
        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        nil
    }

    override func didMove(to view: SKView) {
        rebuildParticles()
    }

    func update(condition: SpriteWeatherCondition) {
        guard self.condition != condition else { return }
        self.condition = condition
        guard didBuildParticles else { return }
        rebuildParticles()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard didBuildParticles, size != oldSize else { return }
        rebuildParticles()
    }

    private func rebuildParticles() {
        removeAllChildren()
        didBuildParticles = true

        if condition.isSunny {
            addSun()
        }
        if condition.isCloudy {
            addClouds()
        }
        if condition.hasPrecipitation {
            if condition.isSnowy {
                addChild(precipitationEmitter())
            } else {
                addRainDrops()
            }
        }
        if condition.hasWind {
            addChild(leafEmitter())
        }
        if condition.isHeavyRain {
            addLightning()
        }
    }

    private func addSun() {
        let sun = SKNode()
        sun.position = CGPoint(x: size.width * 0.78, y: size.height * 0.76)
        sun.alpha = 0.44
        sun.zPosition = -2

        let color = SKColor(red: 1, green: 0.76, blue: 0.10, alpha: 1)
        let disc = SKShapeNode(circleOfRadius: 34)
        disc.fillColor = color
        disc.strokeColor = .clear
        sun.addChild(disc)

        let rays = CGMutablePath()
        for index in 0..<8 {
            let angle = CGFloat(index) * .pi / 4
            rays.move(to: CGPoint(x: cos(angle) * 47, y: sin(angle) * 47))
            rays.addLine(to: CGPoint(x: cos(angle) * 61, y: sin(angle) * 61))
        }
        let rayNode = SKShapeNode(path: rays)
        rayNode.strokeColor = color
        rayNode.lineWidth = 4
        rayNode.lineCap = .round
        sun.addChild(rayNode)
        addChild(sun)

        let pulse = SKAction.sequence([
            .scale(to: 1.12, duration: 3.2),
            .scale(to: 0.96, duration: 3.2)
        ])
        sun.run(.repeatForever(pulse))
    }

    private func addRainDrops() {
        let wind = spriteKitWindVector
        let intensity = min(max(condition.precipitationMillimeters, 0.4), 16)
        let count = min(20 + Int(intensity * 4), 72)
        let color = SKColor(red: 0.34, green: 0.78, blue: 1, alpha: 1)

        for index in 0..<count {
            let depth = CGFloat((index * 53) % 100) / 100
            let drop = SKShapeNode(ellipseOf: CGSize(width: 3 + depth * 2, height: 8 + depth * 7))
            drop.fillColor = color
            drop.strokeColor = .clear
            drop.alpha = 0.34 + depth * 0.44
            drop.zPosition = 1
            addChild(drop)

            let startX = size.width * CGFloat((index * 37) % 100) / 100
            let endX = startX + wind.dx * (40 + CGFloat(condition.windSpeedKnots) * 2)
            let duration = 0.85 + Double(1 - depth) * 0.75
            let start = CGPoint(x: startX, y: size.height + 28)
            let end = CGPoint(x: endX, y: -28)
            drop.position = CGPoint(
                x: startX,
                y: size.height * CGFloat((index * 29) % 100) / 100
            )
            let fall = SKAction.move(to: end, duration: duration)
            let reset = SKAction.move(to: start, duration: 0)
            drop.run(.repeatForever(.sequence([fall, reset])))
        }
    }

    private func addClouds() {
        for index in 0..<3 {
            let cloud = SKSpriteNode(texture: SpriteWeatherTexture.symbol("cloud.fill"))
            cloud.position = CGPoint(
                x: -size.width * 0.20 + CGFloat(index) * size.width * 0.45,
                y: size.height * (0.68 - CGFloat(index) * 0.16)
            )
            cloud.setScale(CGFloat(5 + index * 2))
            cloud.color = .white
            cloud.colorBlendFactor = 1
            cloud.alpha = 0.10 + CGFloat(index) * 0.035
            cloud.zPosition = -1
            addChild(cloud)

            let duration = 18.0 + Double(index * 5)
            let drift = SKAction.moveTo(x: size.width * 1.20, duration: duration)
            let reset = SKAction.moveTo(x: -size.width * 0.25, duration: 0)
            cloud.run(.repeatForever(.sequence([drift, reset])))
        }
    }

    private func precipitationEmitter() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        let intensity = min(max(condition.precipitationMillimeters, 0.4), 16)
        let speed = condition.isSnowy ? 42 + intensity * 4 : 230 + intensity * 14
        let density = condition.isSnowy ? 10 + intensity * 3 : 16 + intensity * 5
        let wind = spriteKitWindVector

        emitter.particleTexture = SpriteWeatherTexture.precipitation(snow: condition.isSnowy)
        emitter.particleBirthRate = CGFloat(density)
        emitter.particleLifetime = condition.isSnowy ? 10 : 3.2
        emitter.particleLifetimeRange = condition.isSnowy ? 2 : 0.8
        emitter.particlePosition = CGPoint(x: size.width / 2, y: size.height + 36)
        emitter.particlePositionRange = CGVector(dx: size.width + 100, dy: 8)
        emitter.particleSpeed = CGFloat(speed)
        emitter.particleSpeedRange = CGFloat(speed * 0.25)
        emitter.emissionAngle = atan2(-1 + wind.dy * 0.22, wind.dx * (condition.isSnowy ? 0.70 : 0.38))
        emitter.emissionAngleRange = condition.isSnowy ? .pi / 4 : .pi / 12
        // The original long streak texture looks like falling glass in
        // SpriteKit. Rain deliberately uses a rounded SF Symbol drop instead.
        emitter.particleScale = condition.isSnowy ? 0.18 : 0.78
        emitter.particleScaleRange = condition.isSnowy ? 0.14 : 0.28
        emitter.particleScaleSpeed = condition.isSnowy ? -0.004 : 0
        // Snowflakes tumble naturally. Keep raindrops upright: their falling
        // trajectory already carries the wind direction, and rotation makes
        // a rounded drop appear to fall sideways.
        emitter.particleRotationRange = condition.isSnowy ? .pi : 0
        emitter.particleRotationSpeed = condition.isSnowy ? 0.7 : 0
        emitter.particleAlpha = condition.isSnowy ? 0.72 : 0.72
        emitter.particleAlphaRange = condition.isSnowy ? 0.22 : 0.18
        emitter.particleAlphaSpeed = condition.isSnowy ? -0.05 : -0.16
        emitter.particleColor = .white
        emitter.particleColorBlendFactor = 1
        emitter.particleBlendMode = .alpha
        return emitter
    }

    private func leafEmitter() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        let speed = min(max(condition.windSpeedKnots, 12), 50)
        let wind = spriteKitWindVector

        emitter.particleTexture = SpriteWeatherTexture.leaf()
        emitter.particleBirthRate = CGFloat(2 + speed / 7)
        emitter.particleLifetime = 8
        emitter.particleLifetimeRange = 2
        emitter.particlePosition = CGPoint(
            x: wind.dx >= 0 ? -30 : size.width + 30,
            y: size.height * 0.55
        )
        emitter.particlePositionRange = CGVector(dx: 10, dy: size.height * 1.2)
        emitter.particleSpeed = CGFloat(40 + speed * 3)
        emitter.particleSpeedRange = 35
        emitter.emissionAngle = atan2(wind.dy, wind.dx)
        emitter.emissionAngleRange = .pi / 6
        emitter.particleScale = 0.13
        emitter.particleScaleRange = 0.11
        emitter.particleRotationRange = .pi
        emitter.particleRotationSpeed = 1.8
        emitter.particleAlpha = 0.48
        emitter.particleAlphaRange = 0.2
        emitter.particleAlphaSpeed = -0.06
        emitter.particleColor = .white
        emitter.particleColorBlendFactor = 1
        return emitter
    }

    private var spriteKitWindVector: CGVector {
        // SwiftUI coordinates point downward; SpriteKit coordinates point up.
        CGVector(
            dx: condition.windVector.x,
            dy: -condition.windVector.y
        )
    }

    private func addLightning() {
        let flash = SKSpriteNode(color: .white, size: size)
        flash.position = CGPoint(x: size.width / 2, y: size.height / 2)
        flash.alpha = 0
        flash.blendMode = .add
        addChild(flash)

        let sequence = SKAction.sequence([
            .wait(forDuration: 3.5),
            .fadeAlpha(to: 0.20, duration: 0.04),
            .fadeOut(withDuration: 0.10),
            .wait(forDuration: 0.12),
            .fadeAlpha(to: 0.12, duration: 0.03),
            .fadeOut(withDuration: 0.12),
            .wait(forDuration: 4.5)
        ])
        flash.run(.repeatForever(sequence))
    }
}

private enum SpriteWeatherTexture {
    static func precipitation(snow: Bool) -> SKTexture? {
        texture(named: "snowflake-sprite")
    }

    static func leaf() -> SKTexture? {
        systemSymbol("leaf.fill")
    }

    static func symbol(_ name: String) -> SKTexture? {
        systemSymbol(name)
    }

    private static func texture(named name: String) -> SKTexture? {
        guard let url = Bundle.module.url(forResource: name, withExtension: "png") else {
            return nil
        }
#if os(macOS)
        return NSImage(contentsOf: url).map(SKTexture.init(image:))
#else
        return UIImage(contentsOfFile: url.path).map(SKTexture.init(image:))
#endif
    }

    private static func systemSymbol(_ name: String) -> SKTexture? {
#if os(macOS)
        return NSImage(systemSymbolName: name, accessibilityDescription: nil).map(SKTexture.init(image:))
#else
        return UIImage(systemName: name).map(SKTexture.init(image:))
#endif
    }
}
#endif

#Preview("SpriteKit rain") {
    SpriteKitWeatherBackground(
        forecast: AnimatedWeatherPreviewData.forecast(precipitation: 5, temperature: 11, cloudCover: 95, windSpeed: 16, gusts: 24),
        hour: "29"
    )
    .frame(height: 400)
}

#Preview("SpriteKit sunny") {
    SpriteKitWeatherBackground(
        forecast: AnimatedWeatherPreviewData.forecast(precipitation: 0, temperature: 24, cloudCover: 0, windSpeed: 5, gusts: 8),
        hour: "29"
    )
    .frame(height: 400)
}

#Preview("SpriteKit cloudy") {
    SpriteKitWeatherBackground(
        forecast: AnimatedWeatherPreviewData.forecast(precipitation: 0, temperature: 15, cloudCover: 95, windSpeed: 7, gusts: 12),
        hour: "29"
    )
    .frame(height: 400)
}

#Preview("SpriteKit snow and wind") {
    SpriteKitWeatherBackground(
        forecast: AnimatedWeatherPreviewData.forecast(precipitation: 4, temperature: -3, cloudCover: 95, windSpeed: 22, gusts: 32),
        hour: "29"
    )
    .frame(height: 400)
}
