//
//  Spot.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/7/15.
//  Copyright © 2015 Fuchs. All rights reserved.
//

import Foundation
#if USE_EXT_FWK
    import ObjectMapper
    import RealmSwift
#endif

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

    dynamic var id_spot: String? = nil
    dynamic var spotname: String? = nil
    dynamic var country: String? = nil
    
#if USE_EXT_FWK

    required public convenience init(map: Map) {
        self.init()
    }
    
    public func mapping(map: Map) {
        id_spot <- map["id_spot"]
        spotname <- map["spotname"]
        country <- map["country"]
    }

#else
    
    public required init(dictionary: [String: Any?]) {
        super.init()
        id_spot = dictionary["id_spot"] as? String ?? nil
        spotname = dictionary["spotname"] as? String ?? nil
        country = dictionary["country"] as? String ?? nil
    }

#endif

    override public var description : String {
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
}
