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

    dynamic var initStamp   = 0  // initstamp
    var temperature         = ListFloatObject() // TMP: temperature
    var cloudCoverTotal     = ListIntObject() // TCDC: Cloud cover (%) Total
    var cloudCoverHigh      = ListIntObject() // HCDC: Cloud cover (%) High
    var cloudCoverMid       = ListIntObject() // MCDC: Cloud cover (%) Mid
    var cloudCoverLow       = ListIntObject() // LCDC: Cloud cover (%) Low
    var relativeHumidity    = ListIntObject() // RH: Relative humidity: relative humidity in percent
    var windGust            = ListFloatObject() // GUST: Wind gusts (knots)
    var seaLevelPressure    = ListIntObject() // SLP: sea level pressure
    var freezingLevel       = ListIntObject() //  FLHGT: Freezing Level height in meters (0 degree isoterm)
    var precipitation       = ListIntObject() //  APCP: Precip. (mm/3h)
    var windSpeed           = ListFloatObject() //  WINDSPD: Wind speed (knots)
    var windDirection       = ListIntObject() //  WINDDIR: Wind direction
    var SMERN               = ListIntObject()
    var SMER                = ListIntObject()
    var temperatureReal     = ListFloatObject() // TMPE: temperature in 2 meters above ground with correction to real altitude of the spot.
    var PCPT                = ListIntObject()
    var HTSGW               = ListFloatObject() // HTSGW: Significant Wave Height (Significant Height of Combined Wind Waves and Swell)
    var WVHGT               = ListFloatObject() // WVHG: Wave height
    var WVPER               = ListFloatObject() // WVPER: Mean wave period [s]
    var WVDIR               = ListFloatObject() // WVDIR: Mean wave direction [°]
    var SWELL1              = ListFloatObject() // SWELL1: Swell height (m)
    var SWPER1              = ListFloatObject() // SWPER1: Swell period
    var SWDIR1              = ListFloatObject() // SWDIR1: Swell direction
    var SWELL2              = ListFloatObject() // SWELL2: Swell height (m)
    var SWPER2              = ListFloatObject() // SWPER2: Swell period
    var SWDIR2              = ListFloatObject() // SWDIR2: Swell direction
    var PERPW               = ListFloatObject() // PERPW: Peak wave period
    var DIRPW               = ListFloatObject() // DIRPW: Peak wave direction [°]
    var hr_weekday          = ListIntObject()
    var hr_h                = ListStringObject()
    var hr_d                = ListStringObject()
    var hours               = ListIntObject()
    var img_param           = ListStringObject()
    var img_var_map         = ListStringObject()
    dynamic var initDate: Date = Date()
    dynamic var init_d: String = ""
    dynamic var init_dm: String = ""
    dynamic var init_h: String = ""
    dynamic var initstr: String = ""
    dynamic var model_name: String = ""
    dynamic var model_longname: String = ""
    dynamic var id_model: String = ""
    dynamic var update_last: Date = Date()
    dynamic var update_next: Date = Date()
    
#if USE_EXT_FWK
    required convenience public init?(map: Map) {
        self.init()
    }

    public func mapping(map: Map) {
        initStamp <- map["initstamp"]

        temperature = FloatObject.map(map: map, key: "TMP")
        cloudCoverTotal = IntObject.map(map: map, key: "TCDC")
        cloudCoverHigh = IntObject.map(map: map, key: "HCDC")
        cloudCoverMid = IntObject.map(map: map, key: "MCDC")
        cloudCoverLow = IntObject.map(map: map, key: "LCDC")
        relativeHumidity = IntObject.map(map: map, key: "RH")
        windGust = FloatObject.map(map: map, key: "GUST")
        seaLevelPressure = IntObject.map(map: map, key: "SLP")
        freezingLevel = IntObject.map(map: map, key: "FLHGT")
        precipitation = IntObject.map(map: map, key: "APCP")
        windSpeed = FloatObject.map(map: map, key: "WINDSPD")
        windDirection = IntObject.map(map: map, key: "WINDDIR")
        SMERN = IntObject.map(map: map, key: "SMERN")
        SMER = IntObject.map(map: map, key: "SMER")
        temperatureReal = FloatObject.map(map: map, key: "TMPE")
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
        img_param = StringObject.map(map: map, key: "img_param")
        img_var_map = StringObject.map(map: map, key: "img_var_map")
    }

#else

    public required init(dictionary: [String: Any?]) {
        // TODO
    }
#endif

    override public var description : String {
        var aux : String = "\(type(of:self)): "
        aux += "initStamp: \(initStamp)\n"
        aux += "Cloud cover Total: \(cloudCoverTotal.printDescription())\n"
        aux += "High: \(cloudCoverHigh.printDescription())\n"
        aux += "Mid: \(cloudCoverMid.printDescription())\n"
        aux += "Low: \(cloudCoverLow.printDescription())\n"
        aux += "Humidity: \(relativeHumidity.printDescription())\n"
        aux += "Sea Level pressure: \(seaLevelPressure.printDescription())\n"
        aux += "Freezing level: \(freezingLevel.printDescription())\n"
        aux += "Precipitation: \(precipitation.printDescription())\n"
        aux += "Wind gust: \(windGust.printDescription())\n"
        aux += "Wind speed: \(windSpeed.printDescription())\n"
        aux += "Wind direccion: \(windDirection.printDescription())\n"
        aux += "SMERN: \(SMERN.printDescription())\n"
        aux += "SMER: \(SMER.printDescription())\n"
        aux += "Temp: \(temperature.printDescription())\n"
        aux += "Temp real: \(temperatureReal.printDescription())\n"
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
        aux += "initDate: \(initDate), "
        aux += "init_d: \(init_d), "
        aux += "init_dm: \(init_dm), "
        aux += "init_h: \(init_h), "
        aux += "initstr: \(initstr)\n"
        aux += "modelName: \(model_name), "
        aux += "model_longname: \(model_longname), "
        aux += "id_model: \(id_model)\n"
        aux += "update_last: \(update_last), "
        aux += "update_next: \(update_next)\n"
        
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
    

    public func temperature(hour: Int) -> Float? {
        if temperature.count > 0 && hour < temperature.count {
            return temperature[hour].v()
        }
        return nil
    }
    
    public func temperatureReal(hour: Int) -> Float? {
        if temperatureReal.count > 0 && hour < temperatureReal.count {
            return temperatureReal[hour].v()
        }
        return nil
    }
    
    public func relativeHumidity(hour: Int) -> Int? {
        if relativeHumidity.count > 0 && hour < relativeHumidity.count {
            return relativeHumidity[hour].v()
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
        if windSpeed.count > 0 && hour < windSpeed.count {
#if USE_EXT_FWK
            return windSpeed[hour].value.value
#else
            return windSpeed[hour]
#endif
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
        if windDirection.count > 0 && hour < windDirection.count {
            return windDirection[hour].v()
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
        if windGust.count > 0 && hour < windGust.count {
            return windGust[hour].v()
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
        if cloudCoverTotal.count > 0 && hour < cloudCoverTotal.count {
            return cloudCoverTotal[hour].v()
        }
        return nil
    }
    
    public func cloudCoverHigh(hour: Int) -> Int? {
        if cloudCoverHigh.count > 0 && hour < cloudCoverHigh.count {
            return cloudCoverHigh[hour].v()
        }
        return nil
    }
    
    public func cloudCoverMid(hour: Int) -> Int? {
        if cloudCoverMid.count > 0 && hour < cloudCoverMid.count {
            return cloudCoverMid[hour].v()
        }
        return nil
    }
    
    public func cloudCoverLow(hour: Int) -> Int? {
        if cloudCoverLow.count > 0 && hour < cloudCoverLow.count {
            return cloudCoverLow[hour].v()
        }
        return nil
    }
    
    public func precipitation(hour: Int) -> Int? {
        if precipitation.count > 0 && hour < precipitation.count {
            return precipitation[hour].v()
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
        if seaLevelPressure.count > 0 && hour < seaLevelPressure.count {
            return seaLevelPressure[hour].v()
        }
        return nil
    }
    
    public func freezingLevel(hour: Int) -> Int? {
        if freezingLevel.count > 0 && hour < freezingLevel.count {
            return freezingLevel[hour].v()
        }
        return nil
    }
}
