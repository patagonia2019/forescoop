//
//  SetInfo.swift
//  Pods
//
//  Created by javierfuchs on 7/27/17.
//
//

import Foundation

/*
 *  GeoRegion
 *
 *  Discussion:
 *    Model object representing the base class of Region.
 *
 * "229823": "My forecast",
 */

public class SetInfo: Object, Mappable {
    
    var id: String? = nil
    var name: String? = nil

    required public convenience init(map: [String:Any]) {
        self.init()
        mapping(map: map)
    }
    
    public func mapping(map: [String:Any]) {
        id = map["id"] as? String
        name = map["name"] as? String
    }

    public var description : String {
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


