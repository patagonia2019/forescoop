#if !os(watchOS)
import SwiftUI

#if canImport(FoundationModels) && !os(tvOS)
import FoundationModels
#endif

/// A concise forecast explanation generated on-device when Apple Intelligence
/// is available. The deterministic summary keeps this useful on every device.
public struct ForecastIntelligenceSummary: View {
    @Environment(\.ventusTheme) private var theme
    private let snapshot: ForecastIntelligenceSnapshot
    @State private var summary: String
    @State private var isGenerating = false

    public init(forecast: SpotForecast, hour: String?) {
        let snapshot = ForecastIntelligenceSnapshot(forecast: forecast, hour: hour)
        self.snapshot = snapshot
        _summary = State(initialValue: snapshot.deterministicSummary)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Label("Forecast insight", systemImage: "sparkles")
                    .font(.headline)
                    .foregroundStyle(theme.accentColor)
                if isGenerating {
                    ProgressView().controlSize(.small)
                }
            }
            Text(summary)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background {
            if theme.usesMaterial {
                RoundedRectangle(cornerRadius: 14).fill(.regularMaterial)
            } else {
                RoundedRectangle(cornerRadius: 14)
                    .fill(theme.backgroundColor.opacity(theme == .system ? 0.2 : 0.82))
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(theme.accentColor.opacity(0.25))
        }
        .task(id: snapshot) {
            await generateSummary()
        }
    }

    @MainActor
    private func generateSummary() async {
        summary = snapshot.deterministicSummary
#if canImport(FoundationModels) && !os(tvOS)
        guard SystemLanguageModel.default.isAvailable else { return }
        isGenerating = true
        defer { isGenerating = false }

        do {
            let session = LanguageModelSession(
                model: SystemLanguageModel.default,
                instructions: "You are a precise weather forecaster. Write one helpful sentence, under 28 words. Use only the supplied forecast facts. Do not invent safety advice or facts."
            )
            let response = try await session.respond(to: snapshot.prompt)
            let generated = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
            if !generated.isEmpty {
                summary = generated
            }
        } catch {
            // The deterministic summary is deliberately retained when the
            // on-device model is unavailable, disabled, or declines a prompt.
        }
#endif
    }
}

private struct ForecastIntelligenceSnapshot: Hashable, Sendable {
    let location: String
    let hour: String
    let temperature: Int
    let wind: Int
    let gust: Int?
    let rain: Double
    let humidity: Int?
    let cloudCover: Int?

    init(forecast: SpotForecast, hour: String?) {
        let hour = hour ?? forecast.currentForecastHour ?? "0"
        let source = forecast.forecast
        location = forecast.locationDisplayName()
        self.hour = hour
        temperature = Int((source?.temperatureReal(hh: hour) ?? source?.temperature(hh: hour) ?? 0).rounded())
        wind = Int((source?.windSpeed(hh: hour) ?? 0).rounded())
        gust = source?.windGustsKnots(hh: hour).map { Int($0.rounded()) }
        rain = source?.precipitation1(hh: hour) ?? source?.precipitation(hh: hour) ?? 0
        humidity = source?.relativeHumidity(hh: hour)
        cloudCover = source?.cloudCoverTotal(hh: hour)
    }

    var prompt: String {
        "Location: \(location). Forecast hour: \(hour). Temperature: \(temperature) °C. Wind: \(wind) kt. Gusts: \(gust.map(String.init) ?? "unavailable") kt. Rain: \(rain.formatted(.number.precision(.fractionLength(0...1)))) mm. Humidity: \(humidity.map(String.init) ?? "unavailable")%. Cloud cover: \(cloudCover.map(String.init) ?? "unavailable")%."
    }

    var deterministicSummary: String {
        var phrases = ["\(location): \(temperature)°C with \(wind) kt wind"]
        if let gust, gust >= wind + 8 { phrases.append("gusting to \(gust) kt") }
        if rain > 0 { phrases.append("\(rain.formatted(.number.precision(.fractionLength(0...1)))) mm of rain") }
        if let cloudCover, cloudCover >= 75 { phrases.append("mostly cloudy") }
        return phrases.joined(separator: ", ") + "."
    }
}

#Preview("Forecast intelligence") {
    if let forecast = ForecastWindguruMockup().dashboardPreviewForecast {
        ForecastIntelligenceSummary(forecast: forecast, hour: "29")
            .padding()
            .modifier(VentusThemeModifier(theme: .ocean))
    }
}
#endif
