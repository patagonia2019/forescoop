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
    let modelIDs: [String]
    let selectedModelIDs: [String]
    let modelNamesByID: [String: String]
    let onToggle: (String) -> Void

    var body: some View {
        if !modelIDs.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Label("Forecast models", systemImage: "cpu")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)

                VStack(spacing: 0) {
                    ForEach(modelIDs, id: \.self) { modelID in
                        let isSelected = selectedModelIDs.contains(modelID)
                        Button {
                            guard isSelected ? selectedModelIDs.count > 1 : true else { return }
                            onToggle(modelID)
                        } label: {
                            HStack {
                                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                                Text(modelNamesByID[modelID] ?? "Model \(modelID)")
                                Spacer()
                            }
                            .font(.subheadline)
                            .padding(.vertical, 5)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(isSelected ? .blue : .primary)

                        if modelID != modelIDs.last {
                            Divider()
                        }
                    }
                }
                .padding(.horizontal, 10)
                .background(Color.primary.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

#if DEBUG
#Preview("Forecast grid model selector") {
    ForecastGridModelSelector(
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
