//
//  WSpotForecast.swift
//  Pods
//
//  Created by javierfuchs on 7/17/17.
//
//

import Foundation
import ObjectMapper

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
 *     "nickname": "Windguru Station",
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

public class WSpotForecast: Mappable {
    public var id_spot: Int?
    public var id_user: Int?
    public var nickname: String?
    public var spot: String?
    public var lat: CGFloat?
    public var lon: CGFloat?
    public var alt: Int?
    public var id_model: String?
    public var model: String?
    public var model_alt: Int?
    public var levels: Int?
    public var sst: String?
    public var sunrise: String?
    public var sunset: String?
    var elapse : Elapse?
    public var tz: String?
    public var tzutc: String?
    public var utc_offset: Int?
    public var tzid: String?
    public var tides: Int?
    public var md5chk: String?
    public var fcst: WForecast?
    public var wgs: Bool?
    public var wgs_arr: [WindguruStation]?
    public var wgs_wind_avg: Int?
    
    required public init?(map: Map) {
    }
    
    
    public func mapping(map: Map) {
        id_spot       <- map["id_spot"]
        id_user       <- map["id_user"]
        nickname      <- map["nickname"]
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
        if let sunrise = sunrise,
            let sunset = sunset
        {
            elapse = Elapse.init(sunrise, end: sunset)
        }
        tz            <- map["tz"]
        tzutc         <- map["tzutc"]
        utc_offset    <- map["utc_offset"]
        tzid          <- map["tzid"]
        tides         <- map["tides"]
        md5chk        <- map["md5chk"]
        wgs           <- map["wgs"]
        wgs_arr       <- map["wgs_arr"]
        wgs_wind_avg  <- map["wgs_wind_avg"]

        guard let id_model = id_model else { return }
        fcst <- map["fcst.\(id_model)"]
    }
    
    public var description : String {
        var aux : String = ""
        if let id_spot      = id_spot       { aux += "id_spot     : \(id_spot), " }
        if let id_user      = id_user       { aux += "id_user     : \(id_user), " }
        if let nickname     = nickname      { aux += "nickname    : \(nickname), " }
        if let spot         = spot          { aux += "spot        : \(spot), " }
        if let lat          = lat           { aux += "lat         : \(lat), " }
        if let lon          = lon           { aux += "lon         : \(lon), " }
        if let alt          = alt           { aux += "alt         : \(alt), " }
        if let id_model     = id_model      { aux += "id_model    : \(id_model), " }
        if let model        = model         { aux += "model       : \(model), " }
        if let model_alt    = model_alt     { aux += "model_alt   : \(model_alt), " }
        if let levels       = levels        { aux += "levels      : \(levels), " }
        if let sst          = sst           { aux += "sst         : \(sst), " }
        if let sunrise      = sunrise       { aux += "sunrise     : \(sunrise), " }
        if let sunset       = sunset        { aux += "sunset      : \(sunset), " }
        if let tz           = tz            { aux += "tz          : \(tz), " }
        if let tzutc        = tzutc         { aux += "tzutc       : \(tzutc), " }
        if let utc_offset   = utc_offset    { aux += "utc_offset  : \(utc_offset), " }
        if let tzid         = tzid          { aux += "tzid        : \(tzid), " }
        if let tides        = tides         { aux += "tides       : \(tides), " }
        if let md5chk       = md5chk        { aux += "md5chk      : \(md5chk), " }
        if let fcst = fcst {
            aux += "Forecast\n \(fcst.description)\n"
        }
        if let wgs_wind_avg = wgs_wind_avg  { aux += "wgs_wind_avg: \(wgs_wind_avg)\n" }
        if let wgs_arr = wgs_arr {
            for wgs in wgs_arr {
                aux += "WGS: \(wgs.description)\n"
            }
        }
        
        return aux
    }
    
    
}
