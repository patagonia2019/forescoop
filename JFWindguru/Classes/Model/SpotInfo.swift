//
//  SpotInfo.swift
//  Pods
//
//  Created by javierfuchs on 7/16/17.
//
//

import Foundation
#if USE_EXT_FWK
    import ObjectMapper
    import RealmSwift
#endif

/*
 *  SpotInfo
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

#if USE_EXT_FWK
    public class SpotInfo: SpotInfoObject, Mappable {

        required convenience public init?(map: Map) {
            self.init()
        }
        
        public func mapping(map: Map) {
            id_spot <- map["id_spot"]
            spotname <- map["spotname"]
            country <- map["country"]
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
                elapse = Elapse.init(elapseStart: sunrise, elapseEnd: sunset)
            }
            models = StringObject.map(map: map, key: "models")
            tides <- map["tides"]
        }
    }

#else

    public class SpotInfo: SpotInfoObject {
        init(dictionary: [String: AnyObject?]) {
            super.init(dictionary: dictionary)
            id_spot = dictionary["id_spot"] ?? nil
            spotname = dictionary["spotname"] ?? nil
            countryId = dictionary["countryId"] ?? nil
            latitude = dictionary["latitude"] ?? nil
            longitude = dictionary["longitude"] ?? nil
            altitude = dictionary["altitude"] ?? nil
            timezone = dictionary["timezone"] ?? nil
            gmtHourOffset = dictionary["gmtHourOffset"] ?? nil
            sunrise = dictionary["sunrise"] ?? nil
            sunset = dictionary["sunset"] ?? nil
            if let sunrise = sunrise,
                let sunset = sunset
            {
                elapse = Elapse.init(sunrise, end: sunset)
            }
            models = dictionary["models"] ?? nil
            tides = dictionary["tides"] ?? nil
       }
    }
#endif

public class SpotInfoObject: SpotObject {
    public dynamic var countryId: Int = 0
    public dynamic var latitude: Double = 0
    public dynamic var longitude: Double = 0
    public dynamic var altitude: Int = 0
    public dynamic var timezone: String? = nil
    public dynamic var gmtHourOffset: Int = 0
    public dynamic var sunrise: String? = nil
    public dynamic var sunset: String? = nil
    public dynamic var elapse : Elapse?
    #if USE_EXT_FWK
    public var models = List<StringObject>()
    #else
    public var models: Array<String>?
    #endif
    public dynamic var tides: String? = nil
    
    
    override public var description : String {
        var aux : String = super.description
        aux += "\(type(of:self)): "
        aux += "country # \(countryId), "
        aux += "latitude \(latitude), "
        aux += "longitude \(longitude), "
        aux += "altitude # \(altitude), "
        if let timezone = timezone {
            aux += "timezone \(timezone), "
        }
        aux += "gmtHourOffset \(gmtHourOffset), "
        if let sunrise = sunrise {
            aux += "sunrise \(sunrise), "
        }
        if let sunset = sunset {
            aux += "sunset \(sunset)\n"
        }
        if let elapse = elapse {
            aux += "elapse \(elapse)\n"
        }
        aux += "models \(models), "
        if let tides = tides {
            aux += "tides \(tides).\n"
        }
        return aux
    }
    
    
}
