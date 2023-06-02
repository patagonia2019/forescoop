//
//  SpotInfo.swift
//  Pods
//
//  Created by javierfuchs on 7/16/17.
//
//

import Foundation

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

    var countryId: Int = 0
    var latitude: Double = 0
    var longitude: Double = 0
    var altitude: Int = 0
    var timezone: String? = nil
    var gmtHourOffset: Int = 0
    var sunrise: String? = nil
    var sunset: String? = nil
    var elapse : Elapse?
    var models = [String]()
    var tides: String? = nil

    required public convenience init?(map: [String:Any]) {
        self.init()
        mapping(map: map)
    }
    
    public override func mapping(map: [String:Any]) {
        super.mapping(map: map)
        countryId = map["countryId"] as? Int ?? 0
        latitude = map["latitude"] as? Double ?? 0.0
        longitude = map["longitude"] as? Double ?? 0.0
        altitude = map["altitude"] as? Int ?? 0
        timezone = map["timezone"] as? String ?? nil
        gmtHourOffset = map["gmtHourOffset"] as? Int ?? 0
        sunrise = map["sunrise"] as? String ?? nil
        sunset = map["sunset"] as? String ?? nil
        models = map["models"] as? [String] ?? []
        tides = map["tides"] as? String ?? nil
        if let sunrise = sunrise,
            let sunset = sunset
        {
            elapse = Elapse.init(elapseStart: sunrise, elapseEnd: sunset)
        }
    }
 
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
        aux += "models \(models.printDescription()), "
        return aux
    }
    
    
}


extension SpotInfo {
    public func elapseContainsTime(date : NSDate) -> Bool {
        return elapse?.containsTime(date: date) ?? false
    }
}
