//
//  ForecastGridDashboardWorkspace.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 08/02/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if !os(watchOS)
import SwiftUI

/// Places the forecast grid and dashboard side by side in a wide container,
/// or one above the other in a tall container. Both supplied views retain the
/// same parent state, keeping hour, location, model, and unit changes synced.
struct ForecastGridDashboardWorkspace<GridContent: View, DashboardContent: View>: View {
    private let gridContent: () -> GridContent
    private let dashboardContent: () -> DashboardContent
    @State private var wideSplitFraction: CGFloat
    @State private var tallSplitFraction: CGFloat
    @State private var splitFractionAtDragStart: CGFloat?
    @Environment(\.displayScale) private var displayScale

    init(
        @ViewBuilder grid: @escaping () -> GridContent,
        @ViewBuilder dashboard: @escaping () -> DashboardContent
    ) {
        gridContent = grid
        dashboardContent = dashboard
        _wideSplitFraction = State(initialValue: ForecastWorkspaceSplitStore.load(isWide: true))
        _tallSplitFraction = State(initialValue: ForecastWorkspaceSplitStore.load(isWide: false))
    }

    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > geometry.size.height {
                HStack(spacing: 0) {
                    gridContent()
                        .frame(width: panelLength(total: geometry.size.width, fraction: wideSplitFraction))

                    splitDivider(isWide: true, totalLength: geometry.size.width)

                    dashboardContent()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                VStack(spacing: 0) {
                    gridContent()
                        .frame(height: panelLength(total: geometry.size.height, fraction: tallSplitFraction))

                    splitDivider(isWide: false, totalLength: geometry.size.height)

                    dashboardContent()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }

    private func panelLength(total: CGFloat, fraction: CGFloat) -> CGFloat {
        max(0, total * fraction - splitHitArea / 2)
    }

    private var splitHitArea: CGFloat { 16 }

    private func splitDivider(isWide: Bool, totalLength: CGFloat) -> some View {
        Color.clear
            .frame(width: isWide ? splitHitArea : nil, height: isWide ? nil : splitHitArea)
            .overlay {
                if isWide {
                    Color.secondary.opacity(0.45)
                        .frame(width: 1 / displayScale)
                } else {
                    Color.secondary.opacity(0.45)
                        .frame(height: 1 / displayScale)
                }
            }
            .contentShape(.rect)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        updateSplit(
                            isWide: isWide,
                            translation: isWide ? value.translation.width : value.translation.height,
                            totalLength: totalLength
                        )
                    }
                    .onEnded { _ in
                        saveSplit(isWide: isWide)
                    }
            )
            .accessibilityLabel("Resize forecast panels")
            .accessibilityHint(isWide ? "Drag left or right to resize the grid" : "Drag up or down to resize the grid")
    }

    private func updateSplit(isWide: Bool, translation: CGFloat, totalLength: CGFloat) {
        guard totalLength > 0 else { return }
        let start = splitFractionAtDragStart ?? (isWide ? wideSplitFraction : tallSplitFraction)
        splitFractionAtDragStart = start
        let fraction = min(max(start + translation / totalLength, 0.25), 0.75)
        if isWide {
            wideSplitFraction = fraction
        } else {
            tallSplitFraction = fraction
        }
    }

    private func saveSplit(isWide: Bool) {
        ForecastWorkspaceSplitStore.save(isWide ? wideSplitFraction : tallSplitFraction, isWide: isWide)
        splitFractionAtDragStart = nil
    }
}

#if DEBUG
#Preview("Forecast grid and dashboard workspace") {
    ForecastGridDashboardWorkspace {
        ContentUnavailableView("Forecast grid", systemImage: "tablecells")
    } dashboard: {
        ContentUnavailableView("Forecast dashboard", systemImage: "rectangle.3.group")
    }
}
#endif
#endif
