//
//  Regions.swift
//  Pods
//
//  Created by javierfuchs on 7/16/17.
//
//

import Foundation
import ObjectMapper

/*
 *  Regions
 *
 *  Discussion:
 *    Model object representing all the regions.
 *
 * {
 * "209": "Alagoas",
 * "212": "Bahia",
 * "213": "Ceará",
 * "222": "Paraíba",
 * "223": "Paraná",
 * "224": "Pernambuco",
 * "225": "Piauí",
 * "226": "Rio de Janeiro",
 * "227": "Rio Grande do Norte",
 * "228": "Rio Grande do Sul",
 * "231": "Santa Catarina",
 * "232": "São Paulo"
 * }
 */

public class Regions: Mappable {
    
    public var regions = [Region]()
    
    required public init?(map: Map){
    }
    
    public func mapping(map: Map) {
        for json in map.JSON {
            let jsonKV = ["id": json.key, "name": json.value]
            if let georegion = Mapper<Region>().map(JSON: jsonKV) {
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


