//
//  DashboardAccountMenu.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 08/01/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

#if !os(watchOS)
import SwiftUI

/// The dashboard hamburger menu. The parent owns navigation and session actions.
struct DashboardAccountMenu: View {
    let isShowingGrid: Bool
    let isShowingWorkspace: Bool
    let isShowingGraph: Bool
    let isLoggedIn: Bool
    let onShowDashboard: () -> Void
    let onShowGrid: () -> Void
    let onShowWorkspace: () -> Void
    let onShowGraph: () -> Void
    let onShowSettings: () -> Void
    let onShowHelp: () -> Void
    let onShowAbout: () -> Void
    let onShowAccount: () -> Void
    let onShowFavorites: () -> Void
    let onLogout: () -> Void

    var body: some View {
        Menu {
            if isShowingGrid || isShowingWorkspace || isShowingGraph {
                Button("Forecast Dashboard", systemImage: "rectangle.3.group", action: onShowDashboard)
            }
            if !isShowingGrid {
                Button("Forecast Grid", systemImage: "tablecells", action: onShowGrid)
            }
            if !isShowingWorkspace {
                Button("Grid and Dashboard", systemImage: "rectangle.split.2x1", action: onShowWorkspace)
            }
            if !isShowingGraph {
                Button("Forecast Graph", systemImage: "chart.xyaxis.line", action: onShowGraph)
            }

            Divider()

            Button("Settings", systemImage: "gearshape", action: onShowSettings)
            Button("Help", systemImage: "questionmark.circle", action: onShowHelp)
            Button("About", systemImage: "info.circle", action: onShowAbout)

            Divider()

            if isLoggedIn {
                Button("Profile", systemImage: "person.crop.circle", action: onShowAccount)
                Button("Favorites", systemImage: "star", action: onShowFavorites)
                Divider()
                Button("Logout", systemImage: "rectangle.portrait.and.arrow.right", role: .destructive, action: onLogout)
            } else {
                Button("Login", systemImage: "person.crop.circle", action: onShowAccount)
            }
        } label: {
            Label("Menu", systemImage: "line.3.horizontal")
                .labelStyle(.iconOnly)
        }
        .accessibilityLabel("Menu")
    }
}

#if DEBUG
#Preview("Dashboard account menu") {
    DashboardAccountMenu(
        isShowingGrid: false,
        isShowingWorkspace: false,
        isShowingGraph: false,
        isLoggedIn: true,
        onShowDashboard: {},
        onShowGrid: {},
        onShowWorkspace: {},
        onShowGraph: {},
        onShowSettings: {},
        onShowHelp: {},
        onShowAbout: {},
        onShowAccount: {},
        onShowFavorites: {},
        onLogout: {}
    )
    .padding()
}
#endif
#endif
