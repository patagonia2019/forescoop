//
//  User.swift
//  Pods
//
//  Created by javierfuchs on 7/11/17.
//
//

import Foundation
import ObjectMapper

/*
 *  User
 *
 *  Discussion:
 *    Represents a model information of the weather data inside the model id
 *    At this moment public models are all "3"
 *    The information contained is of type Forecast (only one object)
 *
 *  {
 *      "id_user": 0,
 *      "username": "",
 *      "id_country": 0,
 *      "wind_units": "knots",
 *      "temp_units": "c",
 *      "wave_units": "m",
 *      "pro": 0,
 *      "no_ads": 0,
 *      "view_hours_from": 3,
 *      "view_hours_to": 22,
 *      "temp_limit": 10,
 *      "wind_rating_limits": [
 *          10.63,
 *          15.57,
 *          19.41
 *      ],
 *      "colors": {
 *          "wind": [
 *              [
 *                  0,
 *                  255,
 *                  255,
 *                  255
 *              ],
 *              [
 *                  5,
 *                  255,
 *                  255,
 *                  255
 *              ],
 *              [
 *                  8.9,
 *                  103,
 *                  247,
 *                  241
 *              ],
 *              [
 *                  13.5,
 *                  0,
 *                  255,
 *                  0
 *              ],
 *              [
 *                  18.8,
 *                  255,
 *                  240,
 *                  0
 *              ],
 *              [
 *                  24.7,
 *                  255,
 *                  50,
 *                  44
 *              ],
 *              [
 *                  31.7,
 *                  255,
 *                  10,
 *                  200
 *              ],
 *              [
 *                  38,
 *                  255,
 *                  0,
 *                  255
 *              ],
 *              [
 *                  45,
 *                  150,
 *                  50,
 *                  255
 *              ],
 *              [
 *                  60,
 *                  60,
 *                  60,
 *                  255
 *              ],
 *              [
 *                  70,
 *                  0,
 *                  0,
 *                  255
 *              ]
 *          ],
 *          "temp": [
 *              [-25,
 *                  80,
 *                  255,
 *                  220
 *              ],
 *              [-15,
 *                  171,
 *                  190,
 *                  255
 *              ],
 *              [
 *                  0,
 *                  255,
 *                  255,
 *                  255
 *              ],
 *              [
 *                  10,
 *                  255,
 *                  255,
 *                  100
 *              ],
 *              [
 *                  20,
 *                  255,
 *                  170,
 *                  0
 *              ],
 *              [
 *                  30,
 *                  255,
 *                  50,
 *                  50
 *              ],
 *              [
 *                  35,
 *                  255,
 *                  0,
 *                  110
 *              ],
 *              [
 *                  40,
 *                  255,
 *                  0,
 *                  160
 *              ],
 *              [
 *                  50,
 *                  255,
 *                  80,
 *                  220
 *              ]
 *          ],
 *          "cloud": [
 *              [
 *                  0,
 *                  255,
 *                  255,
 *                  255
 *              ],
 *              [
 *                  100,
 *                  120,
 *                  120,
 *                  120
 *              ]
 *          ],
 *          "precip": [
 *              [
 *                  0,
 *                  255,
 *                  255,
 *                  255
 *              ],
 *              [
 *                  9,
 *                  115,
 *                  115,
 *                  255
 *              ],
 *              [
 *                  30,
 *                  115,
 *                  115,
 *                  255
 *              ]
 *          ],
 *          "precip1": [
 *              [
 *                  0,
 *                  255,
 *                  255,
 *                  255
 *              ],
 *              [
 *                  3,
 *                  115,
 *                  115,
 *                  255
 *              ],
 *              [
 *                  10,
 *                  115,
 *                  115,
 *                  255
 *              ]
 *          ],
 *          "press": [
 *              [
 *                  900,
 *                  80,
 *                  255,
 *                  220
 *              ],
 *              [
 *                  1000,
 *                  255,
 *                  255,
 *                  255
 *              ],
 *              [
 *                  1070,
 *                  115,
 *                  115,
 *                  255
 *              ]
 *          ],
 *          "rh": [
 *              [
 *                  0,
 *                  171,
 *                  190,
 *                  255
 *              ],
 *              [
 *                  50,
 *                  255,
 *                  255,
 *                  255
 *              ],
 *              [
 *                  100,
 *                  255,
 *                  255,
 *                  0
 *              ]
 *          ],
 *          "htsgw": [
 *              [
 *                  0,
 *                  255,
 *                  255,
 *                  255
 *              ],
 *              [
 *                  0.3,
 *                  255,
 *                  255,
 *                  255
 *              ],
 *              [
 *                  4,
 *                  120,
 *                  120,
 *                  255
 *              ],
 *              [
 *                  10,
 *                  255,
 *                  80,
 *                  100
 *              ],
 *              [
 *                  15,
 *                  255,
 *                  200,
 *                  100
 *              ]
 *          ],
 *          "perpw": [
 *              [
 *                  0,
 *                  255,
 *                  255,
 *                  255
 *              ],
 *              [
 *                  10,
 *                  255,
 *                  255,
 *                  255
 *              ],
 *              [
 *                  20,
 *                  252,
 *                  81,
 *                  81
 *              ]
 *          ]
 *      }
 *  }
 *
 */


public class User: Mappable {
    public var id_user: Int?
    public var username: String?
    public var id_country: Int?
    public var wind_units: String?
    public var temp_units: String?
    public var wave_units: String?
    public var pro: Int?
    public var no_ads: Int?
    public var view_hours_from: Int?
    public var view_hours_to: Int?
    public var temp_limit: Int?
    public var wind_rating_limits: [CGFloat]?
    public var colors : Dictionary<String, [[Int]]>?
    /*
     TODO: implement colors for:
         public var wind: [Int]?
         public var temp: [Int]?
         public var cloud: [Int]?
         public var precip: [Int]?
         public var precip1: [Int]?
         public var press: [Int]?
         public var rh: [Int]?
         public var htsgw: [Int]?
         public var perpw: [Int]?
     */
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        id_user <- map["id_user"]
        username <- map["username"]
        id_country <- map["id_country"]
        wind_units <- map["wind_units"]
        temp_units <- map["temp_units"]
        wave_units <- map["wave_units"]
        pro <- map["pro"]
        no_ads <- map["no_ads"]
        view_hours_from <- map["view_hours_from"]
        view_hours_to <- map["view_hours_to"]
        temp_limit <- map["temp_limit"]
        wind_rating_limits <- map["wind_rating_limits"]
        colors <- map["colors"]
    }

    public func name() -> String {
        if isAnonymous() {
            return "Anonymous"
        }
        return username ?? ""
    }
    
    public func isAnonymous() -> Bool {
        if let username = username, username != "" {
            return false
        }
        return true
    }
    
    var description : String {
        var aux : String = ""
        if let id_user = id_user {
            aux += "#\(id_user) "
        }
        if let username = username {
            aux += "\(username)."
        }
        return aux
    }

}
