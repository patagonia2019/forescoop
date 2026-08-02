//
//  VentusTheme.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 08/02/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

import SwiftUI

/// Device-wide visual treatments. Font design changes preserve each view's
/// existing size, weight, and dynamic-type behavior.
public enum VentusTheme: String, CaseIterable, Identifiable, Sendable {
    case system
    case ocean
    case forest
    case sunset
    case arctic
    case lavender
    case desert

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .system: "System Default"
        case .ocean: "Ocean"
        case .forest: "Forest"
        case .sunset: "Sunset"
        case .arctic: "Arctic"
        case .lavender: "Lavender"
        case .desert: "Desert"
        }
    }

    var accentColor: Color {
        switch self {
        case .system: .accentColor
        case .ocean: Color(red: 0.02, green: 0.43, blue: 0.68)
        case .forest: Color(red: 0.10, green: 0.45, blue: 0.27)
        case .sunset: Color(red: 0.77, green: 0.25, blue: 0.20)
        case .arctic: Color(red: 0.08, green: 0.42, blue: 0.60)
        case .lavender: Color(red: 0.42, green: 0.28, blue: 0.72)
        case .desert: Color(red: 0.62, green: 0.32, blue: 0.08)
        }
    }

    var backgroundColor: Color {
        switch self {
        case .system: .clear
        case .ocean: Color(red: 0.92, green: 0.97, blue: 1.0)
        case .forest: Color(red: 0.94, green: 0.98, blue: 0.93)
        case .sunset: Color(red: 1.0, green: 0.95, blue: 0.91)
        case .arctic: Color(red: 0.92, green: 0.98, blue: 1.0)
        case .lavender: Color(red: 0.97, green: 0.94, blue: 1.0)
        case .desert: Color(red: 1.0, green: 0.96, blue: 0.86)
        }
    }

    var primaryTextColor: Color {
        switch self {
        case .system: .primary
        case .ocean: Color(red: 0.02, green: 0.16, blue: 0.27)
        case .forest: Color(red: 0.04, green: 0.20, blue: 0.10)
        case .sunset: Color(red: 0.29, green: 0.10, blue: 0.06)
        case .arctic: Color(red: 0.02, green: 0.18, blue: 0.28)
        case .lavender: Color(red: 0.18, green: 0.10, blue: 0.32)
        case .desert: Color(red: 0.25, green: 0.13, blue: 0.03)
        }
    }

    var fontDesign: Font.Design? {
        switch self {
        case .system: nil
        case .ocean: .rounded
        case .forest: .serif
        case .sunset: .monospaced
        case .arctic: .rounded
        case .lavender: .serif
        case .desert: .default
        }
    }

    /// Leaves the stock weather renderer unchanged for System Default while
    /// allowing themed backgrounds to show through its animated layer.
    var weatherBackgroundOpacity: Double {
        self == .system ? 1 : 0.72
    }
}

private struct VentusThemeKey: EnvironmentKey {
    static let defaultValue = VentusTheme.system
}

public extension EnvironmentValues {
    var ventusTheme: VentusTheme {
        get { self[VentusThemeKey.self] }
        set { self[VentusThemeKey.self] = newValue }
    }
}

/// Applies a palette and a non-sizing font design to a complete app scene.
struct VentusThemeModifier: ViewModifier {
    let theme: VentusTheme

    @ViewBuilder
    func body(content: Content) -> some View {
        let themedContent = content
            .environment(\.ventusTheme, theme)
            .tint(theme.accentColor)
            .foregroundStyle(theme.primaryTextColor)
            .background(theme.backgroundColor.ignoresSafeArea())

        if let fontDesign = theme.fontDesign {
            themedContent.fontDesign(fontDesign)
        } else {
            themedContent
        }
    }
}

enum VentusThemeStore {
    private static let key = "ventusTheme"

    static func load() -> VentusTheme {
        VentusPreferenceStore.value(forKey: key)
            .flatMap(VentusTheme.init(rawValue:)) ?? .system
    }

    static func save(_ theme: VentusTheme) {
        VentusPreferenceStore.save(theme.rawValue, forKey: key)
    }
}

#Preview("Ventus themes") {
    VStack(alignment: .leading, spacing: 12) {
        Text("Ventus")
            .font(.title.bold())
        Label("Forecast Dashboard", systemImage: "wind")
        Text("Theme font design keeps this text at its existing size.")
    }
    .padding()
    .modifier(VentusThemeModifier(theme: .ocean))
}
