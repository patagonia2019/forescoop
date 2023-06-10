//
//  WForecast.swift
//  Forescoop
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
    
    var TMP         = [Double]() // TMP: temperature
    var TCDC        = [String]() // TCDC: Cloud cover (%) Total
    var HCDC        = [String]() // HCDC: Cloud cover (%) High
    var MCDC        = [String]() // MCDC: Cloud cover (%) Mid
    var LCDC        = [String]() // LCDC: Cloud cover (%) Low
    var RH          = [Int]() // RH: Relative humidity: relative humidity in percent
    var GUST        = [Double]() // GUST: Wind gusts (knots)
    var SLP         = [Int]() // SLP: sea level pressure
    var FLHGT       = [Int]() //  FLHGT: Freezing Level height in meters (0 degree isoterm)
    var APCP        = [Int]() //  APCP: Precip. (mm/3h)
    var WINDSPD     = [Double]() //  WINDSPD: Wind speed (knots)
    var windDirection = [WindDirection]()
    var SMERN       = [Int]()
    var SMER        = [Int]()
    var TMPE        = [Double]() // TMPE: temperature in 2 meters above ground with correction to real altitude of the spot.
    var PCPT        = [Int]()
    var HTSGW       = [Double]() // HTSGW: Significant Wave Height (Significant Height of Combined Wind Waves and Swell)
    var WVHGT       = [Double]() // WVHG: Wave height
    var WVPER       = [Double]() // WVPER: Mean wave period [s]
    var WVDIR       = [Double]() // WVDIR: Mean wave direction [°]
    var SWELL1      = [Double]() // SWELL1: Swell height (m)
    var SWPER1      = [Double]() // SWPER1: Swell period
    var SWDIR1      = [Double]() // SWDIR1: Swell direction
    var SWELL2      = [Double]() // SWELL2: Swell height (m)
    var SWPER2      = [Double]() // SWPER2: Swell period
    var SWDIR2      = [Double]() // SWDIR2: Swell direction
    var PERPW       = [Double]() // PERPW: Peak wave period
    var DIRPW       = [Double]() // DIRPW: Peak wave direction [°]
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
    var id_model: Int = 0
    var update_last: String? = nil
    var update_next: String? = nil
    var initstamp = 0  // initstamp
        
    required public convenience init?(map: [String: Any]?) {
        self.init()
        mapping(map: map)
    }
    
    public func mapping(map: [String:Any]?) {
        guard let map = map else { return }
        
        TMP = map["TMP"] as? [Double] ?? []
        TCDC = map["TCDC"].debugDescription.components(separatedBy: CharacterSet(charactersIn:"\n)")).joined().components(separatedBy: ",")
        HCDC = map["HCDC"] .debugDescription.components(separatedBy: CharacterSet(charactersIn:"\n)")).joined().components(separatedBy: ",")
        MCDC = map["MCDC"] .debugDescription.components(separatedBy: CharacterSet(charactersIn:"\n)")).joined().components(separatedBy: ",")
        LCDC = map["LCDC"] .debugDescription.components(separatedBy: CharacterSet(charactersIn:"\n)")).joined().components(separatedBy: ",")
        RH = map["RH"] as? [Int] ?? []
        GUST = map["GUST"] as? [Double] ?? []
        SLP = map["SLP"] as? [Int] ?? []
        FLHGT = map["FLHGT"] as? [Int] ?? []
        APCP = map["APCP"] as? [Int] ?? []
        WINDSPD = map["WINDSPD"] as? [Double] ?? []
        windDirection = (map["WINDDIR"]as? [Int])?.compactMap {WindDirection(value: $0)} ?? []
        SMERN = map["SMERN"] as? [Int] ?? []
        SMER = map["SMER"] as? [Int] ?? []
        TMPE = map["TMPE"] as? [Double] ?? []
        PCPT = map["PCPT"] as? [Int] ?? []
        HTSGW = map["HTSGW"] as? [Double] ?? []
        WVHGT = map["WVHGT"] as? [Double] ?? []
        WVPER = map["WVPER"] as? [Double] ?? []
        WVDIR = map["WVDIR"] as? [Double] ?? []
        SWELL1 = map["SWELL1"] as? [Double] ?? []
        SWPER1 = map["SWPER1"] as? [Double] ?? []
        SWDIR1 = map["SWDIR1"] as? [Double] ?? []
        SWELL2 = map["SWELL2"] as? [Double] ?? []
        SWPER2 = map["SWPER2"] as? [Double] ?? []
        SWDIR2 = map["SWDIR2"] as? [Double] ?? []
        PERPW = map["PERPW"] as? [Double] ?? []
        DIRPW = map["DIRPW"] as? [Double] ?? []
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
        id_model = map["id_model"] as? Int ?? 0
        update_last = map["update_last"] as? String
        update_next = map["update_next"] as? String
        initstamp = map["initstamp"] as? Int ?? 0
    }
    
    public var description : String {
        [
            "\(type(of:self))",
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
            "WINDDIR = Wind direccion: \(windDirection.compactMap{$0.description})",
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
            "img_param: \(img_param)",
            "img_var_map: \(img_var_map)",
            "initDate: \(initDate ?? "")",
            "init_d: \(init_d ?? "")",
            "init_dm: \(init_dm ?? "")",
            "init_h: \(init_h ?? "")",
            "initstr: \(initstr ?? "")",
            "modelName: \(model_name ?? "")",
            "model_longname: \(model_longname ?? "")",
            "id_model: \(id_model)",
            "update_last: \(update_last ?? "")",
            "update_next: \(update_next ?? "")",
        ]
            .compactMap {$0}
            .joined(separator: ", ")
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
    
    /// TMP: temperature
    func temperature(hour: Int) -> Double? {
        if TMP.count > 0 && hour < TMP.count {
            return TMP[hour]
        }
        return nil
    }
    
    /// TMPE: temperature in 2 meters above ground with correction to real altitude of the spot.
    func temperatureReal(hour: Int) -> Double? {
        if TMPE.count > 0 && hour < TMPE.count {
            return TMPE[hour]
        }
        return nil
    }
    
    /// RH: Relative humidity: relative humidity in percent
    func relativeHumidity(hour: Int) -> Int? {
        if RH.count > 0 && hour < RH.count {
            return RH[hour]
        }
        return nil
    }
    
    /// SMERN: specific moisture extraction rate
    func specificMoistureExtractionRate(hour: Int) -> Int? {
        if SMER.count > 0 && hour < SMER.count {
            return SMER[hour]
        }
        return nil
    }
    
    /// SMERN: specific moisture extraction rate N.
    func specificMoistureExtractionRateN(hour: Int) -> Int? {
        if SMERN.count > 0 && hour < SMERN.count {
            return SMERN[hour]
        }
        return nil
    }
    
    func windSpeed(hour: Int) -> Double? {
        if WINDSPD.count > 0 && hour < WINDSPD.count {
            return WINDSPD[hour]
        }
        return nil
    }
    
    func windSpeedKnots(hour: Int) -> Double? {
        windSpeed(hour:hour)
    }
    
    func windSpeedKmh(hour: Int) -> Double? {
        Knots(windSpeed(hour:hour)).kmh
    }
    
    func windSpeedMph(hour: Int) -> Double? {
        Knots(windSpeed(hour:hour)).mph
    }
    
    func windSpeedMps(hour: Int) -> Double? {
        Knots(windSpeed(hour:hour)).mps
    }
    
    func windSpeedBft(hour: Int) -> Int? {
        Knots(windSpeed(hour:hour)).bft
    }
    
    func windSpeedBftEffect(hour: Int) -> String? {
        Knots(windSpeed(hour: hour)).effect
    }
    
    func windSpeedBftEffectOnSea(hour: Int) -> String? {
        Knots(windSpeed(hour: hour)).effectOnSea
    }
    
    func windSpeedBftEffectOnLand(hour: Int) -> String? {
        Knots(windSpeed(hour: hour)).effectOnLand
    }
        
    func windDirection(hour: Int) -> Int? {
        assert(windDirection.count > 0 && hour < windDirection.count)
        return windDirection[hour].value
    }
    
    func windDirectionName(hour: Int) -> String? {
        assert(windDirection.count > 0 && hour < windDirection.count)
        return windDirection[hour].name
    }
    
    func windGust(hour: Int) -> Double? {
        if GUST.count > 0 && hour < GUST.count {
            return GUST[hour]
        }
        return nil
    }
    
    var isMarineAvailable: Bool {
        !PERPW.isEmpty
    }
    
    /// PERPW: Peak wave period
    func peakWavePeriod(hour: Int) -> Double? {
        if PERPW.count > 0 && hour < PERPW.count {
            return PERPW[hour]
        }
        return nil
    }
    
    /// WVHG: Wave height
    func waveHeight(hour: Int) -> Double? {
        if WVHGT.count > 0 && hour < WVHGT.count {
            return WVHGT[hour]
        }
        return nil
    }
    
    /// WVPER: Mean wave period [s]
    func meanWavePeriod(hour: Int) -> Double? {
        if WVPER.count > 0 && hour < WVPER.count {
            return WVPER[hour]
        }
        return nil
    }

    /// WVDIR: Mean wave direction
    func meanWaveDirection(hour: Int) -> Double? {
        if WVDIR.count > 0 && hour < WVDIR.count {
            return WVDIR[hour]
        }
        return nil
    }
    
    /// SWELL1: Swell height (m)
    func swellHeight(hour: Int) -> Double? {
        if SWELL1.count > 0 && hour < SWELL1.count {
            return SWELL1[hour]
        }
        return nil
    }
    
    /// SWPER1: Swell period
    func swellPeriod(hour: Int) -> Double? {
        if SWPER1.count > 0 && hour < SWPER1.count {
            return SWPER1[hour]
        }
        return nil
    }
    
    /// SWDIR1: Swell direction
    func swellDirection(hour: Int) -> Double? {
        if SWDIR1.count > 0 && hour < SWDIR1.count {
            return SWDIR1[hour]
        }
        return nil
    }

    /// SWELL2: Swell height (m)
    func swellHeight2(hour: Int) -> Double? {
        if SWELL2.count > 0 && hour < SWELL2.count {
            return SWELL2[hour]
        }
        return nil
    }

    /// SWPER2: Swell period
    func swellPeriod2(hour: Int) -> Double? {
        if SWPER2.count > 0 && hour < SWPER2.count {
            return SWPER2[hour]
        }
        return nil
    }
    
    func swellDirection2(hour: Int) -> Double? {
        if SWDIR2.count > 0 && hour < SWDIR2.count {
            return SWDIR2[hour]
        }
        return nil
    }
    
    /// DIRPW: Peak wave direction [°]
    func peakWaveDirection(hour: Int) -> Double? {
        if DIRPW.count > 0 && hour < DIRPW.count {
            return DIRPW[hour]
        }
        return nil
    }
    
    /// HTSGW: Significant Wave Height (Significant Height of Combined Wind Waves and Swell)
    func significantWaveHeight(hour: Int) -> Double? {
        if HTSGW.count > 0 && hour < HTSGW.count {
            return HTSGW[hour]
        }
        return nil
    }
    
    func cloudCoverTotal(hour: Int) -> Int? {
        if TCDC.count > 0 && hour < TCDC.count {
            return Int(TCDC[hour])
        }
        return nil
    }
    
    func cloudCoverHigh(hour: Int) -> Int? {
        if HCDC.count > 0 && hour < HCDC.count {
            return Int(HCDC[hour])
        }
        return nil
    }
    
    func cloudCoverMid(hour: Int) -> Int? {
        if MCDC.count > 0 && hour < MCDC.count {
            return Int(MCDC[hour])
        }
        return nil
    }
    
    func cloudCoverLow(hour: Int) -> Int? {
        if LCDC.count > 0 && hour < LCDC.count {
            return Int(LCDC[hour])
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
