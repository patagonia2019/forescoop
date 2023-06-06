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

enum TypeOfWeather: String {
    case TMP // temperature
    case TCDC //  Cloud cover (%) Total
    case HCDC //  Cloud cover (%) High
    case MCDC //  Cloud cover (%) Mid
    case LCDC //  Cloud cover (%) Low
    case RH //  Relative humidity: relative humidity in percent
    case GUST //  Wind gusts (knots)
    case SLP //  sea level pressure
    case FLHGT //  Freezing Level height in meters (0 degree isoterm)
    case APCP //  Precip. (mm/3h)
    case WINDSPD //  Wind speed (knots)
    case WINDDIR //  Wind direction
    case WINDIRNAME //  wind direction (name)
    case TMPE //  temperature in 2 meters above ground with correction to real altitude of the spot.
}

public class Forecast: Object, Mappable {
    var initStamp: Int = 0
    var weathers: [String: TimeWeather]?
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
        if let TCDC = weathers?[TypeOfWeather.TCDC.rawValue] {
            aux += "Cloud cover Total: \(TCDC.description)\n"
        }
        if let HCDC = weathers?[TypeOfWeather.HCDC.rawValue]  {
            aux += "High: \(HCDC.description)\n"
        }
        if let MCDC = weathers?[TypeOfWeather.MCDC.rawValue]  {
            aux += "Mid: \(MCDC.description)\n"
        }
        if let LCDC = weathers?[TypeOfWeather.LCDC.rawValue]  {
            aux += "Low: \(LCDC.description)\n"
        }
        if let RH = weathers?[TypeOfWeather.RH.rawValue]  {
            aux += "Humidity: \(RH.description)\n"
        }
        if let SLP = weathers?[TypeOfWeather.SLP.rawValue]  {
            aux += "Sea Level pressure: \(SLP.description)\n"
        }
        if let FLHGT = weathers?[TypeOfWeather.FLHGT.rawValue]  {
            aux += "Freezing level: \(FLHGT.description)\n"
        }
        if let APCP = weathers?[TypeOfWeather.APCP.rawValue]  {
            aux += "Precipitation: \(APCP.description)\n"
        }
        if let GUST = weathers?[TypeOfWeather.GUST.rawValue]  {
            aux += "Wind gust: \(GUST.description)\n"
        }
        if let WINDSPD = weathers?[TypeOfWeather.WINDSPD.rawValue]  {
            aux += "Wind speed: \(WINDSPD.description)\n"
        }
        if let WINDDIR = weathers?[TypeOfWeather.WINDDIR.rawValue]  {
            aux += "Wind direccion: \(WINDDIR.description)\n"
        }
        if let WINDIRNAME = weathers?[TypeOfWeather.WINDIRNAME.rawValue]  {
            aux += "Wind name: \(WINDIRNAME.description)\n"
        }
        if let TMP = weathers?[TypeOfWeather.TMP.rawValue]  {
            aux += "Temp: \(TMP.description)\n"
        }
        if let TMPE = weathers?[TypeOfWeather.TMPE.rawValue]  {
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
    }
    
    public func windDirection(hh: String?) -> Float? {
        return weathers?["WINDDIR"]?.value(hh: hh)
    }
    
    public func windSpeed(hh: String?) -> Float? {
        return weathers?["WINDSPD"]?.value(hh: hh)
    }
    
    public func temperatureReal(hh: String?) -> Float? {
        return weathers?["TMPE"]?.value(hh: hh)
    }
    
    public func cloudCoverTotal(hh: String?) -> Int? {
        return weathers?["TCDC"]?.value(hh: hh)
    }

    public func precipitation(hh: String?) -> Float? {
        return weathers?["APCP"]?.value(hh: hh)
    }
}
