//
//  Forecast.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/7/15.
//  Copyright © 2015 Fuchs. All rights reserved.
//

import Foundation
import ObjectMapper

/*
 *  Forecast
 *
 *  Discussion:
 *    Model object representing forecast information, temperature, cloud cover (total, high, 
 *    middle and lower), relative humidity, wind gusts, sea level pressure, feezing level, 
 *    precipitations, wind (speed and direction)
 *
 *  {
 *     "initstamp": 1444197600,
 *     "TMP": { },
 *     "TCDC": { },
 *     "HCDC": { },
 *     "MCDC": { },
 *     "LCDC": { },
 *     "RH": { },
 *     "GUST": { },
 *     "SLP": { },
 *     "FLHGT": { },
 *     "APCP": { },
 *     "WINDSPD": { },
 *     "WINDDIR": { },
 *     "WINDIRNAME": { },
 *     "TMPE": { },
 *     "initdate": "2015-10-07 06:00:00",
 *     "model_name": "GFS 27 km"
 *  }
 */

public class Forecast: Mappable {
    public var initStamp: Int?
    public var temperature: TimeWeather? // temperature
    public var cloudCoverTotal: TimeWeather? //  Cloud cover (%) Total
    public var cloudCoverHigh: TimeWeather? //  Cloud cover (%) High
    public var cloudCoverMid: TimeWeather? //  Cloud cover (%) Mid
    public var cloudCoverLow: TimeWeather? //  Cloud cover (%) Low
    public var relativeHumidity: TimeWeather? //  Relative humidity: relative humidity in percent
    public var windGust: TimeWeather? //  Wind gusts (knots)
    public var seaLevelPressure: TimeWeather? //  sea level pressure
    public var freezingLevel: TimeWeather? //  Freezing Level height in meters (0 degree isoterm)
    public var precipitation: TimeWeather? //  Precip. (mm/3h)
    public var windSpeed: TimeWeather? //  Wind speed (knots)
    public var windDirection: TimeWeather? //  Wind direction
    public var windDirectionName: TimeWeather? //  wind direction (name)
    public var temperatureReal: TimeWeather? //  temperature in 2 meters above ground with correction to real altitude of the spot.
    public var initDate: Date?
    public var modelName: String?

    required public init?(map: Map){
        
    }
    
    public func mapping(map: Map) {
        initStamp <- map["initstamp"]
        temperature <- map["TMP"]
        cloudCoverTotal <- map["TCDC"]
        cloudCoverHigh <- map["HCDC"]
        cloudCoverMid <- map["MCDC"]
        cloudCoverLow <- map["LCDC"]
        relativeHumidity <- map["RH"]
        windGust <- map["GUST"]
        seaLevelPressure <- map["SLP"]
        freezingLevel <- map["FLHGT"]
        precipitation <- map["APCP"]
        windSpeed <- map["WINDSPD"]
        windDirection <- map["WINDDIR"]
        windDirectionName <- map["WINDIRNAME"]
        temperatureReal <- map["TMPE"]
        initDate <- (map["initdate"], DateTransform())
        modelName <- map["model_name"]
    }
    
    public var description : String {
        var aux : String = ""
        if let initStamp = initStamp {
            aux += "initStamp \(initStamp), "
        }
        if let cloudCoverTotal = cloudCoverTotal {
            aux += "Cloud cover Total: \(cloudCoverTotal)  "
        }
        if let cloudCoverHigh = cloudCoverHigh {
            aux += "High: \(cloudCoverHigh) "
        }
        if let cloudCoverMid = cloudCoverMid {
            aux += "Mid: \(cloudCoverMid) "
        }
        if let cloudCoverLow = cloudCoverLow {
            aux += "Low: \(cloudCoverLow), "
        }
        if let relativeHumidity = relativeHumidity {
            aux += "Humidity: \(relativeHumidity), "
        }
        if let seaLevelPressure = seaLevelPressure {
            aux += "\(seaLevelPressure), "
        }
        if let freezingLevel = freezingLevel {
            aux += "\(freezingLevel), "
        }
        if let precipitation = precipitation {
            aux += "\(precipitation). "
        }
        if let windGust = windGust {
            aux += "Wind gust: \(windGust) "
        }
       if let windSpeed = windSpeed {
            aux += "speed: \(windSpeed) "
        }
        if let windDirection = windDirection {
            aux += "direccion: (\(windDirection) "
        }
        if let windDirectionName = windDirectionName {
            aux += "\(windDirectionName)), "
        }
        if let temperature = temperature {
            aux += "Temp: \(temperature), "
        }
       if let temperatureReal = temperatureReal {
            aux += "real: \(temperatureReal), "
        }
        if let initDate = initDate {
            aux += "initDate: \(initDate), "
        }
        if let modelName = modelName {
            aux += "modelName: \(modelName).\n"
        }
        return aux
    }
    
    


}
