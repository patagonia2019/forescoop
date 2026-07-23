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
