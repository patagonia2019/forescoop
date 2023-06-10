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

    var forecasts = Array<ForecastModel>()

    required convenience init?(map: [String: Any]?) {
        self.init()
        mapping(map: map)
    }

    public override func mapping(map: [String:Any]?) {
        guard let map = map else { return }

        super.mapping(map: map)
        guard let forecastDict = map["forecast"] as? [String: Any] else { return }
        forecasts = forecastDict.compactMap { ForecastModel(map: ["model" : $0.key, "info" : $0.value, "gmt_hour_offset": gmtHourOffset]) }
        currentModel = forecasts.last?.model
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
    
    /// Information comes in UTC, contains the every 3 hours information
    var weatherInfo: String {
        
        var str: String = ""
        if isNight {
            str = "🌙"
        } else {
            str = "☀️"
        }
        if isRaining {
            str += "🌧"
        } else if isCloudy {
            str += "🌥"
        }
        return str
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
        elapseContainsTime(date: NSDate())
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
    
    var currentHourInt: Int {
        let date = NSDate()
        let calendar = NSCalendar.current
        let hour = calendar.component(.hour, from: date as Date)
        
        // TODO: Timezone
        return hour
    }
    
    var currentHour: Int {
        var hour: Int = currentHourInt
        let remainder = hour % 3

        hour -= remainder

        // TODO: here the increment
        return hour
    }
    
    var currentHourString: String? {
        var hourString: String
        let hh: Int = currentHour
        
        hourString = String(format: "%d", hh)
        
        return hourString
    }
}
