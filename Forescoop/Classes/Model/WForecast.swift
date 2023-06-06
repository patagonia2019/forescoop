//
//  WForecast.swift
//  Pods
//
//  Created by javierfuchs on 7/17/17.
//
//

import Foundation

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

public class WForecast: Object, Mappable {
    
    // TODO: Maybe refactor this... -> var info = [String: Any]()
    
    var TMP         = [Float]() // TMP: temperature
    var TCDC        = [Int]() // TCDC: Cloud cover (%) Total
    var HCDC        = [Int]() // HCDC: Cloud cover (%) High
    var MCDC        = [Int]() // MCDC: Cloud cover (%) Mid
    var LCDC        = [Int]() // LCDC: Cloud cover (%) Low
    var RH          = [Int]() // RH: Relative humidity: relative humidity in percent
    var GUST        = [Float]() // GUST: Wind gusts (knots)
    var SLP         = [Int]() // SLP: sea level pressure
    var FLHGT       = [Int]() //  FLHGT: Freezing Level height in meters (0 degree isoterm)
    var APCP        = [Int]() //  APCP: Precip. (mm/3h)
    var WINDSPD     = [Float]() //  WINDSPD: Wind speed (knots)
    var windDir: [WindDirection]?
    var SMERN       = [Int]()
    var SMER        = [Int]()
    var TMPE        = [Float]() // TMPE: temperature in 2 meters above ground with correction to real altitude of the spot.
    var PCPT        = [Int]()
    var HTSGW       = [Float]() // HTSGW: Significant Wave Height (Significant Height of Combined Wind Waves and Swell)
    var WVHGT       = [Float]() // WVHG: Wave height
    var WVPER       = [Float]() // WVPER: Mean wave period [s]
    var WVDIR       = [Float]() // WVDIR: Mean wave direction [°]
    var SWELL1      = [Float]() // SWELL1: Swell height (m)
    var SWPER1      = [Float]() // SWPER1: Swell period
    var SWDIR1      = [Float]() // SWDIR1: Swell direction
    var SWELL2      = [Float]() // SWELL2: Swell height (m)
    var SWPER2      = [Float]() // SWPER2: Swell period
    var SWDIR2      = [Float]() // SWDIR2: Swell direction
    var PERPW       = [Float]() // PERPW: Peak wave period
    var DIRPW       = [Float]() // DIRPW: Peak wave direction [°]
    var hr_weekday  = [Int]()
    var hr_h        = [String]()
    var hr_d        = [String]()
    var hours       = [Int]()
    var img_param   = [String]()
    var img_var_map = [String]()
    var initDate: String? = nil
    var init_d: String? = nil
    var init_dm: String? = nil
    var init_h: String? = nil
    var initstr: String? = nil
    var model_name: String? = nil
    var model_longname: String? = nil
    var id_model: String? = nil
    var update_last: String? = nil
    var update_next: String? = nil
    var initstamp = 0  // initstamp
    
    required public convenience init?(map: [String: Any]?) {
        self.init()
        mapping(map: map)
    }
    
    public func mapping(map: [String:Any]?) {
        guard let map = map else { return }
        
        TMP = map["TMP"] as? [Float] ?? []
        TCDC = map["TCDC"] as? [Int] ?? []
        HCDC = map["HCDC"] as? [Int] ?? []
        MCDC = map["MCDC"] as? [Int] ?? []
        LCDC = map["LCDC"] as? [Int] ?? []
        RH = map["RH"] as? [Int] ?? []
        GUST = map["GUST"] as? [Float] ?? []
        SLP = map["SLP"] as? [Int] ?? []
        FLHGT = map["FLHGT"] as? [Int] ?? []
        APCP = map["APCP"] as? [Int] ?? []
        WINDSPD = map["WINDSPD"] as? [Float] ?? []
        windDir = (map["WINDDIR"]as? [Int])?.compactMap {WindDirection(value: $0)}
        SMERN = map["SMERN"] as? [Int] ?? []
        SMER = map["SMER"] as? [Int] ?? []
        TMPE = map["TMPE"] as? [Float] ?? []
        PCPT = map["PCPT"] as? [Int] ?? []
        HTSGW = map["HTSGW"] as? [Float] ?? []
        WVHGT = map["WVHGT"] as? [Float] ?? []
        WVPER = map["WVPER"] as? [Float] ?? []
        WVDIR = map["WVDIR"] as? [Float] ?? []
        SWELL1 = map["SWELL1"] as? [Float] ?? []
        SWPER1 = map["SWPER1"] as? [Float] ?? []
        SWDIR1 = map["SWDIR1"] as? [Float] ?? []
        SWELL2 = map["SWELL2"] as? [Float] ?? []
        SWPER2 = map["SWPER2"] as? [Float] ?? []
        SWDIR2 = map["SWDIR2"] as? [Float] ?? []
        PERPW = map["PERPW"] as? [Float] ?? []
        DIRPW = map["DIRPW"] as? [Float] ?? []
        hr_weekday = map["hr_weekday"] as? [Int] ?? []
        hr_h = map["hr_h"] as? [String] ?? []
        hr_d = map["hr_d"] as? [String] ?? []
        hours = map["hours"] as? [Int] ?? []
        img_param = map["img_param"] as? [String] ?? []
        img_var_map = map["img_var_map"] as? [String] ?? []
        initDate = map["initdate"] as? String
        init_d = map["init_d"] as? String
        init_dm = map["init_dm"] as? String
        init_h = map["init_h"] as? String
        initstr = map["initstr"] as? String
        model_name = map["model_name"] as? String
        model_longname = map["model_longname"] as? String
        id_model = map["id_model"] as? String
        update_last = map["update_last"] as? String
        update_next = map["update_next"] as? String
        initstamp = map["initstamp"] as? Int ?? 0
    }
    
    public var description : String {
        ["\(type(of:self))",
         "initstamp: \(initstamp)",
         "TCDC = Cloud cover Total: \(TCDC)",
         "HCDC = Cloud cover High: \(HCDC)",
         "MCDC = Cloud cover Mid: \(MCDC)",
         "LCDC = Cloud cover Low: \(LCDC)",
         "RH = Humidity: \(RH)",
         "SLP = Sea Level pressure: \(SLP)",
         "FLHGT = Freezing level: \(FLHGT)",
         "APCP = Precipitation: \(APCP)",
         "GUST = Wind gust: \(GUST)",
         "WINDSPD = Wind speed: \(WINDSPD)",
         "WINDDIR = Wind direccion: \(windDir?.compactMap{$0.description} ?? [])",
         "SMERN: \(SMERN)",
         "SMER: \(SMER)",
         "TMP = Temp: \(TMP)",
         "TMPE = Temp real: \(TMPE)",
         "PCPT: \(PCPT)",
         "HTSGW: \(HTSGW)",
         "WVHGT: \(WVHGT)",
         "WVPER: \(WVPER)",
         "WVDIR: \(WVDIR)",
         "SWELL1: \(SWELL1)",
         "SWPER1: \(SWPER1)",
         "SWDIR1: \(SWDIR1)",
         "SWELL2: \(SWELL2)",
         "SWPER2: \(SWPER2)",
         "SWDIR2: \(SWDIR2)",
         "PERPW: \(PERPW)",
         "DIRPW: \(DIRPW)",
         "hr_weekday: \(hr_weekday)",
         "hr_h: \(hr_h)",
         "hr_d: \(hr_d)",
         "hours: \(hours)",
         "img_param: \(img_param), ",
         "img_var_map: \(img_var_map).",
         "initDate: \(initDate ?? ""), ",
         "init_d: \(init_d ?? ""), ",
         "init_dm: \(init_dm ?? ""), ",
         "init_h: \(init_h ?? ""), ",
         "initstr: \(initstr ?? "")",
         "modelName: \(model_name ?? ""), ",
         "model_longname: \(model_longname ?? ""), ",
         "id_model: \(id_model ?? "")",
         "update_last: \(update_last ?? ""), ",
         "update_next: \(update_next ?? "")",
        ].compactMap {$0}.joined(separator: ", ")
    }
}

public extension WForecast {
    
    var numberOfHours: Int {
        hours.count
    }

    func hour24(hour: Int) -> String? {
        if hr_h.count > 0 && hour < hr_h.count {
            return hr_h[hour]
        }
        return nil
    }
    
    func day(hour: Int) -> String? {
        if hr_d.count > 0 && hour < hr_d.count {
            return hr_d[hour]
        }
        return nil
    }
    
    func weekday(hour: Int) -> String? {
        if hr_weekday.count > 0 && hour < hr_weekday.count {
            let w = hr_weekday[hour]
            switch w {
            case 0: return "Sunday"
            case 1: return "Monday"
            case 2: return "Tuesday"
            case 3: return "Wednesday"
            case 4: return "Thursday"
            case 5: return "Friday"
            case 6: return "Saturday"
            default:
                return nil
            }
        }
        return nil
    }
    
    func temperature(hour: Int) -> Float? {
        if TMP.count > 0 && hour < TMP.count {
            return TMP[hour]
        }
        return nil
    }
    
    func temperatureReal(hour: Int) -> Float? {
        if TMPE.count > 0 && hour < TMPE.count {
            return TMPE[hour]
        }
        return nil
    }
    
    func relativeHumidity(hour: Int) -> Int? {
        if RH.count > 0 && hour < RH.count {
            return RH[hour]
        }
        return nil
    }
    
    func smern(hour: Int) -> Int? {
        if SMERN.count > 0 && hour < SMERN.count {
            return SMERN[hour]
        }
        return nil
    }
    
    func smer(hour: Int) -> Int? {
        if SMER.count > 0 && hour < SMERN.count {
            return SMER[hour]
        }
        return nil
    }
    
    func windSpeed(hour: Int) -> Float? {
        if WINDSPD.count > 0 && hour < WINDSPD.count {
            return WINDSPD[hour]
        }
        return nil
    }
    
    func windSpeedKnots(hour: Int) -> Float? {
        windSpeed(hour:hour)
    }
    
    func windSpeedKmh(hour: Int) -> Float? {
        if let knots = windSpeed(hour:hour) {
            var knotsBft = Knots.init(value: knots)
            return knotsBft.kmh()
        }
        return nil
    }
    
    func windSpeedMph(hour: Int) -> Float? {
        if let knots = windSpeed(hour:hour) {
            var knotsBft = Knots.init(value: knots)
            return knotsBft.mph()
        }
        return nil
    }
    
    func windSpeedMps(hour: Int) -> Float? {
        if let knots = windSpeed(hour:hour) {
            var knotsBft = Knots.init(value: knots)
            return knotsBft.mps()
        }
        return nil
    }
    
    func windSpeedBft(hour: Int) -> Int? {
        if let knots = windSpeed(hour:hour) {
            var knotsBft = Knots.init(value: knots)
            return knotsBft.bft()
        }
        return nil
    }
    
    func windSpeedBftEffect(hour: Int) -> String? {
        if let knots = windSpeed(hour:hour) {
            var knotsBft = Knots.init(value: knots)
            return knotsBft.effect()
        }
        return nil
    }
    
    func windSpeedBftEffectOnSea(hour: Int) -> String? {
        if let knots = windSpeed(hour:hour) {
            var knotsBft = Knots.init(value: knots)
            return knotsBft.effectOnSea()
        }
        return nil
    }
    
    func windSpeedBftEffectOnLand(hour: Int) -> String? {
        if let knots = windSpeed(hour:hour) {
            var knotsBft = Knots.init(value: knots)
            return knotsBft.effectOnLand()
        }
        return nil
    }
    
    func windDirection(hour: Int) -> Int? {
        guard let windDir = windDir else { return nil }
        if windDir.count > 0 && hour < windDir.count {
            return windDir[hour].value
        }
        return nil
    }
    
    func windDirectionName(hour: Int) -> String? {
        guard let windDir = windDir else { return nil }
        if windDir.count > 0 && hour < windDir.count {
            return windDir[hour].name
        }
        return nil
    }
    
    func windGust(hour: Int) -> Float? {
        if GUST.count > 0 && hour < GUST.count {
            return GUST[hour]
        }
        return nil
    }
    
    func perpw(hour: Int) -> Float? {
        if PERPW.count > 0 && hour < PERPW.count {
            return PERPW[hour]
        }
        return nil
    }
    
    func wvhgt(hour: Int) -> Float? {
        if WVHGT.count > 0 && hour < WVHGT.count {
            return WVHGT[hour]
        }
        return nil
    }
    
    func wvper(hour: Int) -> Float? {
        if WVPER.count > 0 && hour < WVPER.count {
            return WVPER[hour]
        }
        return nil
    }

    func wvdir(hour: Int) -> Float? {
        if WVDIR.count > 0 && hour < WVDIR.count {
            return WVDIR[hour]
        }
        return nil
    }
    
    func swell1(hour: Int) -> Float? {
        if SWELL1.count > 0 && hour < SWELL1.count {
            return SWELL1[hour]
        }
        return nil
    }
    
    func swper1(hour: Int) -> Float? {
        if SWPER1.count > 0 && hour < SWPER1.count {
            return SWPER1[hour]
        }
        return nil
    }
    
    func swdir1(hour: Int) -> Float? {
        if SWDIR1.count > 0 && hour < SWDIR1.count {
            return SWDIR1[hour]
        }
        return nil
    }

    func swell2(hour: Int) -> Float? {
        if SWELL2.count > 0 && hour < SWELL2.count {
            return SWELL2[hour]
        }
        return nil
    }
    
    func swper2(hour: Int) -> Float? {
        if SWPER2.count > 0 && hour < SWPER2.count {
            return SWPER2[hour]
        }
        return nil
    }
    
    func swdir2(hour: Int) -> Float? {
        if SWDIR2.count > 0 && hour < SWDIR2.count {
            return SWDIR2[hour]
        }
        return nil
    }
    
    func dirpw(hour: Int) -> Float? {
        if DIRPW.count > 0 && hour < DIRPW.count {
            return DIRPW[hour]
        }
        return nil
    }
    func htsgw(hour: Int) -> Float? {
        if HTSGW.count > 0 && hour < HTSGW.count {
            return HTSGW[hour]
        }
        return nil
    }
    
    func cloudCoverTotal(hour: Int) -> Int? {
        if TCDC.count > 0 && hour < TCDC.count {
            return TCDC[hour]
        }
        return nil
    }
    
    func cloudCoverHigh(hour: Int) -> Int? {
        if HCDC.count > 0 && hour < HCDC.count {
            return HCDC[hour]
        }
        return nil
    }
    
    func cloudCoverMid(hour: Int) -> Int? {
        if MCDC.count > 0 && hour < MCDC.count {
            return MCDC[hour]
        }
        return nil
    }
    
    func cloudCoverLow(hour: Int) -> Int? {
        if LCDC.count > 0 && hour < LCDC.count {
            return LCDC[hour]
        }
        return nil
    }
    
    func precipitation(hour: Int) -> Int? {
        if APCP.count > 0 && hour < APCP.count {
            return APCP[hour]
        }
        return nil
    }
    
    func pcpt(hour: Int) -> Int? {
        if PCPT.count > 0 && hour < PCPT.count {
            return PCPT[hour]
        }
        return nil
    }
    
    func seaLevelPressure(hour: Int) -> Int? {
        if SLP.count > 0 && hour < SLP.count {
            return SLP[hour]
        }
        return nil
    }
    
    func freezingLevel(hour: Int) -> Int? {
        if FLHGT.count > 0 && hour < FLHGT.count {
            return FLHGT[hour]
        }
        return nil
    }
    
    var lastUpdate: String? {
        update_last
    }
}
