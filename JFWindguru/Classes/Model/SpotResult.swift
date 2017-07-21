//
//  SpotResult.swift
//  Pods
//
//  Created by javierfuchs on 7/17/17.
//
//

import Foundation
import ObjectMapper

/*
 *  SpotResult
 *
 *  Discussion:
 *    Model object representing the result of a forecast query of locations/spots.
 *
 * {
 *   "count": 2,
 *   "spots": [
 *       {
 *            "id_spot": "64141",
 *            "spotname": "Bariloche",
 *            "country": "Argentina",
 *            "id_user": "169"
 *        },
 *        {
 *            "id_spot": "209155",
 *            "spotname": "Bariloche Classic",
 *            "country": "Argentina",
 *            "id_user": "169"
 *        },
 *    ]
 * }
 */


public class SpotResult: Mappable {
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
            aux += "\(count) spots, "
        }
        if let spots = spots {
            for spot in spots {
                aux += "\(spot.description)\n"
            }
        }
        return aux
    }
    
}
