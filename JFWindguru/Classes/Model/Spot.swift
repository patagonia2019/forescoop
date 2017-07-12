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
 *    Model object representing the base class of SpotOwner, ForecastResult.
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
    
    var description : String {
        var aux : String = "["
        aux += "\(String(describing: id_spot));"
        aux += "\(String(describing: spotname));"
        aux += "\(String(describing: country));"
        aux += "]"
        return aux
    }

}
