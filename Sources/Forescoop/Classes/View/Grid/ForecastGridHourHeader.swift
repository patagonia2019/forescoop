//
//  ForecastGridHourHeader.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 08/01/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if !os(watchOS)
import SwiftUI

/// The horizontally scrolling day, hour, and weather-symbol header.
struct ForecastGridHourHeader: View {
    let hours: [String]
    let columnWidth: CGFloat
    let columnSpacing: CGFloat
    let height: CGFloat
    let day: (String) -> String
    let time: (String) -> String
    let weatherSymbols: (String) -> [String]
    let selectedHour: String?
    let onSelectHour: (String) -> Void

    var body: some View {
        LazyHStack(spacing: columnSpacing) {
            ForEach(hours, id: \.self) { hour in
                ForecastGridHourCell(
                    hour: hour,
                    columnWidth: columnWidth,
                    height: height,
                    day: day,
                    time: time,
                    weatherSymbols: weatherSymbols,
                    isSelected: selectedHour == hour,
                    onSelect: onSelectHour
                )
            }
        }
    }
}

/// A single interactive day/hour/weather header cell that can also be composed
/// with its data column for one continuous selection outline.
struct ForecastGridHourCell: View {
    @Environment(\.ventusTheme) private var theme
    let hour: String
    let columnWidth: CGFloat
    let height: CGFloat
    let day: (String) -> String
    let time: (String) -> String
    let weatherSymbols: (String) -> [String]
    let isSelected: Bool
    let onSelect: (String) -> Void

    var body: some View {
        Button {
            onSelect(hour)
        } label: {
            VStack(spacing: 2) {
                Text(day(hour)).font(.caption2)
                Text(time(hour)).font(.caption.bold())
                HStack(spacing: 2) {
                    ForEach(weatherSymbols(hour).prefix(3), id: \.self) { symbol in
                        Image(systemName: symbol)
                    }
                }
                .font(.caption2)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.secondary)
            }
            .frame(width: columnWidth, height: height)
            .background {
                if theme.usesMaterial && !isSelected {
                    Rectangle().fill(.thinMaterial)
                } else {
                    isSelected ? theme.accentColor.opacity(0.18) : Color.secondary.opacity(0.12)
                }
            }
            .overlay {
                if isSelected {
                    ForecastGridHeaderSelectionBorder(cornerRadius: 3)
                        .stroke(theme.accentColor, lineWidth: 2)
                }
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(theme.accentColor)
        .ventusGlassEffect(theme: theme, in: RoundedRectangle(cornerRadius: 3))
        .accessibilityLabel("\(day(hour)), \(time(hour)), \(weatherSymbols(hour).count) weather symbol\(weatherSymbols(hour).count == 1 ? "" : "s")")
        .accessibilityHint(isSelected ? "Selected forecast hour" : "Select forecast hour")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// The top half of the continuous selection outline that joins the sticky
/// date/hour cell to its scrolling data column.
struct ForecastGridHeaderSelectionBorder: Shape {
    let cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        let radius = min(cornerRadius, min(rect.width, rect.height) / 2)
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + radius, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + radius),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        return path
    }
}

/// The bottom half of the continuous selection outline that joins the sticky
/// date/hour cell above it.
struct ForecastGridDataSelectionBorder: Shape {
    let cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        let radius = min(cornerRadius, min(rect.width, rect.height) / 2)
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - radius))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + radius, y: rect.maxY),
            control: CGPoint(x: rect.minX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY - radius),
            control: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return path
    }
}

#if DEBUG
#Preview("Forecast grid hour header") {
    ScrollView(.horizontal) {
        ForecastGridHourHeader(
            hours: ["0", "1", "2", "3"],
            columnWidth: 56,
            columnSpacing: 0,
            height: 64,
            day: { _ in "Sat 1" },
            time: { hour in "\(hour)h" },
            weatherSymbols: { _ in ["cloud.sun.fill", "wind"] },
            selectedHour: "1",
            onSelectHour: { _ in }
        )
    }
    .padding()
}
#endif
#endif
