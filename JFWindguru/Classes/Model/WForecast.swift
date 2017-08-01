//
//  WForecast.swift
//  Pods
//
//  Created by javierfuchs on 7/17/17.
//
//

import Foundation
#if USE_EXT_FWK
    import ObjectMapper
    import RealmSwift
#endif

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

    var TMP         = ListFloatObject() // TMP: temperature
    var TCDC        = ListIntObject() // TCDC: Cloud cover (%) Total
    var HCDC        = ListIntObject() // HCDC: Cloud cover (%) High
    var MCDC        = ListIntObject() // MCDC: Cloud cover (%) Mid
    var LCDC        = ListIntObject() // LCDC: Cloud cover (%) Low
    var RH          = ListIntObject() // RH: Relative humidity: relative humidity in percent
    var GUST        = ListFloatObject() // GUST: Wind gusts (knots)
    var SLP         = ListIntObject() // SLP: sea level pressure
    var FLHGT       = ListIntObject() //  FLHGT: Freezing Level height in meters (0 degree isoterm)
    var APCP        = ListIntObject() //  APCP: Precip. (mm/3h)
    var WINDSPD     = ListFloatObject() //  WINDSPD: Wind speed (knots)
    var WINDDIR     = ListIntObject() //  WINDDIR: Wind direction
    var SMERN       = ListIntObject()
    var SMER        = ListIntObject()
    var TMPE        = ListFloatObject() // TMPE: temperature in 2 meters above ground with correction to real altitude of the spot.
    var PCPT        = ListIntObject()
    var HTSGW       = ListFloatObject() // HTSGW: Significant Wave Height (Significant Height of Combined Wind Waves and Swell)
    var WVHGT       = ListFloatObject() // WVHG: Wave height
    var WVPER       = ListFloatObject() // WVPER: Mean wave period [s]
    var WVDIR       = ListFloatObject() // WVDIR: Mean wave direction [°]
    var SWELL1      = ListFloatObject() // SWELL1: Swell height (m)
    var SWPER1      = ListFloatObject() // SWPER1: Swell period
    var SWDIR1      = ListFloatObject() // SWDIR1: Swell direction
    var SWELL2      = ListFloatObject() // SWELL2: Swell height (m)
    var SWPER2      = ListFloatObject() // SWPER2: Swell period
    var SWDIR2      = ListFloatObject() // SWDIR2: Swell direction
    var PERPW       = ListFloatObject() // PERPW: Peak wave period
    var DIRPW       = ListFloatObject() // DIRPW: Peak wave direction [°]
    var hr_weekday  = ListIntObject()
    var hr_h        = ListStringObject()
    var hr_d        = ListStringObject()
    var hours       = ListIntObject()
    var img_param   = ListStringObject()
    var img_var_map = ListStringObject()
    dynamic var initDate: String? = nil
    dynamic var init_d: String? = nil
    dynamic var init_dm: String? = nil
    dynamic var init_h: String? = nil
    dynamic var initstr: String? = nil
    dynamic var model_name: String? = nil
    dynamic var model_longname: String? = nil
    dynamic var id_model: String? = nil
    dynamic var update_last: String? = nil
    dynamic var update_next: String? = nil
    dynamic var initstamp = 0  // initstamp

    required public convenience init?(map: Map) {
        self.init()
        #if !USE_EXT_FWK
            mapping(map: map)
        #endif
    }
    
    public func mapping(map: Map) {
        #if USE_EXT_FWK
            TMP = FloatObject.map(map: map, key: "TMP")
            TCDC = IntObject.map(map: map, key: "TCDC")
            HCDC = IntObject.map(map: map, key: "HCDC")
            MCDC = IntObject.map(map: map, key: "MCDC")
            LCDC = IntObject.map(map: map, key: "LCDC")
            RH = IntObject.map(map: map, key: "RH")
            GUST = FloatObject.map(map: map, key: "GUST")
            SLP = IntObject.map(map: map, key: "SLP")
            FLHGT = IntObject.map(map: map, key: "FLHGT")
            APCP = IntObject.map(map: map, key: "APCP")
            WINDSPD = FloatObject.map(map: map, key: "WINDSPD")
            WINDDIR = IntObject.map(map: map, key: "WINDDIR")
            SMERN = IntObject.map(map: map, key: "SMERN")
            SMER = IntObject.map(map: map, key: "SMER")
            TMPE = FloatObject.map(map: map, key: "TMPE")
            PCPT = IntObject.map(map: map, key: "PCPT")
            HTSGW = FloatObject.map(map: map, key: "HTSGW")
            WVHGT = FloatObject.map(map: map, key: "WVHGT")
            WVPER = FloatObject.map(map: map, key: "WVPER")
            WVDIR = FloatObject.map(map: map, key: "WVDIR")
            SWELL1 = FloatObject.map(map: map, key: "SWELL1")
            SWPER1 = FloatObject.map(map: map, key: "SWPER1")
            SWDIR1 = FloatObject.map(map: map, key: "SWDIR1")
            SWELL2 = FloatObject.map(map: map, key: "SWELL2")
            SWPER2 = FloatObject.map(map: map, key: "SWPER2")
            SWDIR2 = FloatObject.map(map: map, key: "SWDIR2")
            PERPW = FloatObject.map(map: map, key: "PERPW")
            DIRPW = FloatObject.map(map: map, key: "DIRPW")
            hr_weekday = IntObject.map(map: map, key: "hr_weekday")
            hr_h = StringObject.map(map: map, key: "hr_h")
            hr_d = StringObject.map(map: map, key: "hr_d")
            hours = IntObject.map(map: map, key: "hours")
            img_param = StringObject.map(map: map, key: "img_param")
            img_var_map = StringObject.map(map: map, key: "img_var_map")
            initDate <- map["initdate"]
            init_d <- map["init_d"]
            init_dm <- map["init_dm"]
            init_h <- map["init_h"]
            initstr <- map["initstr"]
            model_name <- map["model_name"]
            model_longname <- map["model_longname"]
            id_model <- map["id_model"]
            update_last <- map["update_last"]
            update_next <- map["update_next"]
            initstamp <- map["initstamp"]
        #else

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
            WINDDIR = map["WINDDIR"] as? [Int] ?? []
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
        #endif
    }
    override public var description : String {
        var aux : String = "\(type(of:self)): "
        aux += "initstamp: \(initstamp)\n"
        aux += "TCDC = Cloud cover Total: \(TCDC.printDescription())\n"
        aux += "HCDC = Cloud cover High: \(HCDC.printDescription())\n"
        aux += "MCDC = Cloud cover Mid: \(MCDC.printDescription())\n"
        aux += "LCDC = Cloud cover Low: \(LCDC.printDescription())\n"
        aux += "RH = Humidity: \(RH.printDescription())\n"
        aux += "SLP = Sea Level pressure: \(SLP.printDescription())\n"
        aux += "FLHGT = Freezing level: \(FLHGT.printDescription())\n"
        aux += "APCP = Precipitation: \(APCP.printDescription())\n"
        aux += "GUST = Wind gust: \(GUST.printDescription())\n"
        aux += "WINDSPD = Wind speed: \(WINDSPD.printDescription())\n"
        aux += "WINDDIR = Wind direccion: \(WINDDIR.printDescription())\n"
        aux += "SMERN: \(SMERN.printDescription())\n"
        aux += "SMER: \(SMER.printDescription())\n"
        aux += "TMP = Temp: \(TMP.printDescription())\n"
        aux += "TMPE = Temp real: \(TMPE.printDescription())\n"
        aux += "PCPT: \(PCPT.printDescription())\n"
        aux += "HTSGW: \(HTSGW.printDescription())\n"
        aux += "WVHGT: \(WVHGT.printDescription())\n"
        aux += "WVPER: \(WVPER.printDescription())\n"
        aux += "WVDIR: \(WVDIR.printDescription())\n"
        aux += "SWELL1: \(SWELL1.printDescription())\n"
        aux += "SWPER1: \(SWPER1.printDescription())\n"
        aux += "SWDIR1: \(SWDIR1.printDescription())\n"
        aux += "SWELL2: \(SWELL2.printDescription())\n"
        aux += "SWPER2: \(SWPER2.printDescription())\n"
        aux += "SWDIR2: \(SWDIR2.printDescription())\n"
        aux += "PERPW: \(PERPW.printDescription())\n"
        aux += "DIRPW: \(DIRPW.printDescription())\n"
        aux += "hr_weekday: \(hr_weekday.printDescription())\n"
        aux += "hr_h: \(hr_h.printDescription())\n"
        aux += "hr_d: \(hr_d.printDescription())\n"
        aux += "hours: \(hours.printDescription())\n"
        aux += "img_param: \(img_param.printDescription()), "
        aux += "img_var_map: \(img_var_map.printDescription()).\n"
        aux += "initDate: \(initDate ?? ""), "
        aux += "init_d: \(init_d ?? ""), "
        aux += "init_dm: \(init_dm ?? ""), "
        aux += "init_h: \(init_h ?? ""), "
        aux += "initstr: \(initstr ?? "")\n"
        aux += "modelName: \(model_name ?? ""), "
        aux += "model_longname: \(model_longname ?? ""), "
        aux += "id_model: \(id_model ?? "")\n"
        aux += "update_last: \(update_last ?? ""), "
        aux += "update_next: \(update_next ?? "")\n"
        
        return aux
    }
    

}

extension WForecast {
    
    // Thanks: https://www.campbellsci.com/blog/convert-wind-directions
    static public func windDirectionName(direction: Int) -> String? {
        let compass = ["N","NNE","NE","ENE","E","ESE","SE","SSE","S","SSW","SW","WSW","W","WNW","NW","NNW","N"]
        let module = Double(direction % 360)
        let index = Int(module / 22.5) + 1 // degrees for each sector
        if index >= 0 && index < compass.count {
            return compass[index]
        }
        return nil
    }
    
    public func numberOfHours() -> Int {
        return hours.count
    }

    public func temperature(hour: Int) -> Float? {
        if TMP.count > 0 && hour < TMP.count {
            return TMP[hour].v()
        }
        return nil
    }
    
    public func temperatureReal(hour: Int) -> Float? {
        if TMPE.count > 0 && hour < TMPE.count {
            return TMPE[hour].v()
        }
        return nil
    }
    
    public func relativeHumidity(hour: Int) -> Int? {
        if RH.count > 0 && hour < RH.count {
            return RH[hour].v()
        }
        return nil
    }
    
    public func smern(hour: Int) -> Int? {
        if SMERN.count > 0 && hour < SMERN.count {
            return SMERN[hour].v()
        }
        return nil
    }
    
    public func smer(hour: Int) -> Int? {
        if SMER.count > 0 && hour < SMERN.count {
            return SMER[hour].v()
        }
        return nil
    }
    
    private func windSpeed(hour: Int) -> Float? {
        if WINDSPD.count > 0 && hour < WINDSPD.count {
            return WINDSPD[hour].v()
        }
        return nil
    }
    
    public func windSpeedKnots(hour: Int) -> Float? {
        return windSpeed(hour:hour)
    }
    
    public func windSpeedKmh(hour: Int) -> Float? {
        if let knots = windSpeed(hour:hour) {
            var knotsBft = Knots.init(value: knots)
            return knotsBft.kmh()
        }
        return nil
    }
    
    public func windSpeedMph(hour: Int) -> Float? {
        if let knots = windSpeed(hour:hour) {
            var knotsBft = Knots.init(value: knots)
            return knotsBft.mph()
        }
        return nil
    }
    
    public func windSpeedMps(hour: Int) -> Float? {
        if let knots = windSpeed(hour:hour) {
            var knotsBft = Knots.init(value: knots)
            return knotsBft.mps()
        }
        return nil
    }
    
    public func windSpeedBft(hour: Int) -> Int? {
        if let knots = windSpeed(hour:hour) {
            var knotsBft = Knots.init(value: knots)
            return knotsBft.bft()
        }
        return nil
    }
    
    public func windSpeedBftEffect(hour: Int) -> String? {
        if let knots = windSpeed(hour:hour) {
            var knotsBft = Knots.init(value: knots)
            return knotsBft.effect()
        }
        return nil
    }
    
    public func windSpeedBftEffectOnSea(hour: Int) -> String? {
        if let knots = windSpeed(hour:hour) {
            var knotsBft = Knots.init(value: knots)
            return knotsBft.effectOnSea()
        }
        return nil
    }
    
    public func windSpeedBftEffectOnLand(hour: Int) -> String? {
        if let knots = windSpeed(hour:hour) {
            var knotsBft = Knots.init(value: knots)
            return knotsBft.effectOnLand()
        }
        return nil
    }
    
    
    public func windDirection(hour: Int) -> Int? {
        if WINDDIR.count > 0 && hour < WINDDIR.count {
            return WINDDIR[hour].v()
        }
        return nil
    }
    
    public func windDirectionName(hour: Int) -> String? {
        if let direction = windDirection(hour: hour) {
            return WForecast.windDirectionName(direction:direction)
        }
        return nil
    }
    
    public func windGust(hour: Int) -> Float? {
        if GUST.count > 0 && hour < GUST.count {
            return GUST[hour].v()
        }
        return nil
    }
    
    public func perpw(hour: Int) -> Float? {
        if PERPW.count > 0 && hour < PERPW.count {
            return PERPW[hour].v()
        }
        return nil
    }
    
    public func wvhgt(hour: Int) -> Float? {
        if WVHGT.count > 0 && hour < WVHGT.count {
            return WVHGT[hour].v()
        }
        return nil
    }
    
    public func wvper(hour: Int) -> Float? {
        if WVPER.count > 0 && hour < WVPER.count {
            return WVPER[hour].v()
        }
        return nil
    }

    public func wvdir(hour: Int) -> Float? {
        if WVDIR.count > 0 && hour < WVDIR.count {
            return WVDIR[hour].v()
        }
        return nil
    }
    
    public func swell1(hour: Int) -> Float? {
        if SWELL1.count > 0 && hour < SWELL1.count {
            return SWELL1[hour].v()
        }
        return nil
    }
    
    public func swper1(hour: Int) -> Float? {
        if SWPER1.count > 0 && hour < SWPER1.count {
            return SWPER1[hour].v()
        }
        return nil
    }
    
    public func swdir1(hour: Int) -> Float? {
        if SWDIR1.count > 0 && hour < SWDIR1.count {
            return SWDIR1[hour].v()
        }
        return nil
    }

    public func swell2(hour: Int) -> Float? {
        if SWELL2.count > 0 && hour < SWELL2.count {
            return SWELL2[hour].v()
        }
        return nil
    }
    
    public func swper2(hour: Int) -> Float? {
        if SWPER2.count > 0 && hour < SWPER2.count {
            return SWPER2[hour].v()
        }
        return nil
    }
    
    public func swdir2(hour: Int) -> Float? {
        if SWDIR2.count > 0 && hour < SWDIR2.count {
            return SWDIR2[hour].v()
        }
        return nil
    }
    
    public func dirpw(hour: Int) -> Float? {
        if DIRPW.count > 0 && hour < DIRPW.count {
            return DIRPW[hour].v()
        }
        return nil
    }
    public func htsgw(hour: Int) -> Float? {
        if HTSGW.count > 0 && hour < HTSGW.count {
            return HTSGW[hour].v()
        }
        return nil
    }
    
    public func cloudCoverTotal(hour: Int) -> Int? {
        if TCDC.count > 0 && hour < TCDC.count {
            return TCDC[hour].v()
        }
        return nil
    }
    
    public func cloudCoverHigh(hour: Int) -> Int? {
        if HCDC.count > 0 && hour < HCDC.count {
            return HCDC[hour].v()
        }
        return nil
    }
    
    public func cloudCoverMid(hour: Int) -> Int? {
        if MCDC.count > 0 && hour < MCDC.count {
            return MCDC[hour].v()
        }
        return nil
    }
    
    public func cloudCoverLow(hour: Int) -> Int? {
        if LCDC.count > 0 && hour < LCDC.count {
            return LCDC[hour].v()
        }
        return nil
    }
    
    public func precipitation(hour: Int) -> Int? {
        if APCP.count > 0 && hour < APCP.count {
            return APCP[hour].v()
        }
        return nil
    }
    
    public func pcpt(hour: Int) -> Int? {
        if PCPT.count > 0 && hour < PCPT.count {
            return PCPT[hour].v()
        }
        return nil
    }
    
    public func seaLevelPressure(hour: Int) -> Int? {
        if SLP.count > 0 && hour < SLP.count {
            return SLP[hour].v()
        }
        return nil
    }
    
    public func freezingLevel(hour: Int) -> Int? {
        if FLHGT.count > 0 && hour < FLHGT.count {
            return FLHGT[hour].v()
        }
        return nil
    }
    
    public func lastUpdate() -> String? {
        return update_last
    }
}
