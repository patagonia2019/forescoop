//
//  SpotFavoriteContainer.swift
//  Pods
//
//  Created by javierfuchs on 7/12/17.
//
//

import Foundation
import ObjectMapper

/*
 *  SpotFavoriteContainer
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


public class SpotFavoriteContainer: Mappable {
    //
    // count: number of results obtained
    //
    public var count: Int?
    
    //
    // spots: is an array of SpotFavorite objects
    //
    public var spots: [SpotFavorite]?
    
    required public init?(map: Map){
        
    }
    
    public func mapping(map: Map) {
        count <- map["count"]
        spots <- map["spots"]
    }
    
    public var description : String {
        var aux : String = ""
        if let count = count {
            aux += "\(count) spots\n"
        }
        if let spots = spots {
            for spot in spots {
                aux += "\(spot.description)\n"
            }
        }
        return aux
    }

}
