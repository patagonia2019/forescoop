//
//  Forecast.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/7/15.
//  Copyright © 2015 Fuchs. All rights reserved.
//

import Foundation

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
    var initStamp: Int = 0
    var weathers: [String: TimeWeather]?
//    var TMP: TimeWeather? // temperature
//    var TCDC: TimeWeather? //  Cloud cover (%) Total
//    var HCDC: TimeWeather? //  Cloud cover (%) High
//    var MCDC: TimeWeather? //  Cloud cover (%) Mid
//    var LCDC: TimeWeather? //  Cloud cover (%) Low
//    var RH: TimeWeather? //  Relative humidity: relative humidity in percent
//    var GUST: TimeWeather? //  Wind gusts (knots)
//    var SLP: TimeWeather? //  sea level pressure
//    var FLHGT: TimeWeather? //  Freezing Level height in meters (0 degree isoterm)
//    var APCP: TimeWeather? //  Precip. (mm/3h)
//    var WINDSPD: TimeWeather? //  Wind speed (knots)
//    var WINDDIR: TimeWeather? //  Wind direction
//    var WINDIRNAME: TimeWeather? //  wind direction (name)
//    var TMPE: TimeWeather? //  temperature in 2 meters above ground with correction to real altitude of the spot.
    var initdate: String?
    var model_name: String?
    
    required public convenience init?(map: [String: Any]?) {
        self.init()
        mapping(map: map)
    }
    
    public func mapping(map: [String:Any]?) {
        guard let map = map else { return }

        initStamp = map["initstamp"] as? Int ?? 0
        initdate = map["initdate"] as? String
        
        model_name = map["model_name"] as? String
        weathers = map.compactMapValues { TimeWeather(map: $0 as? [String:Any]) }
    }

    public var description : String {
        var aux : String = "\(type(of:self)): \n"
        aux += "initStamp: \(initStamp)\n"
        if let TCDC = weathers?["TCDC"] {
            aux += "Cloud cover Total: \(TCDC.description)\n"
        }
        if let HCDC = weathers?["HCDC"]  {
            aux += "High: \(HCDC.description)\n"
        }
        if let MCDC = weathers?["MCDC"]  {
            aux += "Mid: \(MCDC.description)\n"
        }
        if let LCDC = weathers?["LCDC"]  {
            aux += "Low: \(LCDC.description)\n"
        }
        if let RH = weathers?["RH"]  {
            aux += "Humidity: \(RH.description)\n"
        }
        if let SLP = weathers?["SLP"]  {
            aux += "Sea Level pressure: \(SLP.description)\n"
        }
        if let FLHGT = weathers?["FLHGT"]  {
            aux += "Freezing level: \(FLHGT.description)\n"
        }
        if let APCP = weathers?["APCP"]  {
            aux += "Precipitation: \(APCP.description)\n"
        }
        if let GUST = weathers?["GUST"]  {
            aux += "Wind gust: \(GUST.description)\n"
        }
        if let WINDSPD = weathers?["WINDSPD"]  {
            aux += "Wind speed: \(WINDSPD.description)\n"
        }
        if let WINDDIR = weathers?["WINDDIR"]  {
            aux += "Wind direccion: \(WINDDIR.description)\n"
        }
        if let WINDIRNAME = weathers?["WINDIRNAME"]  {
            aux += "Wind name: \(WINDIRNAME.description)\n"
        }
        if let TMP = weathers?["TMP"]  {
            aux += "Temp: \(TMP.description)\n"
        }
        if let TMPE = weathers?["TMPE"]  {
            aux += "Temp real: \(TMPE.description)\n"
        }
        if let initdate = initdate {
            aux += "initdate: \(initdate), "
        }
        if let model_name = model_name {
            aux += "model_name: \(model_name).\n"
        }
        return aux
    }
}

extension Forecast {
    
    public func windDirectionName(hh: String?) -> String? {
        return weathers?["WINDIRNAME"]?.value(hh: hh)
//        return valueForKey(timeWeather: weathers?["WINDIRNAME"], hh: hh) as? String
    }
    
    public func windDirection(hh: String?) -> Float? {
        return weathers?["WINDDIR"]?.value(hh: hh)
//        return valueForKey(timeWeather: weathers?["WINDDIR"], hh: hh) as? Float
    }
    
    public func windSpeed(hh: String?) -> Float? {
        return weathers?["WINDSPD"]?.value(hh: hh)
//        return valueForKey(timeWeather: weathers?["WINDSPD"], hh: hh) as? Float
    }
    
    public func temperatureReal(hh: String?) -> Float? {
        return weathers?["TMPE"]?.value(hh: hh)
//        return valueForKey(timeWeather: weathers?["TMPE"], hh: hh) as? Float
    }
    
    public func cloudCoverTotal(hh: String?) -> Int? {
        return weathers?["TCDC"]?.value(hh: hh)
//        return valueForKey(timeWeather: weathers?["TCDC"], hh: hh) as? Int
    }

    public func precipitation(hh: String?) -> Float? {
        return weathers?["APCP"]?.value(hh: hh)
//        return valueForKey(timeWeather: weathers?["APCP"], hh: hh) as? Float
    }
}
