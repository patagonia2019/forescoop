//
//  SpotInfo.swift
//  Pods
//
//  Created by javierfuchs on 7/16/17.
//
//

import Foundation
import ObjectMapper

/*
 *  SpotForecast
 *
 *  Discussion:
 *    Represents a model information of the stot or location.
 *    By inheritance the common attributes are parsed and filled in Spot.
 *    Contains id of the spot, spot name, country, latitude, longitude, altitude, timezone,
 *    GMT hour offset, time of sunrise/sunset, the models (normal 3 is the public model).
 *
 *   {
 *       "id_spot": "64141",
 *       "spotname": "Bariloche",
 *       "country": "Argentina",
 *       "id_country": 32,
 *       "lat": -41.1281,
 *       "lon": -71.348,
 *       "alt": 770,
 *       "tz": "America/Argentina/Mendoza",
 *       "gmt_hour_offset": -3,
 *       "sunrise": "07:11",
 *       "sunset": "19:54",
 *       "models": [
 *           "3"
 *       ],
 *       "tides": "0",
 *   }
 *
 *
 */

public class SpotInfo: Spot {
    public var countryId: Int?
    public var latitude: Double?
    public var longitude: Double?
    public var altitude: Int?
    public var timezone: String?
    public var gmtHourOffset: Int?
    public var sunrise: String?
    public var sunset: String?
    var elapse : Elapse?
    public var models: Array<String>?
    public var tides: String?
    
    required public init?(map: Map) {
        super.init(map: map)
    }
    
    
    override public func mapping(map: Map) {
        super.mapping(map: map)
        countryId <- map["id_country"]
        latitude <- map["lat"]
        longitude <- map["lon"]
        altitude <- map["alt"]
        timezone <- map["tz"]
        gmtHourOffset <- map["gmt_hour_offset"]
        sunrise <- map["sunrise"]
        sunset <- map["sunset"]
        if let sunrise = sunrise,
            let sunset = sunset
        {
            elapse = Elapse.init(sunrise, end: sunset)
        }
        models <- map["models"]
        tides <- map["tides"]
    }
    
    override public var description : String {
        var aux : String = super.description
        if let countryId = countryId {
            aux += "country # \(countryId), "
        }
        if let latitude = latitude {
            aux += "latitude \(latitude), "
        }
        if let longitude = longitude {
            aux += "longitude \(longitude), "
        }
        if let altitude = altitude {
            aux += "altitude # \(altitude), "
        }
        if let timezone = timezone {
            aux += "timezone \(timezone), "
        }
        if let gmtHourOffset = gmtHourOffset {
            aux += "gmtHourOffset \(gmtHourOffset), "
        }
        if let sunrise = sunrise {
            aux += "sunrise \(sunrise), "
        }
        if let sunset = sunset {
            aux += "sunset \(sunset), "
        }
        if let elapse = elapse {
            aux += "elapse \(elapse), "
        }
        if let models = models {
            aux += "models \(models), "
        }
        if let tides = tides {
            aux += "tides \(tides).\n"
        }
        return aux
    }
    
    
}
