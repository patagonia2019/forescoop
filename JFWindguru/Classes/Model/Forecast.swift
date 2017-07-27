//
//  Forecast.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/7/15.
//  Copyright © 2015 Fuchs. All rights reserved.
//

import Foundation
#if USE_EXT_FWK
    import ObjectMapper
    import RealmSwift
#endif

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

#if USE_EXT_FWK

    public class Forecast: ForecastObject, Mappable {

        required convenience public init?(map: Map) {
            self.init()
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
    }
#else
    public class Forecast: ForecastObject {
        init(dictionary: [String: AnyObject?]) {
            super.init()
            initStamp = dictionary["initStamp"] as? Int ?? 0
        }
    }
#endif

public class ForecastObject : Object {
    dynamic var initStamp : Int = 0
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
    public dynamic var initDate: Date?
    public dynamic var modelName: String?


    override public var description : String {
        var aux : String = "\(type(of:self)): \n"
        aux += "initStamp: \(initStamp)\n"
        if let cloudCoverTotal = cloudCoverTotal {
            aux += "Cloud cover Total: \(cloudCoverTotal.description)\n"
        }
        if let cloudCoverHigh = cloudCoverHigh {
            aux += "High: \(cloudCoverHigh.description)\n"
        }
        if let cloudCoverMid = cloudCoverMid {
            aux += "Mid: \(cloudCoverMid.description)\n"
        }
        if let cloudCoverLow = cloudCoverLow {
            aux += "Low: \(cloudCoverLow.description)\n"
        }
        if let relativeHumidity = relativeHumidity {
            aux += "Humidity: \(relativeHumidity.description)\n"
        }
        if let seaLevelPressure = seaLevelPressure {
            aux += "Sea Level pressure: \(seaLevelPressure.description)\n"
        }
        if let freezingLevel = freezingLevel {
            aux += "Freezing level: \(freezingLevel.description)\n"
        }
        if let precipitation = precipitation {
            aux += "Precipitation: \(precipitation.description)\n"
        }
        if let windGust = windGust {
            aux += "Wind gust: \(windGust.description)\n"
        }
       if let windSpeed = windSpeed {
            aux += "Wind speed: \(windSpeed.description)\n"
        }
        if let windDirection = windDirection {
            aux += "Wind direccion: \(windDirection.description)\n"
        }
        if let windDirectionName = windDirectionName {
            aux += "Wind name: \(windDirectionName.description)\n"
        }
        if let temperature = temperature {
            aux += "Temp: \(temperature.description)\n"
        }
        if let temperatureReal = temperatureReal {
            aux += "Temp real: \(temperatureReal.description)\n"
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
