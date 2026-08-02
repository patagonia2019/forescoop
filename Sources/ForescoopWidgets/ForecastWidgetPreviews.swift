#if DEBUG && canImport(WidgetKit) && !os(tvOS)
import SwiftUI

extension ForecastWidgetEntry {
    static let stormPreview = ForecastWidgetEntry(
        date: .now,
        locationName: "Cerro Catedral",
        temperature: "6°C",
        wind: "22 kt",
        rain: "1.8 mm",
        symbolName: "cloud.rain.fill"
    )
}

#Preview("Forecast widget") {
    ForecastWidgetView(entry: .stormPreview)
        .frame(width: 320, height: 150)
        .padding()
        .background(.blue.gradient)
}
#endif
