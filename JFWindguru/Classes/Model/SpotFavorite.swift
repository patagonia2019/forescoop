//
//  SpotFavorite.swift
//  Pods
//
//  Created by javierfuchs on 7/12/17.
//
//

import Foundation
import ObjectMapper

/*
 *  SpotFavorite
 *
 *  Discussion:
 *    Model object representing the result of a forecast favorite of the user.
 *
 * {
 *   "count": 1,
 *   "spots": [
 *       {
 *           "id_spot": "48769",
 *           "spotname": "Bolonia",
 *           "country": "Spain",
 *           "id_user": "169"
 *       }
 *   ]
 * }
 */


public class SpotFavorite: Mappable {
    //
    // count: number of results obtained
    //
    public var count: Int?
    
    //
    // spots: is an array of SpotOwner objects
    //
    public var spots: [SpotOwner]?
    
    required public init?(map: Map){
        
    }
    
    public func mapping(map: Map) {
        count <- map["count"]
        spots <- map["spots"]
    }
    
    public var description : String {
        var aux : String = ""
        if let count = count {
            aux += "\(count) spots.\n"
        }
        if let spots = spots {
            for spot in spots {
                aux += "\(spot)"
            }
        }
        return aux
    }

}
