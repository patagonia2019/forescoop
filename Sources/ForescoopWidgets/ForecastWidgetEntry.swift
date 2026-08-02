#if canImport(WidgetKit) && !os(tvOS)
import SwiftUI
import WidgetKit

public struct ForecastWidgetEntry: TimelineEntry, Sendable {
    public let date: Date
    public let locationName: String
    public let temperature: String
    public let wind: String
    public let rain: String
    public let symbolName: String

    public static let placeholder = ForecastWidgetEntry(
        date: .now,
        locationName: "Bariloche",
        temperature: "12°C",
        wind: "10 kt",
        rain: "0 mm",
        symbolName: "cloud.sun.fill"
    )
}

#if DEBUG
#Preview("Placeholder entry") {
    ForecastWidgetView(entry: .placeholder)
        .frame(width: 320, height: 150)
        .padding()
        .background(.blue.gradient)
}
#endif
#endif
