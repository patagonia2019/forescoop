import SwiftUI

public struct ForecastGraphPoint: Identifiable, Sendable {
    public let id: String
    public let date: Date
    public let wind: Double
    public let gust: Double
    public let direction: Double?
    public let cloudCover: Double
    public let humidity: Double
    public let pressure: Double
    public let temperature: Double
    public let precipitation: Double

    public init(id: String, date: Date, wind: Double, gust: Double, direction: Double?, cloudCover: Double, humidity: Double, pressure: Double, temperature: Double, precipitation: Double) {
        self.id = id; self.date = date; self.wind = wind; self.gust = gust; self.direction = direction
        self.cloudCover = cloudCover; self.humidity = humidity; self.pressure = pressure
        self.temperature = temperature; self.precipitation = precipitation
    }
}

/// Self-contained Canvas renderer. This target deliberately depends only on SwiftUI,
/// allowing Xcode to cache it separately from the forecast dashboard target.
public struct ForecastGraphCanvas: View {
    public let points: [ForecastGraphPoint]
    @Binding public var selectedID: String?
    public let windUnitLabel: String

    public init(points: [ForecastGraphPoint], selectedID: Binding<String?>, windUnitLabel: String) {
        self.points = points; _selectedID = selectedID; self.windUnitLabel = windUnitLabel
    }

    private var width: CGFloat { max(720, CGFloat(points.count) * 62) }
    private var pressureRange: ClosedRange<Double> {
        let values = points.map(\.pressure).filter { $0 > 0 }
        guard let low = values.min(), let high = values.max(), low != high else { return 0...1 }
        return low...high
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Label("Wind", systemImage: "chart.line.uptrend.xyaxis")
                Label("Gusts", systemImage: "wind")
                Label("Cloud · humidity · pressure · temperature · rain", systemImage: "chart.bar.xaxis")
            }
            .font(.caption).foregroundStyle(.secondary)
            legend
            ScrollView(.horizontal) {
                Canvas(opaque: false, colorMode: .linear, rendersAsynchronously: true) { context, size in
                    draw(in: &context, size: size)
                }
                .frame(width: width, height: 520)
                .contentShape(Rectangle())
                // Selection is a tap. A drag must remain available to the
                // enclosing horizontal scroll view so long forecasts can be
                // explored rather than getting stuck on the first columns.
                .simultaneousGesture(SpatialTapGesture().onEnded { value in
                    let progress = min(max((value.location.x - 42) / (width - 58), 0), 1)
                    selectedID = points[Int((progress * CGFloat(points.count - 1)).rounded())].id
                })
            }
            .scrollIndicators(.hidden)
        }
        .accessibilityLabel("Wind, gust, cloud cover, humidity, pressure, temperature and precipitation forecast graph")
    }

    private var legend: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 122), alignment: .leading)],
            alignment: .leading,
            spacing: 7
        ) {
            ForecastGraphLegendItem(label: "Wind", color: .primary, style: .line)
            ForecastGraphLegendItem(label: "Gusts · low → strong", style: .gustGradient)
            ForecastGraphLegendItem(label: "Cloud cover", color: .gray.opacity(0.55), style: .area)
            ForecastGraphLegendItem(label: "Humidity", color: .green, style: .line)
            ForecastGraphLegendItem(label: "Pressure", color: .blue, style: .line)
            ForecastGraphLegendItem(label: "Temperature", color: .yellow, style: .dot)
            ForecastGraphLegendItem(label: "Rain", color: .cyan, style: .bar)
            ForecastGraphLegendItem(label: "Wind direction", color: .primary, style: .arrow)
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
    }

    private func draw(in context: inout GraphicsContext, size: CGSize) {
        let wind = CGRect(x: 42, y: 28, width: size.width - 58, height: 240)
        let weather = CGRect(x: 42, y: 334, width: wind.width, height: 165)
        let x: (Int) -> CGFloat = { wind.minX + CGFloat($0) / CGFloat(max(points.count - 1, 1)) * wind.width }
        let maxGust = max(points.map(\.gust).max() ?? 1, 1)
        let windY: (Double) -> CGFloat = { wind.maxY - CGFloat($0 / maxGust) * wind.height }
        let weatherY: (Double) -> CGFloat = { weather.maxY - CGFloat(min(max($0, 0), 100) / 100) * weather.height }

        for index in points.indices {
            guard index.isMultiple(of: 2) else { continue }
            var line = Path(); line.move(to: CGPoint(x: x(index), y: wind.minY)); line.addLine(to: CGPoint(x: x(index), y: weather.maxY))
            context.stroke(line, with: .color(.secondary.opacity(0.2)), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
            context.draw(Text(points[index].date.formatted(.dateTime.weekday(.abbreviated).hour())).font(.caption2).foregroundStyle(.secondary), at: CGPoint(x: x(index), y: 12))
        }

        var gustArea = smoothPath(points.map(\.gust), x: x, y: windY)
        gustArea.addLine(to: CGPoint(x: x(points.count - 1), y: wind.maxY)); gustArea.closeSubpath()
        context.fill(gustArea, with: .linearGradient(Gradient(colors: [.cyan.opacity(0.2), .mint.opacity(0.55), .yellow.opacity(0.7), .orange.opacity(0.8), .pink.opacity(0.9)]), startPoint: CGPoint(x: 0, y: wind.maxY), endPoint: CGPoint(x: 0, y: wind.minY)))
        drawLine(points.map(\.wind), color: .primary, in: &context, x: x, y: windY)

        for index in points.indices {
            let point = CGPoint(x: x(index), y: windY(points[index].wind))
            context.draw(Text(points[index].wind, format: .number.precision(.fractionLength(0))).font(.caption2.monospacedDigit()), at: CGPoint(x: point.x, y: point.y - 10))
            if let direction = points[index].direction {
                var arrow = context; arrow.translateBy(x: point.x, y: wind.maxY + 22); arrow.rotate(by: .degrees(direction))
                arrow.draw(Text("↓").font(.caption.weight(.bold)), at: .zero)
            }
        }

        var clouds = smoothPath(points.map(\.cloudCover), x: x, y: weatherY)
        clouds.addLine(to: CGPoint(x: x(points.count - 1), y: weather.maxY)); clouds.closeSubpath()
        context.fill(clouds, with: .color(.gray.opacity(0.4)))
        drawLine(points.map(\.humidity), color: .green, in: &context, x: x, y: weatherY)
        drawLine(points.map { pressureLevel($0.pressure) }, color: .blue, in: &context, x: x, y: weatherY)
        for index in points.indices {
            let point = points[index]
            let rainHeight = min(CGFloat(point.precipitation * 20), 28)
            context.fill(Path(CGRect(x: x(index) - 2, y: weather.maxY - rainHeight, width: 4, height: rainHeight)), with: .color(.cyan))
            let temperatureCenter = CGPoint(x: x(index), y: weather.maxY - 18)
            context.fill(Path(ellipseIn: CGRect(x: temperatureCenter.x - 10, y: temperatureCenter.y - 10, width: 20, height: 20)), with: .color(.yellow.opacity(0.9)))
            context.draw(Text(point.temperature, format: .number.precision(.fractionLength(0))).font(.caption2.weight(.bold)), at: temperatureCenter)
        }
        if let index = points.firstIndex(where: { $0.id == selectedID }) {
            var selection = Path(); selection.move(to: CGPoint(x: x(index), y: wind.minY)); selection.addLine(to: CGPoint(x: x(index), y: weather.maxY))
            context.stroke(selection, with: .color(.accentColor), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
        }
    }

    private func drawLine(_ values: [Double], color: Color, in context: inout GraphicsContext, x: (Int) -> CGFloat, y: (Double) -> CGFloat) {
        context.stroke(smoothPath(values, x: x, y: y), with: .color(color), lineWidth: 2)
    }

    /// Cubic Catmull–Rom interpolation expressed as Bezier segments. It keeps
    /// the line close to the supplied forecast points without the kinks that
    /// midpoint quadratic curves can leave at every sample.
    private func smoothPath(_ values: [Double], x: (Int) -> CGFloat, y: (Double) -> CGFloat) -> Path {
        guard !values.isEmpty else { return Path() }
        func point(_ index: Int) -> CGPoint { CGPoint(x: x(index), y: y(values[index])) }
        var path = Path()
        path.move(to: point(0))
        guard values.count > 1 else { return path }
        for index in 0..<(values.count - 1) {
            let previous = point(max(index - 1, 0))
            let start = point(index)
            let end = point(index + 1)
            let next = point(min(index + 2, values.count - 1))
            let control1 = CGPoint(x: start.x + (end.x - previous.x) / 6, y: start.y + (end.y - previous.y) / 6)
            let control2 = CGPoint(x: end.x - (next.x - start.x) / 6, y: end.y - (next.y - start.y) / 6)
            path.addCurve(to: end, control1: control1, control2: control2)
        }
        return path
    }

    private func pressureLevel(_ pressure: Double) -> Double {
        guard pressureRange.lowerBound != pressureRange.upperBound, pressure > 0 else { return 50 }
        return 22 + (pressure - pressureRange.lowerBound) / (pressureRange.upperBound - pressureRange.lowerBound) * 58
    }
}

private struct ForecastGraphLegendItem: View {
    enum Style { case line, area, dot, bar, arrow, gustGradient }

    let label: String
    var color: Color = .clear
    let style: Style

    var body: some View {
        HStack(spacing: 5) {
            swatch.frame(width: 22, height: 12)
            Text(label).lineLimit(1)
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder private var swatch: some View {
        switch style {
        case .line:
            Capsule().fill(color).frame(height: 2)
        case .area:
            RoundedRectangle(cornerRadius: 2).fill(color)
        case .dot:
            Circle().fill(color)
        case .bar:
            RoundedRectangle(cornerRadius: 1).fill(color).frame(width: 5)
        case .arrow:
            Image(systemName: "arrow.down").foregroundStyle(color)
        case .gustGradient:
            RoundedRectangle(cornerRadius: 2)
                .fill(LinearGradient(colors: [.cyan, .mint, .yellow, .orange, .pink], startPoint: .leading, endPoint: .trailing))
        }
    }
}
