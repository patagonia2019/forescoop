//
//  GeoRegions.swift
//  Pods
//
//  Created by javierfuchs on 7/14/17.
//
//

import Foundation
import ObjectMapper

/*
 *  GeoRegion
 *
 *  Discussion:
 *    Model object representing the base class of GeoRegion.
 *
 * {
 *  "2": "Africa",
 *  "5": "South America",
 *  "9": "Oceania",
 *  "13": "Central America",
 *  "21": "Northern America",
 *  "29": "Caribbean",
 *  "53": "Australia and New Zealand",
 *  "142": "Asia",
 *  "150": "Europe"
 * }
 */

public class GeoRegions: Mappable {
    
    public var value: Dictionary<String, String>
    
    required public init?(map: Map){
        value = [:]
    }
    
    public func mapping(map: Map) {
        for key in map.JSON.keys {
            var tmpValue : String?
            tmpValue <- map[key]
            value[key] = tmpValue
        }
    }
    
    public var description : String {
        var aux : String = ""
        let sortedValue = value.sorted { (v0, v1) -> Bool in
            guard let iv0 = Int(v0.key),
                let iv1 = Int(v1.key) else {
                    return false
            }
            return iv0 < iv1
        }
        for (k,v) in sortedValue {
            aux += "\(k):\(v); "
        }
        aux += "\n"
        return aux
    }
    
}


