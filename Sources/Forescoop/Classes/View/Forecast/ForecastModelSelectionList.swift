//
//  ForecastModelSelectionList.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 08/01/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if !os(watchOS)
import SwiftUI

struct ForecastModelOption: Identifiable {
    let identifier: String
    let name: String

    var id: String { identifier }
}

/// Reusable model rows for both the modal picker and inline forecast grid.
struct ForecastModelSelectionList: View {
    @Environment(\.ventusTheme) private var theme
    let models: [ForecastModelOption]
    let selectedModelIDs: Set<String>
    let minimumSelectionCount: Int
    let showsDividers: Bool
    let onToggle: (String) -> Void

    init(
        models: [ForecastModelOption],
        selectedModelIDs: Set<String>,
        minimumSelectionCount: Int = 0,
        showsDividers: Bool = false,
        onToggle: @escaping (String) -> Void
    ) {
        self.models = models
        self.selectedModelIDs = selectedModelIDs
        self.minimumSelectionCount = minimumSelectionCount
        self.showsDividers = showsDividers
        self.onToggle = onToggle
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(models) { model in
                let isSelected = selectedModelIDs.contains(model.identifier)
                Button {
                    guard !isSelected || selectedModelIDs.count > minimumSelectionCount else { return }
                    onToggle(model.identifier)
                } label: {
                    HStack {
                        Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                        Text(model.name)
                        Spacer()
                    }
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .foregroundStyle(isSelected ? theme.accentColor : Color.primary)

                if showsDividers, model.identifier != models.last?.identifier {
                    Divider()
                }
            }
        }
    }
}

#if DEBUG
#Preview("Forecast model selection list") {
    ForecastModelSelectionList(
        models: [
            ForecastModelOption(identifier: "3", name: "GFS 13 km"),
            ForecastModelOption(identifier: "4", name: "ICON 13 km"),
            ForecastModelOption(identifier: "28", name: "ECMWF 9 km")
        ],
        selectedModelIDs: ["3", "28"],
        minimumSelectionCount: 1,
        showsDividers: true,
        onToggle: { _ in }
    )
    .padding()
}
#endif
#endif
