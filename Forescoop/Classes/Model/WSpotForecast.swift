//
//  WSpotForecast.swift
//  Pods
//
//  Created by javierfuchs on 7/17/17.
//
//

import Foundation

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

    var id_spot = 0
    var id_user = 0
    var nickname: String? = nil
    var spotname: String? = nil
    var spot: String? = nil
    var lat: Double = 0.0
    var lon: Double = 0.0
    var alt = 0
    var id_model: String? = nil
    var model: String? = nil
    var model_alt = 0
    var levels = 0
    var sst: String? = nil
    var sunrise: String? = nil
    var sunset: String? = nil
    var tz: String? = nil
    var tzutc: String? = nil
    var utc_offset = 0
    var tzid: String? = nil
    var tides = 0
    var md5chk: String? = nil
    var fcst: [WForecast]?
    var wgs = false
    var wgs_arr: [WindguruStation]?
    var wgs_wind_avg: Float = 0.0
  
    required public convenience init?(map: [String: Any]?) {
        self.init()
        mapping(map: map)
    }
    
    public func mapping(map: [String:Any]?) {
        guard let map = map else { return }
        
        id_spot = map["id_spot"] as? Int ?? 0
        id_user = map["id_user"] as? Int ?? 0
        nickname = map["nickname"] as? String
        spotname = map["spotname"] as? String
        spot = map["spot"] as? String
        lat = map["lat"] as? Double ?? 0.0
        lon = map["lon"] as? Double ?? 0.0
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
        wgs_arr = (map["wgs_arr"] as? [[String: Any]])?.compactMap { WindguruStation.init(map: $0)}
        wgs_wind_avg = map["wgs_wind_avg"] as? Float ?? 0.0
        fcst = (map["fcst"] as? [String: Any])?.compactMap({WForecast.init(map: $0.value as? [String: Any])})
    }
    
    public var description : String {
        ["\(type(of:self))",
         "id_spot : \(id_spot)",
         "id_user : \(id_user)",
         nickname,
         spotname,
         spot,
         "lat/lon/alt: \(lat)/\(lon)/\(alt)",
         id_model,
         model,
         "\(model_alt)",
         "\(levels)",
         sst,
         sunrise,
         sunset,
         tz,
         tzutc,
         "\(utc_offset)",
         tzid,
         md5chk,
         "wgs_wind_avg: \(wgs_wind_avg)",
         fcst?.compactMap{$0.description}.joined(separator: "\n"),
         wgs_arr?.compactMap{$0.description}.joined(separator: "\n")
        ].compactMap {$0}.joined(separator: ", ")
    }
}

public extension WSpotForecast {
    
    var elapse: Elapse? {
        Elapse.init(elapseStart: sunrise, elapseEnd: sunset)
    }
    
    var locationName: String? {
        wgs_arr?.first?.station
    }
    
    var spotName: String {
        if let locationName = locationName {
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
    
    var forecast: WForecast? {
        fcst?.first(where: {$0.id_model == id_model})
    }
    
    var spotId: Int {
        id_spot
    }
    
    var timezone: String? {
        if let tz = tz,
            let tzuttc = tzutc,
            let tzid = tzid {
            return "\(tz), \(tzuttc), \(tzid), \(utc_offset)"
        }
        return nil
    }
    
    var coordinates: String {
        "\(lat), \(lon)\n\(alt) meters"
    }
    
    var elapsedDay: Elapse? {
        elapse
    }
    
    var sunriseTime: String? {
        sunrise
    }
    
    var sunsetTime: String? {
        sunset
    }
    
    var modelInfo: String? {
        if let id_model = id_model,
            let model = model {
            return "\(id_model): \(model), alt: \(model_alt)"
        }
        return nil
    }
}
