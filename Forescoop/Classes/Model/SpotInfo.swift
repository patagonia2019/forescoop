//
//  SpotInfo.swift
//  Forescoop
//
//  Created by javierfuchs on 7/16/17.
//
//

import Foundation
import CoreLocation

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

    var id_country: Int = 0
    var latitude: Double = 0
    var longitude: Double = 0
    var altitude: Int = 0
    var gmt_hour_offset: Int = 0
    var sunrise: String? = nil
    var sunset: String? = nil
    var models = [Int]()
    var tides: String? = nil
    var tz: String?

    required convenience init?(map: [String: Any]?) {
        self.init()
        mapping(map: map)
    }
    
    public override func mapping(map: [String:Any]?) {
        guard let map = map else { return }

        super.mapping(map: map)
        id_country = map["id_country"] as? Int ?? 0
        latitude = map["lat"] as? Double ?? 0.0
        longitude = map["lon"] as? Double ?? 0.0
        altitude = map["alt"] as? Int ?? 0
        tz = map["tz"] as? String ?? nil
        gmt_hour_offset = map["gmt_hour_offset"] as? Int ?? 0
        sunrise = map["sunrise"] as? String ?? nil
        sunset = map["sunset"] as? String ?? nil
        models = map["models"] as? [Int] ?? []
        tides = map["tides"] as? String
        tz = map["tz"] as? String
    }
 
    override public var description : String {
        [
            super.description,
            "\nSpotInfo\n",
            [
                "id_country # \(id_country)",
                "latitude \(latitude)",
                "longitude \(longitude)",
                "altitude # \(altitude)",
                tz,
                "gmtHourOffset: \(gmt_hour_offset)",
                sunrise,
                sunset,
                elapse?.description,
                tides,
                "\(models)"
            ]
                .compactMap {$0}
                .joined(separator: ", ")
        ]
            .joined(separator: "\n")
    }
}

public extension SpotInfo {
    func elapseContainsTime(date: NSDate) -> Bool {
        elapse?.containsTime(date: date) == true
    }
    
    var countryIdentifier: Int {
        id_country
    }
    
    var location: CLLocation? {
        CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), altitude: CLLocationDistance(altitude), horizontalAccuracy: 0, verticalAccuracy: 0, course: CLLocationDirection.greatestFiniteMagnitude, speed: 0, timestamp: Date())
    }
    
    var elapse: Elapse? {
        Elapse(sunrise, sunset, Float(gmtHourOffset))
    }
    
    var timezone: TimeZone? {
        tz != nil ? TimeZone(identifier: tz!) : nil
    }
    
    var gmtHourOffset: Int {
        gmt_hour_offset
    }

    var currentModels: [Int] {
        models
    }

    var currentTides: String? {
        tides
    }
}
