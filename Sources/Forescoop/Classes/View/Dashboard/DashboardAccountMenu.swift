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
    let isLoggedIn: Bool
    let onShowDashboard: () -> Void
    let onShowGrid: () -> Void
    let onShowSettings: () -> Void
    let onShowAbout: () -> Void
    let onShowAccount: () -> Void
    let onShowFavorites: () -> Void
    let onLogout: () -> Void

    var body: some View {
        Menu {
            if isShowingGrid {
                Button("Forecast Dashboard", systemImage: "rectangle.3.group", action: onShowDashboard)
            } else {
                Button("Forecast Grid", systemImage: "tablecells", action: onShowGrid)
            }

            Divider()

            Button("Settings", systemImage: "gearshape", action: onShowSettings)
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
        isLoggedIn: true,
        onShowDashboard: {},
        onShowGrid: {},
        onShowSettings: {},
        onShowAbout: {},
        onShowAccount: {},
        onShowFavorites: {},
        onLogout: {}
    )
    .padding()
}
#endif
#endif
