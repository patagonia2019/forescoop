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
    
#if USE_EXT_FWK
    var temperature         = List<FloatObject>() // TMP: temperature
    var cloudCoverTotal     = List<IntObject>() // TCDC: Cloud cover (%) Total
    var cloudCoverHigh      = List<IntObject>() // HCDC: Cloud cover (%) High
    var cloudCoverMid       = List<IntObject>() // MCDC: Cloud cover (%) Mid
    var cloudCoverLow       = List<IntObject>() // LCDC: Cloud cover (%) Low
    var relativeHumidity    = List<IntObject>() // RH: Relative humidity: relative humidity in percent
    var windGust            = List<FloatObject>() // GUST: Wind gusts (knots)
    var seaLevelPressure    = List<IntObject>() // SLP: sea level pressure
    var freezingLevel       = List<IntObject>() //  FLHGT: Freezing Level height in meters (0 degree isoterm)
    var precipitation       = List<IntObject>() //  APCP: Precip. (mm/3h)
    var windSpeed           = List<FloatObject>() //  WINDSPD: Wind speed (knots)
    var windDirection       = List<IntObject>() //  WINDDIR: Wind direction
    var SMERN               = List<IntObject>()
    var SMER                = List<IntObject>()
    var temperatureReal     = List<FloatObject>() // TMPE: temperature in 2 meters above ground with correction to real altitude of the spot.
    var PCPT                = List<IntObject>()
    var HTSGW               = List<FloatObject>()
    var PERPW               = List<FloatObject>()
    var hr_weekday          = List<IntObject>()
    var hr_h                = List<StringObject>()
    var hr_d                = List<StringObject>()
    var hours               = List<StringObject>()
    var img_param           = List<StringObject>()
    var img_var_map         = List<StringObject>()
#else
    public var temperature: [Float]? // TMP: temperature
    public var cloudCoverTotal: [Int]? // TCDC: Cloud cover (%) Total
    public var cloudCoverHigh: [Int]? // HCDC: Cloud cover (%) High
    public var cloudCoverMid: [Int]? // MCDC: Cloud cover (%) Mid
    public var cloudCoverLow: [Int]? // LCDC: Cloud cover (%) Low
    public var relativeHumidity: [Int]? // RH: Relative humidity: relative humidity in percent
    public var windGust: [Float]? // GUST: Wind gusts (knots)
    public var seaLevelPressure: [Int]? // SLP: sea level pressure
    public var freezingLevel: [Int]? //  FLHGT: Freezing Level height in meters (0 degree isoterm)
    public var precipitation: [Int]? //  APCP: Precip. (mm/3h)
    public var windSpeed: [Float]? //  WINDSPD: Wind speed (knots)
    public var windDirection: [Int]? //  WINDDIR: Wind direction
    public var SMER: [Int]?          // SMER: something related to wind speed
    public var SMERN: [Int]?         // SMERN: something related to wind speed
    public var HTSGW: [Float]?         // HTSGW: something related to wind
    public var PERPW: [Float]?         // PERPW: something related to wind
    public var temperatureReal: [Float]? // TMPE: temperature in 2 meters above ground with correction to real altitude of the spot.
    public var PCPT: [Int]?         // PCPT: precip.
    public var hr_weekday: [Int]?
    public var hr_h: [String]?
    public var hr_d: [String]?
    public var hours: [String]?
    
    public var img_param: [String:String]?
    public var img_var_map: [String:String]?
#endif

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
        PERPW = FloatObject.map(map: map, key: "PERPW")
        hr_weekday = IntObject.map(map: map, key: "hr_weekday")
        hr_h = StringObject.map(map: map, key: "hr_h")
        hr_d = StringObject.map(map: map, key: "hr_d")
        hours = StringObject.map(map: map, key: "hours")
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

    init(dictionary: [String: AnyObject?]) {
        // TODO
   }
#endif

    override public var description : String {
        var aux : String = "\(type(of:self)): "

        aux += "initStamp: \(initStamp)\n"
        
#if USE_EXT_FWK
            aux += "Cloud cover Total: ["
            for v in cloudCoverTotal {
                aux += "\(v), "
            }
            aux += "]\n"
            aux += "High (HCDC): ["
            for v in cloudCoverHigh {
                aux += "\(v), "
            }
            aux += "]\n"
            aux += "Mid: ["
            for v in cloudCoverMid {
                aux += "\(v), "
            }
            aux += "]\n"
            aux += "Low: ["
            for v in cloudCoverLow {
                aux += "\(v), "
            }
            aux += "]\n"
            aux += "Humidity: ["
            for v in relativeHumidity {
                aux += "\(v), "
            }
            aux += "]\n"
            aux += "Sea Level pressure: ["
            for v in seaLevelPressure {
                aux += "\(v), "
            }
            aux += "]\n"
            aux += "Freezing level: ["
            for v in freezingLevel {
                aux += "\(v), "
            }
            aux += "]\n"
            aux += "Precipitation: ["
            for v in precipitation {
                aux += "\(v), "
            }
            aux += "]\n"
            aux += "Wind gust: ["
            for v in windGust {
                aux += "\(v), "
            }
            aux += "]\n"
            aux += "Wind speed: ["
            for v in windSpeed {
                aux += "\(v), "
            }
            aux += "]\n"
            aux += "Wind direccion: ["
            for v in windDirection {
                aux += "\(v), "
            }
            aux += "]\n"
            aux += "SMERN: ["
            for v in SMERN {
                aux += "\(v), "
            }
            aux += "]\n"
            aux += "SMER: ["
            for v in SMER {
                aux += "\(v), "
            }
            aux += "]\n"
            aux += "Temp: ["
            for v in temperature {
                aux += "\(v), "
            }
            aux += "]\n"
            aux += "Temp: ["
            for v in temperatureReal {
                aux += "\(v), "
            }
            aux += "]\n"
            aux += "PCPT: ["
            for v in PCPT {
                aux += "\(v), "
            }
            aux += "]\n"
            aux += "HTSGW: ["
            for v in HTSGW {
                aux += "\(v), "
            }
            aux += "]\n"
            aux += "PERPW: ["
            for v in PERPW {
                aux += "\(v), "
            }
            aux += "]\n"
            aux += "hr_weekday: ["
            for v in hr_weekday {
                aux += "\(v), "
            }
            aux += "]\n"
            aux += "hr_h: ["
            for v in hr_h {
                aux += "\(v), "
            }
            aux += "]\n"
            aux += "hr_d: ["
            for v in hr_d {
                aux += "\(v), "
            }
            aux += "]\n"
            aux += "hours: ["
            for v in hours {
                aux += "\(v), "
            }
            aux += "]\n"
            aux += "img_param: ["
            for v in img_param {
                aux += "\(v), "
            }
            aux += "]\n"
            aux += "img_var_map: ["
            for v in img_var_map {
                aux += "\(v), "
            }
            aux += "]\n"
#else
        
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
        if let SMER = SMER {
            aux += "SMER: \(SMER.description)\n"
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
        if let HTSGW = HTSGW {
            aux += "HTSGW: \(HTSGW.description)\n"
        }
        if let PERPW = PERPW {
            aux += "PERPW: \(PERPW.description)\n"
        }
        if let hr_weekday = hr_weekday {
            aux += "hr_weekday: \(hr_weekday)\n"
        }
        if let hr_h = hr_h {
            aux += "hr_h: \(hr_h)\n"
        }
        if let hr_d = hr_d {
            aux += "hr_d: \(hr_d)\n"
        }
        if let hours = hours {
            aux += "hours: \(hours)\n"
        }

        if let img_param = img_param {
            aux += "img_param: \(img_param), "
        }
        if let img_var_map = img_var_map {
            aux += "img_var_map: \(img_var_map)."
        }
        
#endif

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
    

}
