//
//  User.swift
//  Forescoop
//
//  Created by javierfuchs on 7/11/17.
//
//

import Foundation

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
 *      "wind_rating_limits": [ 10.63, 15.57, 19.41 ],
 *      "colors": {
 *          "wind": [
 *              [ 0, 255, 255, 255 ],
 *              [ 5, 255, 255, 255 ],
 *              [ 8.9, 103, 247, 241 ],
 *              [ 13.5, 0, 255, 0 ],
 *              [ 18.8, 255, 240, 0 ],
 *              [ 24.7, 255, 50, 44 ],
 *              [ 31.7, 255, 10, 200 ],
 *              [ 38, 255, 0, 255 ],
 *              [ 45, 150, 50, 255 ],
 *              [ 60, 60, 60, 255 ],
 *              [ 70, 0, 0, 255 ]
 *          ],
 *          "temp": [
 *              [-25, 80, 255, 220 ],
 *              [-15, 171, 190, 255 ],
 *              [ 0, 255, 255, 255 ],
 *              [ 10, 255, 255, 100 ],
 *              [ 20, 255, 170, 0 ],
 *              [ 30, 255, 50, 50 ],
 *              [ 35, 255, 0, 110 ],
 *              [ 40, 255, 0, 160 ],
 *              [ 50, 255, 80, 220 ]
 *          ],
 *          "cloud": [
 *              [ 0, 255, 255, 255 ],
 *              [ 100, 120, 120, 120 ]
 *          ],
 *          "precip": [
 *              [ 0, 255, 255, 255 ],
 *              [ 9, 115, 115, 255 ],
 *              [ 30, 115, 115, 255 ]
 *          ],
 *          "precip1": [
 *              [ 0, 255, 255, 255 ],
 *              [ 3, 115, 115, 255 ],
 *              [ 10, 115, 115, 255 ]
 *          ],
 *          "press": [
 *              [ 900, 80, 255, 220 ],
 *              [ 1000, 255, 255, 255 ],
 *              [ 1070, 115, 115, 255 ]
 *          ],
 *          "rh": [
 *              [ 0, 171, 190, 255 ],
 *              [ 50, 255, 255, 255 ],
 *              [ 100, 255, 255, 0 ]
 *          ],
 *          "htsgw": [
 *              [ 0, 255, 255, 255 ], 
 *              [ 0.3, 255, 255, 255 ], 
 *              [ 4, 120, 120, 255 ], 
 *              [ 10, 255, 80, 100 ], 
 *              [ 15, 255, 200, 100 ]
 *          ],
 *          "perpw": [
 *              [ 0, 255, 255, 255 ],
 *              [ 10, 255, 255, 255],
 *              [ 20, 252, 81, 81]
 *          ]
 *      }
 *  }
 *
 */

enum TypeOfColor: String {
    case wind
    case temperature = "temp"
    case cloud
    case precipitation = "precip"
    case precip1
    case pressure = "press"
    case rh
    case wpower
    case tide
    case initial = "init"
}


public class User: Object, Mappable {
    
    var id_user : Int = 0
    var username: String?
    var id_country : Int = 0
    var wind_units: String?
    var temp_units: String?
    var wave_units: String?
    var pro : Int = 0
    var no_ads : Int = 0
    var view_hours_from : Int = 0
    var view_hours_to : Int = 0
    var temp_limit : Int = 0
    var wind_rating_limits = [Float]()
    var customColors: [String: [CustomColor]]?

    required public convenience init?(map: [String: Any]?) throws {
        self.init()
        try mapping(map: map)
    }
    
    public override func mapping(map: [String: Any]?) throws {
        try super.mapping(map: map)
                
        id_user = map?["id_user"] as? Int ?? 0
        username = map?["username"] as? String
        id_country = map?["id_country"] as? Int ?? 0
        wind_units = map?["wind_units"] as? String
        temp_units = map?["temp_units"] as? String
        wave_units = map?["wave_units"] as? String
        pro = map?["pro"] as? Int ?? 0
        no_ads = map?["no_ads"] as? Int ?? 0
        view_hours_from = map?["view_hours_from"] as? Int ?? 0
        view_hours_to = map?["view_hours_to"] as? Int ?? 0
        temp_limit = map?["temp_limit"] as? Int ?? 0
        wind_rating_limits = (map?["wind_rating_limits"] as? [Double])?.compactMap({Float($0)}) ?? []
        customColors = (map?["colors"] as? [String: Any])?
            .compactMapValues { value in
                (value as? [[Double]])?
                    .compactMap({CustomColor(info: String($0[0]),
                                             alpha: Float($0[1]),
                                             red: Float($0[2]),
                                             green: Float($0[3]),
                                             blue: Float($0[4]))})
            }
    }
    
    public var description: String {
        var aux: [String?] = [
            "\(type(of:self))",
            "\(self)",
            "#\(id_user)",
            username ?? "-",
            "\(id_country)",
            wind_units ?? "-",
            temp_units ?? "-",
            wave_units ?? "-",
            pro.toString]
        aux.append(contentsOf: [
            no_ads.toString,
            view_hours_from.toString,
            view_hours_to.toString,
            temp_limit.toString,
            wind_rating_limits.toString
        ])
        aux.append(contentsOf: customColors?.compactMap({$0.value.description}) ?? [""])
        return aux
            .compactMap {$0}
            .joined(separator: "\n")
    }
}

public extension Int {
    var toString: String {
        String(format: "%d", self)
    }
}

public extension Array where Iterator.Element == Float {
    var toString: String {
        self.compactMap {String(format: "%f", $0)}.joined(separator: ", ")
    }
}


public extension User {
    enum Constant: String {
        case Anonymous
    }
    var name: String {
        isAnonymous ? Constant.Anonymous.rawValue : username ?? ""
    }
    var isAnonymous: Bool {
        username?.isEmpty == true
    }
    var countryIdentifier: Int {
        id_country
    }
    var windUnits: String? {
        wind_units
    }
    var temperatureUnits: String? {
        temp_units
    }
    var waveUnits: String? {
        wave_units
    }
    var isPro: Bool {
        pro != 0
    }
    var noAdvertisement: Bool {
        no_ads != 0
    }
    var viewHoursFrom: Int {
        view_hours_from
    }
    var viewHoursTo: Int {
        view_hours_to
    }
    var temperatureLimit: Int {
        temp_limit
    }
    var windRatingLimits: [Float] {
        wind_rating_limits
    }
    var windColor: [CustomColor] {
        customColors?[TypeOfColor.wind.rawValue] ?? []
    }
    var temperatureColor: [CustomColor] {
        customColors?[TypeOfColor.temperature.rawValue] ?? []
    }
    var cloudColor: [CustomColor] {
        customColors?[TypeOfColor.cloud.rawValue] ?? []
    }
    var precipitationColor: [CustomColor] {
        customColors?[TypeOfColor.precipitation.rawValue] ?? []
    }
    var precip1Color: [CustomColor] {
        customColors?[TypeOfColor.precip1.rawValue] ?? []
    }
    var pressureColor: [CustomColor] {
        customColors?[TypeOfColor.pressure.rawValue] ?? []
    }
    var rhColor: [CustomColor] {
        customColors?[TypeOfColor.rh.rawValue] ?? []
    }
    var wpowerColor: [CustomColor] {
        customColors?[TypeOfColor.wpower.rawValue] ?? []
    }
    var tideColor: [CustomColor] {
        customColors?[TypeOfColor.tide.rawValue] ?? []
    }
    var initialColor: [CustomColor] {
        customColors?[TypeOfColor.initial.rawValue] ?? []
    }
    
    /*
     case wind
     case temperature = "temp"
     case cloud
     case precipitation = "precip"
     case precip1
     case pressure = "press"
     case rh
     case wpower
     case tide
     case initial = "init"

     */
}
