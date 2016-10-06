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
    public var identity: String?
    public var name: String?
    public var country: String?
    
    required public init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        identity <- map["id_spot"]
        name <- map["spotname"]
        country <- map["country"]
    }
}