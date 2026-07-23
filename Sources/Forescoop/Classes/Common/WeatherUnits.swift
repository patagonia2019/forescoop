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
