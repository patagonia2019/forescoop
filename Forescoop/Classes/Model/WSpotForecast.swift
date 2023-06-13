//
//  WSpotForecast.swift
//  Forescoop
//
//  Created by javierfuchs on 7/17/17.
//
//

import Foundation
import CoreLocation

/*
 *  WSpotForecast
 *
 *  Discussion:
 *    Represents a model information of the stot or location when the forecast is obtained.
 *    By inheritance the common attributes are parsed and filled in SpotInfo and Spot.
 *    Contains the complete forecast (inside a single instance of ForecastModel)
 *
 * {
 *     "id_spot": 546356,
 *     "id_user": 2,
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
 */

public class WSpotForecast: Object, Mappable {

    var id_spot = 0
    var id_user = 0
    var nickname: String? = nil
    var spot: String? = nil
    var lat: Double = 0.0
    var lon: Double = 0.0
    var alt = 0
    var id_model: Int = 0
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
  
    required public convenience init?(map: [String: Any]?) throws {
        self.init()
        try mapping(map: map)
    }
    
    public override func mapping(map: [String: Any]?) throws {
        try super.mapping(map: map)
        
        id_spot = map?["id_spot"] as? Int ?? 0
        id_user = map?["id_user"] as? Int ?? 0
        nickname = map?["nickname"] as? String
        spot = map?["spot"] as? String
        lat = map?["lat"] as? Double ?? 0.0
        lon = map?["lon"] as? Double ?? 0.0
        alt = map?["alt"] as? Int ?? 0
        id_model = map?["id_model"] as? Int ?? 0
        model = map?["model"] as? String
        model_alt = map?["model_alt"] as? Int ?? 0
        levels = map?["levels"] as? Int ?? 0
        sst = map?["sst"] as? String
        sunrise = map?["sunrise"] as? String
        sunset = map?["sunset"] as? String
        tz = map?["tz"] as? String
        tzutc = map?["tzutc"] as? String
        utc_offset = map?["utc_offset"] as? Int ?? 0
        tzid = map?["tzid"] as? String
        tides = map?["tides"] as? Int ?? 0
        md5chk = map?["md5chk"] as? String
        wgs_arr = try (map?["wgs_arr"] as? [[String: Any]])?
            .compactMap { try WindguruStation.init(map: $0)}
        wgs_wind_avg = map?["wgs_wind_avg"] as? Float ?? 0.0
        fcst = try (map?["fcst"] as? [String: Any])?
            .compactMap({try WForecast.init(map: $0.value as? [String: Any])})
    }
    
    public var description : String {
        [
            "\(type(of:self))",
            "id_spot : \(id_spot)",
            "id_user : \(id_user)",
            nickname,
            spot,
            "lat/lon/alt: \(lat)/\(lon)/\(alt)",
            id_model.toString,
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
        ]
            .compactMap {$0}
            .joined(separator: ", ")
    }
}

public extension WSpotForecast {
    
    var identifier: String {
        id_spot.toString
    }
    
    var userIdentifier: String {
        id_user.toString
    }

    var nickName: String? {
        nickname
    }
    
    var elapse: Elapse? {
        Elapse(sunrise, sunset, utc_offset)
    }
    
    var locationName: String? {
        wgs_arr?.first?.station
    }
    
    var spotname: String? {
        spot
    }
    
    var location: CLLocation? {
        CLLocation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), altitude: CLLocationDistance(alt), horizontalAccuracy: 0, verticalAccuracy: 0, course: CLLocationDirection.greatestFiniteMagnitude, speed: 0, timestamp: Date())
    }
    
    var modelId: Int {
        id_model
    }
    
    var forecast: WForecast? {
        fcst?.first(where: {$0.id_model == id_model})
    }
    
    var spotId: Int {
        id_spot
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
    
    var timezoneUtc: String? {
        tzutc?.components(separatedBy: CharacterSet(charactersIn:"()")).joined()
    }
    
    var timezone: TimeZone? {
        timezoneUtc != nil ? TimeZone(identifier: timezoneUtc!) : nil
    }
    
    var gmtHourOffset: Int {
        utc_offset
    }
    
    var timezoneId: String? {
        tzid
    }
    
    var numberOfTides: Int {
        tides
    }

}
