//
//  ForecastGraphLegendItem.swift
//  ForescoopGraph package
//
//  Created by Javier on 08/02/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

import SwiftUI

struct ForecastGraphLegendItem: View {
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
