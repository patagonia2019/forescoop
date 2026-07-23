//
//  VisionForecastView.swift
//  Forescoop
//
//  Created by Javier Fuchs on 07/23/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if os(visionOS)
import SwiftUI
import Forescoop

struct VisionForecastView: View {
    private let forecastService: ForecastWindguruProtocol = ForecastWindguruService()
    @Environment(\.openWindow) private var openWindow
    @State private var forecast: SpotForecast?
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.cyan.opacity(0.25), .indigo.opacity(0.18), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            if let forecast {
                visionForecast(for: forecast)
            } else if let errorMessage {
                ContentUnavailableView("Forecast unavailable", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
            } else {
                ProgressView("Loading forecast…")
            }
        }
        .task { await loadForecast() }
        .ornament(attachmentAnchor: .scene(.bottom), contentAlignment: .center) {
            HStack(spacing: 18) {
                Button("Locations", systemImage: "map") {
                    openWindow(id: "locations")
                }
                Button("Refresh", systemImage: "arrow.clockwise") {
                    Task { await loadForecast() }
                }
            }
            .labelStyle(.titleAndIcon)
            .padding(.horizontal, 22)
            .padding(.vertical, 12)
            .background(.thinMaterial, in: Capsule())
        }
    }

    private func visionForecast(for forecast: SpotForecast) -> some View {
        let hour = forecast.currentForecastHour
        let weather = forecast.forecast

        return VStack(alignment: .leading, spacing: 28) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Label(forecast.asCurrentLocation ?? "Forecast", systemImage: "mappin.and.ellipse")
                        .font(.largeTitle.bold())
                    Label(weather?.modelName ?? "Forecast model", systemImage: "cpu")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("(hour) hs")
                    .font(.title2.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 24) {
                HStack(spacing: 14) {
                    ForEach(forecast.weatherSymbolNames(hour: hour), id: \.self) { symbol in
                        Image(systemName: symbol)
                    }
                }
                .font(.system(size: 72))
                .symbolRenderingMode(.hierarchical)

                Text(temperature(weather?.temperatureReal(hh: hour) ?? weather?.temperature(hh: hour)))
                    .font(.system(size: 72, weight: .semibold, design: .rounded))
            }

            HStack(spacing: 18) {
                visionMetric("Wind", value: wind(weather?.windSpeed(hh: hour)), symbol: "wind")
                visionMetric("Gusts", value: wind(weather?.windGustsKnots(hh: hour)), symbol: "wind")
                visionMetric("Humidity", value: percent(weather?.relativeHumidity(hh: hour)), symbol: "humidity")
                visionMetric("Pressure", value: pressure(weather?.seaLevelPressure(hh: hour)), symbol: "gauge.medium")
            }
        }
        .padding(40)
        .frame(maxWidth: 1_200, alignment: .leading)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 32))
        .overlay {
            RoundedRectangle(cornerRadius: 32)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        }
        .padding(48)
    }

    private func visionMetric(_ title: String, value: String, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: symbol)
                .font(.headline)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.monospacedDigit())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.thinMaterial, in: .rect(cornerRadius: 20))
    }

    @MainActor
    private func loadForecast() async {
        do {
            forecast = try await forecastService.forecast(bySpotId: "64141", model: nil)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func temperature(_ value: Double?) -> String {
        guard let value else { return "—" }
        return "\(value.formatted(.number.precision(.fractionLength(0))))°C"
    }

    private func wind(_ value: Double?) -> String {
        guard let value else { return "—" }
        return "\(value.formatted(.number.precision(.fractionLength(0)))) kt"
    }

    private func percent(_ value: Int?) -> String {
        guard let value else { return "—" }
        return "\(value)%"
    }

    private func pressure(_ value: Double?) -> String {
        guard let value else { return "—" }
        return "\(value.formatted(.number.precision(.fractionLength(0)))) hPa"
    }
}

#Preview(windowStyle: .automatic) {
    VisionForecastView()
}
#endif
