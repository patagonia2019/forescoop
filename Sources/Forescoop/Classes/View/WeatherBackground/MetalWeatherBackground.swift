//
//  MetalWeatherBackground.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 07/30/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

import SwiftUI

#if canImport(MetalKit) && !os(watchOS)
import MetalKit
#endif

/// Experimental GPU-rendered weather background.
///
/// This is intentionally separate from `AnimatedWeatherBackground` so the two
/// visual treatments can be evaluated independently. It accepts the forecast,
/// rather than individual weather values, just like the SwiftUI implementation.
public struct MetalWeatherBackground: WeatherBackground {
    private let condition: MetalWeatherCondition

    public init(forecast: SpotForecast, hour: String? = nil) {
        let selectedHour = hour ?? forecast.currentForecastHour
        let weather = forecast.forecast
        let precipitation = weather?.precipitation(hh: selectedHour) ?? weather?.precipitation1(hh: selectedHour) ?? 0
        let symbols = forecast.weatherSymbolNames(hour: selectedHour)
        let direction = weather?.windDirection(hh: selectedHour) ?? 270
        let downwindDirection = (direction + 180) * .pi / 180
        let windSpeed = max(weather?.windSpeed(hh: selectedHour) ?? 0, weather?.windGustsKnots(hh: selectedHour) ?? 0)

        condition = MetalWeatherCondition(
            isSnowy: symbols.contains { $0.contains("snow") },
            precipitationMillimeters: precipitation,
            windVector: SIMD2(Float(sin(downwindDirection)), Float(-cos(downwindDirection))),
            windSpeedKnots: windSpeed
        )
    }

    public var body: some View {
        #if canImport(MetalKit) && !os(watchOS)
        MetalWeatherSurface(condition: condition)
            .background(.black.opacity(0.48))
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        #else
        Color.clear
            .accessibilityHidden(true)
        #endif
    }
}

private struct MetalWeatherCondition: Equatable {
    let isSnowy: Bool
    let precipitationMillimeters: Double
    let windVector: SIMD2<Float>
    let windSpeedKnots: Double

    var hasPrecipitation: Bool { precipitationMillimeters > 0 }
    var hasWind: Bool { windSpeedKnots >= 12 }
    var hasEffect: Bool { hasPrecipitation || hasWind }
    var isHeavyRain: Bool { !isSnowy && precipitationMillimeters >= 8 }
}

#if canImport(MetalKit) && !os(watchOS)
    #if os(macOS)
    private typealias PlatformViewRepresentable = NSViewRepresentable
    #else
    private typealias PlatformViewRepresentable = UIViewRepresentable
    #endif

private struct MetalWeatherSurface: PlatformViewRepresentable {
    let condition: MetalWeatherCondition

    func makeCoordinator() -> MetalWeatherRenderer? {
        guard let device = MTLCreateSystemDefaultDevice() else { return nil }
        return MetalWeatherRenderer(device: device, condition: condition)
    }

    #if os(macOS)
    func makeNSView(context: Context) -> MTKView {
        makeView(renderer: context.coordinator)
    }

    func updateNSView(_ view: MTKView, context: Context) {
        context.coordinator?.condition = condition
    }
    #else
    func makeUIView(context: Context) -> MTKView {
        makeView(renderer: context.coordinator)
    }

    func updateUIView(_ view: MTKView, context: Context) {
        context.coordinator?.condition = condition
    }
    #endif

    private func makeView(renderer: MetalWeatherRenderer?) -> MTKView {
        let view = MTKView(frame: .zero, device: renderer?.device)
        view.colorPixelFormat = .bgra8Unorm
        view.sampleCount = 4
        view.clearColor = MTLClearColorMake(0, 0, 0, 0)
        #if !os(macOS)
        view.isOpaque = false
        #endif
        view.preferredFramesPerSecond = 30
        view.enableSetNeedsDisplay = false
        view.isPaused = renderer == nil
        view.delegate = renderer
        return view
    }
}

private final class MetalWeatherRenderer: NSObject, MTKViewDelegate {
    let device: MTLDevice
    var condition: MetalWeatherCondition

    private let commandQueue: MTLCommandQueue
    private let pipelineState: MTLRenderPipelineState
    private let rainTexture: MTLTexture
    private let snowTexture: MTLTexture
    private let startedAt = Date()

    init?(device: MTLDevice, condition: MetalWeatherCondition) {
        self.device = device
        self.condition = condition

        guard let commandQueue = device.makeCommandQueue(),
              let rainTexture = Self.texture(named: "rain-streak-sprite", device: device),
              let snowTexture = Self.texture(named: "snowflake-sprite", device: device),
              let library = try? device.makeLibrary(source: Self.shaderSource, options: nil),
              let vertex = library.makeFunction(name: "weatherVertex"),
              let fragment = library.makeFunction(name: "weatherFragment") else {
            return nil
        }

        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertex
        descriptor.fragmentFunction = fragment
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        #if os(macOS)
        descriptor.rasterSampleCount = 4
        #else
        descriptor.sampleCount = 4
        #endif
        descriptor.colorAttachments[0].isBlendingEnabled = true
        descriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        descriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        descriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
        descriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha

        guard let pipelineState = try? device.makeRenderPipelineState(descriptor: descriptor) else {
            return nil
        }

        self.commandQueue = commandQueue
        self.pipelineState = pipelineState
        self.rainTexture = rainTexture
        self.snowTexture = snowTexture
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    func draw(in view: MTKView) {
        guard condition.hasEffect,
              let descriptor = view.currentRenderPassDescriptor,
              let drawable = view.currentDrawable,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }

        let elapsed = Float(Date().timeIntervalSince(startedAt))
        var weather = SIMD4<Float>(
            elapsed,
            Float(condition.precipitationMillimeters),
            condition.isSnowy ? 1 : 0,
            Float(min(condition.windSpeedKnots, 55))
        )
        var windAndSize = SIMD4<Float>(
            condition.windVector.x,
            condition.windVector.y,
            Float(view.drawableSize.width),
            Float(view.drawableSize.height)
        )

        encoder.setRenderPipelineState(pipelineState)
        encoder.setFragmentBytes(&weather, length: MemoryLayout<SIMD4<Float>>.stride, index: 0)
        encoder.setFragmentBytes(&windAndSize, length: MemoryLayout<SIMD4<Float>>.stride, index: 1)
        encoder.setFragmentTexture(rainTexture, index: 0)
        encoder.setFragmentTexture(snowTexture, index: 1)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    private static func texture(named name: String, device: MTLDevice) -> MTLTexture? {
        // SwiftPM processes resource directories into the module bundle root.
        guard let url = Bundle.module.url(forResource: name, withExtension: "png") else {
            return nil
        }
        return try? MTKTextureLoader(device: device).newTexture(
            URL: url,
            options: [.SRGB: false, .generateMipmaps: true]
        )
    }

    private static let shaderSource = """
    #include <metal_stdlib>
    using namespace metal;
    constexpr sampler particleSampler(coord::normalized, address::clamp_to_zero, filter::linear);

    struct RasterizerData {
        float4 position [[position]];
        float2 uv;
    };

    vertex RasterizerData weatherVertex(uint vertexID [[vertex_id]]) {
        float2 positions[3] = { float2(-1.0, -1.0), float2(3.0, -1.0), float2(-1.0, 3.0) };
        RasterizerData out;
        out.position = float4(positions[vertexID], 0.0, 1.0);
        out.uv = positions[vertexID] * 0.5 + 0.5;
        return out;
    }

    float hash(float value) {
        return fract(sin(value) * 43758.5453123);
    }

    fragment float4 weatherFragment(
        RasterizerData in [[stage_in]],
        constant float4 &weather [[buffer(0)]],
        constant float4 &windAndSize [[buffer(1)]],
        texture2d<float> rainTexture [[texture(0)]],
        texture2d<float> snowTexture [[texture(1)]]
    ) {
        float time = weather.x;
        float precipitation = weather.y;
        bool snow = weather.z > 0.5;
        float windSpeed = weather.w;
        bool heavyRain = !snow && precipitation >= 8.0;
        bool hasPrecipitation = precipitation > 0.0;
        float2 wind = normalize(float2(windAndSize.x, windAndSize.y) + 0.0001);
        float2 perpendicular = float2(-wind.y, wind.x);
        float2 uv = float2(in.uv.x, 1.0 - in.uv.y);
        float intensity = 0.0;
        float3 spriteColor = float3(0.0);
        float particleCount = hasPrecipitation
            ? (snow ? min(76.0, 28.0 + precipitation * 14.0) : min(80.0, 24.0 + precipitation * 8.0))
            : min(42.0, 12.0 + windSpeed * 0.55);

        for (uint index = 0; index < 80; index++) {
            if (float(index) >= particleCount) { break; }
            float seed = float(index) * 19.73;
            float depth = hash(seed + 2.0);
            if (hasPrecipitation) {
                float fallSpeed = snow ? mix(0.07, 0.16, depth) : mix(0.18, 0.38, depth);
                float progress = fract(time * fallSpeed + hash(seed + 4.0));
                float2 center = float2(hash(seed), progress - 0.12);
                center += wind * (snow ? 0.14 : 0.055) * progress;
                float2 delta = uv - center;

                if (snow) {
                    delta.x += sin(time * 1.6 + seed) * 0.025;
                    float halfSize = mix(0.004, 0.018, depth);
                    float2 spriteUV = delta / (halfSize * 2.0) + 0.5;
                    float4 sprite = snowTexture.sample(particleSampler, spriteUV);
                    float opacity = sprite.a * mix(0.20, 0.72, depth);
                    intensity += opacity;
                    spriteColor += sprite.rgb * opacity;
                } else {
                    delta.x -= wind.x * delta.y * 0.18;
                    float halfLength = mix(0.010, heavyRain ? 0.042 : 0.026, depth);
                    float halfWidth = halfLength * 0.11;
                    float2 spriteUV = float2(delta.x / (halfWidth * 2.0), delta.y / (halfLength * 2.0)) + 0.5;
                    float4 sprite = rainTexture.sample(particleSampler, spriteUV);
                    float opacity = sprite.a * mix(0.18, heavyRain ? 0.82 : 0.55, depth);
                    intensity += opacity;
                    spriteColor += sprite.rgb * opacity;
                }
            } else {
                // Dry wind is rendered as short directional wisps travelling downwind.
                float progress = fract(time * mix(0.08, 0.22, depth) * (windSpeed / 18.0) + hash(seed + 4.0));
                float lane = hash(seed + 7.0) - 0.5;
                float2 center = float2(0.5) + wind * (progress * 1.65 - 0.82) + perpendicular * lane;
                float2 delta = uv - center;
                float alongWind = dot(delta, wind);
                float acrossWind = dot(delta, perpendicular);
                float width = mix(0.0008, 0.0022, depth);
                float halfLength = mix(0.018, 0.070, depth);
                float distance = length(float2(acrossWind, max(abs(alongWind) - halfLength, 0.0))) - width;
                float edge = max(fwidth(distance) * 1.5, 0.0007);
                float wisp = 1.0 - smoothstep(-edge, edge, distance);
                intensity += wisp * mix(0.14, 0.52, depth);
            }
        }

        float3 fallbackColor = snow ? float3(0.92, 0.97, 1.0) : (hasPrecipitation ? (heavyRain ? float3(0.38, 0.70, 1.0) : float3(0.48, 0.86, 1.0)) : float3(0.72, 0.96, 0.98));
        float3 color = hasPrecipitation && intensity > 0.0001 ? spriteColor / intensity : fallbackColor;
        return float4(color, min(intensity, 0.88));
    }
    """
}
#endif

private enum MetalWeatherPreviewData {
    static func forecast(precipitation: Double, temperature: Double, windSpeed: Double, gusts: Double) -> SpotForecast {
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

#Preview("Metal wind") {
    MetalWeatherBackground(
        forecast: MetalWeatherPreviewData.forecast(precipitation: 0, temperature: 18, windSpeed: 28, gusts: 40),
        hour: "29"
    )
    .background(.black.opacity(0.28))
    .frame(height: 400)
}

#Preview("Metal rain") {
    MetalWeatherBackground(
        forecast: MetalWeatherPreviewData.forecast(precipitation: 3, temperature: 12, windSpeed: 12, gusts: 20),
        hour: "29"
    )
        .background(.black.opacity(0.35))
        .frame(height: 400)
}

#Preview("Metal snow") {
    MetalWeatherBackground(
        forecast: MetalWeatherPreviewData.forecast(precipitation: 4, temperature: -3, windSpeed: 15, gusts: 22),
        hour: "29"
    )
    .background(.black.opacity(0.30))
    .frame(height: 400)
}

#Preview("Metal storm") {
    MetalWeatherBackground(
        forecast: MetalWeatherPreviewData.forecast(precipitation: 12, temperature: 14, windSpeed: 32, gusts: 48),
        hour: "29"
    )
    .background(.black.opacity(0.48))
    .frame(height: 400)
}
