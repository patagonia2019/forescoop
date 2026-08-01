//
//  WeatherRainbowOverlay.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 08/01/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

import SwiftUI

/// A lightweight shared rainbow treatment for sun-and-rain conditions.
struct WeatherRainbowOverlay: View {
    let isVisible: Bool

    private let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo, .purple]

    var body: some View {
        if isVisible {
            GeometryReader { proxy in
                let diameter = max(proxy.size.width, proxy.size.height) * 0.68
                ZStack {
                    ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
                        Circle()
                            .trim(from: 0, to: 0.5)
                            .stroke(color.opacity(0.58), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                            .rotationEffect(.degrees(180))
                            .frame(
                                width: diameter - CGFloat(index) * 12,
                                height: diameter - CGFloat(index) * 12
                            )
                    }
                }
                .position(x: proxy.size.width * 0.72, y: proxy.size.height * 0.94)
                .blendMode(.screen)
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }
}

#Preview("Rainbow") {
    ZStack {
        LinearGradient(colors: [.blue.opacity(0.48), .gray.opacity(0.20)], startPoint: .top, endPoint: .bottom)
        WeatherRainbowOverlay(isVisible: true)
    }
    .frame(height: 400)
}
