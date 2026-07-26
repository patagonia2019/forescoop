//
//  SpotForecast.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/7/15.
//  Copyright © 2023 Fuchs. All rights reserved.
//

import Foundation

/*
 *  SpotForecast
 *
 *  Discussion:
 *    Represents a model information of the stot or location when the forecast is obtained.
 *    By inheritance the common attributes are parsed and filled in SpotInfo and Spot.
 *    Contains the complete forecast (inside a single instance of ForecastModel)
 *
 *   {
 *       "id_spot": "64141",
 *       "spotname": "Bariloche",
 *       "country": "Argentina",
 *       "id_country": 32,
 *       "lat": -41.1281,
 *       "lon": -71.348,
 *       "alt": 770,
 *       "tz": "America/Argentina/Mendoza",
 *       "gmt_hour_offset": -3,
 *       "sunrise": "07:11",
 *       "sunset": "19:54",
 *       "models": [
 *           "3"
 *       ],
 *       "tides": "0",
 *       "forecast": { ... }
 *   }
 *        
 *
 */

public class SpotForecast: SpotInfo {
    
    var currentModel: String? = nil

    var forecasts = [ForecastModel]()

    required convenience init?(map: [String: Any]?) throws {
        self.init()
        try mapping(map: map)
    }

    public override func mapping(map: [String: Any]?) throws {
        try super.mapping(map: map)
        guard let forecastDict = map?["forecast"] as? [String: Any] else { return }
        forecasts = try forecastDict.compactMap { model, value in
            guard let info = value as? [String: Any],
                  info[TypeOfWeather.WINDSPD.rawValue] is [String: Any] else {
                return nil
            }
            return try ForecastModel(map: ["model": model, "info": info, "gmt_hour_offset": gmtHourOffset])
        }
        currentModel = forecasts.first(where: { $0.model == Model.defaultModel })?.model ?? forecasts.first?.model
    }
    
    override public var description : String {
        [
            super.description,
            "\(type(of:self)): ",
            currentModel?.description,
            forecasts
                .compactMap({$0.description})
                .joined(separator: "\n")
        ]
            .compactMap{$0}
            .joined(separator: "\n")
    }
}

public extension SpotForecast {

    var availableForecastHours: [String] {
        forecast?.availableHours ?? []
    }

    var currentForecastHour: String? {
        availableForecastHours.min {
            abs((Int($0) ?? .max) - currentHourInt) < abs((Int($1) ?? .max) - currentHourInt)
        }
    }

    /// The local calendar date represented by a forecast hour offset.
    ///
    /// Windguru's hour keys are displayed relative to today's midnight: `27` is
    /// therefore tomorrow at 03:00, regardless of when the forecast was fetched.
    func forecastDate(hour: String?, relativeTo referenceDate: Date = Date()) -> Date? {
        guard let offset = Int(hour ?? "") else { return nil }
        let calendar = Calendar.current
        return calendar.date(byAdding: .hour, value: offset, to: calendar.startOfDay(for: referenceDate))
    }
    
    var numberOfForecasts: Int {
        forecasts.count
    }
    
    var model: String? {
        currentModel
    }
    
    var forecastModel: ForecastModel? {
        forecasts.first(where: {$0.model == currentModel})
    }
    
    var forecast: Forecast? {
        forecastModel?.forecast
    }
    
    /// The current weather symbol, using the nearest available forecast hour.
    var weatherInfo: String {
        weatherSymbolName(hour: currentForecastHour)
    }

    /// The primary SF Symbol matching the weather data for a particular forecast hour.
    func weatherSymbolName(hour: String?) -> String {
        weatherSymbolNames(hour: hour).first ?? "sun.max.fill"
    }

    /// SF Symbols matching all applicable weather conditions for a forecast hour.
    func weatherSymbolNames(hour: String?) -> [String] {
        let precipitation = forecast?.precipitation(hh: hour)
            ?? forecast?.precipitation1(hh: hour)
            ?? 0
        let modelTemperature = forecast?.temperature(hh: hour) ?? forecast?.temperatureReal(hh: hour) ?? 0
        let cloudCover = forecast?.cloudCoverTotal(hh: hour) ?? 0
        let humidity = forecast?.relativeHumidity(hh: hour) ?? 0
        let windSpeed = forecast?.windSpeed(hh: hour) ?? 0
        let windGusts = forecast?.windGusts(hh: hour) ?? 0
        let isNight = elapseContainsTime(date: forecastDate(hour: hour) ?? Date())
        var symbols: [String] = []

        if windGusts >= 60 {
            symbols.append("tornado")
        } else if windSpeed > 0 {
            symbols.append("wind")
        }

        if humidity >= 95 && cloudCover >= 80 {
            symbols.append("cloud.fog")
        } else if cloudCover >= 80 {
            symbols.append("cloud.fill")
        } else if cloudCover > 0 {
            symbols.append(isNight ? "cloud.moon.fill" : "cloud.sun.fill")
        } else {
            symbols.append(isNight ? "moon.stars.fill" : modelTemperature >= 30 ? "sun.haze" : "sun.max.fill")
        }

        if precipitation >= 8 {
            symbols.append("cloud.heavyrain")
        } else if precipitation > 0 && precipitation < 2 {
            symbols.append("cloud.drizzle")
        } else if precipitation > 0 {
            symbols.append("cloud.rain.fill")
        }
        if precipitation > 0 && modelTemperature <= 0 {
            symbols.append("snowflake")
        }

        return symbols
    }
    
    var asHourString: String {
        var hourString: String
        let hh: Int = currentHour

        hourString = String(format: "%02d hs", hh)
        
        return hourString
    }
    
    var asCurrentWindDirectionName: String? {
        forecast?.windDirectionName(hh: currentHourString)
    }
    
    var asCurrentWindDirection: Float {
        Float(forecast?.windDirection(hh: currentHourString) ?? 0.0)
    }
    
    var asCurrentWindSpeed: String? {
        guard let forecast = forecast,
            let windSpeed = forecast.windSpeed(hh: currentHourString) else {
                return nil
        }
        return "\(windSpeed) knots"
    }
    
    // "11"
    var asCurrentTemperature: String? {
        guard let forecast = forecast,
            let temperatureReal = forecast.temperatureReal(hh: currentHourString) else {
                return nil
        }
        return "\(temperatureReal)\(asCurrentUnit)"
    }
    
    // "C" or "F"
    var asCurrentUnit: String {
        "°C"
    }
    
    // name contains the location in this object
    var asCurrentLocation: String? {
        name
    }
}

private extension SpotForecast {
    
    var isNight: Bool {
        elapseContainsTime(date: Date())
    }
    
    var isSunny: Bool {
        // if TCDC is == 0
        cloudCoverTotal == 0
    }
    
    var isCloudy: Bool {
        !isSunny
    }
    
    var cloudCoverTotal: Int {
        forecast?.cloudCoverTotal(hh: currentHourString) ?? 0
    }
    
    var isRaining: Bool {
        precipitation > 0.0
    }
    
    var precipitation: Double {
        forecast?.precipitation(hh: currentHourString) ?? 0
    }

    var windSpeed: Double {
        forecast?.windSpeed(hh: currentHourString) ?? 0
    }

    var windGusts: Double {
        forecast?.windGusts(hh: currentHourString) ?? 0
    }

    var relativeHumidity: Int {
        forecast?.relativeHumidity(hh: currentHourString) ?? 0
    }

    var currentTemperature: Double {
        forecast?.temperatureReal(hh: currentHourString) ?? forecast?.temperature(hh: currentHourString) ?? 0
    }
    
    var mockupCurrentHourInt: Int {
        12
    }

    var realCurrentHourInt: Int {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        return hour
    }

    var currentHourInt: Int {
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            return mockupCurrentHourInt
        } else {
            return realCurrentHourInt
        }
    }
    
    var currentHour: Int {
        Int(currentForecastHour ?? "") ?? currentHourInt
    }
    
    var currentHourString: String? {
        currentForecastHour
    }
}
