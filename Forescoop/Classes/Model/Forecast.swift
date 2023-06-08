//
//  Forecast.swift
//  Forescoop
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
    case APCP1
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
    public var gmtHourOffset: Int = 0

    required public convenience init?(map: [String: Any]?) {
        self.init()
        mapping(map: map)
    }
    
    public func mapping(map: [String:Any]?) {
        guard let map = map else { return }
        initStamp = map["initstamp"] as? Int ?? 0
        initdate = map["initdate"] as? String
        model_name = map["model_name"] as? String
        weathers = map
            .compactMapValues { TimeWeather(map: $0 as? [String:Any]) }
            .filter {$0.key != "model_name" && $0.key != "initstamp" && $0.key != "initdate"}
    }
    
    public var description : String {
        [
            "\(type(of:self))",
            initStamp.toString,
            initdate,
            model_name,
            weathers?
                .compactMap {"\($0.key): {\($0.value.description)}"}
                .joined(separator: "\n")
        ]
            .compactMap { $0 }
            .joined(separator: "\n")
    }
}

public extension Forecast {
    
    /// WINDIRNAME: wind direction (name)
    func windDirectionName(hh: String?) -> String? {
        weathers?[TypeOfWeather.WINDIRNAME.rawValue]?.value(hh: hh)
    }
    
    /// WINDDIR: Wind direction
    func windDirection(hh: String?) -> Float? {
        weathers?[TypeOfWeather.WINDDIR.rawValue]?.value(hh: hh)
    }
    
    /// WINDSPD:  Wind speed (knots)
    func windSpeed(hh: String?) -> Float? {
        weathers?[TypeOfWeather.WINDSPD.rawValue]?.value(hh: hh)
    }
    
    /// TMP:  temperature
    func temperature(hh: String?) -> Double? {
        weathers?[TypeOfWeather.TMP.rawValue]?.value(hh: hh)
    }

    /// TMPE:  temperature in 2 meters above ground with correction to real altitude of the spot.
    func temperatureReal(hh: String?) -> Double? {
        weathers?[TypeOfWeather.TMPE.rawValue]?.value(hh: hh)
    }
    
    /// TCDC: Cloud cover (%) Total
    func cloudCoverTotal(hh: String?) -> Int? {
        weathers?[TypeOfWeather.TCDC.rawValue]?.value(hh: hh)
    }

    /// HCDC: Cloud cover (%) High
    func cloudCoverHigh(hh: String?) -> Int? {
        weathers?[TypeOfWeather.HCDC.rawValue]?.value(hh: hh)
    }

    /// MCDC: Cloud cover (%) Mid
    func cloudCoverMid(hh: String?) -> Int? {
        weathers?[TypeOfWeather.MCDC.rawValue]?.value(hh: hh)
    }

    /// LCDC: Cloud cover (%) Low
    func cloudCoverLow(hh: String?) -> Int? {
        weathers?[TypeOfWeather.LCDC.rawValue]?.value(hh: hh)
    }

    /// RH: Relative humidity: relative humidity in percent
    func relativeHumidity(hh: String?) -> Double? {
        weathers?[TypeOfWeather.RH.rawValue]?.value(hh: hh)
    }
    
    /// GUST:  Wind gusts (knots)
    func windGusts(hh: String?) -> Double? {
        weathers?[TypeOfWeather.GUST.rawValue]?.value(hh: hh)
    }
    
    /// SLP: sea level pressure
    func seaLevelPressure(hh: String?) -> Double? {
        weathers?[TypeOfWeather.SLP.rawValue]?.value(hh: hh)
    }
    
    /// FLHGT: Freezing Level height in meters (0 degree isoterm)
    func freezingLevelHeightInMeters(hh: String?) -> Double? {
        weathers?[TypeOfWeather.FLHGT.rawValue]?.value(hh: hh)
    }

    /// APCP:  Precip. (mm/3h)
    func precipitation(hh: String?) -> Double? {
        weathers?[TypeOfWeather.APCP.rawValue]?.value(hh: hh)
    }

    func precipitation1(hh: String?) -> Double? {
        weathers?[TypeOfWeather.APCP1.rawValue]?.value(hh: hh)
    }
    
    var initializationStamp: Int {
        initStamp
    }
    var initializationDate: Date? {
        DateTime(initdate, gmtHourOffset: gmtHourOffset)?.asDate
    }
    var modelName: String? {
        model_name
    }
    var numberOfWeathers: Int {
        weathers?.count ?? 0
    }
}
