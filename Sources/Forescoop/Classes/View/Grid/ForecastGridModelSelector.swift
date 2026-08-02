//
//  ForecastGridModelSelector.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 08/01/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if !os(watchOS)
import SwiftUI

/// Inline toggle list for the models represented in the forecast grid.
struct ForecastGridModelSelector: View {
    let modelSummaryTitle: String
    let modelIDs: [String]
    let selectedModelIDs: [String]
    let modelNamesByID: [String: String]
    let onToggle: (String) -> Void
    @State private var showsModelOptions = false

    var body: some View {
        if !modelIDs.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                ForecastModelSummary(title: modelSummaryTitle) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showsModelOptions.toggle()
                    }
                }

                if showsModelOptions {
                    ForecastModelSelectionList(
                        models: modelIDs.map {
                            ForecastModelOption(
                                identifier: $0,
                                name: modelNamesByID[$0] ?? "Model \($0)"
                            )
                        },
                        selectedModelIDs: Set(selectedModelIDs),
                        minimumSelectionCount: 1,
                        showsDividers: true,
                        onToggle: onToggle
                    )
                    .font(.subheadline)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(Color.primary.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }
}

#if DEBUG
#Preview("Forecast grid model selector") {
    ForecastGridModelSelector(
        modelSummaryTitle: "Forescoop Mix (2 models)",
        modelIDs: ["3", "4", "28"],
        selectedModelIDs: ["3", "28"],
        modelNamesByID: [
            "3": "GFS 13 km",
            "4": "ICON 13 km",
            "28": "ECMWF 9 km"
        ],
        onToggle: { _ in }
    )
    .padding()
}
#endif
#endif
