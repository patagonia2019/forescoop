#if canImport(WidgetKit) && !os(tvOS)
import Forescoop
import SwiftUI
import WidgetKit

public struct ForecastWidgetView: View {
    public let entry: ForecastWidgetEntry
    @Environment(\.widgetFamily) private var family
    private let theme: VentusTheme

    public init(entry: ForecastWidgetEntry, theme: VentusTheme = VentusThemeStore.load()) {
        self.entry = entry
        self.theme = theme
    }

    @ViewBuilder public var body: some View {
#if os(watchOS) || os(iOS)
        switch family {
        case .accessoryCircular:
            Image(systemName: entry.symbolName)
                .font(.title2)
                .widgetAccentable()
        case .accessoryInline:
            Text("\(entry.temperature) · \(entry.wind)")
        case .accessoryRectangular:
            HStack {
                Image(systemName: entry.symbolName).widgetAccentable()
                VStack(alignment: .leading) {
                    Text(entry.locationName).lineLimit(1)
                    Text("\(entry.temperature) · \(entry.wind)").font(.caption)
                }
            }
        default:
            regularWidgetContent
        }
#else
        regularWidgetContent
#endif
    }

    private var regularWidgetContent: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(entry.locationName).font(.headline).lineLimit(1)
            HStack(alignment: .center) {
                Image(systemName: entry.symbolName).font(.largeTitle).widgetAccentable()
                Text(entry.temperature).font(.title.bold())
            }
            HStack {
                Label(entry.wind, systemImage: "wind")
                Spacer()
                Label(entry.rain, systemImage: "drop.fill")
            }
            .font(.caption)
        }
        .foregroundStyle(theme.primaryTextColor)
        .tint(theme.accentColor)
        .containerBackground(for: .widget) { theme.backgroundColor }
        .modifier(ForecastWidgetFontDesign(design: theme.fontDesign))
    }
}

private struct ForecastWidgetFontDesign: ViewModifier {
    let design: Font.Design?

    @ViewBuilder func body(content: Content) -> some View {
        if let design {
            content.fontDesign(design)
        } else {
            content
        }
    }
}

#if DEBUG
#Preview("Widget view") {
    ForecastWidgetView(entry: .stormPreview)
        .frame(width: 320, height: 150)
        .padding()
        .background(.blue.gradient)
}
#endif
#endif
