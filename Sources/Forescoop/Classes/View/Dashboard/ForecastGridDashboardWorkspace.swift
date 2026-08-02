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
    @GestureState private var splitDragTranslation: CGSize = .zero
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
                let dividerFraction = displayedSplitFraction(isWide: true, totalLength: geometry.size.width)
                HStack(spacing: 0) {
                    gridContent()
                        .frame(width: panelLength(total: geometry.size.width, fraction: wideSplitFraction))

                    dashboardContent()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .overlay(alignment: .leading) {
                    splitDivider(
                        isWide: true,
                        totalLength: geometry.size.width,
                        crossLength: geometry.size.height
                    )
                    .offset(x: panelLength(total: geometry.size.width, fraction: dividerFraction) - splitHitArea / 2)
                }
            } else {
                let dividerFraction = displayedSplitFraction(isWide: false, totalLength: geometry.size.height)
                VStack(spacing: 0) {
                    gridContent()
                        .frame(height: panelLength(total: geometry.size.height, fraction: tallSplitFraction))

                    dashboardContent()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .overlay(alignment: .top) {
                    splitDivider(
                        isWide: false,
                        totalLength: geometry.size.height,
                        crossLength: geometry.size.width
                    )
                    .offset(y: panelLength(total: geometry.size.height, fraction: dividerFraction) - splitHitArea / 2)
                }
            }
        }
    }

    private func panelLength(total: CGFloat, fraction: CGFloat) -> CGFloat {
        max(0, total * fraction)
    }

    private var splitHitArea: CGFloat { 16 }

    private func splitDivider(isWide: Bool, totalLength: CGFloat, crossLength: CGFloat) -> some View {
        Color.clear
            .frame(
                width: isWide ? splitHitArea : crossLength,
                height: isWide ? crossLength : splitHitArea
            )
            .overlay {
                if isWide {
                    Color.secondary.opacity(0.45)
                        .frame(width: 5 / displayScale)
                } else {
                    Color.secondary.opacity(0.45)
                        .frame(height: 5 / displayScale)
                }
            }
            .contentShape(.rect)
            .gesture(
                DragGesture()
                    .updating($splitDragTranslation) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        saveSplit(
                            isWide: isWide,
                            translation: isWide ? value.translation.width : value.translation.height,
                            totalLength: totalLength
                        )
                    }
            )
            .accessibilityLabel("Resize forecast panels")
            .accessibilityHint(isWide ? "Drag left or right to resize the grid" : "Drag up or down to resize the grid")
    }

    private func displayedSplitFraction(isWide: Bool, totalLength: CGFloat) -> CGFloat {
        guard totalLength > 0 else { return isWide ? wideSplitFraction : tallSplitFraction }
        let translation = isWide ? splitDragTranslation.width : splitDragTranslation.height
        let storedFraction = isWide ? wideSplitFraction : tallSplitFraction
        return min(max(storedFraction + translation / totalLength, 0.25), 0.75)
    }

    private func saveSplit(isWide: Bool, translation: CGFloat, totalLength: CGFloat) {
        guard totalLength > 0 else { return }
        let storedFraction = isWide ? wideSplitFraction : tallSplitFraction
        let fraction = min(max(storedFraction + translation / totalLength, 0.25), 0.75)
        if isWide {
            wideSplitFraction = fraction
        } else {
            tallSplitFraction = fraction
        }
        ForecastWorkspaceSplitStore.save(fraction, isWide: isWide)
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
