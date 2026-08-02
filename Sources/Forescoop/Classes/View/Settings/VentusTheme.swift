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
    case liquidGlass
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
        case .liquidGlass: "Liquid Glass"
        case .ocean: "Ocean"
        case .forest: "Forest"
        case .sunset: "Sunset"
        case .arctic: "Arctic"
        case .lavender: "Lavender"
        case .desert: "Desert"
        }
    }

    public var accentColor: Color {
        switch self {
        case .system: .accentColor
        case .liquidGlass: .accentColor
        case .ocean: Color(red: 0.02, green: 0.43, blue: 0.68)
        case .forest: Color(red: 0.10, green: 0.45, blue: 0.27)
        case .sunset: Color(red: 0.77, green: 0.25, blue: 0.20)
        case .arctic: Color(red: 0.08, green: 0.42, blue: 0.60)
        case .lavender: Color(red: 0.42, green: 0.28, blue: 0.72)
        case .desert: Color(red: 0.62, green: 0.32, blue: 0.08)
        }
    }

    public var backgroundColor: Color {
        switch self {
        case .system: .clear
        case .liquidGlass: .clear
        case .ocean: Color(red: 0.92, green: 0.97, blue: 1.0)
        case .forest: Color(red: 0.94, green: 0.98, blue: 0.93)
        case .sunset: Color(red: 1.0, green: 0.95, blue: 0.91)
        case .arctic: Color(red: 0.92, green: 0.98, blue: 1.0)
        case .lavender: Color(red: 0.97, green: 0.94, blue: 1.0)
        case .desert: Color(red: 1.0, green: 0.96, blue: 0.86)
        }
    }

    public var primaryTextColor: Color {
        switch self {
        case .system: .primary
        case .liquidGlass: .primary
        case .ocean: Color(red: 0.02, green: 0.16, blue: 0.27)
        case .forest: Color(red: 0.04, green: 0.20, blue: 0.10)
        case .sunset: Color(red: 0.29, green: 0.10, blue: 0.06)
        case .arctic: Color(red: 0.02, green: 0.18, blue: 0.28)
        case .lavender: Color(red: 0.18, green: 0.10, blue: 0.32)
        case .desert: Color(red: 0.25, green: 0.13, blue: 0.03)
        }
    }

    public var fontDesign: Font.Design? {
        switch self {
        case .system, .liquidGlass: nil
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
        (self == .system || self == .liquidGlass) ? 1 : 0.72
    }

    /// Uses the adaptive system material that reads as Liquid Glass on modern
    /// platforms and remains a native material surface on every supported OS.
    public var usesMaterial: Bool { self == .liquidGlass }
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

/// Applies the platform's native Liquid Glass treatment only for the Liquid
/// Glass theme. Other themes retain their existing visual treatment.
public extension View {
    @ViewBuilder
    func ventusGlassEffect<S: Shape>(theme: VentusTheme, in shape: S) -> some View {
#if os(visionOS)
        // visionOS already supplies depth and material to its windows; this
        // API is unavailable there.
        self
#else
        if theme.usesMaterial {
            glassEffect(.regular, in: shape)
        } else {
            self
        }
#endif
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

        let surfacedContent = themedContent.background {
            if theme.usesMaterial {
                Rectangle().fill(.ultraThinMaterial).ignoresSafeArea()
            } else {
                theme.backgroundColor.ignoresSafeArea()
            }
        }

        if let fontDesign = theme.fontDesign {
            surfacedContent.fontDesign(fontDesign)
        } else {
            surfacedContent
        }
    }
}

/// Theme storage shared by every Forescoop target installed on this device.
/// The App Group is intentionally also used by the widget extensions.
public enum VentusThemeStore {
    private static let key = "ventusTheme"
    private static let appGroupIdentifier = "group.org.forescoop.shared"
    private static func defaults() -> UserDefaults {
        UserDefaults(suiteName: appGroupIdentifier) ?? .standard
    }

    public static func load() -> VentusTheme {
        defaults().string(forKey: key).flatMap(VentusTheme.init(rawValue:)) ?? .system
    }

    public static func save(_ theme: VentusTheme) {
        defaults().set(theme.rawValue, forKey: key)
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

#Preview("Liquid Glass theme") {
    VStack(alignment: .leading, spacing: 12) {
        Text("Ventus")
            .font(.title.bold())
        Label("Forecast Dashboard", systemImage: "wind")
        Text("Adaptive material surface")
    }
    .padding()
    .modifier(VentusThemeModifier(theme: .liquidGlass))
}
