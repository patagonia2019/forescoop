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
 *  SetResult
 *
 *  Discussion:
 *    Model object representing the result of c_sets
 *
 * {
 *   "count": 1,
 *   "sets": {
 *      "229823": "My forecast"
 *    }
 *  }
 */


public class SetResult: Mappable {
    //
    // count: number of results obtained
    //
    public var count: Int?
    
    //
    // spots: is a dictionary forecast id/ forecast name
    //
    public var sets: [String: String]?
    
    required public init?(map: Map){
        
    }
    
    public func mapping(map: Map) {
        count <- map["count"]
        sets <- map["sets"]
    }
    
    public var description : String {
        var aux : String = ""
        if let count = count {
            aux += "\(count) sets, "
        }
        if let sets = sets {
            for forecast in sets {
                aux += "\(forecast)\n"
            }
        }
        return aux
    }

}
