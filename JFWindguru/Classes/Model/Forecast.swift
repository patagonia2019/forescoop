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


public class Forecast: Object, Mappable {
    dynamic var initStamp : Int = 0
    var temperature: TimeWeather? // temperature
    var cloudCoverTotal: TimeWeather? //  Cloud cover (%) Total
    var cloudCoverHigh: TimeWeather? //  Cloud cover (%) High
    var cloudCoverMid: TimeWeather? //  Cloud cover (%) Mid
    var cloudCoverLow: TimeWeather? //  Cloud cover (%) Low
    var relativeHumidity: TimeWeather? //  Relative humidity: relative humidity in percent
    var windGust: TimeWeather? //  Wind gusts (knots)
    var seaLevelPressure: TimeWeather? //  sea level pressure
    var freezingLevel: TimeWeather? //  Freezing Level height in meters (0 degree isoterm)
    var precipitation: TimeWeather? //  Precip. (mm/3h)
    var windSpeed: TimeWeather? //  Wind speed (knots)
    var windDirection: TimeWeather? //  Wind direction
    var windDirectionName: TimeWeather? //  wind direction (name)
    var temperatureReal: TimeWeather? //  temperature in 2 meters above ground with correction to real altitude of the spot.
    dynamic var initDate: String?
    dynamic var modelName: String?

#if USE_EXT_FWK
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
        initDate <- map["initdate"]
        modelName <- map["model_name"]
    }

#else
    public required init(dictionary: [String: Any?]) {
        super.init()
        initStamp = dictionary["initstamp"] as? Int ?? 0
        initDate = dictionary["initdate"] as? String
        modelName = dictionary["model_name"] as? String
        for (k, v) in dictionary {
            if let dict = v as? [String: Any?] {
                let tw = TimeWeather.init(dictionary: dict)
                switch k {
                case "TMP": temperature = tw; break
                case "TCDC": cloudCoverTotal = tw; break
                case "HCDC": cloudCoverHigh = tw; break
                case "MCDC": cloudCoverMid = tw; break
                case "LCDC": cloudCoverLow = tw; break
                case "RH": relativeHumidity = tw; break
                case "GUST": windGust = tw; break
                case "SLP": seaLevelPressure = tw; break
                case "FLHGT": freezingLevel = tw; break
                case "APCP": precipitation = tw; break
                case "WINDSPD": windSpeed = tw; break
                case "WINDDIR": windDirection = tw; break
                case "WINDIRNAME": windDirectionName = tw; break
                case "TMPE": temperatureReal = tw; break
                default:
                    break
                }
            }
        }
    }
#endif

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
