//
//  Spot.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/7/15.
//  Copyright © 2015 Fuchs. All rights reserved.
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

    var id_spot: String? = nil
    var spotname: String? = nil
    var country: String? = nil
    
    
    required public convenience init?(map: Map) {
        self.init()
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        id_spot = map["id_spot"] as? String ?? nil
        spotname = map["spotname"] as? String ?? nil
        country = map["country"] as? String ?? nil
    }

    public var description : String {
        var aux : String = "\(type(of:self)): "
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

extension Spot {
    public func id() -> String? {
        return id_spot
    }
    
    public func name() -> String? {
        return spotname
    }
}
