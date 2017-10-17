//
//  Country.swift
//  Pods
//
//  Created by javierfuchs on 7/16/17.
//
//

import Foundation

/*
 *  GeoRegion
 *
 *  Discussion:
 *    Model object representing the base class of GeoRegion.
 *
 * "32": "Argentina"
 */

public class Country: Object, Mappable {
    
    var id: String? = nil
    var name: String? = nil
    
    
    required public convenience init(map: Map) {
        self.init()
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
            id = map["id"] as? String
            name = map["name"] as? String
    }
    
    override public var description : String {
        var aux : String = "\(type(of:self)): "
        
        if let id = id {
            aux += "id: \(id), "
        }
        if let name = name {
            aux += "name: \(name)"
        }
        return aux
    }
    

}

