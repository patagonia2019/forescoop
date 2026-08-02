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

    init(
        @ViewBuilder grid: @escaping () -> GridContent,
        @ViewBuilder dashboard: @escaping () -> DashboardContent
    ) {
        gridContent = grid
        dashboardContent = dashboard
    }

    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > geometry.size.height {
                HStack(spacing: 0) {
                    gridContent()
                        .frame(width: geometry.size.width * 0.56)

                    Divider()

                    dashboardContent()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                VStack(spacing: 0) {
                    gridContent()
                        .frame(height: geometry.size.height * 0.52)

                    Divider()

                    dashboardContent()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
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
