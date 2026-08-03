//
//  WeatherNightSkyOverlay.swift
//  Forescoop package
//

import SwiftUI

/// A small celestial layer shared by renderers that do not provide their own
/// night illustration. It is deliberately independent of the weather artwork
/// so a rainy night can still show moonlight without ever falling back to sun.
struct WeatherNightSkyOverlay: View {
    let isVisible: Bool
    let showsStars: Bool

    var body: some View {
        if isVisible {
            GeometryReader { proxy in
                ZStack(alignment: .topTrailing) {
                    if showsStars {
                        ForEach(0..<10, id: \.self) { index in
                            Image(systemName: "sparkle")
                                .font(.system(size: CGFloat(6 + index % 4)))
                                .foregroundStyle(.white.opacity(0.35 + Double(index % 3) * 0.14))
                                .position(
                                    x: proxy.size.width * (0.08 + Double((index * 29) % 78) / 100),
                                    y: proxy.size.height * (0.08 + Double((index * 17) % 35) / 100)
                                )
                        }
                    }

                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: min(max(proxy.size.width * 0.12, 26), 64)))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.white.opacity(0.72))
                        .padding(.top, max(16, proxy.size.height * 0.08))
                        .padding(.trailing, max(20, proxy.size.width * 0.09))
                }
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }
}

#Preview("Clear night sky") {
    ZStack {
        LinearGradient(colors: [.indigo, .black], startPoint: .top, endPoint: .bottom)
        WeatherNightSkyOverlay(isVisible: true, showsStars: true)
    }
    .frame(height: 400)
}
