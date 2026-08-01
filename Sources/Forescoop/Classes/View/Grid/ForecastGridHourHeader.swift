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
    let height: CGFloat
    let day: (String) -> String
    let time: (String) -> String
    let weatherSymbols: (String) -> [String]
    let onSelectHour: (String) -> Void

    var body: some View {
        LazyHStack(spacing: 0) {
            ForEach(hours, id: \.self) { hour in
                Button {
                    onSelectHour(hour)
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
                    .background(Color.secondary.opacity(0.12))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)
            }
        }
    }
}

#if DEBUG
#Preview("Forecast grid hour header") {
    ScrollView(.horizontal) {
        ForecastGridHourHeader(
            hours: ["0", "1", "2", "3"],
            columnWidth: 56,
            height: 64,
            day: { _ in "Sat 1" },
            time: { hour in "\(hour)h" },
            weatherSymbols: { _ in ["cloud.sun.fill", "wind"] },
            onSelectHour: { _ in }
        )
    }
    .padding()
}
#endif
#endif
