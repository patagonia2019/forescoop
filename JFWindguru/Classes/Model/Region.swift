//
//  Region.swift
//  Pods
//
//  Created by javierfuchs on 7/16/17.
//
//

import Foundation

/*
 *  Region
 *
 *  Discussion:
 *    Model object representing the base class of Region.
 *
 * "223": "Paraná",
 */

public class Region: Object, Mappable {

    var id: String? = nil
    var name: String? = nil
    
    required public convenience init(map: Map) {
        self.init()
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        id = map["id"] as? String ?? nil
        name = map["name"] as? String  ?? nil
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


