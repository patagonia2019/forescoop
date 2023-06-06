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
 /*
  ▿ 13 elements
    ▿ 0 : 2 elements
      - key : "lat"
      - value : -41.1281
    ▿ 1 : 2 elements
      - key : "alt"
      - value : 770
    ▿ 2 : 2 elements
      - key : "id_spot"
      - value : 64141
    ▿ 3 : 2 elements
      - key : "sunrise"
      - value : 09:08
    ▿ 4 : 2 elements
      - key : "lon"
      - value : -71.348
    ▿ 5 : 2 elements
      - key : "gmt_hour_offset"
      - value : -3
    ▿ 6 : 2 elements
      - key : "spotname"
      - value : Bariloche
    ▿ 7 : 2 elements
      - key : "models"
      ▿ value : 4 elements
        - 0 : 100
        - 1 : 3
        - 2 : 45
        - 3 : 59
    ▿ 8 : 2 elements
      - key : "tides"
      - value : 0
    ▿ 9 : 2 elements
      - key : "sunset"
      - value : 18:20
    ▿ 10 : 2 elements
      - key : "id_country"
      - value : 32
    ▿ 11 : 2 elements
      - key : "country"
      - value : Argentina
    ▿ 12 : 2 elements
      - key : "tz"
      - value : America/Argentina/Mendoza

  */
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
    var models = [Int]()
    var tides: String? = nil

    required public convenience init?(map: [String: Any]?) {
        self.init()
        mapping(map: map)
    }
    
    public override func mapping(map: [String:Any]?) {
        guard let map = map else { return }

        super.mapping(map: map)
        latitude = map["lat"] as? Double ?? 0.0
        longitude = map["lon"] as? Double ?? 0.0
        altitude = map["alt"] as? Int ?? 0
        timezone = map["tz"] as? String ?? nil
        gmtHourOffset = map["gmt_hour_offset"] as? Int ?? 0
        sunrise = map["sunrise"] as? String ?? nil
        sunset = map["sunset"] as? String ?? nil
        models = map["models"] as? [Int] ?? []
        tides = map["tides"] as? String ?? nil
        elapse = Elapse.init(elapseStart: sunrise, elapseEnd: sunset)
    }
 
    override public var description : String {
        [
            super.description,
            "\nSpotInfo\n",
            [
                "country # \(countryId)",
                "latitude \(latitude)",
                "longitude \(longitude)",
                "altitude # \(altitude)",
                timezone,
                "gmtHourOffset: \(gmtHourOffset)",
                sunrise,
                sunset,
                elapse?.description,
                tides,
                "\(models)"
            ].compactMap {$0}.joined(separator: ", ")
        ].joined(separator: "\n")
    }
    
    
}


extension SpotInfo {
    public func elapseContainsTime(date : NSDate) -> Bool {
        return elapse?.containsTime(date: date) ?? false
    }
}
