//
//  Region.swift
//  Pods
//
//  Created by javierfuchs on 7/16/17.
//
//

import Foundation
//
//  GeoRegion.swift
//  Pods
//
//  Created by javierfuchs on 7/16/17.
//
//

import Foundation
import ObjectMapper

/*
 *  GeoRegion
 *
 *  Discussion:
 *    Model object representing the base class of Region.
 *
 * "223": "Paraná",
 */

public class Region: Mappable {
    
    public var id: String?
    public var name: String?
    
    required public init?(map: Map){
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
    
    public var description : String {
        var aux : String = ""
        
        if let id = id {
            aux += "id: \(id), "
        }
        if let name = name {
            aux += "name: \(name)"
        }
        return aux
    }
    
}


