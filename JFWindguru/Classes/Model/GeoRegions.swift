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
    
    public var regions = [GeoRegion]()
 
    required public init?(map: Map){
    }
    
    public func mapping(map: Map) {
        for json in map.JSON {
            let jsonKV = ["id": json.key, "name": json.value]
            if let georegion = Mapper<GeoRegion>().map(JSON: jsonKV) {
                regions.append(georegion)
            }
        }
    }
    public var description : String {
        var aux : String = ""
        for region in regions {
            aux += "\(region.description)\n"
        }
        aux += "\n"
        return aux
    }
    
}


