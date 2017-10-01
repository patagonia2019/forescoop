//
//  WSpotForecast.swift
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
 *  SpotForecast
 *
 *  Discussion:
 *    Represents a model information of the stot or location when the forecast is obtained.
 *    By inheritance the common attributes are parsed and filled in SpotInfo and Spot.
 *    Contains the complete forecast (inside a single instance of ForecastModel)
 *
 * {
 *     "id_spot": 546356,
 *     "id_user": 2,
 *     "spotname": "Windguru Station",
 *     "spot": "Argentina - Agrotécnico 4 - San Pedro, Guasayan - Sgo del Estero, MeteoStar",
 *     "lat": -27.9567,
 *     "lon": -65.1579,
 *     "alt": 338,
 *     "id_model": "3",
 *     "model": "gfs",
 *     "model_alt": 355,
 *     "levels": 1,
 *     "sst": null,
 *     "sunrise": "08:12",
 *     "sunset": "18:41",
 *     "tz": "-03",
 *     "tzutc": "(UTC-3)",
 *     "utc_offset": -3,
 *     "tzid": "America/Argentina/Cordoba",
 *     "tides": 0,
 *     "md5chk": "a25b18ccf9fbe6c2a382d9867034537b",
 *     "fcst": { "3": <WForecast> },
 *     "wgs": true,
 *     "wgs_arr": [ <WindguruStation>],
 *     "wgs_wind_avg": 2
 * }
 *
 *
 */

public class WSpotForecast: Object, Mappable {

    dynamic var id_spot = 0
    dynamic var id_user = 0
    dynamic var nickname: String? = nil
    dynamic var spotname: String? = nil
    dynamic var spot: String? = nil
    dynamic var lat: Float = 0.0
    dynamic var lon: Float = 0.0
    dynamic var alt = 0
    dynamic var id_model: String? = nil
    dynamic var model: String? = nil
    dynamic var model_alt = 0
    dynamic var levels = 0
    dynamic var sst: String? = nil
    dynamic var sunrise: String? = nil
    dynamic var sunset: String? = nil
    dynamic var tz: String? = nil
    dynamic var tzutc: String? = nil
    dynamic var utc_offset = 0
    dynamic var tzid: String? = nil
    dynamic var tides = 0
    dynamic var md5chk: String? = nil
    dynamic var fcst : WForecast?
    dynamic var wgs = false
    var wgs_arr = List<WindguruStation>()
    dynamic var wgs_wind_avg = 0
  
    required public convenience init?(map: Map) {
        self.init()
        #if !USE_EXT_FWK
            mapping(map: map)
        #endif
    }
    
    public func mapping(map: Map) {
        #if USE_EXT_FWK
            id_spot       <- map["id_spot"]
            id_user       <- map["id_user"]
            nickname      <- map["nickname"]
            spotname      <- map["spotname"]
            spot          <- map["spot"]
            lat           <- map["lat"]
            lon           <- map["lon"]
            alt           <- map["alt"]
            id_model      <- map["id_model"]
            model         <- map["model"]
            model_alt     <- map["model_alt"]
            levels        <- map["levels"]
            sst           <- map["sst"]
            sunrise       <- map["sunrise"]
            sunset        <- map["sunset"]
            tz            <- map["tz"]
            tzutc         <- map["tzutc"]
            utc_offset    <- map["utc_offset"]
            tzid          <- map["tzid"]
            tides         <- map["tides"]
            md5chk        <- map["md5chk"]
            wgs           <- map["wgs"]
            wgs_arr <- (map["wgs_arr"], ArrayTransform<WindguruStation>())
            wgs_wind_avg  <- map["wgs_wind_avg"]
            
            guard let id_model = id_model else { return }
            fcst <- map["fcst.\(id_model)"]
        #else
            id_spot = map["id_spot"] as? Int ?? 0
            id_user = map["id_user"] as? Int ?? 0
            nickname = map["nickname"] as? String
            spotname = map["spotname"] as? String
            spot = map["spot"] as? String
            lat = map["lat"] as? Float ?? 0.0
            lon = map["lon"] as? Float ?? 0.0
            alt = map["alt"] as? Int ?? 0
            id_model = map["id_model"] as? String
            model = map["model"] as? String
            model_alt = map["model_alt"] as? Int ?? 0
            levels = map["levels"] as? Int ?? 0
            sst = map["sst"] as? String
            sunrise = map["sunrise"] as? String
            sunset = map["sunset"] as? String
            tz = map["tz"] as? String
            tzutc = map["tzutc"] as? String
            utc_offset = map["utc_offset"] as? Int ?? 0
            tzid = map["tzid"] as? String
            tides = map["tides"] as? Int ?? 0
            md5chk = map["md5chk"] as? String
            guard let fcstDict = map["fcst"] as? [String: Any] else { return }
            for (k,v) in fcstDict {
                if let tmpDictionary = v as? [String: Any],
                    k == id_model {
                    fcst = WForecast.init(map: tmpDictionary)
                }
            }
        #endif
    }
    
    public var elapse: Elapse? {
        if let sunrise = sunrise, let sunset = sunset {
            return Elapse.init(elapseStart: sunrise, elapseEnd: sunset)
        }
        return nil
    }


    override public var description : String {
        var aux : String = "\(type(of:self)):\n"
        aux += "id_spot : \(id_spot), "
        aux += "id_user : \(id_user)\n"
        if let nickname     = nickname      { aux += "nickname : \(nickname), " }
        if let spotname     = spotname      { aux += "spotname : \(spotname), " }
        if let spot         = spot          { aux += "spot : \(spot)\n" }
        aux += "lat         : \(lat), "
        aux += "lon         : \(lon), "
        aux += "alt         : \(alt)\n"
        if let id_model     = id_model      { aux += "id_model : \(id_model), " }
        if let model        = model         { aux += "model : \(model), " }
        aux += "model_alt   : \(model_alt), "
        aux += "levels      : \(levels)\n"
        if let sst          = sst           { aux += "sst : \(sst)\n" }
        if let sunrise      = sunrise       { aux += "sunrise : \(sunrise), " }
        if let sunset       = sunset        { aux += "sunset : \(sunset)\n" }
        if let tz           = tz            { aux += "tz : \(tz), " }
        if let tzutc        = tzutc         { aux += "tzutc : \(tzutc), " }
        aux += "utc_offset  : \(utc_offset), "
        if let tzid         = tzid          { aux += "tzid : \(tzid)\n" }
        aux += "tides       : \(tides), "
        if let md5chk       = md5chk        { aux += "md5chk      : \(md5chk)\n" }
        if let fcst = fcst {
            aux += "Forecast\n \(fcst.description)\n"
        }
        aux += "wgs_wind_avg: \(wgs_wind_avg)\n"
        for wgs in wgs_arr {
            aux += "WGS: \(wgs.description)\n"
        }
        return aux
    }
}

extension WSpotForecast {
    
    public func locationName() -> String? {
        guard let windguruStation = wgs_arr.first
            else { return nil }
        return windguruStation.station
    }
    
    public func spotName() -> String {
        if let locationName = locationName() {
            return locationName
        }
        if let spot = spot {
            return spot
        }
        if let spotname = spotname {
            return spotname
        }
        if let nickname = nickname {
            return nickname
        }
        if let tzid = tzid {
            return tzid
        }
        return "Spot id: \(id_spot)"
    }
    
    public func forecast() -> WForecast? {
        return fcst
    }
    
    public func spotId() -> Int {
        return id_spot
    }
    
    public func timezone() -> String? {
        if let tz = tz,
            let tzuttc = tzutc,
            let tzid = tzid {
            return "\(tz), \(tzuttc), \(tzid), \(utc_offset)"
        }
        return nil
    }
    
    public func coordinates() -> String {
        return "\(lat), \(lon)\n\(alt) meters"
    }
    
    public func elapsedDay() -> Elapse? {
        return elapse
    }
    
    public func sunriseTime() -> String? {
        return sunrise
    }
    
    public func sunsetTime() -> String? {
        return sunset
    }
    
    public func modelInfo() -> String? {
        if let id_model = id_model,
            let model = model {
            return "\(id_model): \(model), alt: \(model_alt)"
        }
        return nil
    }
}

