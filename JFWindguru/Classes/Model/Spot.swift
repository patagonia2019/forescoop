//
//  Spot.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/7/15.
//  Copyright © 2015 Fuchs. All rights reserved.
//

import Foundation
import ObjectMapper

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

public class Spot: Mappable {
    public var id_spot: String?
    public var spotname: String?
    public var country: String?
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        id_spot <- map["id_spot"]
        spotname <- map["spotname"]
        country <- map["country"]
    }
    
    public var description : String {
        var aux : String = ""
        if let id_spot = id_spot {
            aux += "Spot # \(id_spot), "
        }
        if let spotname = spotname {
            aux += "name \(spotname), "
        }
        if let country = country {
            aux += "country \(country).\n"
        }
        return aux
    }


}
