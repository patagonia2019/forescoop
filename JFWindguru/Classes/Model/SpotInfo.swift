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
    import Realm
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

public class SpotInfo: Spot {

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
    public var models = [String]()
#endif
    public dynamic var tides: String? = nil

#if USE_EXT_FWK
    public required init(map: Map) {
        super.init()
    }
    
    required public init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    required public init() {
        super.init()
    }
    
    required public init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }

    
    public override func mapping(map: Map) {
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
            elapse = Elapse.init(elapseStart: sunrise, elapseEnd: sunset)
        }
        models = StringObject.map(map: map, key: "models")
        tides <- map["tides"]
    }
#else

    public override init(dictionary: [String: AnyObject?]) {
        super.init(dictionary: dictionary)
        countryId = dictionary["countryId"] as? Int ?? 0
        latitude = dictionary["latitude"] as? Double ?? 0.0
        longitude = dictionary["longitude"] as? Double ?? 0.0
        altitude = dictionary["altitude"] as? Int ?? 0
        timezone = dictionary["timezone"] as? String ?? nil
        gmtHourOffset = dictionary["gmtHourOffset"] as? Int ?? 0
        sunrise = dictionary["sunrise"] as? String ?? nil
        sunset = dictionary["sunset"] as? String ?? nil
        if let sunrise = sunrise,
            let sunset = sunset
        {
            elapse = Elapse.init(elapseStart: sunrise, elapseEnd: sunset)
        }
        if let modelDicts = dictionary["models"] as? [String] {
            for model in modelDicts {
                models.append(model)
            }
        }
        tides = dictionary["tides"] as? String ?? nil
   }

#endif
 
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
        if let tides = tides {
            aux += "tides \(tides).\n"
        }
        aux += "models \(models), "
        return aux
    }
    
    
}
