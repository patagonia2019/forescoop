//
//  GeoRegion.swift
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
 *  "2": "Africa",
 */

public class GeoRegion: Object, Mappable {

    var id: String? = nil
    var name: String? = nil

    required public convenience init(map: [String:Any]) {
        self.init()
        mapping(map: map)
    }
    
    public func mapping(map: [String:Any]) {
        id = map["id"] as? String ?? nil
        name = map["name"] as? String ?? nil
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
