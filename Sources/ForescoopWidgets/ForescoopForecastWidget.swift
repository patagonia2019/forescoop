#if canImport(WidgetKit) && !os(tvOS)
import SwiftUI
import WidgetKit

public struct ForescoopForecastWidget: Widget {
    public let kind = "org.forescoop.forecast"

    public init() {}

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ForecastWidgetProvider()) { entry in
            ForecastWidgetView(entry: entry)
        }
        .configurationDisplayName("Forecast")
        .description("Current weather at your selected forecast location.")
        .supportedFamilies(supportedFamilies)
    }

    private var supportedFamilies: [WidgetFamily] {
#if os(watchOS)
        [.accessoryCircular, .accessoryRectangular, .accessoryInline]
#elseif os(iOS)
        [.systemSmall, .systemMedium, .systemLarge, .accessoryCircular, .accessoryRectangular, .accessoryInline]
#elseif os(visionOS)
        [.systemSmall, .systemMedium, .systemLarge, .systemExtraLargePortrait]
#else
        [.systemSmall, .systemMedium, .systemLarge]
#endif
    }
}

#if DEBUG
#Preview("Widget configuration") {
    ForecastWidgetView(entry: .stormPreview)
        .frame(width: 320, height: 150)
        .padding()
        .background(.blue.gradient)
}
#endif
#endif
