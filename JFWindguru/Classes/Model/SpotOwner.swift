//
//  SpotOwner.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/7/15.
//  Copyright © 2015 Fuchs. All rights reserved.
//

import Foundation
import ObjectMapper

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
    public var id_user: Int?
    
    required public init?(map: Map) {
        super.init(map: map)
    }
    
    override public func mapping(map: Map) {
        super.mapping(map: map)
        id_user <- map["id_user"]
    }
    
    override public var description : String {
        var aux : String = super.description
        if let id_user = id_user {
            aux += "\nuser ud \(id_user).\n"
        }
        return aux
    }
    

}
