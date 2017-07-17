//
//  WForecast.swift
//  Pods
//
//  Created by javierfuchs on 7/17/17.
//
//

import Foundation
import ObjectMapper

/*
 *  WForecast
 *
 *  Discussion:
 *    Model object representing forecast information, temperature, cloud cover (total, high,
 *    middle and lower), relative humidity, wind gusts, sea level pressure, feezing level,
 *    precipitations, wind (speed and direction)
 *
 *  {
 *     "initstamp": 1444197600,
 *     "TMP": [ ],
 *     "TCDC": [ ],
 *     "HCDC": [ ],
 *     "MCDC": [ ],
 *     "LCDC": [ ],
 *     "RH": [ ],
 *     "GUST": [ ],
 *     "SLP": [ ],
 *     "FLHGT": [ ],
 *     "APCP": [ ],
 *     "WINDSPD": [ ],
 *     "WINDDIR": [ ],
 *     "SMERN": [ ], ????
 *     "WINDIRNAME": [ ],
 *     "TMPE": [ ],
 *     "initdate": "2015-10-07 06:00:00",
 *     "model_name": "GFS 27 km"
 *  }
 */

public class WForecast: Mappable {
    public var initStamp: Int? // initstamp
    public var temperature: [CGFloat]? // TMP: temperature
    public var cloudCoverTotal: [Int]? // TCDC: Cloud cover (%) Total
    public var cloudCoverHigh: [Int]? // HCDC: Cloud cover (%) High
    public var cloudCoverMid: [Int]? // MCDC: Cloud cover (%) Mid
    public var cloudCoverLow: [Int]? // LCDC: Cloud cover (%) Low
    public var relativeHumidity: [Int]? // RH: Relative humidity: relative humidity in percent
    public var windGust: [CGFloat]? // GUST: Wind gusts (knots)
    public var seaLevelPressure: [Int]? // SLP: sea level pressure
    public var freezingLevel: [Int]? //  FLHGT: Freezing Level height in meters (0 degree isoterm)
    public var precipitation: [Int]? //  APCP: Precip. (mm/3h)
    public var windSpeed: [CGFloat]? //  WINDSPD: Wind speed (knots)
    public var windDirection: [Int]? //  WINDDIR: Wind direction
    public var SMERN: [Int]?
    public var temperatureReal: [CGFloat]? // TMPE: temperature in 2 meters above ground with correction to real altitude of the spot.
    public var PCPT: [Int]?
    public var hr_weekday: [Int]?
    public var hr_h: [String]?
    public var hr_d: [String]?
    public var hours: [String]?
    public var initDate: Date?
    public var init_d: String?
    public var init_dm: String?
    public var init_h: String?
    public var initstr: String?
    public var model_name: String?
    public var model_longname: String?
    public var id_model: String?
    public var update_last: Date?
    public var update_next: Date?
    public var img_param: [String:String]?
    public var img_var_map: [String:String]?
    
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
        SMERN <- map["SMERN"]
        temperatureReal <- map["TMPE"]
        PCPT <- map["PCPT"]
        hr_weekday <- map["hr_weekday"]
        hr_h <- map["hr_h"]
        hr_d <- map["hr_d"]
        hours <- map["hours"]
        initDate <- (map["initdate"], DateTransform())
        init_d <- map["init_d"]
        init_dm <- map["init_dm"]
        init_h <- map["init_h"]
        initstr <- map["initstr"]
        model_name <- map["model_name"]
        model_longname <- map["model_longname"]
        id_model <- map["id_model"]
        update_last <- (map["update_last"], DateTransform())
        update_next <- (map["update_next"], DateTransform())
        img_param <- map["img_param"]
        img_var_map <- map["img_var_map"]
    }
    
    public var description : String {
        var aux : String = ""
        if let initStamp = initStamp {
            aux += "initStamp: \(initStamp)\n"
        }
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
        if let SMERN = SMERN {
            aux += "SMERN: \(SMERN.description)\n"
        }
        if let temperature = temperature {
            aux += "Temp: \(temperature.description)\n"
        }
        if let temperatureReal = temperatureReal {
            aux += "Temp real: \(temperatureReal.description)\n"
        }
        if let PCPT = PCPT {
            aux += "PCPT: \(PCPT.description)\n"
        }
        if let hr_weekday = hr_weekday {
            aux += "hr_weekday: \(hr_weekday), "
        }
        if let hr_h = hr_h {
            aux += "hr_h: \(hr_h), "
        }
        if let hr_d = hr_d {
            aux += "hr_d: \(hr_d), "
        }
        if let hours = hours {
            aux += "hours: \(hours), "
        }
        if let initDate = initDate {
            aux += "initDate: \(initDate), "
        }
        if let init_d = init_d {
            aux += "init_d: \(init_d), "
        }
        if let init_dm = init_dm {
            aux += "init_dm: \(init_dm), "
        }
        if let init_h = init_h {
            aux += "init_h: \(init_h), "
        }
        if let initstr = initstr {
            aux += "initstr: \(initstr), "
        }
        if let model_name = model_name {
            aux += "modelName: \(model_name), "
        }
        if let model_longname = model_longname {
            aux += "model_longname: \(model_longname), "
        }
        if let id_model = id_model {
            aux += "id_model: \(id_model), "
        }
        if let update_last = update_last {
            aux += "update_last: \(update_last), "
        }
        if let update_next = update_next {
            aux += "update_next: \(update_next), "
        }
        if let img_param = img_param {
            aux += "img_param: \(img_param), "
        }
        if let img_var_map = img_var_map {
            aux += "img_var_map: \(img_var_map)."
        }
        return aux
    }
    
}
