#if canImport(WidgetKit) && !os(tvOS)
import Forescoop
import SwiftUI
import WidgetKit

public struct ForecastWidgetProvider: TimelineProvider {
    public init() {}

    public func placeholder(in context: Context) -> ForecastWidgetEntry { .placeholder }

    public func getSnapshot(in context: Context, completion: @escaping (ForecastWidgetEntry) -> Void) {
        completion(currentEntry())
    }

    public func getTimeline(in context: Context, completion: @escaping (Timeline<ForecastWidgetEntry>) -> Void) {
        let entry = currentEntry()
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: entry.date) ?? entry.date.addingTimeInterval(3_600)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func currentEntry() -> ForecastWidgetEntry {
        guard let forecast = ForecastWindguruMockup().dashboardPreviewForecast else { return .placeholder }
        let hour = forecast.currentForecastHour
        let temperature = forecast.forecast?.temperatureReal(hh: hour) ?? forecast.forecast?.temperature(hh: hour) ?? 0
        let wind = forecast.forecast?.windSpeed(hh: hour) ?? 0
        let rain = forecast.forecast?.precipitation1(hh: hour) ?? forecast.forecast?.precipitation(hh: hour) ?? 0

        return ForecastWidgetEntry(
            date: .now,
            locationName: forecast.locationDisplayName(),
            temperature: "\(Int(temperature.rounded()))°C",
            wind: "\(Int(wind.rounded())) kt",
            rain: "\(rain.formatted(.number.precision(.fractionLength(0...1)))) mm",
            symbolName: forecast.weatherSymbolName(hour: hour)
        )
    }
}

#if DEBUG
#Preview("Provider result") {
    ForecastWidgetView(entry: .stormPreview)
        .frame(width: 320, height: 150)
        .padding()
        .background(.blue.gradient)
}
#endif
#endif
