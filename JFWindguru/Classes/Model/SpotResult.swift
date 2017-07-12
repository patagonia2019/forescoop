//
//  SpotResult.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/7/15.
//  Copyright © 2015 Fuchs. All rights reserved.
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
 *  "count": 426,
 *  "spots": [
 *   {
 *    ...
 *   },
 *  ]
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
    
    var description : String {
        var aux : String = "["
        aux += "\(String(describing: count));"
        aux += "\(String(describing: spots));"
        aux += "]"
        return aux
    }
}
