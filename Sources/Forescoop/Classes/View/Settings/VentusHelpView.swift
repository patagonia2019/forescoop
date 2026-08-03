//
//  VentusHelpView.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 08/02/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

import SwiftUI

/// An in-app guide to choosing locations, reading forecasts, and comparing
/// models in Ventus. Its flow is informed by Windguru's introductory guide.
public struct VentusHelpView: View {
    @Environment(\.dismiss) private var dismiss
    private let windguruHelpURL = URL(string: "https://www.windguru.cz/help.php?sec=intro")!
    private let windguruModelsURL = URL(string: "https://www.windguru.cz/help.php?sec=models")!

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Welcome to Ventus", systemImage: "wind")
                        .font(.title.bold())
                        .foregroundStyle(.tint)
                    Text("A practical guide to Windguru-powered forecasts across your Apple devices.")
                        .foregroundStyle(.secondary)
                }

                HelpSection {
                    VStack(alignment: .leading, spacing: 14) {
                        HelpStep(
                            number: 1,
                            title: "Choose a location",
                            detail: "Use the location button to search Windguru spots, choose a saved place, select the map, or use your current location."
                        )
                        HelpStep(
                            number: 2,
                            title: "Pick the forecast view",
                            detail: "Switch between Forecast Dashboard, Forecast Grid, or Grid and Dashboard from the menu or Settings."
                        )
                        HelpStep(
                            number: 3,
                            title: "Read and compare",
                            detail: "Tap a grid hour to inspect it in the dashboard. Select units from their blue-tinted labels, then compare selected forecast models when available."
                        )
                    }
                    .padding(.vertical, 4)
                } label: {
                    Label("Quick guide", systemImage: "list.number")
                }

                VStack(alignment: .leading, spacing: 12) {
                    Label("Ventus across Apple devices", systemImage: "apple.logo")
                        .font(.headline)

                    Text("These interface previews show how the same forecast workflow adapts to each Ventus app.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    ScrollView(.horizontal) {
                        HStack(alignment: .top, spacing: 14) {
                            HelpPlatformPreview(name: "iPhone", systemImage: "iphone", layout: .phone)
                            HelpPlatformPreview(name: "iPad", systemImage: "ipad", layout: .split)
                            HelpPlatformPreview(name: "Mac", systemImage: "laptopcomputer", layout: .split)
                            HelpPlatformPreview(name: "Vision", systemImage: "visionpro", layout: .spatial)
                            HelpPlatformPreview(name: "Watch", systemImage: "applewatch", layout: .watch)
                            HelpPlatformPreview(name: "Apple TV", systemImage: "appletv", layout: .television)
                        }
                        .padding(.vertical, 2)
                    }
                    .scrollIndicators(.hidden)
                }

                HelpSection {
                    VStack(alignment: .leading, spacing: 12) {
                        HelpFeature(symbol: "cpu", title: "Models depend on the location", detail: "Each spot exposes the forecast models that cover it. The available selection can change when you choose another location or sign in to a different account tier.")
                        HelpFeature(symbol: "circle.hexagongrid", title: "Forescoop Mix", detail: "When multiple sources are selected, Ventus presents a Forescoop Mix: one continuous forecast assembled from the selected model data available for each hour.")
                        HelpFeature(symbol: "arrow.left.and.right", title: "Compare before relying on a forecast", detail: "In Forecast Grid, use Compare models to reveal source values row by row, or Compare all to expand every forecast field at once.")
                        HelpFeature(symbol: "checklist", title: "Choose the sources", detail: "Tap the Forescoop Mix model summary below the grid to expand the checkbox list. Keep at least one model selected, then use the mix and comparison tools to judge agreement.")
                    }
                    .padding(.vertical, 4)
                } label: {
                    Label("Understanding forecast models", systemImage: "cpu")
                }

                HelpSection {
                    VStack(alignment: .leading, spacing: 12) {
                        HelpFeature(symbol: "tablecells", title: "Forecast Grid", detail: "Scroll through hours, tap a column to select it, and use the comparison control to inspect individual or all model sources.")
                        HelpFeature(symbol: "rectangle.split.2x1", title: "Grid and Dashboard", detail: "Drag the separator to choose your preferred balance. The selected hour, units, location, and models stay synchronized.")
                        HelpFeature(symbol: "cpu", title: "Forecast models", detail: "Ventus combines selected models into a Forescoop Mix. Expand the model summary in the grid to change the selected sources.")
                        HelpFeature(symbol: "map", title: "Maps and saved locations", detail: "View forecast locations on the map, keep places locally, and use Windguru favorites when signed in.")
                    }
                    .padding(.vertical, 4)
                } label: {
                    Label("Forecast essentials", systemImage: "book")
                }

                VStack(alignment: .leading, spacing: 10) {
                    Link(destination: windguruHelpURL) {
                        Label("Open Windguru introductory help", systemImage: "safari")
                    }
                    Link(destination: windguruModelsURL) {
                        Label("Open Windguru forecast model help", systemImage: "safari")
                    }
                }
                .font(.footnote)
            }
            .frame(maxWidth: 900, alignment: .leading)
            .padding()
        }
        .navigationTitle("Help")
#if os(macOS)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { dismiss() }
                    .keyboardShortcut(.cancelAction)
            }
        }
#endif
    }
}

private struct HelpStep: View {
    let number: Int
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number.formatted())
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
                .background(.tint, in: .circle)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(detail).font(.footnote).foregroundStyle(.secondary)
            }
        }
    }
}

/// A cross-platform replacement for GroupBox, which is unavailable on tvOS.
private struct HelpSection<Content: View, Label: View>: View {
    @ViewBuilder let content: () -> Content
    @ViewBuilder let label: () -> Label

    init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.content = content
        self.label = label
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            label()
                .font(.headline)
            content()
        }
        .padding()
        .background(.thinMaterial, in: .rect(cornerRadius: 16))
    }
}

private struct HelpFeature: View {
    let symbol: String
    let title: String
    let detail: String

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(detail).font(.footnote).foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: symbol)
                .foregroundStyle(.tint)
        }
    }
}

private struct HelpPlatformPreview: View {
    enum Layout { case phone, split, spatial, watch, television }

    let name: String
    let systemImage: String
    let layout: Layout
    @Environment(\.ventusTheme) private var theme

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.thinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(theme.accentColor.opacity(0.35))
                    }

                previewContent
                    .padding(12)
            }
            .frame(width: 156, height: 190)

            Label(name, systemImage: systemImage)
                .font(.caption.bold())
        }
    }

    @ViewBuilder
    private var previewContent: some View {
        switch layout {
        case .phone:
            VStack(spacing: 7) {
                previewTitle
                miniGrid
                miniDashboard
            }
        case .split:
            VStack(spacing: 7) {
                previewTitle
                HStack(spacing: 5) {
                    miniGrid
                    miniDashboard
                }
            }
        case .spatial:
            VStack(spacing: 10) {
                previewTitle
                HStack(spacing: 7) {
                    miniPanel
                    miniPanel
                }
                miniDashboard
            }
        case .watch:
            VStack(spacing: 9) {
                Image(systemName: "wind")
                    .font(.title)
                    .foregroundStyle(.tint)
                Text("Ventus")
                    .font(.caption.bold())
                Text("12 kn")
                    .font(.title3.monospacedDigit())
                Text("Cloudy")
                    .font(.caption2)
            }
        case .television:
            VStack(spacing: 8) {
                previewTitle
                HStack(spacing: 6) {
                    miniGrid
                    miniDashboard
                }
                Label("Remote-friendly forecast", systemImage: "rectangle.on.rectangle")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var previewTitle: some View {
        HStack {
            Image(systemName: "wind")
            Text("Ventus").font(.caption.bold())
            Spacer()
        }
        .foregroundStyle(.tint)
    }

    private var miniGrid: some View {
        VStack(spacing: 2) {
            ForEach(0..<4, id: \.self) { row in
                HStack(spacing: 2) {
                    Capsule().fill(theme.accentColor.opacity(0.55)).frame(width: 24, height: 5)
                    ForEach(0..<3, id: \.self) { column in
                        RoundedRectangle(cornerRadius: 1)
                            .fill((row + column).isMultiple(of: 2) ? theme.accentColor.opacity(0.24) : Color.secondary.opacity(0.15))
                            .frame(width: 17, height: 8)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var miniDashboard: some View {
        VStack(spacing: 5) {
            Image(systemName: "cloud.sun.fill")
                .font(.title3)
                .foregroundStyle(.tint)
            Text("14°")
                .font(.title3.bold())
            Capsule().fill(Color.secondary.opacity(0.2)).frame(width: 58, height: 5)
        }
        .frame(maxWidth: .infinity)
    }

    private var miniPanel: some View {
        RoundedRectangle(cornerRadius: 7)
            .fill(theme.accentColor.opacity(0.12))
            .overlay {
                Image(systemName: "wind")
                    .foregroundStyle(.tint)
            }
            .frame(height: 56)
    }
}

#Preview("Ventus help") {
    NavigationStack {
        VentusHelpView()
    }
}
