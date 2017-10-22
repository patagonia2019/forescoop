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
    var initStamp : Int = 0
    var TMP: TimeWeather? // temperature
    var TCDC: TimeWeather? //  Cloud cover (%) Total
    var HCDC: TimeWeather? //  Cloud cover (%) High
    var MCDC: TimeWeather? //  Cloud cover (%) Mid
    var LCDC: TimeWeather? //  Cloud cover (%) Low
    var RH: TimeWeather? //  Relative humidity: relative humidity in percent
    var GUST: TimeWeather? //  Wind gusts (knots)
    var SLP: TimeWeather? //  sea level pressure
    var FLHGT: TimeWeather? //  Freezing Level height in meters (0 degree isoterm)
    var APCP: TimeWeather? //  Precip. (mm/3h)
    var WINDSPD: TimeWeather? //  Wind speed (knots)
    var WINDDIR: TimeWeather? //  Wind direction
    var WINDIRNAME: TimeWeather? //  wind direction (name)
    var TMPE: TimeWeather? //  temperature in 2 meters above ground with correction to real altitude of the spot.
    var initdate: String?
    var model_name: String?
    
    required public convenience init(map: Map) {
        self.init()
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        initStamp = map["initstamp"] as? Int ?? 0
        initdate = map["initdate"] as? String
        model_name = map["model_name"] as? String
        for (k, v) in map {
            if let dict = v as? Map {
                let tw = TimeWeather.init(map: dict)
                switch k {
                case "TMP": TMP = tw; break
                case "TCDC": TCDC = tw; break
                case "HCDC": HCDC = tw; break
                case "MCDC": MCDC = tw; break
                case "LCDC": LCDC = tw; break
                case "RH": RH = tw; break
                case "GUST": GUST = tw; break
                case "SLP": SLP = tw; break
                case "FLHGT": FLHGT = tw; break
                case "APCP": APCP = tw; break
                case "WINDSPD": WINDSPD = tw; break
                case "WINDDIR": WINDDIR = tw; break
                case "WINDIRNAME": WINDIRNAME = tw; break
                case "TMPE": TMPE = tw; break
                default:
                    break
                }
            }
        }
    }

    public var description : String {
        var aux : String = "\(type(of:self)): \n"
        aux += "initStamp: \(initStamp)\n"
        if let TCDC = TCDC {
            aux += "Cloud cover Total: \(TCDC.description)\n"
        }
        if let HCDC = HCDC {
            aux += "High: \(HCDC.description)\n"
        }
        if let MCDC = MCDC {
            aux += "Mid: \(MCDC.description)\n"
        }
        if let LCDC = LCDC {
            aux += "Low: \(LCDC.description)\n"
        }
        if let RH = RH {
            aux += "Humidity: \(RH.description)\n"
        }
        if let SLP = SLP {
            aux += "Sea Level pressure: \(SLP.description)\n"
        }
        if let FLHGT = FLHGT {
            aux += "Freezing level: \(FLHGT.description)\n"
        }
        if let APCP = APCP {
            aux += "Precipitation: \(APCP.description)\n"
        }
        if let GUST = GUST {
            aux += "Wind gust: \(GUST.description)\n"
        }
        if let WINDSPD = WINDSPD {
            aux += "Wind speed: \(WINDSPD.description)\n"
        }
        if let WINDDIR = WINDDIR {
            aux += "Wind direccion: \(WINDDIR.description)\n"
        }
        if let WINDIRNAME = WINDIRNAME {
            aux += "Wind name: \(WINDIRNAME.description)\n"
        }
        if let TMP = TMP {
            aux += "Temp: \(TMP.description)\n"
        }
        if let TMPE = TMPE {
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
        return valueForKey(key : WINDIRNAME, hh: hh) as? String
    }
    
    public func windDirection(hh: String?) -> Float? {
        return valueForKey(key : WINDDIR, hh: hh) as? Float
    }
    
    public func windSpeed(hh: String?) -> Float? {
        return valueForKey(key : WINDSPD, hh: hh) as? Float
    }
    
    public func temperatureReal(hh: String?) -> Float? {
        return valueForKey(key : TMPE, hh: hh) as? Float
    }
    
    public func cloudCoverTotal(hh: String?) -> Int? {
        return valueForKey(key : TCDC, hh: hh) as? Int
    }

    public func precipitation(hh: String?) -> Float? {
        return valueForKey(key : APCP, hh: hh) as? Float
    }
    


    // 
    // Private parts
    //
    private func valueForKey(key : TimeWeather?, hh: String?) -> AnyObject?
    {
        guard let key = key,
              let hhString = hh else { return nil }

        for k in key.keys {
            if k.v() == hhString {
                guard let index = key.keys.index(of: k) else { continue }
                if key.strings.count >= 0 && index < key.strings.count {
                    return key.strings[index].v() as AnyObject
                }
                else if key.floats.count >= 0 && index < key.floats.count{
                    return key.floats[index].v() as AnyObject
                }
            }
        }
        return nil
    }

}
