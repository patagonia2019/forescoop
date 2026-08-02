#if DEBUG
import SwiftUI

#Preview("Forecast graph canvas") {
    ForecastGraphCanvasPreview()
        .padding()
}

#Preview("Forecast graph legend") {
    ForecastGraphLegendPreview()
        .padding()
}

private struct ForecastGraphCanvasPreview: View {
    @State private var selectedID: String? = "12"

    private let points = (0...24).map { hour in
        ForecastGraphPoint(
            id: "\(hour)",
            date: Calendar.current.date(byAdding: .hour, value: hour * 3, to: .now) ?? .now,
            wind: Double(6 + (hour % 6)),
            gust: Double(12 + (hour % 9)),
            direction: Double(220 + (hour % 5) * 16),
            cloudCover: Double(35 + (hour % 6) * 10),
            humidity: Double(62 + (hour % 7) * 4),
            pressure: Double(1_008 + (hour % 8)),
            temperature: Double(8 + (hour % 7)),
            precipitation: hour.isMultiple(of: 5) ? 1.2 : 0
        )
    }

    var body: some View {
        ForecastGraphCanvas(
            points: points,
            comparisonSeries: [
                ForecastGraphSeries(id: "icon", name: "ICON", points: points.map { point in
                    ForecastGraphPoint(
                        id: point.id, date: point.date, wind: point.wind + 2, gust: point.gust + 2,
                        direction: point.direction, cloudCover: point.cloudCover, humidity: point.humidity,
                        pressure: point.pressure, temperature: point.temperature + 1, precipitation: point.precipitation
                    )
                })
            ],
            selectedID: $selectedID,
            windUnitLabel: "kt"
        )
    }
}

private struct ForecastGraphLegendPreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForecastGraphLegendItem(label: "Wind", color: .primary, style: .line)
            ForecastGraphLegendItem(label: "Gusts · low → strong", style: .gustGradient)
            ForecastGraphLegendItem(label: "Cloud cover", color: .gray.opacity(0.55), style: .area)
            ForecastGraphLegendItem(label: "Humidity", color: .green, style: .line)
            ForecastGraphLegendItem(label: "Pressure", color: .blue, style: .line)
            ForecastGraphLegendItem(label: "Temperature", color: .yellow, style: .dot)
            ForecastGraphLegendItem(label: "Rain", color: .cyan, style: .bar)
            ForecastGraphLegendItem(label: "Wind direction", color: .primary, style: .arrow)
        }
    }
}
#endif
