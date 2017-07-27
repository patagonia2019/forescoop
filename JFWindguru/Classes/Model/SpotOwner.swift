//
//  SpotOwner.swift
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
 *  SpotOwner
 *
 *  Discussion:
 *    Represents a model information of the stot.
 *    By inheritance the common attributes are parsed and filled in Spot.
 *    It adds 2 more properties, nick name and id of the user that controls the weather station.
 *    Probably information not useful now, but in terms of having all the data.
 *
 *     {
 *      "id_spot": "48769",
 *      "spotname": "Bolonia",
 *      "country": "Spain",
 *      "id_user": "169"
 *     }
 * 
 *        
 *
 */

#if USE_EXT_FWK
    public class SpotOwner: SpotOwnerObject, Mappable {
    
        required convenience public init?(map: Map) {
            self.init()
        }
    
        public func mapping(map: Map) {
            id_user <- map["id_user"]
            id_spot <- map["id_spot"]
            spotname <- map["spotname"]
            country <- map["country"]
        }
    
    }

#else

    public class SpotOwner: SpotOwnerObject {
        init(dictionary: [String: AnyObject?]) {
            super.init(dictionary: dictionary)
            id_user = dictionary["id_user"] ?? nil
       }
    }
#endif

public class SpotOwnerObject: SpotObject {

    public dynamic var id_user: String? = nil

    override public var description : String {
        var aux : String = super.description
        aux += "\(type(of:self)): "
        if let id_user = id_user {
            aux += "\nuser id \(id_user).\n"
        }
        return aux
    }
    
}
