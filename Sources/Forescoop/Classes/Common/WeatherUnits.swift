//
//  WeatherUnits.swift
//  Forescoop
//
//  Created by Javier Fuchs on 07/22/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

import Foundation

public enum WindSpeedUnit: String, CaseIterable, Identifiable, Sendable {
    case knots
    case metersPerSecond
    case kilometersPerHour
    case milesPerHour
    case beaufort

    public var id: Self { self }

    public var label: String {
        switch self {
        case .knots: "knots"
        case .metersPerSecond: "m/s"
        case .kilometersPerHour: "km/h"
        case .milesPerHour: "mph"
        case .beaufort: "Bft"
        }
    }
}

public extension WindSpeedUnit {
    init?(windguruPreference: String?) {
        switch windguruPreference?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "knots", "knot", "kt", "kts": self = .knots
        case "m/s", "ms", "mps": self = .metersPerSecond
        case "km/h", "kmh", "kph": self = .kilometersPerHour
        case "mph": self = .milesPerHour
        case "bft", "beaufort": self = .beaufort
        default: return nil
        }
    }
}

public enum TemperatureUnit: String, CaseIterable, Identifiable, Sendable {
    case celsius
    case fahrenheit

    public var id: Self { self }

    public var label: String {
        switch self {
        case .celsius: "°C"
        case .fahrenheit: "°F"
        }
    }
}

public extension TemperatureUnit {
    init?(windguruPreference: String?) {
        switch windguruPreference?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "c", "°c", "celsius": self = .celsius
        case "f", "°f", "fahrenheit": self = .fahrenheit
        default: return nil
        }
    }
}

public enum WaveHeightUnit: String, CaseIterable, Identifiable, Sendable {
    case meters
    case feet

    public var id: Self { self }

    public var label: String {
        switch self {
        case .meters: "m"
        case .feet: "ft"
        }
    }

    public init?(windguruPreference: String?) {
        switch windguruPreference?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "m", "meter", "meters", "metre", "metres": self = .meters
        case "ft", "foot", "feet": self = .feet
        default: return nil
        }
    }
}

public enum PressureUnit: String, CaseIterable, Identifiable, Sendable {
    case hectopascals
    case millibars
    case inchesOfMercury
    case millimetersOfMercury

    public var id: Self { self }

    public var label: String {
        switch self {
        case .hectopascals: "hPa"
        case .millibars: "mbar"
        case .inchesOfMercury: "inHg"
        case .millimetersOfMercury: "mmHg"
        }
    }
}

public enum PrecipitationUnit: String, CaseIterable, Identifiable, Sendable {
    case millimeters
    case inches

    public var id: Self { self }

    public var label: String {
        switch self {
        case .millimeters: "mm"
        case .inches: "in"
        }
    }
}

public enum FreezingLevelUnit: String, CaseIterable, Identifiable, Sendable {
    case meters
    case feet

    public var id: Self { self }

    public var label: String {
        switch self {
        case .meters: "m"
        case .feet: "ft"
        }
    }
}

/// Device defaults used when no Windguru account is signed in.
/// They follow the iPhone's regional measurement system rather than app-specific values.
public enum DeviceForecastPreferences {
    private static var usesMetricSystem: Bool { Locale.autoupdatingCurrent.measurementSystem != .us }

    public static var temperatureUnit: TemperatureUnit {
        usesMetricSystem ? .celsius : .fahrenheit
    }

    public static var windSpeedUnit: WindSpeedUnit {
        usesMetricSystem ? .kilometersPerHour : .milesPerHour
    }

    public static var waveHeightUnit: WaveHeightUnit {
        usesMetricSystem ? .meters : .feet
    }

    public static var pressureUnit: PressureUnit {
        usesMetricSystem ? .hectopascals : .inchesOfMercury
    }

    public static var precipitationUnit: PrecipitationUnit {
        usesMetricSystem ? .millimeters : .inches
    }

    public static var freezingLevelUnit: FreezingLevelUnit {
        usesMetricSystem ? .meters : .feet
    }
}

public struct Temperature: Sendable {
    public let celsius: Double

    public init(celsius: Double) {
        self.celsius = celsius
    }

    public func value(in unit: TemperatureUnit) -> Double {
        switch unit {
        case .celsius: celsius
        case .fahrenheit: celsius * 9 / 5 + 32
        }
    }
}

public struct AtmosphericPressure: Sendable {
    public let hectopascals: Double

    public init(hectopascals: Double) {
        self.hectopascals = hectopascals
    }

    public func value(in unit: PressureUnit) -> Double {
        switch unit {
        case .hectopascals, .millibars: hectopascals
        case .inchesOfMercury: hectopascals * 0.029_529_983_071_4
        case .millimetersOfMercury: hectopascals * 0.750_061_683
        }
    }
}

public struct Precipitation: Sendable {
    public let millimeters: Double

    public init(millimeters: Double) {
        self.millimeters = millimeters
    }

    public func value(in unit: PrecipitationUnit) -> Double {
        switch unit {
        case .millimeters: millimeters
        case .inches: millimeters / 25.4
        }
    }
}

public struct FreezingLevel: Sendable {
    public let meters: Double

    public init(meters: Double) {
        self.meters = meters
    }

    public func value(in unit: FreezingLevelUnit) -> Double {
        switch unit {
        case .meters: meters
        case .feet: meters * 3.280_839_895
        }
    }
}

public struct WaveHeight: Sendable {
    public let meters: Double

    public init(meters: Double) {
        self.meters = meters
    }

    public func value(in unit: WaveHeightUnit) -> Double {
        switch unit {
        case .meters: meters
        case .feet: meters * 3.280_839_895
        }
    }
}
