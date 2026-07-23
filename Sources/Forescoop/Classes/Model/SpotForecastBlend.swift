//
//  SpotForecastBlend.swift
//  Forescoop
//
//  Created by Javier Fuchs on 07/22/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

import Foundation

public extension SpotForecast {
    /// Creates an equal-weight local blend of individual Windguru model forecasts.
    static func blended(_ forecasts: [SpotForecast]) throws -> SpotForecast? {
        guard let base = forecasts.first,
              forecasts.count > 1,
              forecasts.allSatisfy({ $0.forecast != nil }) else {
            return forecasts.first
        }

        let sources = forecasts.compactMap(\.forecast)
        let commonHours = sources.dropFirst().reduce(Set(sources[0].availableHours)) {
            $0.intersection(Set($1.availableHours))
        }
        guard !commonHours.isEmpty else { throw CustomError.notMappeable }

        let weatherKeys = Set(sources.flatMap { $0.weathers.map { Array($0.keys) } ?? [] })
        var blendedWeather = [String: [String: Any]]()
        for key in weatherKeys where key != TypeOfWeather.WINDIRNAME.rawValue {
            var valuesByHour = [String: Any]()
            for hour in commonHours {
                let values = sources.compactMap { numericValue($0.weathers?[key]?.info[hour]) }
                guard !values.isEmpty else { continue }
                let value = key == TypeOfWeather.WINDDIR.rawValue
                    ? circularMean(values)
                    : values.reduce(0, +) / Double(values.count)
                valuesByHour[hour] = value
            }
            if !valuesByHour.isEmpty { blendedWeather[key] = valuesByHour }
        }

        if let directions = blendedWeather[TypeOfWeather.WINDDIR.rawValue] {
            blendedWeather[TypeOfWeather.WINDIRNAME.rawValue] = directions.reduce(into: [:]) { result, item in
                result[item.key] = WindDirection(value: Int(item.value as? Double ?? 0)).description
            }
        }

        let mixName = "Forescoop Mix (\(forecasts.count) models)"
        var model: [String: Any] = blendedWeather
        model["initdate"] = base.forecast?.initdate ?? ""
        model["initstamp"] = base.forecast?.initStamp ?? 0
        model["model_name"] = mixName
        let map: [String: Any] = [
            "id_spot": base.id_spot ?? "",
            "spotname": base.spotname ?? "",
            "country": base.country ?? "",
            "id_country": base.id_country,
            "lat": base.latitude,
            "lon": base.longitude,
            "alt": base.altitude,
            "gmt_hour_offset": base.gmt_hour_offset,
            "models": base.models,
            "forecast": ["forescoop-mix": model]
        ]
        return try SpotForecast(map: map)
    }
}

private func numericValue(_ value: Any?) -> Double? {
    switch value {
    case let value as Double: value
    case let value as Int: Double(value)
    case let value as NSNumber: value.doubleValue
    default: nil
    }
}

private func circularMean(_ degrees: [Double]) -> Double {
    let radians = degrees.map { $0 * .pi / 180 }
    let angle = atan2(radians.map(sin).reduce(0, +), radians.map(cos).reduce(0, +)) * 180 / .pi
    return angle >= 0 ? angle : angle + 360
}
