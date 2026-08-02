//
//  ForecastModelSummary.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 08/02/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if !os(watchOS)
import SwiftUI

/// Shared compact model summary used by the dashboard and forecast grid.
struct ForecastModelSummary: View {
    let title: String
    let onSelect: () -> Void
    let modelInfoURL: URL

    init(
        title: String,
        modelInfoURL: URL = URL(string: "https://www.windguru.cz/help.php?sec=models")!,
        onSelect: @escaping () -> Void
    ) {
        self.title = title
        self.modelInfoURL = modelInfoURL
        self.onSelect = onSelect
    }

    var body: some View {
        HStack(spacing: 6) {
            Button(action: onSelect) {
                Label(title, systemImage: "cpu")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)

            Link(destination: modelInfoURL) {
                Image(systemName: "info.circle")
            }
            .accessibilityLabel("About Windguru forecast models")
            .accessibilityHint("Opens Windguru's model explanation")
        }
    }
}

#Preview("Forecast model summary") {
    ForecastModelSummary(title: "Forescoop Mix (4 models)") {}
        .padding()
}
#endif
