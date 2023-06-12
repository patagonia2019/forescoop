//
//  Spot.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/7/15.
//  Copyright © 2023 Fuchs. All rights reserved.
//

import Foundation

/*
 *  Spot
 *
 *  Discussion:
 *    Model object representing the base class of SpotOwner, SpotForecast.
 *    Is a repeated structure and is easy to integrate using inheritance.
 *
 * {
 *   "id_spot": "64141",
 *   "spotname": "Bariloche",
 *   "country": "Argentina",
 * }
 */


public class Spot: Object, Mappable {

    var id_spot: String?
    var spotname: String?
    var country: String?
    var nickname: String?

    required public convenience init?(map: [String: Any]?) throws {
        self.init()
        try mapping(map: map)
    }
    
    public func mapping(map: [String:Any]?) throws {
        guard let map = map else { throw CustomError.notMappeable }
        guard map.keys.contains("id_spot"), map.keys.contains("spotname"), map.keys.contains("country") else {
            throw CustomError.notMappeable
        }
        id_spot = map["id_spot"] as? String
        spotname = map["spotname"] as? String
        country = map["country"] as? String
        nickname = map["nickname"] as? String
    }
    
    public var description : String {
        [
            "Spot",
            id_spot,
            spotname,
            country,
            nickname
        ]
            .compactMap {$0}
            .joined(separator: ", ")
    }
}

public extension Spot {
    var identifier: String? {
        id_spot
    }
    
    var name: String? {
        spotname
    }
    
    var countryName: String? {
        country
    }
    
    var nickName: String? {
        nickname
    }
}
