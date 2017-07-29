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
    import Realm
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

public class SpotOwner: Spot {

    dynamic var id_user: String? = nil

#if USE_EXT_FWK
    public required init(map: Map) {
        super.init()
    }
    
    required public init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    required public init() {
        super.init()
    }
    
    required public init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
    
    override public func mapping(map: Map) {
        super.mapping(map: map)
        id_user <- map["id_user"]
    }

#else

    public required init(dictionary: [String: Any?]) {
        super.init(dictionary: dictionary)
        id_user = dictionary["id_user"] as? String ?? nil
   }

#endif

    override public var description : String {
        var aux : String = super.description
        aux += "\(type(of:self)): "
        if let id_user = id_user {
            aux += "\nuser id \(id_user).\n"
        }
        return aux
    }
    
}
